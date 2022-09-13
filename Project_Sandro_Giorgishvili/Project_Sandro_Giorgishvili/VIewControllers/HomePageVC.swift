//
//  HomePageVC.swift
//  Project_Sandro_Giorgishvili
//
//  Created by TBC on 01.08.22.
//

import UIKit
import FirebaseAuth
import FirebaseFirestore
import SkeletonView

class HomePageVC: UIViewController {
    
    var countryFlagNames = ["Flag_of_Europe.svg", "Flag_of_the_United_States.svg", "Flag_of_the_United_Kingdom.svg"]
    var countryCurrency = ["EUR", "USD", "GBP"]
    var countryCurrencyGEO = ["ევრო", "აშშ დოლარი", "გირვანქა სტერლინგი"]
    var exchangeRate = [Double]()
    
    let defaults = UserDefaults.standard
    
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    
    @IBOutlet private weak var homePageiView: UIView!
    @IBOutlet private weak var transfersPageView: UIView!
    @IBOutlet private weak var profilePageView: UIView!
    
    @IBOutlet private weak var totalBalanceLbl: UILabel!
    @IBOutlet private weak var balanceInUSDLbl: UILabel!
    @IBOutlet private weak var balanceInEURLbl: UILabel!
    
    @IBOutlet private weak var contentView: UIView!
    @IBOutlet private weak var tabBarView: UIView!
    @IBOutlet private weak var balanceView: UIView!
    
