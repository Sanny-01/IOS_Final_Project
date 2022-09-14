//
//  TransfersViewController.swift
//  Project_Sandro_Giorgishvili
//
//  Created by TBC on 11.09.22.
//

import UIKit

class TransfersViewController: UIViewController {
    
    @IBOutlet private weak var transfersTableView: UITableView!
    
    let transfers = ["Internal transfer", "To someone else"]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setUpTableView()
    }
    
    func setUpTableView() {
        transfersTableView.delegate = self
        transfersTableView.dataSource = self
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
            let storyboard = UIStoryboard(name: "InternalTransfers", bundle: nil)
            let internalTransfersViewController = storyboard.instantiateViewController(withIdentifier: "InternalTransfersViewController") as! InternalTransfersViewController

            present(internalTransfersViewController, animated: true)
        case "To someone else":
            print("Sandro")
            let storyboard = UIStoryboard(name: "TransferToSomeone", bundle: nil)
            let transferToSomeoneViewController = storyboard.instantiateViewController(withIdentifier: "TransferToSomeoneViewController") as! TransferToSomeoneViewController

            present(transferToSomeoneViewController, animated: true)
        default:
            print("Error occured")
        }
    }
}
