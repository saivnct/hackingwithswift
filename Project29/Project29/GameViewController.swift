//
//  GameViewController.swift
//  Project29
//
//  Created by Giang Bb on 9/7/17.
//  Copyright © 2017 Giang Bb. All rights reserved.
//

import UIKit
import SpriteKit
import GameplayKit

class GameViewController: UIViewController {

    //add a strong reference to the game scene inside the view controller
    var currentGame: GameScene!
    
    
    //outlet
    @IBOutlet weak var angleSlider: UISlider!
    @IBOutlet weak var angleLabel: UILabel!
    @IBOutlet weak var velocitySlider: UISlider!
    @IBOutlet weak var velocityLabel: UILabel!
    @IBOutlet weak var launchButton: UIButton!
    @IBOutlet weak var playerNumber: UILabel!
    
    
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //we need to call both of them inside viewDidLoad() in order to have them load up with their default values
        angleChanged(angleSlider)
        velocityChanged(velocitySlider)
        
        if let view = self.view as! SKView? {
            // Load the SKScene from 'GameScene.sks'
            if let scene = SKScene(fileNamed: "GameScene") {
                // Set the scale mode to scale to fit the window
                scene.scaleMode = .aspectFill
                
                // Present the scene
                view.presentScene(scene)
                
                
                //Like I said, the game controller already owns the game scene, but it's a pain to get to. Adding that property means we have direct access to the game scene whenever we need it
                currentGame = scene as! GameScene   //sets the property to the initial game scene so that we can start using it
                currentGame.viewController = self   // makes sure that the reverse is true so that the scene knows about the view controller too
            }
            
            view.ignoresSiblingOrder = true
            
            view.showsFPS = false
            view.showsNodeCount = false
        }
    }

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
    
    func activatePlayer(number: Int) {
        //activatePlayer() method that will be called from the game scene when control should pass to the other player. This will just update the player label to say who is in control, then show all our controls again
        if number == 1 {
            playerNumber.text = "<<< PLAYER ONE"
        }else{
            playerNumber.text = "PLAYER TWO >>>"
        }
        
        angleSlider.isHidden = false
        angleLabel.isHidden = false
        
        velocitySlider.isHidden = false
        velocityLabel.isHidden = false
        
        launchButton.isHidden = false
        
    }
    
    
    //MARK: - Action
    @IBAction func angleChanged(_ sender: Any) {
        angleLabel.text = "Angel: \(Int(angleSlider.value))°"   //The only hard thing there is typing the ° symbol that represents degrees – to do that, press Shift+Alt+8
    }
    
    @IBAction func velocityChanged(_ sender: Any) {
        velocityLabel.text = "Angel: \(Int(velocitySlider.value))"
    }
    
    @IBAction func launch(_ sender: Any) {
        //When a player taps the launch button, we need to hide the user interface so they can't try to fire again until we're ready, then tell the game scene to launch a banana using the current angle and velocity. Our game will then proceed with physics calculations until the banana is destroyed or lost (i.e., off screen), at which point the game will tell the game controller to change players and continue.
        //The code for the launch() method is trivial, largely because the work of actually launching the banana is hidden behind a call to a launch() method that we'll add to the game scene shortly
        angleSlider.isHidden = true
        angleLabel.isHidden = true
        
        velocitySlider.isHidden = true
        velocityLabel.isHidden = true
        
        launchButton.isHidden = true
        
        currentGame.launch(angle: Int(angleSlider.value), velocity: Int(velocitySlider.value))
    }
    
    

    
    
    
    
}
