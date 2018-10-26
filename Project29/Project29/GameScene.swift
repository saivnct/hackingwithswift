//
//  GameScene.swift
//  Project29
//
//  Created by Giang Bb on 9/7/17.
//  Copyright © 2017 Giang Bb. All rights reserved.
//

import SpriteKit
import GameplayKit

//define some collision bitmasks. This is identical to project 26, except now we need only three categories: buildings, bananas and players. In the case of buildings, the only thing they'll collide with is a banana, which triggers our explosion
enum CollisionTypes: UInt32 {
    case banana = 1
    case building = 2
    case player = 4
}

class GameScene: SKScene, SKPhysicsContactDelegate {
    
    //add a weak reference to the view controller from the game scene
    //In the very first project, I explained that outlet properties could be declared weak "because the object has been placed inside a view, so the view owns it." That's true, but using weak to declare properties is a bit more generalized: it means "I want to hold a reference to this, but I don't own it so I don't care if the reference goes away."
    weak var viewController: GameViewController!
    
    
    //add a property that will store an array of buildings. We'll be using this to figure out where to place players later on:
    var buildings = [BuildingNode]()
    
    
    var player1: SKSpriteNode!
    var player2: SKSpriteNode!
    var banana: SKSpriteNode!
    
    var currentPlayer = 1
    
    
    override func didMove(to view: SKView) {
        //the didMove(to:) method needs to do only two things: give the scene a dark blue color to represent the night sky, then call a method called createBuildings() that will create the buildings
        backgroundColor = UIColor(hue: 0.669, saturation: 0.99, brightness: 0.67, alpha: 1)
        
        physicsWorld.contactDelegate = self
        
        createBuildings()
        createPlayer()
    }
    
    func createBuildings()  {
        //The createBuildings() method is the important one here, and calling it will finish our background scene. It needs to move horizontally across the screen, filling space with buildings of various sizes until it hits the far edge of the screen. I'm going to make it start at -15 rather than the left edge so that the buildings look like they keep on going past the screen's edge. I'm also going to leave a 2-point gap between the buildings to distinguish their edges slightly more.
        //Each building needs to be a random size. For the height, it can be anything between 300 and 600 points high; for the width, I want to make sure it divides evenly into 40 so that our window-drawing code is simple, so we'll generate a random number between 2 and 4 then multiply that by 40 to give us buildings that are 80, 120 or 160 points wide.
        //As I said earlier, we'll be creating each building node with a solid red color to begin with, then drawing over it with the building texture once it's generated. Remember: SpriteKit positions nodes based on their center, so we need to do a little division of width and height to place these buildings correctly
        var currentX: CGFloat = -15
        while  currentX < 1024 {
            let size = CGSize(width: RandomInt(min: 2, max: 4) * 40, height: RandomInt(min: 300, max: 600))
            currentX += size.width+2
            
            let building = BuildingNode(color: UIColor.red, size: size)
            building.position = CGPoint(x: currentX - (size.width / 2), y: size.height / 2)
            building.setup()
            addChild(building)
            
            buildings.append(building)
        }
    }
    
    func createPlayer() {
        //1 - Create a player sprite and name it "player1".
        //2 - Create a physics body for the player that collides with bananas, and set it to not be dynamic.
        //3 - Position the player at the top of the second building in the array. (This is why we needed to keep an array of the buildings.)
        //4 - Add the player to the scene.
        //5 - Repeat all the above for player 2, except they should be on the second to last building
        
        player1 = SKSpriteNode(imageNamed: "player")
        player1.name = "player1"
        player1.physicsBody = SKPhysicsBody(circleOfRadius: player1.size.width/2)
        player1.physicsBody!.categoryBitMask = CollisionTypes.player.rawValue
        player1.physicsBody!.collisionBitMask = CollisionTypes.banana.rawValue
        player1.physicsBody!.contactTestBitMask = CollisionTypes.banana.rawValue
        player1.physicsBody!.isDynamic = false
        
        let player1Building = buildings[1]
        player1.position = CGPoint(x: player1Building.position.x, y:  player1Building.position.y + ((player1Building.size.height + player1.size.height) / 2))
        addChild(player1)
        
        
        
        player2 = SKSpriteNode(imageNamed: "player")
        player2.name = "player2"
        player2.physicsBody = SKPhysicsBody(circleOfRadius: player2.size.width/2)
        player2.physicsBody!.categoryBitMask = CollisionTypes.player.rawValue
        player2.physicsBody!.collisionBitMask = CollisionTypes.banana.rawValue
        player2.physicsBody!.contactTestBitMask = CollisionTypes.banana.rawValue
        player2.physicsBody!.isDynamic = false
        
        let player2Building = buildings[buildings.count-2]
        player2.position = CGPoint(x: player2Building.position.x, y:  player2Building.position.y + ((player2Building.size.height + player2.size.height) / 2))
        addChild(player2)
        
    }
    
