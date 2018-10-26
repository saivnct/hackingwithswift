//
//  GameScene.swift
//  Project11
//
//  Created by Giang Bb on 6/30/17.
//  Copyright © 2017 Giang Bb. All rights reserved.
//

import SpriteKit
import GameplayKit

class GameScene: SKScene, SKPhysicsContactDelegate {
    
    var scoreLabel: SKLabelNode!    //The SKLabelNode class is somewhat similar to UILabel in that it has a text property, a font, a position, an alignment, and so on
    
    var score: Int = 0 {
        didSet {            // use the property observers
            scoreLabel.text = "Score: \(score)"
        }
    }
    
    var editLabel: SKLabelNode!
    
    var editingMode: Bool = false {
        didSet {
            if editingMode{
                editLabel.text = "Done"
            }else{
                editLabel.text = "Edit"
            }
        }
    }
    
    
    
    override func didMove(to view: SKView) {
        let background = SKSpriteNode(imageNamed: "background.jpg")
        background.position = CGPoint(x: 512, y: 384)
        background.blendMode = .replace     //Blend modes determine how a node is drawn, and SpriteKit gives you many options. The .replace option means "just draw it, ignoring any alpha values," which makes it fast for things without gaps such as our background
        background.zPosition = -1   //We're also going to give the background a zPosition of -1, which in our game means "draw this behind everything else."
        //To add any node to the current screen, you use the addChild() method. As you might expect, SpriteKit doesn't use UIViewController like our UIKit apps have done. Yes, there is a view controller in your project, but it's there to host your SpriteKit game. The equivalent of screens in SpriteKit are called scenes.
        //When you add a node to your scene, it becomes part of the node tree. Using addChild() you can add nodes to other nodes to make a more complicated tree
        addChild(background)
        
        
        
        physicsBody = SKPhysicsBody(edgeLoopFrom: frame) // adds a physics body to the whole scene that is a line on each edge, effectively acting like a container for the scene
        
        physicsWorld.contactDelegate = self  //implement SKPhysicsContactDelegate
        
        let bouncerPosArr: [CGPoint] = [CGPoint(x: 0, y: 0),CGPoint(x: 256, y: 0),CGPoint(x: 512, y: 0),CGPoint(x: 768, y: 0),CGPoint(x: 1024, y: 0)]
        for position in bouncerPosArr {
            makeBouncer(at: position)
        }
        
        let slotPosArr: [CGPoint] = [CGPoint(x: 128, y: 0),CGPoint(x: 384, y: 0),CGPoint(x: 640, y: 0),CGPoint(x: 896, y: 0)]
        for (index,position) in slotPosArr.enumerated() {
            makeSlot(at: position, isGood: (index%2==0))
        }
    
        
        scoreLabel = SKLabelNode(fontNamed: "Chalkduster")
        scoreLabel.text = "Score: 0"
        scoreLabel.horizontalAlignmentMode = .right
        scoreLabel.position = CGPoint(x: 980, y: 700)
        addChild(scoreLabel)
        
        
        editLabel = SKLabelNode(fontNamed: "Chalkduster")
        editLabel.text = "Edit"
        editLabel.position = CGPoint(x: 80, y: 700)
        addChild(editLabel)
        
    }
    
    //this method gets called (in UIKit and SpriteKit) whenever someone starts touching their device. It's possible they started touching with multiple fingers at the same time, so we get passed a new data type called Set. This is just like an array, except each object can appear only once
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        //We want to know where the screen was touched, so we use a conditional typecast plus if let to pull out any of the screen touches from the touches set, then use its location(in:) method to find out where the screen was touched in relation to self - i.e., the game scene. UITouch is a UIKit class that is also used in SpriteKit, and provides information about a touch such as its position and when it happened
        
