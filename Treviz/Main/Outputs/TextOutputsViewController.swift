//
//  TextOutputsViewController.swift
//  Treviz
//
//  Controls the display of text-based outputs
//
//  Created by Tyler Anderson on 3/21/19.
//  Copyright © 2019 Tyler Anderson. All rights reserved.
//

import Cocoa

class TextOutputContainerViewController: TZViewController{
    @IBOutlet weak var textOutputSplitView: NSView!
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do view setup here.
    }
}

class TextOutputSplitViewController: NSSplitViewController{
    
}

class TextLogViewController: TZViewController{
    
}

class TextOutputsViewController: TZViewController {

    @IBOutlet var textView: NSTextView!
    override func viewDidLoad() {
        super.viewDidLoad()
        textView.string.append("Analysis results will be shown below \n")
        // Do view setup here.
    }
    
}