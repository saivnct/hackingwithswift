//
//  GameScene.swift
//  Project26
//
//  Created by Giang Bb on 7/28/17.
//  Copyright © 2017 Giang Bb. All rights reserved.
//

import SpriteKit
import GameplayKit

//working with the accelerometer
//All motion detection is done with an Apple framework called Core Motion, and most of the work is done by a class called CMMotionManager. Using it here won't require any special user permissions, so all we need to do is create an instance of the class and ask it to start collecting information. We can then read from that information whenever and wherever we need to, and in this project the best place is update()
import CoreMotion

class GameScene: SKScene, SKPhysicsContactDelegate {

    var player: SKSpriteNode!
    var scoreLabel: SKLabelNode!
    var score: Int = 0 {
        didSet {
            scoreLabel.text = "Score: \(score)"
        }
    }
    
    var isGameOver = false
    
    
    var lastTouchPosition: CGPoint?
    var motionManager: CMMotionManager!
    
    
    //Note that your bitmasks should start at 1 then double each time
    enum CollitionTypes: UInt32{
        case player = 1
        case wall = 2
        case start = 4
        case vortex = 8
        case finish = 16
    }
    
    override func didMove(to view: SKView) {
        let background = SKSpriteNode(imageNamed: "background.jpg")
        background.position = CGPoint(x: 512, y: 384)
        background.blendMode = .replace
        background.zPosition = -1
        addChild(background)
        
        
        
        physicsWorld.gravity = CGVector(dx: 0, dy: 0)
        
        motionManager = CMMotionManager()
        motionManager.startAccelerometerUpdates()   //instructs Core Motion to start collecting accelerometer information we can read later
        
        physicsWorld.contactDelegate = self
        
        loadGame()
        
        scoreLabel = SKLabelNode(fontNamed: "Chalkduster")
        scoreLabel.text = "Score: 0"
        scoreLabel.horizontalAlignmentMode = .left
        scoreLabel.position = CGPoint(x: 16, y: 16)
        addChild(scoreLabel)
    }
    