        if let touch = touches.first {
            let location = touch.location(in: self)
            
            //we're going to ask SpriteKit to give us a list of all the nodes at the point that was tapped, and check whether it contains our edit label. If it does, we'll flip the value of our editingMode boolean; if it doesn't, we want to execute the ball-creation code
            let objects = nodes(at: location)
            if objects.contains(editLabel){
                editingMode = !editingMode
            }else{
                if editingMode{
                    //create ball object
                    let ball = SKSpriteNode(imageNamed: "ballRed")
                    ball.physicsBody = SKPhysicsBody(circleOfRadius: ball.size.width/2.0)
                    ball.physicsBody!.restitution = 0.4 //we're giving the ball's physics body a restitution (bounciness) level of 0.4, where values are from 0 to 1        //do dan hoi
                    ball.physicsBody!.contactTestBitMask = ball.physicsBody!.collisionBitMask //The collisionBitMask bitmask means "which nodes should I bump into?" By default, it's set to everything, which is why our ball are already hitting each other and the bouncers. The contactTestBitMask bitmask means "which collisions do you want to know about?" and by default it's set to nothing. So by setting contactTestBitMask to the value of collisionBitMask we're saying, "tell me about every collision.
                    ball.position = location;
                    ball.name = "ball"
                    addChild(ball)
                }else{
                    //create a box //tao chuong ngai vat
                    let size = CGSize(width: GKRandomDistribution(lowestValue: 16, highestValue: 128).nextInt(), height: 16) // generate random numbers between two values: 16 and 128. So, we create a size with a height of 16 and a width between 16 and 128
                    let box = SKSpriteNode(color: RandomColor(), size: size)    //reate an SKSpriteNode with the random size we made along with a random color
                    box.zRotation = RandomCGFloat(min: 0, max: 3)   //give the new box a random rotation //you can imagine Z rotation: it rotates a node on the screen as if it had been skewered straight through the screen
                    box.position = location
                    box.physicsBody = SKPhysicsBody(rectangleOf: box.size)
                    box.physicsBody!.isDynamic = false
                    
                    addChild(box)
                    
                }
                
                //            let box = SKSpriteNode(color: .red, size: CGSize(width: 64, height: 64))    //generates a node filled with a color (red) at a size (64x64
                //            box.physicsBody = SKPhysicsBody(rectangleOf: CGSize(width: 64, height: 64)) //adds a physics body to the box that is a rectangle of the same size as the box
                //            box.position = location
                //            addChild(box)                            
            }
        }
    }
    
    func makeBouncer(at position: CGPoint) {
        let bouncer = SKSpriteNode(imageNamed: "bouncer")
        bouncer.position = position
        bouncer.physicsBody = SKPhysicsBody(circleOfRadius: bouncer.size.width/2) //Remember, SpriteKit's positions start from the center of nodes, so X:512 Y:0 means "centered horizontally on the bottom edge of the scene."
        bouncer.physicsBody?.isDynamic = false  //isDynamic property of a physics body. When this is true, the object will be moved by the physics simulator based on gravity and collisions. When it's false (as we're setting it) the object will still collide with other things, but it won't ever be moved as a result.
        addChild(bouncer)
    }
    
    func makeSlot(at position: CGPoint, isGood: Bool) {
        var slotBase: SKSpriteNode
        var slotGlow: SKSpriteNode
        
        
        //for general use, Apple recommends assigning names to your nodes, then checking the name to see what node it is. We need to have three names in our code: good slots, bad slots and balls
        if isGood{
            slotBase = SKSpriteNode(imageNamed: "slotBaseGood")
            slotBase.name = "good"
            slotGlow = SKSpriteNode(imageNamed: "slotGlowGood")
           
        }else{
            slotBase = SKSpriteNode(imageNamed: "slotBaseBad")
            slotBase.name = "bad"
            slotGlow = SKSpriteNode(imageNamed: "slotGlowBad")
           
        }
        
        slotBase.position = position
        slotBase.physicsBody = SKPhysicsBody(rectangleOf: slotBase.size)
        slotBase.physicsBody!.isDynamic = false //The slot base needs to be non-dynamic because we don't want it to move out of the way when a player ball hits.
        
        slotGlow.position = position
        
        addChild(slotBase)
        addChild(slotGlow)
        
        //create action
        //We could even make the slots spin slowly by using a new class called SKAction. SpriteKit actions are ridiculously powerful
        //Before we look at the code to make this happen, you need to learn a few things up front:
        //Angles are specified in radians, not degrees. This is true in UIKit too. 360 degrees is equal to the value of 2 x Pi – that is, the mathematical value π. Therefore π radians is equal to 180 degrees
        //Rather than have you try to memorize it, there is a built-in value of π called CGFloat.pi
        //Yes CGFloat is yet another way of representing decimal numbers, just like Double and Float. Swift also has Double.pi and Float.pi for when you need it at different precisions.
        //When you create an action it will execute once. If you want it to run forever, you create another action to wrap the first using the repeatForever() method, then run that.
        let spin = SKAction.rotate(byAngle: CGFloat.pi, duration: 10)
        let spinForever = SKAction.repeatForever(spin)
        slotGlow.run(spinForever)
    }
    
    //MARK: - Process Collition
    
    //implement SKPhysicsContactDelegate
    func didBegin(_ contact: SKPhysicsContact) {
        if contact.bodyA.node?.name == "ball"{
            collisionBetween(ball: contact.bodyA.node!, object: contact.bodyB.node!)
        }else if contact.bodyB.node?.name == "ball"{
         collisionBetween(ball: contact.bodyB.node!, object: contact.bodyA.node!)
        }
    }
    
    func collisionBetween(ball: SKNode, object: SKNode) {
        if object.name == "good"{
            score += 1
        }else if object.name == "bad"{
            score -= 1
        }
        
        
        if object.name == "good" || object.name == "bad" {
            destroy(ball: ball)
        }
    }
    
    func destroy(ball: SKNode){
        //it's remarkably easy to create special effects with SpriteKit. In fact, it has a built-in particle editor to help you create effects like fire, snow, rain and smoke almost entirely through a graphical editor
        
        //The SKEmitterNode class is new and powerful: it's designed to create high-performance particle effects in SpriteKit games, and all you need to do is provide it with the filename of the particles you designed and it will do the rest. Once we have an SKEmitterNode object to work with, we position it where the ball was then use addChild() to add it to the scene.
        if let fireParticles = SKEmitterNode(fileNamed: "MyParticle"){   //FireParticles da dc chep vao asset
            fireParticles.position = ball.position
            addChild(fireParticles)
        }
        
        
        ball.removeFromParent() //The removeFromParent() method removes a node from your node tree
        
        
        
        //you can create particles from one of Xcode's built-in particle template. Add a new file, but this time choose "Resource" under the iOS heading, then choose "SpriteKit Particle File" to see the list of options.
//        Confused by all the options? Here's what they do:
//        
//        Particle Texture: what image to use for your particles.
//        Particles Birthrate: how fast to create new particles.
//        Particles Maximum: the maximum number of particles this emitter should create before finishing.
//        Lifetime Start: the basic value for how many seconds each particle should live for.
//        Lifetime Range: how much, plus or minus, to vary lifetime.
//        Position Range X/Y: how much to vary the creation position of particles from the emitter node's position.
//        Angle Start: which angle you want to fire particles, in degrees, where 0 is to the right and 90 is straight up.
//        Angle Range: how many degrees to randomly vary particle angle.
//        Speed Start: how fast each particle should move in its direction.
//        Speed Range: how much to randomly vary particle speed.
//        Acceleration X/Y: how much to affect particle speed over time. This can be used to simulate gravity or wind.
//        Alpha Start: how transparent particles are when created.
//        Alpha Range: how much to randomly vary particle transparency.
//        Alpha Speed: how much to change particle transparency over time. A negative value means "fade out."
//        Scale Start / Range / Speed: how big particles should be when created, how much to vary it, and how much it should change over time. A negative value means "shrink slowly."
//        Rotation Start / Range / Speed: what Z rotation particles should have, how much to vary it, and how much they should spin over time.
//        Color Blend Factor / Range / Speed: how much to color each particle, how much to vary it, and how much it should change over time.
    }
}
