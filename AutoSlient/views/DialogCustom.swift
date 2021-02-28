//
//  DialogCustom.swift
//  AutoSlient
//
//  Created by DuyNguyen on 8/13/20.
//  Copyright © 2020 DuyNguyen. All rights reserved.
//

import UIKit

protocol DiaLogdelegate: class {
    func tapOkButton()
}

class DiaLogCustom: UIView {
    @IBOutlet weak var OkButton: UIButton!
    @IBOutlet weak var mTitleLbl: UILabel!
    @IBOutlet weak var mMessageLbl: UILabel!
    weak var delegate: DiaLogdelegate?
    
    enum TypeOfDiaLog {
        case DialogRequsetTurnOnLocation
        case DialogRequsetAllowLocationAcess
    }
    
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        loadNibFile()
    }

    init(frame: CGRect, Type: TypeOfDiaLog){
        super.init(frame: frame)
        loadNibFile()
        switch Type {
        case .DialogRequsetAllowLocationAcess:
            self.mTitleLbl.text = "Notice"
            self.mMessageLbl.text = "Please chose \"Allow\" or \"When in Use\" to use this app"
            self.OkButton.setTitle("Config", for: .normal)
            break
        case .DialogRequsetTurnOnLocation:
            self.mTitleLbl.text = "Notice"
            self.mMessageLbl.text = "Please turn on location to use this app"
            self.OkButton.setTitle("Config", for: .normal)
            break
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func loadNibFile() {
        let view = Bundle.main.loadNibNamed("DialogCustom", owner: self, options: nil)![0] as? UIView
        if let mview = view {
            mview.frame = frame
            self.addSubview(mview)
        }
    }
    
    @IBAction func tapOkButton(_ sender: Any) {
        self.delegate?.tapOkButton()
        removeFromSuperview()
    }
}
