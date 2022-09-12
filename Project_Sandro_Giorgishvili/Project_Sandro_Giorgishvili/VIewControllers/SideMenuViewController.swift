//import UIKit
//import SideMenu
//
//class ProfileViewController: UIViewController {
//    var menu:SideMenuNavigationController?
//    override func viewDidLoad() {
//        super.viewDidLoad()
//        configureSideMenu()
//    }
//
//
//
//    func configureSideMenu() {
//        menu = SideMenuNavigationController(rootViewController: MenuListController())
//        menu?.navigationBar.setBackgroundImage(UIImage(named: "top_navbrBG"), for: .default)
//        let firstFrame = CGRect(x: 20, y: 0, width: menu?.navigationBar.frame.width ?? 0/2, height: menu?.navigationBar.frame.height ?? 0)
//            let firstLabel = UILabel(frame: firstFrame)
//            firstLabel.text = "Settings"
//
//        menu?.navigationBar.addSubview(firstLabel)
//        SideMenuManager.default.addPanGestureToPresent(toView: self.view)
//
//
//
//        let screenSize = UIScreen.main.bounds
//        let screenHeight = screenSize.height + 40
//
//        let leftBorderView = UIView(frame: CGRect(x: 1, y: -40, width: 1, height: screenHeight))
//        leftBorderView.backgroundColor = UIColor.init(hexString: "#cfcfcf")
//        menu?.navigationBar.addSubview(leftBorderView)
//
//
//    }
//
//    @IBAction func menuButtonAction(_ sender: UIButton) {
//        if let menu = menu {
//            present(menu, animated: true)
//        }
//    }
//
//
//}
//
//// functions
//extension ProfileViewController {
//
//    @objc func signOutButtonTapped(_ sender: AnyObject?) {
//        print("sigin out")
//    }
//    func getSignOutButton()->UIButton {
//        let button = UIButton()
//        button.setTitle("Sign out", for: .normal)
//        let color = UIColor.init(hexString: "#1A73E9")
//        button.setTitleColor(color, for: .normal)
//        button.addTarget(self, action: #selector(signOutButtonTapped), for: .touchUpInside)
//        return button
//    }
//
//    func setConstraintsForSignOutButton(button: UIButton) {
//        let screenSize = UIScreen.main.bounds
//        let screenHeight = screenSize.height
//        guard let menuTopAnchor = menu?.navigationBar.topAnchor else { return  }
//        guard let menuLeadingAnchor = menu?.navigationBar.leadingAnchor else { return  }
//        guard let menuTrailingAnchor = menu?.navigationBar.trailingAnchor else { return  }
//
//
//        guard let menuWidth = menu?.menuWidth else { return  }
//        button.translatesAutoresizingMaskIntoConstraints = false
//        NSLayoutConstraint.activate([
//            button.leadingAnchor.constraint(equalTo: menuLeadingAnchor, constant: 0),
//            button.trailingAnchor.constraint(equalTo: menuTrailingAnchor, constant: 0),
//            button.widthAnchor.constraint(equalToConstant: menuWidth),
//            button.heightAnchor.constraint(equalToConstant: 40),
//            button.bottomAnchor.constraint(equalTo: menuTopAnchor, constant: 300)
//        ])
//
//    }
//}
//
//
//
//// Menu Items
//class MenuListController: UITableViewController {
//    var menuItems = [[String: String]]()
//
//    override func viewDidLoad() {
//        super.viewDidLoad()
//        menuItems.append(["name": "Privacy", "img": "privacy", "key" : "privacy"])
//        menuItems.append(["name": "Report issue", "img": "report_issue", "key": "report_issue"])
//        tableView.dataSource = self
//        tableView.delegate = self
//        tableView.separatorStyle = .none
//        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
//
//
//        tableView.tableFooterView = getSignOutButton()
//
//    }
//
//
//    @objc func signOutButtonTapped(_ sender: AnyObject?) {
//        print("sigin out")
//    }
//    func getSignOutButton()->UIButton {
//        let button = UIButton()
//        button.height = 20
//        button.width = 100
//        button.setTitle("Sign out", for: .normal)
//        let color = UIColor.init(hexString: "#1A73E9")
//        button.setTitleColor(color, for: .normal)
//        button.addTarget(self, action: #selector(signOutButtonTapped), for: .touchUpInside)
//        return button
//    }
//
//    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
//        menuItems.count
//    }
//
//    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
//        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
//        if menuItems.indices.contains(indexPath.row) {
//            let dict = menuItems[indexPath.row]
//            cell.textLabel?.text = dict["name"]
//            if let img = dict["img"] {
//                cell.imageView?.image = UIImage(named: img)
//            }
//
//        }
//        return cell
//    }
//
//
//}
