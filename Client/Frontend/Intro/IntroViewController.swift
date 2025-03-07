// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0

import Foundation
import UIKit
import Shared

class IntroViewController: UIViewController, OnboardingViewControllerProtocol {

    private var viewModel: IntroViewModel
    private let profile: Profile
    private var onboardingCards = [OnboardingCardViewController]()
    var notificationCenter: NotificationProtocol = NotificationCenter.default
    var didFinishFlow: (() -> Void)?

    struct UX {
        static let closeButtonSize: CGFloat = 30
        static let closeButtonPadding: CGFloat = 24
        static let pageControlHeight: CGFloat = 40
        static let pageControlBottomPadding: CGFloat = 8
    }

    // MARK: - Var related to onboarding
    private lazy var closeButton: UIButton = .build { button in
        button.setImage(UIImage(named: ImageIdentifiers.bottomSheetClose), for: .normal)
        button.addTarget(self, action: #selector(self.closeOnboarding), for: .touchUpInside)
        button.accessibilityIdentifier = AccessibilityIdentifiers.Onboarding.closeButton
    }

    private lazy var pageController: UIPageViewController = {
        let pageVC = UIPageViewController(transitionStyle: .scroll, navigationOrientation: .horizontal)
        pageVC.dataSource = self
        pageVC.delegate = self
        return pageVC
    }()

    private lazy var pageControl: UIPageControl = .build { pageControl in
        pageControl.currentPage = 0
        pageControl.numberOfPages = self.viewModel.enabledCards.count
        pageControl.currentPageIndicatorTintColor = UIColor.Photon.Blue50
        pageControl.pageIndicatorTintColor = UIColor.Photon.LightGrey40
        pageControl.isUserInteractionEnabled = false
        pageControl.accessibilityIdentifier = AccessibilityIdentifiers.Onboarding.pageControl
    }

    // MARK: Initializer
    init(viewModel: IntroViewModel, profile: Profile) {
        self.viewModel = viewModel
        self.profile = profile
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    deinit {
        notificationCenter.removeObserver(self)
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        setupPageController()
        setupLayout()
        setupNotifications(forObserver: self,
                                   observing: [.DisplayThemeChanged])
        applyTheme()
    }

    // MARK: View setup
    private func setupPageController() {
        // Create onboarding card views
        var cardViewController: OnboardingCardViewController
        for cardType in viewModel.enabledCards {
            if let viewModel = viewModel.getCardViewModel(cardType: cardType) {
                if cardType == .wallpapers {
                    cardViewController = WallpaperCardViewController(viewModel: viewModel,
                                                                     delegate: self)
                } else {
                    cardViewController = OnboardingCardViewController(viewModel: viewModel,
                                                                      delegate: self)
                }
                onboardingCards.append(cardViewController)
            }
        }

        if let firstViewController = onboardingCards.first {
            pageController.setViewControllers([firstViewController],
                                              direction: .forward,
                                              animated: true,
                                              completion: nil)
        }
    }

    private func setupLayout() {
        addChild(pageController)
        view.addSubview(pageController.view)
        pageController.didMove(toParent: self)
        view.addSubviews(pageControl, closeButton)

        NSLayoutConstraint.activate([
            pageControl.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            pageControl.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor,
                                                constant: -UX.pageControlBottomPadding),
            pageControl.trailingAnchor.constraint(equalTo: view.trailingAnchor),

            closeButton.topAnchor.constraint(equalTo: view.topAnchor, constant: UX.closeButtonPadding),
            closeButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -UX.closeButtonPadding),
            closeButton.widthAnchor.constraint(equalToConstant: UX.closeButtonSize),
            closeButton.heightAnchor.constraint(equalToConstant: UX.closeButtonSize),
        ])
    }

    @objc private func closeOnboarding() {
        didFinishFlow?()
        viewModel.sendCloseButtonTelemetry(index: pageControl.currentPage)
    }

    func getNextOnboardingCard(index: Int, goForward: Bool) -> OnboardingCardViewController? {
        guard let index = viewModel.getNextIndex(currentIndex: index, goForward: goForward) else { return nil }

        return onboardingCards[index]
    }

    // Used to programmatically set the pageViewController to show next card
    func moveToNextPage(cardType: IntroViewModel.InformationCards) {
        if let nextViewController = getNextOnboardingCard(index: cardType.rawValue, goForward: true) {
            pageControl.currentPage = cardType.rawValue + 1
            pageController.setViewControllers([nextViewController], direction: .forward, animated: false)
        }
    }

