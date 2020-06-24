//
//  CPRInstructions.swift
//  Shock
//
//  Created by Kurt Höblinger on 26.04.19.
//  Copyright © 2019 Kurt Höblinger. All rights reserved.
//

import UIKit

class CPRInstructions: UITableViewController {

    @IBAction func call144(_ sender: Any) {
        if let url = URL(string: "tel://144") {
            UIApplication.shared.open(url)
        }
    }
    @IBAction func goASB(_ sender: Any) {
        goOnline(goUrl: "https://www.samariterbund.net/ausbildung-und-erste-hilfe/")
    }
    
    @IBAction func goJOH(_ sender: Any) {
        goOnline(goUrl: "https://www.johanniter.at/kurse/")
    }
    
    @IBAction func goMAL(_ sender: Any) {
        goOnline(goUrl: "https://www.malteser.at/was-wir-tun/kurse-erste-hilfe/")
    }
    
    @IBAction func goRK(_ sender: Any) {
        goOnline(goUrl: "https://www.roteskreuz.at/wien/kurse-aus-weiterbildung/erste-hilfe/")
    }
    
    func goOnline(goUrl: String) {
        if let url = URL(string: goUrl) {
            UIApplication.shared.open(url)
        }
    }
}
