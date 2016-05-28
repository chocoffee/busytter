//
//  ViewController.swift
//  TwitterClient02
//
//  Created by guest on 2016/04/18.
//  Copyright © 2016年 JEC. All rights reserved.
//

import UIKit
import Social
import Accounts


class ViewController: UIViewController {
    private var twitterAccounts = [ACAccount]()
    private var twitterAccount = ACAccount()

    @IBOutlet weak var accountLabel: UILabel!
    
    func setAccountsByDevice(accountType: ACAccountType) {
        let accountStore = ACAccountStore()
        accountStore.requestAccessToAccountsWithType(accountType, options: nil) { granted, error in
            if let accountError = error {
                print("Account Error: %@", accountError.localizedDescription)
                dispatch_async(dispatch_get_main_queue(), {
                    self.accountLabel.text = "アカウント認証エラー"
                })
                return
            }
            if !granted {
                print("Account Error: Cannot access to account data.")
                dispatch_async(dispatch_get_main_queue(), {
                    self.accountLabel.text = "アカウント認証エラー"
                })
                return
            }
            self.twitterAccounts = accountStore.accountsWithAccountType(accountType) as! [ACAccount]
            if (self.twitterAccounts.count <= 0){
                dispatch_async(dispatch_get_main_queue(), {
                    self.accountLabel.text = "アカウントなし"
                })
            } else {
                self.twitterAccount = self.twitterAccounts[0]
                dispatch_async(dispatch_get_main_queue(), {
                    self.accountLabel.text = self.twitterAccount.username
                })
            }
        }
    }

    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if let timeLineVC = segue.destinationViewController as? TabBarViewController{
            timeLineVC.twitterAccount = twitterAccount
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        let twitterAccountType = ACAccountStore().accountTypeWithAccountTypeIdentifier(ACAccountTypeIdentifierTwitter)
        setAccountsByDevice(twitterAccountType)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    @IBAction func setAccount() {
        let alertController = UIAlertController(
            title: "アカウント一覧",
            message: "選択してください",
            preferredStyle: .ActionSheet)
        
        for account in twitterAccounts {
            let otherAction = UIAlertAction(title: account.username, style: .Default) { action in
                self.twitterAccount = account
                self.accountLabel.text = account.username
            }
            alertController.addAction(otherAction)
        }
        
        let cancelAction = UIAlertAction(title: "キャンセル", style: .Cancel) { action in
        }
        alertController.addAction(cancelAction)
        presentViewController(alertController, animated: true, completion: nil)
    }
}

