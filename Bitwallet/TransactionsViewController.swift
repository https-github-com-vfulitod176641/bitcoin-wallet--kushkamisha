//
//  TransactionsViewController.swift
//  Bitwallet
//
//  Created by Kushka Misha on 5/9/19.
//  Copyright © 2019 Misha Kushka. All rights reserved.
//

import UIKit
import Alamofire
import Firebase
import FirebaseAuth

class Transaction: UITableViewCell {
    
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var address: UILabel!
    @IBOutlet weak var btcAmount: UILabel!
    @IBOutlet weak var usdAmount: UILabel!
    @IBOutlet weak var transactionDirection: UIImageView!

}

class TransactionsViewController: UIViewController, UITableViewDataSource {

    @IBOutlet weak var tableView: UITableView!
    
    var times : Array<String> = []
    var addresses : Array<String> = []
    var btcAmounts : Array<NSNumber> = []
    var usdAmounts : Array<NSNumber> = []
    var transactionDirections : Array<String> = []
    
    private let userId = Auth.auth().currentUser?.uid
    private let apiKey = "b4tXEhQaUmYyAUBMf0SMSoFzcVkXZ64JnCprKWc8iZyv8KiX8kNuQsoB"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Firebase custom event
        Analytics.logEvent("visit_screen", parameters: [
            "name": "Transaction's Screen" as NSObject,
            "full_text": "A user have visited the Transaction's screen" as NSObject
            ])
        
        self.tableView.register(UINib(nibName: "TransactionsCell", bundle: nil), forCellReuseIdentifier: "transaction")
        
        // Load user's balance
        getUserTransactions()
    }
    
    func getUserTransactions() {
        var headers = HTTPHeaders.default
        headers["x-api-key"] = apiKey
        headers["user-id"] = userId
        
        AF.request("http://127.0.0.1:8364/wallet/getTransactions", headers: headers).responseJSON { response in
            switch response.result {
            case .success(let data):
                let dict = data as! NSDictionary
                let status = dict["status"] as! String

                if (status == "success") {
                    // Show all transactions
                    let txs = dict["txs"] as! NSArray
                    for tx in (txs as! [NSDictionary]) {
                        self.times.append(String(tx["time"]! as! Int64))
                        self.btcAmounts.append(tx["amount"]! as? NSNumber ?? 0)
                        self.usdAmounts.append(tx["amount"]! as? NSNumber ?? 0)
                        self.transactionDirections.append(tx["category"]! as! String == "receive" ? "in" : "out")
                        self.addresses.append(tx["address"]! as! String)
                    }
                    
                    self.tableView.reloadData()
                    
                } else {
                    let alert = UIAlertController(title: "Oops", message: "Something went wrong. Try again.", preferredStyle: .alert)
                    self.present(alert, animated: true)
                    alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                }
            case .failure(let error):
                print(error.localizedDescription)
            }
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return times.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell: Transaction = self.tableView.dequeueReusableCell(withIdentifier: "transaction") as! Transaction
        
        cell.timeLabel.text = times[indexPath.row]
        cell.address.text = addresses[indexPath.row]
        cell.btcAmount.text = "\(btcAmounts[indexPath.row]) BTC"
        cell.usdAmount.text = "$\(usdAmounts[indexPath.row])"
        cell.transactionDirection.image = UIImage(named: transactionDirections[indexPath.row])
        
        return cell
    }

}
