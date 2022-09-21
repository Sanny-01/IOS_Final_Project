//
//  HomeViewController.swift
//  Project_Sandro_Giorgishvili
//
//  Created by TBC on 19.09.22.

import UIKit
import SkeletonView

protocol HomeDisplayLogic: AnyObject {
    func displayUserBalance(viewModel: Home.GetUserBalance.ViewModel)
    func displayExchangeRates(viewModel: Home.GetExchangeRates.ViewModel)
    func displayTabBarItemPage(viewModel: Home.TabBarItemTapped.ViewModel)
}

final class HomeViewController: UIViewController {
    // MARK: - Clean Components
    
    var interactor: HomeBusinessLogic?
    var router: (NSObjectProtocol & HomeRoutingLogic & HomeDataPassing)?
    
    // MARK: - Outlets
    
    @IBOutlet private weak var scrollView: UIScrollView!
    
    @IBOutlet private weak var homePageiView: UIView!
    @IBOutlet private weak var transfersPageView: UIView!
    @IBOutlet private weak var profilePageView: UIView!
    
    @IBOutlet private weak var balanceInGelLabel: UILabel!
    @IBOutlet private weak var balanceInUsdLabel: UILabel!
    @IBOutlet private weak var balanceInEurLabel: UILabel!
    
    @IBOutlet private weak var contentView: UIView!
    @IBOutlet private weak var tabBarView: UIView!
    @IBOutlet private weak var balanceView: UIView!
    
    @IBOutlet private weak var homeImageView: UIImageView!
    @IBOutlet private weak var transfersImageView: UIImageView!
    @IBOutlet private weak var profileImageView: UIImageView!
    @IBOutlet private weak var bubbleImageView: UIImageView!
    @IBOutlet private weak var exchangeRatesTableView: UITableView!
    @IBOutlet private weak var spinner: UIActivityIndicatorView!
    
    // MARK: - Fields
    
    let countryFlagNames = ["Flag_of_Europe.svg", "Flag_of_the_United_States.svg", "Flag_of_the_United_Kingdom.svg"]
    let countryCurrency = ["EUR", "USD", "GBP"]
    let countryCurrencyGEO = ["ევრო", "აშშ დოლარი", "გირვანქა სტერლინგი"]
    private var exchangeRate = [Double]()
    @objc let refreshControl = UIRefreshControl()
    
    
    // MARK: - Object lifecycle
    
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
        setup()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setup()
    }
    
    // MARK: Setup
    
    private func setup() {
        let viewController = self
        let interactor = HomeInteractor()
        let presenter = HomePresenter()
        let router = HomeRouter()
        let worker = HomeWorker(apiManager: APIManager())
        viewController.interactor = interactor
        viewController.router = router
        interactor.presenter = presenter
        interactor.worker = worker
        presenter.viewController = viewController
        router.viewController = viewController
        router.dataStore = interactor
    }
    
    // MARK: - View Lifecycle
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setTintColorAndAnimateTapToTabBarItem(tag: 1)
        setUpSpinner()
        startSkeletonAnimation()
        interactor?.getUserBalace(request: Home.GetUserBalance.Request())
        startAnimatingSpinner()
        interactor?.getExchangeRates(request: Home.GetExchangeRates.Request())
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setNavigationBarColor()
        setUpRefreshControl()
        setUpBalanceView()
        setUpTabBar()
        setUpTableView()
        hideKeyboardWhenTappedAround()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        removeChildrenViewControllers()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        removeChildrenViewControllers()
    }
    
    // MARK: - Private Methods

    private func setUpRefreshControl() {
        refreshControl.tintColor = UIColor.cyan
        refreshControl.addTarget(self, action: #selector(refresh), for: UIControl.Event.valueChanged)
        self.scrollView.addSubview(refreshControl)
    }
    
    private func setNavigationBarColor(){
        navigationController?.navigationBar.barTintColor = UIColor.clear
    }
    
    private func setUpBalanceView() {
        balanceView.layer.borderWidth = 2
        balanceView.layer.cornerRadius = 22
        balanceView.layer.borderColor = UIColor.cyan.cgColor
    }
    
    private func setUpTableView() {
        exchangeRatesTableView.delegate = self
        exchangeRatesTableView.dataSource = self
    }
    
    private func setUpTabBar() {
        tabBarView.layer.cornerRadius = tabBarView.frame.size.height / 2
        tabBarView.clipsToBounds = true
    }
    
    private func setTableData(data: ExchangeRates) {
        exchangeRate.append(data.gelToUsd)
        exchangeRate.append(data.gelToEur)
        exchangeRate.append(data.gelToGbp)
    
        spinner.stopAnimating()
        exchangeRatesTableView.reloadData()
    }
    
    private func startSkeletonAnimation() {
        balanceView.showAnimatedGradientSkeleton(usingGradient: .init(baseColor: .wetAsphalt), animation: nil, transition: .crossDissolve(0.25))
    }
    
    private func setUpSpinner() {
        spinner.hidesWhenStopped = true
    }
    
    private func startAnimatingSpinner() {
        spinner.startAnimating()
    }
    
    private func setUpBubbleView() {
        bubbleImageView.center.x = homePageiView.center.x
    }
    
    private func setTintColorAndAnimateTapToTabBarItem(tag: Int) {
        switch tag {
        case 0:
            removeChildrenViewControllers()
            animateTap(for: transfersPageView)
            homeImageView.tintColor = .white
            transfersImageView.tintColor = .midnightBlue
            profileImageView.tintColor = .white
        case 1:
            removeChildrenViewControllers()
            animateTap(for: homePageiView)
            homeImageView.tintColor = .midnightBlue
            transfersImageView.tintColor = .white
            profileImageView.tintColor = .white
        case 2:
            removeChildrenViewControllers()
            animateTap(for: profilePageView)
            homeImageView.tintColor = .white
            transfersImageView.tintColor = .white
            profileImageView.tintColor = .midnightBlue
        default:
            print("Incorrect tag id")
        }
    }
    
    private func animateTap(for item: UIView) {
        UIView.animate(withDuration: 0.2) {
            self.bubbleImageView.transform = .init(scaleX: 2.5, y: 1)
        } completion: { _ in
            UIView.animate(withDuration: 0.2) {
                self.bubbleImageView.transform = .identity
            }
        }
        UIView.animate(withDuration: 0.4) {
            self.bubbleImageView.center.x = item.center.x
        }
    }
    
    private func removeChildrenViewControllers() {
        if self.children.count > 0 {
            let viewControllers:[UIViewController] = self.children
            for viewContoller in viewControllers{
                viewContoller.willMove(toParent: nil)
                viewContoller.view.removeFromSuperview()
                viewContoller.removeFromParent()
            }
        }
    }
    
    private func validateTabBarItemChange(tag: Int) -> Bool {
        if tag == 0 && transfersImageView.tintColor == .midnightBlue {
           return false
        } else if tag == 1 && homeImageView.tintColor == .midnightBlue {
          return false
        } else if tag == 2 && profileImageView.tintColor == .midnightBlue {
           return false
        }
        
        return true
    }
    
    // MARK: - Actions
    
    @IBAction func tabBarTapped(_ sender: UIButton) {
        let tag = sender.tag

        if validateTabBarItemChange(tag: tag) {
            removeChildrenViewControllers()
            interactor?.processTabBarItemTap(request: Home.TabBarItemTapped.Request(tag: tag))
        }
    }
    
    // MARK: Objective C Methods
    
    @objc private func refresh(send: UIRefreshControl) {
        interactor?.getUserBalace(request: Home.GetUserBalance.Request())
        refreshControl.endRefreshing()
    }
}