    func launch(angle: Int, velocity: Int) {
        //1 - Figure out how hard to throw the banana. We accept a velocity parameter, but I'll be dividing that by 10. You can adjust this based on your own play testing.
        //2 - Convert the input angle to radians. Most people don't think in radians, so the input will come in as degrees that we will convert to radians
        //3 - If somehow there's a banana already, we'll remove it then create a new one using circle physics.
        //4 - If player 1 was throwing the banana, we position it up and to the left of the player and give it some spin\
        //5 - Animate player 1 throwing their arm up then putting it down again.
        //6 - Make the banana move in the correct direction.
        //7 - If player 2 was throwing the banana, we position it up and to the right, apply the opposite spin, then make it move in the correct direction
        
        //1
        let speed = Double(velocity) / 10.0
        
        //2
        let radian = deg2rad(degrees: angle)
        
        //3
        if banana != nil {
            banana.removeFromParent()
            banana = nil
        }
        
        banana = SKSpriteNode(imageNamed: "banana")
        banana.name = "banana"
        banana.physicsBody = SKPhysicsBody(circleOfRadius: banana.size.width/2)
        banana.physicsBody!.categoryBitMask = CollisionTypes.banana.rawValue
        banana.physicsBody!.collisionBitMask = CollisionTypes.player.rawValue | CollisionTypes.building.rawValue
        banana.physicsBody!.contactTestBitMask = CollisionTypes.player.rawValue | CollisionTypes.building.rawValue
        banana.physicsBody!.usesPreciseCollisionDetection = true
        addChild(banana)
        
        if currentPlayer == 1 {
            //4
            banana.position = CGPoint(x: player1.position.x - 30 , y: player1.position.y + 40 )
            banana.physicsBody!.angularVelocity = -20
            
            //5
            let raiseArm = SKAction.setTexture(SKTexture(imageNamed: "player1Throw"))
            let lowerArm = SKAction.setTexture(SKTexture(imageNamed: "player"))
            let pause = SKAction.wait(forDuration: 0.15)
            let sequence = SKAction.sequence([raiseArm,pause,lowerArm])
            player1.run(sequence)
            
            //6
            let impulse = CGVector(dx: cos(radian) * speed, dy: sin(radian) * speed)
            banana.physicsBody!.applyImpulse(impulse)
        }else{
            //7
            banana.position = CGPoint(x: player2.position.x + 30 , y: player2.position.y + 40 )
            banana.physicsBody!.angularVelocity = 20
            
            let raiseArm = SKAction.setTexture(SKTexture(imageNamed: "player2Throw"))
            let lowerArm = SKAction.setTexture(SKTexture(imageNamed: "player"))
            let pause = SKAction.wait(forDuration: 0.15)
            let sequence = SKAction.sequence([raiseArm,pause,lowerArm])
            player2.run(sequence)
            
            let impulse = CGVector(dx: cos(radian) * -speed, dy: sin(radian) * speed)
            banana.physicsBody!.applyImpulse(impulse)
            
        }
    }
    
    //MARK: - IMPLEMENT CONTACT DELEGATE
    func didBegin(_ contact: SKPhysicsContact) {
        //When it comes to implementing the didBegin() method, there are various possible contacts we need to consider: banana hit building, building hit banana (remember the philosophy?), banana hit player1, player1 hit banana, banana hit player2 and player2 hit banana. This is a lot to check, so we're going to eliminate half of them by eliminating whether "banana hit building" or "building hit banana"
        
        //Take another look at our category bitmasks
        //They are ordered numerically and alphabetically, so what we're going to do is create two new variables of type SKPhysicsBody and assign one object from the collision to each: the first physics body will contain the lowest number, and the second the highest. So, if we get banana (collision type 1) and building (collision type 2) we'll put banana in body 1 and building in body 2, but if we get building (2) and banana (1) then we'll still put banana in body 1 and building in body 2.
        
        var firstBody: SKPhysicsBody
        var secondBody: SKPhysicsBody
        
        if contact.bodyA.categoryBitMask < contact.bodyB.categoryBitMask {
            firstBody = contact.bodyA
            secondBody = contact.bodyB
        }else{
            firstBody = contact.bodyB
            secondBody = contact.bodyA
        }
        
        
        //If the banana hit a player, we're going to call a new method named destroy(player:). If the banana hit a building, we'll call a different new method named bananaHit(building:), but we'll also pass in the contact point. This value tells us where on the screen the impact actually happened, and it's important because we're going to destroy the building at that point.
        if let firstNode = firstBody.node {
            if let secondNode = secondBody.node {
                if firstNode.name == "banana" && secondNode.name == "building" {
                    bananaHit(building: secondNode as! BuildingNode, atPoint: contact.contactPoint)
                }
                
                if firstNode.name == "banana" && secondNode.name == "player1" {
                    destroy(player: player1)
                }
                
                if firstNode.name == "banana" && secondNode.name == "player2" {
                    destroy(player: player2)
                }
                
            }
        }
        
        
    }
    
