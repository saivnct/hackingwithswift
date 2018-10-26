//
//  GameScene.swift
//  Project23
//
//  Created by Giang Bb on 7/25/17.
//  Copyright © 2017 Giang Bb. All rights reserved.
//

import SpriteKit
import GameplayKit

class GameScene: SKScene, SKPhysicsContactDelegate {

    var startfield: SKEmitterNode!
    var player: SKSpriteNode!
    
    var scoreLabel: SKLabelNode!
    
    var score: Int = 0 {
        didSet {
            scoreLabel.text = "Score: \(score)"
        }
    }
    
    var possibleEnemies = ["ball","hammer","tv"]
    var gameTimer: Timer!
    var isGameOver = false
    
    override func didMove(to view: SKView) {
        backgroundColor = UIColor.black
        
        startfield = SKEmitterNode(fileNamed: "Starfield")
        startfield.position = CGPoint(x: 1024, y: 384) //the starfield particle emitter is positioned at X:1024 Y:384, which is the right edge of the screen and half way up
        startfield.advanceSimulationTime(10) //using the advanceSimulationTime() method of the emitter we're going to ask SpriteKit to simulate 10 seconds passing in the emitter, thus updating all the particles as if they were created 10 seconds ago. This will have the effect of filling our screen with star particles.
        addChild(startfield)
        startfield.zPosition = -1
        
        //because the spaceship is an irregular shape and the objects in space are also irregular, we're going to use per-pixel collision detection. This means collisions happen not based on rectangles and circles but based on actual pixels from one object touching actual pixels in another
        //Now, SpriteKit does a really great job of optimizing this so that it looks like it's using actual pixels when in fact it just uses a very close approximation, but you should still only use it when it's needed. If something can be created as a rectangle or a circle you should do so because it's much faster.
        player = SKSpriteNode(imageNamed: "player")
        player.position = CGPoint(x: 100, y: 384)
        player.physicsBody = SKPhysicsBody(texture: player.texture!, size: player.size)
        player.physicsBody!.contactTestBitMask = 1 //set the contact test bit mask for our player to be 1. This will match the category bit mask we will set for space debris later on, and it means that we'll be notified when the player collides with debris.
        addChild(player)
        
        scoreLabel = SKLabelNode(fontNamed: "Chalkduster")
        scoreLabel.position = CGPoint(x: 16, y: 16)
        scoreLabel.horizontalAlignmentMode = .left
        addChild(scoreLabel)
        
        score = 0
        
        physicsWorld.gravity = CGVector(dx: 0, dy: 0) //set the gravity of our physics world to be empty, because this is space and there isn't any gravity
        physicsWorld.contactDelegate = self //sets our current game scene to be the contact delegate of the physics world
        
        
        gameTimer = Timer.scheduledTimer(timeInterval: 0.5, target: self, selector: #selector(createEnemy), userInfo: nil, repeats: true)
    }
    
    func createEnemy()  {
        possibleEnemies = GKRandomSource.sharedRandom().arrayByShufflingObjects(in: possibleEnemies) as! [String]
        let randomDistribution = GKRandomDistribution(lowestValue: 50, highestValue: 736) //generate a random number between 50 and 736 inclusive
        
        let sprite = SKSpriteNode(imageNamed: possibleEnemies[0])
        sprite.position = CGPoint(x: 1200, y: randomDistribution.nextInt())
        addChild(sprite)
        
        
        //create the physics body of the debris: we're going to use per-pixel collision again, tell it to collide with the player, make it move to the left at a fast speed, and give it some angular velocity
        sprite.physicsBody = SKPhysicsBody(texture: sprite.texture!, size: sprite.size)
        sprite.physicsBody?.categoryBitMask = 1
        sprite.physicsBody?.velocity = CGVector(dx: -500, dy: 0)
        sprite.physicsBody?.angularVelocity = 5
        
        //set to 0 its linearDamping and angularDamping properties, which means its movement and rotation will never slow down over time. Perfect for a frictionless space environment!
        sprite.physicsBody?.linearDamping = 0
        sprite.physicsBody?.angularDamping = 0
        
        
    }
    
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
       
    }
    
    //We will, like always, need to use the location(in:) method to figure out where on the screen the user touched. But this time we're going to clamp the player's Y position, which in plain English means that we're going to stop them going above or below a certain point, keeping them firmly in the game area.
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else {
            return
        }
        
        var location = touch.location(in: self)
        
        if location.y < 100{
            location.y = 100
        }else if location.y > 668 {
            location.y = 668
        }
        
        player.position = location
        
        
    }
    
    override func update(_ currentTime: TimeInterval) {
        // Called before each frame is rendered
        for node in children {
            if node.position.x < -300 {
                node.removeFromParent()
            }
        }
        
        if !isGameOver {
            score += 1
        }
    }
    
    //MARK: - IMPLEMENT SKPhysicsContactDelegate
    func didBegin(_ contact: SKPhysicsContact) {
        let explotion = SKEmitterNode(fileNamed: "explosion")!
        explotion.position = player.position
        addChild(explotion)
    
        
//        player.removeFromParent()
        if let nodeA = contact.bodyA.node{
            if let nodeB = contact.bodyB.node{
                if (player == nodeA || player == nodeB){
                    contact.bodyA.node?.removeFromParent()
                    contact.bodyB.node?.removeFromParent()
                }
            }
        }
        
        
        isGameOver = true
        gameTimer.invalidate()
        
    }
    
}