// MARK: - HomeDisplayLogic

extension HomeViewController: HomeDisplayLogic {
    func displayTabBarItemPage(viewModel: Home.TabBarItemTapped.ViewModel) {
        setTintColorAndAnimateTapToTabBarItem(tag: viewModel.tag)
        
        if viewModel.tag == 0 {
            router?.moveToTransfers(view: contentView, parentViewController: self)
        } else if viewModel.tag == 1 {
            removeChildrenViewControllers()
        } else if viewModel.tag == 2 {
            router?.moveToProfile(view: contentView, parentViewController: self)
        }
    }
    
    func displayExchangeRates(viewModel: Home.GetExchangeRates.ViewModel) {
        setTableData(data: viewModel.exchangeRate)
    }
    
    func displayUserBalance(viewModel: Home.GetUserBalance.ViewModel) {
        balanceInGelLabel.text = "\(round(viewModel.balance.GEL * 100.00 ) / 100.00)"
        balanceInUsdLabel.text = "\(round(viewModel.balance.USD * 100.00 ) / 100.00)"
        balanceInEurLabel.text = "\(round(viewModel.balance.EUR * 100.00 ) / 100.00)"
        
        balanceView.stopSkeletonAnimation()
        balanceView.hideSkeleton()
    }
}

// MARK: - TableViewDelegate and TableViewDataSource

extension HomeViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        exchangeRate.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = exchangeRatesTableView.dequeueReusableCell(withIdentifier: "CurrencyCell", for: indexPath) as! CurrencyCell
        
        cell.countryFlag.image = UIImage(named: countryFlagNames[indexPath.row])
        cell.currencyShortNameLbl.text = countryCurrency[indexPath.row]
        cell.currencyNameInGEOLbl.text = countryCurrencyGEO[indexPath.row]
        cell.currencyAmountLbl.text = "\(round(exchangeRate[indexPath.row] * 100.00) / 100.00)"
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        80
    }
}
