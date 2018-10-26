//
//  GameViewController.swift
//  Project20
//
//  Created by Giang Bb on 7/14/17.
//  Copyright © 2017 Giang Bb. All rights reserved.
//

import UIKit
import SpriteKit
import GameplayKit

class GameViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let view = self.view as! SKView? {
            // Load the SKScene from 'GameScene.sks'
            if let scene = SKScene(fileNamed: "GameScene") {
                // Set the scale mode to scale to fit the window
                scene.scaleMode = .aspectFill
                
                // Present the scene
                view.presentScene(scene)
            }
            
            view.ignoresSiblingOrder = true
            
            view.showsFPS = false
            view.showsNodeCount = false
        }
    }
    
    //There's one last thing to do before this game is complete, and that's to detect the device being shaken. This is easy enough to do because iOS will automatically call a method called motionBegan() on our game when the device is shaken. Well, it's a little more complicated than that – what actually happens is that the method gets called in GameViewController.swift, which is the UIViewController that hosts our SpriteKit game scene.
    //The default view controller doesn't know that it has a SpriteKit view, and certainly doesn't know what scene is showing, so we need to do a little typecasting. Once we have a reference to our actual game scene, we can call explodeFireworks()
    override func motionBegan(_ motion: UIEventSubtype, with event: UIEvent?) {
        if let skView = self.view as! SKView? {
            let gameScene = skView.scene as! GameScene
            gameScene.explodeFireworks()
        }
    }
    //That's it, your game is done. Obviously you can't shake your laptop to make the iOS Simulator respond, but you can use the keyboard shortcut Ctrl+Cmd+Z to get the same result. If you're testing on your iPad, make sure you give it a good shake in order to trigger the explosions!
    

    override var shouldAutorotate: Bool {
        return true
    }

    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        if UIDevice.current.userInterfaceIdiom == .phone {
            return .allButUpsideDown
        } else {
            return .all
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Release any cached data, images, etc that aren't in use.
    }

    override var prefersStatusBarHidden: Bool {
        return true
    }
}