    func bananaHit(building: BuildingNode, atPoint contactPoint: CGPoint) {
        let buildingLocation = convert(contactPoint, to: building)  //convertPoint(), which asks the game scene to convert the collision contact point into the coordinates relative to the building node. That is, if the building node was at X:200 and the collision was at X:250, this would return X:50, because it was 50 points into the building node.
        building.hitAt(point: buildingLocation)
        
        let explosion = SKEmitterNode(fileNamed: "hitBuilding")!
        explosion.position = contactPoint
        addChild(explosion)
        
        banana.name = ""    //If you're curious why I use banana.name = "", it's to fix a small but annoying bug: if a banana just so happens to hit two buildings at the same time, then it will explode twice and thus call changePlayer() twice – effectively giving the player another throw. By clearing the banana's name here, the second collision won't happen because our didBegin() method won't see the banana as being a banana any more – it's name is gone.
        banana?.removeFromParent()
        banana = nil
        
        changePlayer()
    }
    
    
    func destroy(player: SKSpriteNode)  {
        //If a banana hits a player, it means they have lost the game: we need to create an explosion (yay, particles!), remove the destroyed player and the banana from the scene, then… what? Well, so far we've just left it there – we haven't looked at how to make games restart.
        //There are a number of things you could do: take players to a results screen, take them to a menu screen, and so on. In our case, we're going to reload the level so they can carry on playing. We could just delete all the buildings and generate it all from scratch, but that would be passing up a great opportunity to learn something new!
        //SpriteKit has a super-stylish and built-in way of letting you transition between scenes. This means you can have one scene for your menu, one for your options, one for your game, and so on, then transition between them as if they were view controllers in a navigation controller.
        //To transition from one scene to another, you first create the scene, then create a transition using the list available from SKTransition, then finally use the presentScene() method of our scene's view, passing in the new scene and the transition you created
        
        
        
        //In the destroy(player:) method we're going to execute the scene transition after two seconds so that players have a chance to see who won and, let's face it, laugh at the losing player. But when we create the new game scene we also need to do something very important: we need to update the view controller's currentGame property and set the new scene's viewController property so they can talk to each other once the change has happened.
        //We also need to call the changePlayer() method when a player is destroyed. We haven't written this method yet, but it transfers control of the game to the other player, then calls the activatePlayer() method on the game view controller so that the game controls are re-shown. Calling this method here ensures that the player who lost gets the first turn in the new game.
        let exposion = SKEmitterNode(fileNamed: "hitPlayer")!
        exposion.position = player.position
        addChild(exposion)
        
        player.removeFromParent()
        banana?.removeFromParent()
        
        DispatchQueue.main.asyncAfter(deadline: .now()+2) { [unowned self] in
            let newGame = GameScene(size: self.size)
            newGame.viewController = self.viewController
            self.viewController.currentGame = newGame
            
            self.changePlayer()
            newGame.currentPlayer = self.currentPlayer  //after calling changePlayer(), we must set the new game's currentPlayer property to our own currentPlayer property, so that whoever died gets the first shot.
            
            let transition = SKTransition.doorway(withDuration: 1.5)
            self.view?.presentScene(newGame, transition: transition)
        
        }
    }
    

    func changePlayer() {
        if currentPlayer == 1 {
            currentPlayer = 2
        }else {
            currentPlayer = 1
        }
        
        viewController.activatePlayer(number: currentPlayer)
    }
    
    //MARK: - Touch IMPLEMENT
    func touchDown(atPoint pos : CGPoint) {

    }
    
    func touchMoved(toPoint pos : CGPoint) {

    }
    
    func touchUp(atPoint pos : CGPoint) {

    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {

    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        
    }
    
    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        
    }
    
    
    override func update(_ currentTime: TimeInterval) {
        // what if the banana misses the other player and misses all the other buildings? If you put in a 45° angle and full velocity, changes are it will shoot right off the screen, at which point the game won't end. We're going to fix this by using the update() method: if the banana is ever way off the screen, remove it and change players
        
        if banana != nil {
            if banana.position.y < -1000 {
                banana.removeFromParent()
                banana = nil
                
                changePlayer()
            }
        }
    }
}
