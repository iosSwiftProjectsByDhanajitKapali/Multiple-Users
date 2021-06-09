//
//  AccountsTableViewCell.swift
//  Multiple Users
//
//  Created by unthinkable-mac-0025 on 04/06/21.
//

import UIKit

protocol AccountCellDelegate {
    func deleteButtonPressedButton(_ userID : String)
}

class AccountCell: UITableViewCell {

    var delegate : AccountCellDelegate?
    var userid : String?
    
    
    @IBOutlet var radioBtn: UIButton!
    @IBOutlet var userName: UILabel!
    @IBOutlet var userID: UILabel!
    @IBOutlet var deleteBtn: UIButton!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
    }
    @IBAction func radioBtnPressed(_ sender: Any) {
        //print("radio Btn pressed")
        changeRadioButtonStyle()
        
    }
    @IBAction func deleteBtnPressed(_ sender: UIButton) {
        //print("Delete Btn pressed for \(userid!)")
        delegate?.deleteButtonPressedButton(userid!)
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func changeRadioButtonStyle(){
//        let checkedRadioImage = UIImage(named: "checked-radio-button")
//        let uncheckedRadioImage = UIImage(named: "unchecked-radio-button")
        
    }

}