    // Due to restrictions with PageViewController we need to get the index of the current view controller
    // to calculate the next view controller
    func getCardIndex(viewController: OnboardingCardViewController) -> Int? {
        let cardType = viewController.viewModel.cardType

        guard let index = viewModel.enabledCards.firstIndex(of: cardType) else { return nil }

        return index
    }
}

// MARK: UIPageViewControllerDataSource & UIPageViewControllerDelegate
extension IntroViewController: UIPageViewControllerDataSource, UIPageViewControllerDelegate {
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {

        guard let onboardingVC = viewController as? OnboardingCardViewController,
              let index = getCardIndex(viewController: onboardingVC) else {
              return nil
        }

        pageControl.currentPage = index
        return getNextOnboardingCard(index: index, goForward: false)
    }

    func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {

        guard let onboardingVC = viewController as? OnboardingCardViewController,
              let index = getCardIndex(viewController: onboardingVC) else {
              return nil
        }

        pageControl.currentPage = index
        return getNextOnboardingCard(index: index, goForward: true)

    }
}

extension IntroViewController: OnboardingCardDelegate {
    func showNextPage(_ cardType: IntroViewModel.InformationCards) {
        guard cardType != viewModel.enabledCards.last else {
            self.didFinishFlow?()
            return
        }

        moveToNextPage(cardType: cardType)
    }

    func primaryAction(_ cardType: IntroViewModel.InformationCards) {
        switch cardType {
        case .welcome, .wallpapers:
            moveToNextPage(cardType: cardType)
        case .signSync:
            presentSignToSync()
        default:
            break
        }
    }

    // Extra step to make sure pageControl.currentPage is the right index card
    // because UIPageViewControllerDataSource call fails
    func pageChanged(_ cardType: IntroViewModel.InformationCards) {
        if let cardIndex = viewModel.enabledCards.firstIndex(of: cardType),
           cardIndex != pageControl.currentPage {
            pageControl.currentPage = cardIndex
        }
    }

    private func presentSignToSync(_ fxaOptions: FxALaunchParams? = nil,
                                  flowType: FxAPageType = .emailLoginFlow,
                                  referringPage: ReferringPage = .onboarding) {
        let singInSyncVC = FirefoxAccountSignInViewController.getSignInOrFxASettingsVC(fxaOptions,
                                                                                      flowType: flowType,
                                                                                      referringPage: referringPage,
                                                                                      profile: profile)
        let controller: DismissableNavigationViewController
        let buttonItem = UIBarButtonItem(title: .SettingsSearchDoneButton,
                                         style: .plain,
                                         target: self,
                                         action: #selector(dismissSignInViewController))
        let theme = BuiltinThemeName(rawValue: LegacyThemeManager.instance.current.name) ?? .normal
        buttonItem.tintColor = theme == .dark ? UIColor.theme.homePanel.activityStreamHeaderButton : UIColor.Photon.Blue50
        singInSyncVC.navigationItem.rightBarButtonItem = buttonItem
        controller = DismissableNavigationViewController(rootViewController: singInSyncVC)
        controller.onViewDismissed = {
            self.closeOnboarding()
        }
        self.present(controller, animated: true)
    }

    @objc func dismissSignInViewController() {
        dismiss(animated: true, completion: nil)
        closeOnboarding()
    }
}

// MARK: UIViewController setup
extension IntroViewController {
    override var prefersStatusBarHidden: Bool {
        return true
    }

    override var shouldAutorotate: Bool {
        return false
    }

    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        // This actually does the right thing on iPad where the modally
        // presented version happily rotates with the iPad orientation.
        return .portrait
    }
}

// MARK: - NotificationThemeable and Notifiable
extension IntroViewController: NotificationThemeable, Notifiable {

    func handleNotifications(_ notification: Notification) {
        switch notification.name {
        case .DisplayThemeChanged:
            applyTheme()
        default:
            break
        }
    }

    func applyTheme() {
        let theme = BuiltinThemeName(rawValue: LegacyThemeManager.instance.current.name) ?? .normal

        let indicatorColor = theme == .dark ? UIColor.theme.homePanel.activityStreamHeaderButton : UIColor.Photon.Blue50
        pageControl.currentPageIndicatorTintColor = indicatorColor
        view.backgroundColor = theme == .dark ? UIColor.Photon.DarkGrey40 : .white

        onboardingCards.forEach { cardViewController in
            cardViewController.applyTheme()
        }
    }
}
