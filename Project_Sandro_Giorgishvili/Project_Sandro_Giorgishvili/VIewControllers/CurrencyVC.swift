//
//  CurrencyVC.swift
//  Project_Sandro_Giorgishvili
//
//  Created by TBC on 04.09.22.
//

import UIKit

class CurrencyVC: UIViewController {
    
    var networService = NetworkService.shared
    
    @IBOutlet weak var currencyTableView: UITableView!
    
    var countryFlagNames = ["Flag_of_Europe.svg", "Flag_of_the_United_States.svg", "Flag_of_the_United_Kingdom.svg"]
    var countryCurrency = ["EUR", "USD", "GBP"]
    var countryCurrencyGEO = ["ევრო", "აშშ დოლარი", "გირვანქა სტერლინგი"]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setUpTableView()
    }
    
    func setUpTableView() {
        currencyTableView.delegate = self
        currencyTableView.dataSource = self
    }
}

extension CurrencyVC: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        countryFlagNames.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = currencyTableView.dequeueReusableCell(withIdentifier: "CurrencyCell", for: indexPath) as! CurrencyCell
        
        cell.countryFlag.image = UIImage(named: countryFlagNames[indexPath.row])
        cell.currencyShortNameLbl.text = countryCurrency[indexPath.row]
        cell.currencyNameInGEOLbl.text = countryCurrencyGEO[indexPath.row]
        
//        networService.convertCurrency(to: "GEL", from: countryCurrency[indexPath.row], amount: 1.00) { [weak self] (amount: CurrencyAmount?, error) in
//
//            DispatchQueue.main.async {
//                if error != nil {
//                    cell.currencyAmountLbl.text = "0.0000"
//                } else {
//                    guard let amount = amount?.result else { return }
//                    cell.currencyAmountLbl.text = "\(round(10000 * amount) / 10000)"
//                }
//            }
//        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        80
    }
}
