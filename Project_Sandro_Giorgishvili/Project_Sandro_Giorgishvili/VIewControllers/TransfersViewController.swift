//
//  TransfersViewController.swift
//  Project_Sandro_Giorgishvili
//
//  Created by TBC on 11.09.22.
//

import UIKit

class TransfersViewController: UIViewController {
    
    @IBOutlet weak var transfersTableView: UITableView!
    
    let transfers = ["Internal transfer", "To someone else"]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setUpTableView()
        getExchangeRates()
    }
    
    func setUpTableView() {
        transfersTableView.delegate = self
        transfersTableView.dataSource = self
    }
    
    func getExchangeRates() {
        let defaults = UserDefaults.standard
        
        
    }
}

extension TransfersViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        transfers.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = transfersTableView.dequeueReusableCell(withIdentifier: "TransferCell", for: indexPath) as! TransferCell
        cell.transferNameLbl.text = transfers[indexPath.row]
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        switch transfers[indexPath.row] {
        case "Internal transfer":
            let storyboard = UIStoryboard(name: "InternalTransfersBoard", bundle: nil)
            let transfers = storyboard.instantiateViewController(withIdentifier: "InternalTransfersViewController") as! InternalTransfersViewController
            
            present(transfers, animated: true)
            
        case "To someone else":
            print("Sandro")
//            let storyboard = UIStoryboard(name: "Main", bundle: nil)
//            let initialController = storyboard.instantiateViewController(withIdentifier: "LogInViewController") as! LogInPageVC
//
//            let navigationController = UINavigationController(rootViewController: initialController)
        default:
            print("Error occured")
        }
    }
}
