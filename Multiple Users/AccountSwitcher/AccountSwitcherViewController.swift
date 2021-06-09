//
//  AccountSwitcherViewController.swift
//  Multiple Users
//
//  Created by unthinkable-mac-0025 on 04/06/21.
//

import UIKit
import BLTNBoard
import SQLite3

class AccountSwitcherViewController: UIViewController {
    
    let SQLITE_TRANSIENT = unsafeBitCast(-1, to: sqlite3_destructor_type.self)
    
    var currentUserPosition : Int?
    var userArray = [AccountModel]()
    var itemNo : Int? = nil
    var boardManager: BLTNItemManager?
    var dbManager : SQLiteManager?
    
    @IBOutlet var accountsTableView: UITableView!
    @IBOutlet var addNewAccountBtn: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        addNewAccountBtn.layer.cornerRadius = 15.0
        dbManager = SQLiteManager()
        
        //adding the delegate and detasorce for the tableView, registering a xib for tableViewCell
        accountsTableView.delegate = self
        accountsTableView.dataSource = self
        accountsTableView.register(UINib(nibName: "AccountCell", bundle: nil), forCellReuseIdentifier: "acountsTableViewCell")
        
      
        //creating an array to act as a datasource for tableView
        userArray = (dbManager?.getAllDataFromDB())!
        print(userArray.count)
        
    }
    
    @IBAction func addNewAccountBtnPressed(_ sender: UIButton) {
        //print("Button for adding new account pressed ")
        
        var userName = UITextField()
        var userID = UITextField()

        //creating an alert
        let alert = UIAlertController(title: "Add New Account", message: "", preferredStyle: .alert)
        let action = UIAlertAction(title: "Add Item", style: .default) { (action) in
            //what will happen once the user clicks the Add Item btn in the alert

            //saving data only if there is some data in the textField
            if userName.text != "" || userID.text != "" || (userID.text != "" && userName.text != "") {
                //adding this new user to DB
                self.insertUserToDB(userName.text!, userID.text!)
                self.userArray.append(AccountModel(name: userName.text!, id: userID.text!, isParent: "FALSE"))
                self.accountsTableView.reloadData()
            }else{
                userName.placeholder = "User Name can't be empty"
                userID.placeholder = "User ID can't be emppty"
            }
            
            //self.accountsTableView.reloadData()
        }//alert action END
        
        //adding a texField in the alert
        alert.addTextField { (alertTextField) in
            alertTextField.placeholder = "Enter User Name"
            userName = alertTextField
        }
        //adding a texField in the alert
        alert.addTextField { (alertTextField) in
            alertTextField.placeholder = "Enter Uer ID"
            userID = alertTextField
        }
        alert.addAction(action)
        present(alert, animated: true, completion:  nil)
        
    }
   

}

//MARK: - Table view delegate and dataSource
extension AccountSwitcherViewController : UITableViewDelegate, UITableViewDataSource{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return userArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = accountsTableView.dequeueReusableCell(withIdentifier: "acountsTableViewCell", for: indexPath) as! AccountCell
        
        cell.delegate = self
        
        cell.userName.text = userArray[indexPath.row].name
        cell.userID.text = userArray[indexPath.row].id
        cell.userid = userArray[indexPath.row].id
        
        //setting the delegate of the cell
       
        
        if(indexPath.row == 0){
            //cell.isUserInteractionEnabled = false
            cell.deleteBtn.isHidden = true
        }
        if(indexPath.row == currentUserPosition){
            cell.radioBtn.setImage(UIImage(named: "checked-radio-button"), for: .normal)
            cell.isUserInteractionEnabled = false
            cell.deleteBtn.isHidden = true
        }else{
            cell.radioBtn.setImage(UIImage(named: "unchecked-radio-button"), for: .normal)
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 114.0
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        //print("row selected")
        itemNo = indexPath.row
        showLoginAlert(userArray[indexPath.row].name)
        tableView.deselectRow(at: indexPath, animated: true)
    }
}