    func  loadGame() {
        loadLevel(levelname: "level1")
        createPlayer()
    }
    
    
    func loadLevel(levelname: String) {
        //At the core of the method it loads a level file from disk, then splits it up by line. Each line will become one row of level data on the screen, so the method will loop over every character in the row and see what letter it is. Our game will recognize five possible options: a space will mean empty space, "x" means a wall, "v" means a vortex (deadly to players), "s" means a star (awards points), and "f" means level finish.
        //We'll be using the enumerated() method again. In case you've forgotten, this loops over an array, extracting each item and its position in the array.
        //We'll be positioning items as we go. Each square in the game world occupies a 64x64 space, so we can find its position by multiplying its row and column by 32. But: remember that SpriteKit calculates its positions from the center of objects, so we need to add 32 to the X and Y coordinates in order to make everything lines up on our screen.
        //You might also remember that SpriteKit uses an inverted Y axis to UIKit, which means for SpriteKit Y:0 is the bottom of the screen whereas for UIKit Y:0 is the top. When it comes to loading level rows, this means we need to read them in reverse so that the last row is created at the bottom of the screen and so on upwards.
        
        
        //we're going to be using the categoryBitMask, contactTestBitMask and collisionBitMask properties for this project, because we have very precise rules that make the game work
            //The categoryBitMask property is a number defining the type of object this is for considering collisions.
            //The collisionBitMask property is a number defining what categories of object this node should collide with,
            //The contactTestBitMask property is a number defining which collisions we want to be notified about
        //They all do very different things, although the distinction might seem fine before you fully understand. Category is simple enough: every node you want to reference in your collision bitmasks or your contact test bitmasks must have a category attached. If you give a node a collision bitmask but not a contact test bitmask, it means they will bounce off each other but you won't be notified. If you do the opposite (contact test but not collision) it means they won't bounce off each other but you will be told when they overlap.
        
        //By default, physics bodies have a collision bitmask that means "everything", so everything bounces off everything else. By default, they also have a contact test bitmask that means "nothing", so you'll never get told about collisions.
        //SpriteKit expects these three bitmasks to be described using a UInt32. It's a particular way of storing numbers, but rather than using numbers we're going to use enums with a raw value like we did in project 17. This means we can refer to the various options using names
        
        if let levelPath = Bundle.main.path(forResource: levelname, ofType: "txt"){
            if let levelString = try? String(contentsOfFile: levelPath){
                let lines = levelString.components(separatedBy: "\n")
                
                for (row,line) in lines.reversed().enumerated(){
                    for (column, letter) in line.characters.enumerated() {
                        let position = CGPoint(x: (64 * column)+32, y: (64 * row)+32)
                        
                        switch letter {
                        case "x":
                            //load wall
                            let node = SKSpriteNode(imageNamed: "block")
                            node.position = position
                            
                            node.physicsBody = SKPhysicsBody(rectangleOf: node.size)
                            node.physicsBody!.categoryBitMask = CollitionTypes.wall.rawValue
                            node.physicsBody!.isDynamic = false //the walls should be fixed
                            addChild(node)
                            break
                        case "v":
                            //load vortex
                            let node = SKSpriteNode(imageNamed: "vortex")
                            node.position = position
                            node.name = "vortex"
                            node.run(SKAction.repeatForever(SKAction.rotate(byAngle: CGFloat.pi, duration: 1)))
                            
                            node.physicsBody = SKPhysicsBody(circleOfRadius: node.size.width/2)
                            node.physicsBody!.isDynamic = false
                            node.physicsBody!.categoryBitMask = CollitionTypes.vortex.rawValue
                            node.physicsBody!.contactTestBitMask = CollitionTypes.player.rawValue   //sets the contactTestBitMask property to the value of the player's category, which means we want to be notified when these two touch
                            node.physicsBody!.collisionBitMask = 0
                            addChild(node)
                            break
                        case "s":
                            //load start
                            let node = SKSpriteNode(imageNamed: "star")
                            node.position = position
                            node.name = "star"
                            
                            node.physicsBody = SKPhysicsBody(circleOfRadius: node.size.width/2)
                            node.physicsBody!.isDynamic = false
                            node.physicsBody!.categoryBitMask = CollitionTypes.start.rawValue
                            node.physicsBody!.contactTestBitMask = CollitionTypes.player.rawValue
                            node.physicsBody!.collisionBitMask = 0
                            addChild(node)
                            break
                        case "f":
                            //load finish
                            let node = SKSpriteNode(imageNamed: "finish")
                            node.position = position
                            node.name = "finish"
                            
                            node.physicsBody = SKPhysicsBody(circleOfRadius: node.size.width/2)
                            node.physicsBody!.isDynamic = false
                            node.physicsBody!.categoryBitMask = CollitionTypes.finish.rawValue
                            node.physicsBody!.contactTestBitMask = CollitionTypes.player.rawValue
                            node.physicsBody!.collisionBitMask = 0
                            addChild(node)
                            break
                        default:
                            break
                        }
                    }
                }
            }
        }
    }
    
    
    func createPlayer() {
        player = SKSpriteNode(imageNamed: "player")
        player.position = CGPoint(x: 96, y: 672)
        player.physicsBody = SKPhysicsBody(circleOfRadius: player.size.width/2)
        player.physicsBody!.allowsRotation = true
        player.physicsBody!.linearDamping = 0.5 //applies a lot of friction to its movement. The game will still be hard, but this does help a little by slowing the ball down naturally.
        
        player.physicsBody!.categoryBitMask = CollitionTypes.player.rawValue
        player.physicsBody!.contactTestBitMask = CollitionTypes.finish.rawValue|CollitionTypes.vortex.rawValue|CollitionTypes.start.rawValue
        player.physicsBody!.collisionBitMask  = CollitionTypes.wall.rawValue
        
        addChild(player)
    }
    
    
    //MARK: - IMPLEMENT TOUCH EVENT
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        if let touch = touches.first {
            let location = touch.location(in: self)
            lastTouchPosition = location
        }
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        if let touch = touches.first{
            let location = touch.location(in: self)
            lastTouchPosition = location
        }
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        lastTouchPosition = nil
    }
    
    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        lastTouchPosition = nil
    }
    
    override func update(_ currentTime: TimeInterval) {
        // Called before each frame is rendered
        guard isGameOver==false else {
            return
        }
        //check app run on simulator or real devices
        #if (arch(i386)||arch(x86_64))
            if let currentTouch = lastTouchPosition {
                let diff = CGPoint(x: currentTouch.x - player.position.x, y: currentTouch.y - player.position.y)
                physicsWorld.gravity = CGVector(dx: diff.x/100, dy: diff.y/100)
            }
        #else
            if let accelerometerData = motionManager.accelerometerData{
                physicsWorld.gravity = CGVector(dx: accelerometerData.acceleration.y * -50, dy: accelerometerData.acceleration.x * 50)   //Remember, your device is rotated to landscape right now, which means you also need to flip your coordinates around!!!!! You're welcome to adjust the speed multipliers as you please; I found a value of 50 worked well.
            }
        #endif
    }
    
    //MARK: - IMPLEMENT SKPhysicsContactDelegate
    func didBegin(_ contact: SKPhysicsContact) {
        if contact.bodyA.node == player{
            playerCollided(with: contact.bodyB.node!)
        }else if contact.bodyB.node == player{
            playerCollided(with: contact.bodyA.node!)
        }
    }
    
    func playerCollided(with node: SKNode) {
        if let nodeName = node.name {
            switch nodeName {
            case "vortex":
                //We need to stop the ball from being a dynamic physics body so that it stops moving once it's sucked in
                //We need to move the ball over the vortex, to simulate it being sucked in. It will also be scaled down at the same time.
                //Once the move and scale has completed, we need to remove the ball from the game.
                //After all the actions complete, we need to create the player ball again and re-enable control.
                player.physicsBody!.isDynamic = false
                isGameOver = true
                score -= 1
                
                let move = SKAction.move(to: node.position, duration: 0.25)
                let scale = SKAction.scale(to: 0.0001, duration: 0.25)
                let remove = SKAction.removeFromParent()
                let sequence = SKAction.sequence([move,scale,remove])
                
                player.run(sequence){ [unowned self] in
                    self.createPlayer()
                    self.isGameOver = false
                }
                
                break
            case "star":
                node.removeFromParent()
                score += 1
                break
            case "finish":
                //next level
                break
            default:
                break
            }
        }
        
    }
    
    
}
