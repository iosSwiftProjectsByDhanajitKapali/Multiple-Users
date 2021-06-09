//
//  ViewController.swift
//  Multiple Users
//
//  Created by unthinkable-mac-0025 on 04/06/21.
//

import UIKit

class ProfileManagerViewController: UIViewController {
    
    var currentUserPosition : Int?
    
    @IBOutlet var userImage: UIImageView!
    @IBOutlet var userName: UILabel!
    @IBOutlet var userMobileNo: UILabel!
    @IBOutlet var switchAccountBtn: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        switchAccountBtn.layer.cornerRadius = 15.0
    }
    
    override func viewWillAppear(_ animated: Bool) {
        let dbManager = SQLiteManager()
        let usersArray = dbManager.getAllDataFromDB()
        
        userName.isHidden = true
        userMobileNo.isHidden = true
        
        if(usersArray.count > 0){
            for i in 0...usersArray.count-1{
                let status = usersArray[i].isParent
                if(status == "TRUE"){
                    userName.text = usersArray[i].name
                    userMobileNo.text = usersArray[i].id
                    currentUserPosition = i
                    
                    userName.isHidden = false
                    userMobileNo.isHidden = false
                }
            }
        }
        
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: animated)
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        navigationController?.setNavigationBarHidden(false, animated: animated)
    }

    @IBAction func switchAcouuntBtnPressed(_ sender: UIButton) {
        performSegue(withIdentifier: "userProfileToSwitcher", sender: self)
    }
    
    //preparation before segue
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let destinationVC = segue.destination as! AccountSwitcherViewController
        destinationVC.currentUserPosition = currentUserPosition
    }
}