    @IBOutlet private weak var homePageImage: UIImageView!
    @IBOutlet private weak var transfersPageImage: UIImageView!
    @IBOutlet private weak var profilePageImage: UIImageView!
    @IBOutlet private weak var bubbleImageView: UIImageView!
    @IBOutlet private weak var currencyTableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setUpTabBar()
        getandSetUserData()
        setUpTableView()
        getExchangeRates()
        self.hideKeyboardWhenTappedAround()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        currencyTableView.isSkeletonable = true
        balanceView.isSkeletonable = true
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: animated)
        deleteChildrenViewControllersAndSetTintColor(tag: 1)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        removeChildrenViewControllers()
        //deleteChildrenViewControllersAndSetTintColor(tag: 0)
    }
    
    func setUpTableView() {
        currencyTableView.delegate = self
        currencyTableView.dataSource = self
    }
    
    func setUpTabBar() {
        tabBarView.layer.cornerRadius = tabBarView.frame.size.height / 2
        tabBarView.clipsToBounds = true
    }
    
    func getandSetUserData() {
        balanceView.showAnimatedGradientSkeleton(usingGradient: .init(baseColor: .wetAsphalt), animation: nil, transition: .crossDissolve(0.25))
        
        self.totalBalanceLbl.text = defaults.string(forKey: userDefaultKeyNames.GEL.rawValue)
        self.balanceInUSDLbl.text = defaults.string(forKey: userDefaultKeyNames.USD.rawValue)
        self.balanceInEURLbl.text = defaults.string(forKey: userDefaultKeyNames.EUR.rawValue)
        
        self.balanceView.stopSkeletonAnimation()
        self.balanceView.hideSkeleton()
    }
    
    
    func getExchangeRates() {
        currencyTableView.showAnimatedGradientSkeleton(usingGradient: .init(baseColor: .wetAsphalt), animation: nil, transition: .crossDissolve(0.25))
        
        do {
            let fetchedExchangeRates = try context.fetch(ExchangeRates.fetchRequest())
            
            guard let firstValueOfExchangeRates = fetchedExchangeRates.first else { return }
            
            exchangeRate.append(firstValueOfExchangeRates.gelToUsd)
            exchangeRate.append(firstValueOfExchangeRates.gelToEur)
            exchangeRate.append(firstValueOfExchangeRates.gelToGbp)
        } catch {
            print("Could not load data")
        }
        
        currencyTableView.reloadData()
        
        self.currencyTableView.stopSkeletonAnimation()
        self.currencyTableView.hideSkeleton()
    }
    
    func setUpBubbleView() {
        bubbleImageView.center.x = homePageiView.center.x
    }
    
    @IBAction func tabBarTapped(_ sender: UIButton) {
        let tag = sender.tag
        
        print(tag)
        if tag == 0 && transfersPageImage.tintColor != .midnightBlue {
            deleteChildrenViewControllersAndSetTintColor(tag: 0)
            
            let storyboard = UIStoryboard(name: "TransfersBoard", bundle: nil)
            guard let Currency = storyboard.instantiateViewController(withIdentifier: "TransfersViewController") as? TransfersViewController else { return }
            contentView.addSubview(Currency.view)
            self.addChild(Currency)
            Currency.didMove(toParent: self)
        } else if tag == 1 && homePageImage.tintColor != .midnightBlue {
            deleteChildrenViewControllersAndSetTintColor(tag: 1)
            
            let storyboard = UIStoryboard(name: "HomePageBoard", bundle: nil)
            guard let Home = storyboard.instantiateViewController(withIdentifier: "home_page_vc") as? HomePageVC else { return }
            contentView.addSubview(Home.view)
            self.addChild(Home)
            Home.didMove(toParent: self)
            
        }else if tag == 2 && profilePageImage.tintColor != .midnightBlue {
            deleteChildrenViewControllersAndSetTintColor(tag: 2)
            
            let storyboard = UIStoryboard(name: "ProfilePageBoard", bundle: nil)
            guard let PasswordChange = storyboard.instantiateViewController(withIdentifier: "ProfileViewController") as? ProfileVC else { return }
            contentView.addSubview(PasswordChange.view)
            self.addChild(PasswordChange)
            PasswordChange.didMove(toParent: self)
        }
    }
    @IBAction func touch(_ sender: Any) {
        print("TOUCHED")
    }
    
    func removeChildrenViewControllers() {
        if self.children.count > 0 {
            let viewControllers:[UIViewController] = self.children
            for viewContoller in viewControllers{
                viewContoller.willMove(toParent: nil)
                viewContoller.view.removeFromSuperview()
                viewContoller.removeFromParent()
            }
        }
    }
    
    func deleteChildrenViewControllersAndSetTintColor(tag: Int) {
        switch tag {
        case 0:
            removeChildrenViewControllers()
            animateTap(for: transfersPageView)
            homePageImage.tintColor = .white
            transfersPageImage.tintColor = .midnightBlue
            profilePageImage.tintColor = .white
        case 1:
            removeChildrenViewControllers()
            animateTap(for: homePageiView)
            homePageImage.tintColor = .midnightBlue
            transfersPageImage.tintColor = .white
            profilePageImage.tintColor = .white
        case 2:
            removeChildrenViewControllers()
            animateTap(for: profilePageView)
            homePageImage.tintColor = .white
            transfersPageImage.tintColor = .white
            profilePageImage.tintColor = .midnightBlue
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
    
    deinit {
        print("HOME Page was deinitilized!!!!!!!!!!!!!!!!!!!!!!")
    }
}

extension UIViewController{
    
    func pushToViewController(identifier: String) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let logInVc = storyboard.instantiateViewController(withIdentifier: identifier)
        self.navigationController?.pushViewController(logInVc, animated: false)
    }
}

extension HomePageVC: UITableViewDelegate, UITableViewDataSource, SkeletonTableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        exchangeRate.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = currencyTableView.dequeueReusableCell(withIdentifier: "CurrencyCell", for: indexPath) as! CurrencyCell
        
        cell.countryFlag.image = UIImage(named: countryFlagNames[indexPath.row])
        cell.currencyShortNameLbl.text = countryCurrency[indexPath.row]
        cell.currencyNameInGEOLbl.text = countryCurrencyGEO[indexPath.row]
        cell.currencyAmountLbl.text = "\(round(exchangeRate[indexPath.row] * 100) / 100)"
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        80
    }
    
    func collectionSkeletonView(_ skeletonView: UITableView, cellIdentifierForRowAt indexPath: IndexPath) -> ReusableCellIdentifier {
        "CurrencyCell"
    }
}
