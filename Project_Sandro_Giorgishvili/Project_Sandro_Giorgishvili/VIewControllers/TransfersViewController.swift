//
//  TransfersViewController.swift
//  Project_Sandro_Giorgishvili
//
//  Created by TBC on 11.09.22.
//

import UIKit

class TransfersViewController: UIViewController {
    // MARK: - Outlets

    @IBOutlet private weak var transfersTableView: UITableView!
    
    // MARK: - Fields
    
    let transfers = ["Internal transfer", "To someone else"]
    
    // MARK: - View Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setUpTableView()
    }
    
    func setUpTableView() {
        transfersTableView.delegate = self
        transfersTableView.dataSource = self
    }
}

//MARK: - UITableViewDataSource

extension TransfersViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        transfers.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = transfersTableView.dequeueReusableCell(withIdentifier: Constants.CellNames.transferCell, for: indexPath) as! TransferCell
        cell.transferNameLbl.text = transfers[indexPath.row]
        
        return cell
    }
}

//MARK: - UITableViewDelegate

extension TransfersViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        transfersTableView.deselectRow(at: indexPath, animated: true)
        
        switch transfers[indexPath.row] {
        case "Internal transfer":
            let internalTransfersStoryboard = UIStoryboard(name: Constants.StoryBoards.internalTransfers, bundle: nil)
            guard let internalTransfersViewController = internalTransfersStoryboard.instantiateViewController(withIdentifier: Constants.StoryboardIds.internalTransfersViewController) as? InternalTransfersViewController else { return }

            present(internalTransfersViewController, animated: true)
        case "To someone else":
            let transfersToSomeoneStoryboard = UIStoryboard(name: Constants.StoryBoards.transferToSomeone, bundle: nil)
            guard let transferToSomeoneViewController = transfersToSomeoneStoryboard.instantiateViewController(withIdentifier: Constants.StoryboardIds.transferToSomeoneViewController) as? TransferToSomeoneViewController else { return }

            present(transferToSomeoneViewController, animated: true)
        default:
           return
        }
    }
}