//MARK: - Account Cell Delegate
extension AccountSwitcherViewController : AccountCellDelegate{
    func deleteButtonPressedButton(_ userID : String) {
        print("Namaste \(userID)")
        var temp : Int?
        for i in 0...userArray.count-1{
            let account = userArray[i]
            if account.id == userID{
                temp = i;
            }
        }
        if let pos = temp{
            let user = userArray[pos].name
            self.showDeleteAlert(user, with: pos)
            //userArray.remove(at: pos)
        }
    }
}



//MARK: - Managing SQLite DB
extension AccountSwitcherViewController{
    
    func changeCurrentUser()  {
        dbManager?.updateDataInDB(userArray[itemNo!].id , "TRUE")
        dbManager?.updateDataInDB(userArray[currentUserPosition!].id , "FALSE")
        currentUserPosition = itemNo
        
        //accountsTableView.reloadData()
    }
    
    func insertUserToDB(_ userName : String, _ userID : String )  {
        var status : String = "FALSE"
        if(userArray.count == 0){
            status = "TRUE"
            currentUserPosition = 0
        }
        dbManager?.insertDataToDB(userName, userID, status)
    }
    
    func deleteUserFromDB(with userID : String, _ pos : Int) {
        dbManager?.deleteDataFromDB(with: userID)
        userArray.remove(at: pos)
        accountsTableView.reloadData()
        
    }

}


//MARK: - Buletin Button card
extension AccountSwitcherViewController {
    
    func showBoardAlert(_ boardData : BulletinBoardData){
        boardManager = {
            //let user = userArray[itemNo!].name
            let item = BLTNPageItem(title: boardData.tile)
            item.image = UIImage(named: boardData.imageName)
            item.actionButtonTitle = boardData.buttonTitle
            item.alternativeButtonTitle = boardData.alternateButtonTitle
            item.actionHandler = { _ in
                self.didTapBoardContinue()
            }
            item.alternativeHandler = {_ in
                self.didTapBoardSkip()
            }
            return BLTNItemManager(rootItem: item)
        }()
        
        boardManager?.showBulletin(above: self)
        boardManager?.backgroundViewStyle = .blurred(style: .dark, isDark: true)
    }
    
    func showLoginAlert(_ forUser : String)  {
        let boardData = BulletinBoardData(tile: "Login as \(forUser)", imageName: "change-user", buttonTitle: "Continue", alternateButtonTitle: "No thanks")
        showBoardAlert(boardData)
    }
    
    func showDeleteAlert(_ forUser : String , with pos: Int)  {
        //print("the position is \(pos)")
        let boardData = BulletinBoardData(tile: "\(forUser) will be deleted", imageName: "delete-user", buttonTitle: "Delete", alternateButtonTitle: "No thanks")
        showDeleteBoardAlert(boardData, pos)
    }
    
    func didTapBoardContinue() {
        //print("Continuing with new account login")
        changeCurrentUser()
        boardManager?.dismissBulletin()
        navigationController?.popViewController(animated: true)
    }

    func didTapBoardSkip()  {
        //print("skiping acount switch")
        boardManager?.dismissBulletin()
    }
    
    func showDeleteBoardAlert(_ boardData : BulletinBoardData, _ pos : Int){
        boardManager = {
            //let user = userArray[itemNo!].name
            let item = BLTNPageItem(title: boardData.tile)
            item.image = UIImage(named: boardData.imageName)
            item.actionButtonTitle = boardData.buttonTitle
            item.alternativeButtonTitle = boardData.alternateButtonTitle
            item.actionHandler = { _ in
                self.didTapBoardDelete(pos)
            }
            item.alternativeHandler = {_ in
                self.didTapBoardSkip()
            }
            return BLTNItemManager(rootItem: item)
        }()
        
        boardManager?.showBulletin(above: self)
        boardManager?.backgroundViewStyle = .blurred(style: .dark, isDark: true)
    }
    
    func didTapBoardDelete(_ pos : Int) {
        //print("Deleting the account")
        let userID = userArray[pos].id
        deleteUserFromDB(with: userID, pos)
        
        boardManager?.dismissBulletin()
    }
}



