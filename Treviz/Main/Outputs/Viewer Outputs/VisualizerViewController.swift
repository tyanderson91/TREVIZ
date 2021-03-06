//
//  PlotViewController.swift
//  Treviz
//
//  Created by Tyler Anderson on 11/2/19.
//  Copyright © 2019 Tyler Anderson. All rights reserved.
//

import Cocoa
import SpriteKit
import SceneKit

class TZSKView: SKView {
    var tzscene: TZScene? { return scene as? TZScene }
    
    override func keyDown(with event: NSEvent) {
        guard tzscene != nil else { return }
        let key = event.keyCode
        if key == 49 { // space
            if let cont = tzscene!.playbackController {
                cont.playPauseButtonToggled(self)
            }
        }
    }
    
    override func viewDidChangeEffectiveAppearance() {
        super.viewDidChangeEffectiveAppearance()
        let dmode = self.effectiveAppearance.name
        if dmode.rawValue == "NSAppearanceNameDarkAqua" {
            tzscene?.backgroundScene?.changeMode(darkMode: true)
        } else if dmode.rawValue == "NSAppearanceNameAqua" {
            tzscene?.backgroundScene?.changeMode(darkMode: false)
        }
    }
}

class VisualizerViewController: TZViewController, TZVizualizer, SKSceneDelegate {
    
    @IBOutlet weak var placeholderImageView: NSImageView!
    @IBOutlet weak var skView: TZSKView!
    //@IBOutlet weak var sceneView: SCNView!
    
    var trajectory: State!
    var curScene: TZScene!
    var controlsVC: TZPlaybackController!
    var dockControls = true
    
    var preferences = VisualizerPreferences()
    static var preferencesGetter: PlotPreferencesGetter?
    
    @IBOutlet weak var controlsFixedWidthConstraint: NSLayoutConstraint!
    @IBOutlet weak var controlsEqualWidthConstraint: NSLayoutConstraint!
    @IBOutlet weak var controlsBottomOffsetConstraint: NSLayoutConstraint!
    @IBOutlet weak var scene2dBottomConstraint: NSLayoutConstraint!
    @IBOutlet weak var controlsTopConstraint: NSLayoutConstraint!
    
    override func viewDidLoad() {
        //view.wantsLayer = true
        //view.layer?.backgroundColor = NSColor.black.cgColor
        placeholderImageView?.image = NSImage(named: analysis.phases[0].physicsSettings.centralBodyParam.stringValue)
        analysis.visualViewer = self
        
        toggleView(1)
        dockControls = UserDefaults.dockVisualizationController
        
        let sceneSize = skView.bounds.size
        curScene = TZScene(size: sceneSize)
        super.viewDidLoad()
        curScene.isPaused = true
        self.view.viewDidChangeEffectiveAppearance()
    }
    
    override func prepare(for segue: NSStoryboardSegue, sender: Any?) {
        // let id = segue.identifier
        if let playbackVC = segue.destinationController as? TZPlaybackController {
            controlsVC = playbackVC
            curScene.playbackController = playbackVC
            playbackVC.scene = curScene
        }
    }

    func toggleView(_ iview: Int){
        
        let curViews: [NSView] = [placeholderImageView, skView]//, sceneView]
        for i in 0...curViews.count-1 {
            if i == iview { curViews[i].isHidden = false }
            else { curViews[i].isHidden = true}
        }
    }
    
    func loadTrajectoryData() {
        guard UserDefaults.showVisualization else { return }
        if let prefGetter = VisualizerViewController.preferencesGetter {
            preferences = prefGetter.getPreferences()
            curScene.preferences = preferences
        }
        
        // 2D SpriteKit view
        toggleView(1)
        skView.presentScene(curScene)
        var groups: [RunGroup]
        if analysis.tradeGroups.count > 0 {
            groups = analysis.tradeGroups
        } else {
            var rg = RunGroup(name: "TempGroup")
            rg.runs = analysis.runs
            groups = [rg]
        }
        curScene.loadData(groups: groups)
        
        skView.viewDidChangeEffectiveAppearance()
    }
}
