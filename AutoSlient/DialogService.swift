//
//  DialogService.swift
//  AutoSlient
//
//  Created by DuyNguyen on 8/14/20.
//  Copyright © 2020 DuyNguyen. All rights reserved.
//

import Foundation
import UIKit

class DialogService: NSObject {
    static let ShareInstance =  DialogService()
    var mDialog:DiaLogCustom?

    func showDialog(ViewController: UIViewController, type:DiaLogCustom.TypeOfDiaLog) {
        mDialog?.removeFromSuperview()
        print("showDialog")
        mDialog = DiaLogCustom.init(frame: ViewController.view.frame, Type: type)
        mDialog!.translatesAutoresizingMaskIntoConstraints = false
        mDialog!.delegate = ViewController as? DiaLogdelegate
        ViewController.view.addSubview(mDialog!)
        mDialog!.topAnchor.constraint(equalTo: ViewController.view.topAnchor).isActive = true
        mDialog!.bottomAnchor.constraint(equalTo: ViewController.view.bottomAnchor).isActive = true
        mDialog!.leadingAnchor.constraint(equalTo: ViewController.view.leadingAnchor).isActive = true
        mDialog!.trailingAnchor.constraint(equalTo: ViewController.view.trailingAnchor).isActive = true
    }
    
    func removeDiaLog() {
        mDialog?.removeFromSuperview()
    }
    
}
