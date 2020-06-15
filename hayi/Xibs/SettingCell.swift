//
//  SettingCell.swift
//  Hayi
//
//  Created by Muhammad zain ul Abideen on 19/08/2019.
//  Copyright © 2019 Hayi. All rights reserved.
//

import UIKit
protocol MuteNotificationDelegate {
    func TurnOffAll(state: Bool)
    func Mute(tag:Int,state: Bool)
}
class SettingCell: UITableViewCell {
    
    var delgate: MuteNotificationDelegate?
    
    @IBOutlet weak var stateSwitch: UISwitch!
    
    @IBOutlet weak var settingLabel: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    @IBAction func switchStateChanged(_ sender: UISwitch) {
        var state:Bool?
        if sender.isOn {
            state = true
        } else {
            state = false
        }
        if settingLabel.text == "Mute All" {
            self.delgate?.TurnOffAll(state: state!)
        }
        else {
            let tag =  self.stateSwitch.tag
            self.delgate?.Mute(tag: tag,state: state!)
        }
    }
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
    
    func configureCell(label:String, state: Bool) {
        self.settingLabel.text = label
        self.stateSwitch.setOn(state, animated: true)
    }
    func asignTag(tag: Int) {
        self.stateSwitch.tag = tag
    }
    
}
