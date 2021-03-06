//
//  ViewerTabViewController.swift
//  Treviz
//
//  Created by Tyler Anderson on 1/28/20.
//  Copyright © 2020 Tyler Anderson. All rights reserved.
//

import Cocoa

class ViewerTabViewController: TZTabViewController {

    @IBOutlet weak var visualizerTabViewItem: NSTabViewItem!
    @IBOutlet weak var plotTabViewItem: NSTabViewItem!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do view setup here.
        let plotView = plotTabViewItem.viewController
        let vizView = visualizerTabViewItem.viewController
        
        /*
        if let lastTabView = UserDefaults.standard.value(forKey: "selectedOutputTab") {
            tabView.selectTabViewItem(withIdentifier: lastTabView)
        } else {
            tabView.selectTabViewItem(withIdentifier: "visualizerTabViewItem")
        }*/
        tabView.selectTabViewItem(withIdentifier: "visualizerTabViewItem")
    }
    
    override func tabView(_ tabView: NSTabView, didSelect tabViewItem: NSTabViewItem?) {
        UserDefaults.standard.set(tabViewItem?.identifier, forKey: "selectedOutputTab")
    }
}
