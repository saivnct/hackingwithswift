//
//  GameScene.swift
//  Project17
//
//  Created by Giang Bui Binh on 7/11/17.
//  Copyright © 2017 giangbb. All rights reserved.
//

import SpriteKit
import GameplayKit
import AVFoundation

class GameScene: SKScene {
    
    var gameEnded = false
    
    var gameScore: SKLabelNode!
    var score: Int = 0 {
        didSet {
            gameScore.text = "Score: \(score)"
        }
    }
    
    var livesImage = [SKSpriteNode]()
    var lives = 3
    
    //check whether the swooshsound is playing or not
    var isSWooshSoundActive = false
    
    var bombSoundEffect: AVAudioPlayer!
    
    //Drawing a shape in SpriteKit is easy thanks to a special node type called SKShapeNode. This lets you define any kind of shape you can draw, along with line width, stroke color and more, and it will render it to the screen. We're going to draw two lines – one for a yellow glow, and one for a white glow in the middle of the yellow glow – so we're going to need two SKShapeNode properties:
    var activeSliceBG: SKShapeNode!
    var activeSliceFG: SKShapeNode!
    
    
    //we're going to keep an array of the user's swipe points so that we can draw a shape resembling their slicing
    var activeSlicePoints = [CGPoint] ()
    
    
    
    //declare a new enum that tracks what kind of enemy should be created: should we force a bomb always, should we force a bomb never, or use the default randomization?
    enum ForceBomb {
        case never, always, random
    }
    
    
    //sometimes we want to create two enemies at once, sometimes we want to create four at once, and sometimes we want to create five in quick sequence. Each one of these will call createEnemy() in different ways
    enum SequenceType: Int {    //it means "I want this enum to be mapped to integer values," and means we can reference each of the sequence type options using so-called "raw values" from 0 to 7.
        case oneNoBomb, one, twoWithOneBomb, two, three, four, chain, fastChain
    }
    
    var popupTime = 0.9 //the amount of time to wait between the last enemy being destroyed and a new one being created.
    var sequence: [SequenceType]!    //array of our SequenceType enum that defines what enemies to create
    var sequencePosition = 0    //where we are right now in the game
    var chainDelay = 3.0        //how long to wait before creating a new enemy when the sequence type is .chain or .fastChain. Enemy chains don't wait until the previous enemy is offscreen before creating a new one, so it's like throwing five enemies quickly but with a small delay between each one
    var nextSequenceQueued = true   //property is used so we know when all the enemies are destroyed and we're ready to create more
    
    
    //We're going to need to track enemies that are currently active in the scene
    var activeEnemies = [SKSpriteNode]()
    
    
    //MARK: - INIT VIEW
    override func didMove(to view: SKView) {
        let background = SKSpriteNode(imageNamed: "sliceBackground")
        background.position = CGPoint(x: 512, y: 384)
        background.blendMode = .replace
        background.zPosition = -1
        addChild(background)
        
     
        
        //Gravity is expressed using a new data type called CGVector, which looks and works like a CGPoint except it takes "delta x" and "delta y" as its parameters. "Delta" is a fancy way of saying "difference", in this case from 0. Vectors are best visualized like an arrow that has its base always at 0,0 and its tip at the point you specify. We're specifying X:0 and Y:-6, so our vector arrow is pointing straight down.
        physicsWorld.gravity = CGVector(dx: 0, dy: -6)
        //The default gravity of our physics world is -0.98, which is roughly equivalent to Earth's gravity. I'm using a slightly lower value so that items stay up in the air a bit longer
        physicsWorld.speed = 0.85
        
        createScore()
        createLives()
        createSlides()
        
        sequence = [.oneNoBomb, .oneNoBomb, .twoWithOneBomb, .twoWithOneBomb, .three, .one, .chain]
        
        for _ in 0...1000 {
            let nextSequence = SequenceType(rawValue: RandomInt(min: 2, max: 7))!;  //Swift doesn't know whether that number exists or not (we could have written 77), so it returns an optional type that you need to unwrap
            sequence.append(nextSequence)
        }
        
        //triggers the initial enemy toss after two seconds
        DispatchQueue.main.asyncAfter(deadline: .now() + 2){[unowned self] in
            self.tossEnemies()
        }
    }
    
    func createScore() {
        gameScore = SKLabelNode(fontNamed: "Chalkduster")
        gameScore.text = "Score: 0"
        gameScore.horizontalAlignmentMode = .left
        gameScore.fontSize = 48
        addChild(gameScore)
        
        gameScore.position = CGPoint(x: 8, y: 8)
    }
    
    func createLives()  {
        for i in 0..<3 {
            let spriteNode = SKSpriteNode(imageNamed: "sliceLife")
            spriteNode.position = CGPoint(x: CGFloat(834 + (i*70)), y: 720)
            addChild(spriteNode)
            
            livesImage.append(spriteNode)
        }
    }
    
    //In this game, swiping around the screen will lead a glowing trail of slice marks that fade away when you let go or keep on moving. To make this work, we're going to do three things:
        //Track all player moves on the screen, recording an array of all their swipe points.
        //Draw two slice shapes, one in white and one in yellow to make it look like there's a hot glow.
        //Use the zPosition property that you met in project 11 to make sure the slices go above everything else in the game.
    func createSlides()  {
        activeSliceBG = SKShapeNode()
        activeSliceBG.zPosition = 2 //I'm using Z position 2 for the slice shapes, because I'll be using Z position 1 for bombs and Z position 0 for everything else – this ensures the slice shapes are on top, then bombs, then everything else.
        
        activeSliceFG = SKShapeNode()
        activeSliceFG.zPosition = 2
        
        activeSliceBG.strokeColor = UIColor(red: 1, green: 0.9, blue: 0, alpha: 1)
        activeSliceBG.lineWidth = 9
        
        activeSliceFG.strokeColor = UIColor.white
        activeSliceFG.lineWidth = 5
        
        addChild(activeSliceBG)
        addChild(activeSliceFG)
    }

    
    //MARK: - UPDATE METHOD
    //This method is called every frame before it's drawn, and gives you a chance to update your game state as you want. We're going to use this method to count the number of bomb containers that exist in our game, and stop the fuse sound if the answer is 0.
    override func update(_ currentTime: TimeInterval) {
        var bombCount = 0
        
        for node in activeEnemies {
            if node.name == "bombContainer" {
                bombCount += 1
                break
            }
        }
        
        if bombCount == 0 {
            if bombSoundEffect != nil {
                bombSoundEffect.stop()
                bombSoundEffect = nil
            }
        }
        
        //1- If we have active enemies, we loop through each of them.
        //2- if any enemy is at or lower than Y position -140, we remove it from the game and our activeEnemies array.
        //3- If we don't have any active enemies and we haven't already queued the next enemy sequence, we schedule the next enemy sequence and set nextSequenceQueued to be true.
        if activeEnemies.count>0 {
            for node in activeEnemies {
                if node.position.y < -140 {
                    node.removeAllActions()
                    if node.name == "enemy" {
                        subtractLife()
                    }
                    node.name = "" //We're going to delete the node's name just in case any further checks for enemies or bombs happen – clearing the node name will avoid any problems
                    node.removeFromParent()
                    if let index = activeEnemies.index(of: node) {
                        activeEnemies.remove(at: index)
                    }
                }
            }
        }else{
            if !nextSequenceQueued {
                DispatchQueue.main.asyncAfter(deadline: .now() + popupTime){[unowned self] in
                    self.tossEnemies()
                }
                
                nextSequenceQueued = true
            }
        }
        
        
    }

    
    
    //MARK: - PROCESSING TOUCH EVENT
    //we're going to keep an array of the user's swipe points so that we can draw a shape resembling their slicing. To make this work, we're going to need five new methods, one of which you've met already. They are: touchesBegan(), touchesMoved(), touchesEnded(), touchesCancelled() and redrawActiveSlice()
    //here's a subtle difference between touchesEnded() and touchesCancelled(): the former is called when the user stops touching the screen, and the latter is called if the system has to interrupt the touch for some reason – e.g. if a low battery warning appears. We're going to make touchesCancelled() just call touchesEnded(), to avoid duplicating code.
    
    //All the touchesMoved() method needs to do is figure out where in the scene the user touched, add that location to the slice points array, then redraw the slice shape
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        //We want to know where the screen was touched, so we use a conditional typecast plus if let to pull out any of the screen touches from the touches set, then use its location(in:) method to find out where the screen was touched in relation to self - i.e., the game scene. UITouch is a UIKit class that is also used in SpriteKit, and provides information about a touch such as its position and when it happened
        guard let touch = touches.first else {return}
        
        if gameEnded {
            return
        }
        
        let location = touch.location(in: self)
        
        activeSlicePoints.append(location)
        redrawActiveSlice()
        
        if !isSWooshSoundActive {
            playSwooshSound()
        }
        
        
        //process slice collition
        let nodesAtPoint = nodes(at: location)
        for node in nodesAtPoint{
            if node.name == "enemy" {
                //destroy penguin
                //1- Create a particle effect over the penguin.
                //2- Clear its node name so that it can't be swiped repeatedly.
                //3- Disable the isDynamic of its physics body so that it doesn't carry on falling
                //4- Make the penguin scale out and fade out at the same time.
                //5- After making the penguin scale out and fade out, we should remove it from the scene.
                //6- Add one to the player's score.
                //7- Remove the enemy from our activeEnemies array.
                //8- Play a sound so the player knows they hit the penguin.
                
                //1
                let emitter = SKEmitterNode(fileNamed: "sliceHitEnemy")!
                emitter.position = node.position
                addChild(emitter)
                
                //2
                node.name = ""
                
                //3
                node.physicsBody!.isDynamic = false
                
                //4
                let scaleout = SKAction.scale(to: 0.001, duration: 0.2)
                let fadeout = SKAction.fadeOut(withDuration: 0.2)
                let group = SKAction.group([scaleout,fadeout])  //An action "group" specifies that all actions inside it should execute simultaneously, whereas an action "sequence" runs them all one at a time
                
                //5
                node.run(group)
                
                //6
                score += 1
                
                //7
                if let index = activeEnemies.index(of: node as! SKSpriteNode){
                    activeEnemies.remove(at: index)
                }
                
                //8
                run(SKAction.playSoundFileNamed("whack", waitForCompletion: false))
                
                
                
            }else if node.name == "bomb" {
                //destroy bomb
                //the node called "bomb" is the bomb image, which is inside the bomb container. So, we need to reference the node's parent when looking up our position, changing the physics body, removing the node from the scene, and removing the node from our activeEnemies array..
                //1
                let emitter = SKEmitterNode(fileNamed: "sliceHitBomb")!
                emitter.position = node.parent!.position
                addChild(emitter)
                //2
                node.name = ""
                //3
                node.parent!.physicsBody!.isDynamic = false
                //4
                let scaleout = SKAction.scale(to: 0.001, duration: 0.2)
                let fadeout = SKAction.fadeOut(withDuration: 0.2)
                let group = SKAction.group([scaleout,fadeout])
                let seq = SKAction.sequence([group, SKAction.removeFromParent()])
                
                //5
                node.parent!.run(seq)
                
                //7
                if let index = activeEnemies.index(of: node.parent as! SKSpriteNode){
                    activeEnemies.remove(at: index)
                }
                
                //8
                run(SKAction.playSoundFileNamed("explosion", waitForCompletion: false))
                
                endGame(triggeredByBomb: true)
                
            }
        }
    }
    
    //When the user finishes touching the screen, touchesEnded() will be called. I'm going to make this method fade out the slice shapes over a quarter of a second. We could remove them immediately but that looks ugly, and leaving them sitting there for no reason would rather destroy the effect. So, fading it is – add this touchesEnded() method:
    override func touchesEnded(_ touches: Set<UITouch>?, with event: UIEvent?) {
        activeSliceBG.run(SKAction.fadeOut(withDuration: 0.25))
        activeSliceFG.run(SKAction.fadeOut(withDuration: 0.25))
        
    }
    
    //The third easy function is touchesCancelled(), and it's easy because we're just going to forward it on to touchesEnded() like this:
    override func touchesCancelled(_ touches: Set<UITouch>?, with event: UIEvent?) {
        if let touches = touches {
            touchesEnded(touches, with: event)
        }
    }
    
    // we're going to look at an interesting method now: touchesBegan(). This needs to do several things:
        //1-Remove all existing points in the activeSlicePoints array, because we're starting fresh.
        //2=Get the touch location and add it to the activeSlicePoints array.
        //3 - Call the (as yet unwritten) redrawActiveSlice() method to clear the slice shapes.
        //4- Remove any actions that are currently attached to the slice shapes. This will be important if they are in the middle of a fadeOut(withDuration:) action.
        //Set both slice shapes to have an alpha value of 1 so they are fully visible.
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)
        
        //1
        activeSlicePoints.removeAll(keepingCapacity: true)
        
        //2
        if let touch = touches.first {
            let location = touch.location(in: self)
            activeSlicePoints.append(location)
            
            //3
             redrawActiveSlice()
            
            //4
            activeSliceBG.removeAllActions()
            activeSliceFG.removeAllActions()
            
            //5
            activeSliceBG.alpha = 1
            activeSliceFG.alpha = 1
            
        }
    }
    
    
    //MARK: - PROCESS DRAW
    // let's take a look at what redrawActiveSlice() needs to do:
        //1- If we have fewer than two points in our array, we don't have enough data to draw a line so it needs to clear the shapes and exit the method.
        //2- If we have more than 12 slice points in our array, we need to remove the oldest ones until we have at most 12 – this stops the swipe shapes from becoming too long.
        //3- It needs to start its line at the position of the first swipe point, then go through each of the others drawing lines to each point.
        //4- Finally, it needs to update the slice shape paths so they get drawn using their designs – i.e., line width and color.
    //To make this work, you're going to need to know that an SKShapeNode object has a property called path which describes the shape we want to draw. When it's nil, there's nothing to draw; when it's set to a valid path, that gets drawn with the SKShapeNode's settings. SKShapeNode expects you to use a data type called CGPath, but we can easily create that from a UIBezierPath.
    //Drawing a path using UIBezierPath is a cinch: we'll use its move(to:) method to position the start of our lines, then loop through our activeSlicePoints array and call the path's addLine(to:) method for each point.
    func redrawActiveSlice() {
        //1
        if activeSlicePoints.count < 2 {
            activeSliceBG.path = nil
            activeSliceFG.path = nil
            return
        }
        
        //2
        while activeSlicePoints.count > 12 {
            activeSlicePoints.remove(at: 0)
        }
        
        //3
        let path = UIBezierPath()
        path.move(to: activeSlicePoints[0])
        for i in 1..<activeSlicePoints.count {
            path.addLine(to: activeSlicePoints[i])
        }
        
        //4
        activeSliceFG.path = path.cgPath
        activeSliceBG.path = path.cgPath
        
    }
    
    //MARK: - PROCESSING SOUND
    func playSwooshSound() {
        isSWooshSoundActive = true
        
        let randomNumber = RandomInt(min: 1, max: 3)
        
        let soundName = "swoosh\(randomNumber).caf"
        
        let swooshsound = SKAction.playSoundFileNamed(soundName, waitForCompletion: true)   //By playing our sound with waitForCompletion set to true, SpriteKit automatically ensures the completion closure given to runAction() isn't called until the sound has finished
        
        run(swooshsound){ [unowned self] in
            self.isSWooshSoundActive = false
        }
        
    }
    
    //MARK: - PROCESSING ENEMY
    
    //the createEnemy() method. It needs to:
        //Accept a parameter of whether we want to force a bomb, not force a bomb, or just be random.
        //Decide whether to create a bomb or a penguin (based on the parameter input) then create the correct thing.
        //Add the new enemy to the scene, and also to our activeEnemies array.
    //To decide whether to create a bomb or a player, I'll choose a random number from 0 to 6, and consider 0 to mean "bomb"
    func createEnemy(forceBomb: ForceBomb = .random) {      //set forceBomb default value to .random
        var enemy: SKSpriteNode
        var enemyType = RandomInt(min: 0, max: 6)
        
        if forceBomb == .never{
            enemyType = 1
        }else if forceBomb == .always{
            enemyType = 0
        }
        
        if enemyType == 0{
            //bomb here
            
            //Creating a bomb also needs to play a fuse sound, but that has its own complexity. You've already seen that SKAction has a very simple way to play sounds, but it's so simple that it's not useful here because we want to be able to stop the sound and SKAction sounds don't let you do that. It would be confusing for the fuse sound to be playing when no bombs are visible, so we need a better solution.
            //That solution is called AVAudioPlayer, and it's not a SpriteKit class – it's available to use in your UIKit apps too if you want. We're going to have an AVAudioPlayer property for our class that will store a sound just for bomb fuses so that we can stop it as needed.
            
                //1- Create a new SKSpriteNode that will hold the fuse and the bomb image as children, setting its Z position to be 1, which is higher than the default value of 0. This is so that bombs always appear in front of penguins, because hours of play testing has made it clear to me that it's awful if you don't realize there's a bomb lurking behind something when you swipe it!
                //2- Create the bomb image, name it "bomb", and add it to the container.
                //3- If the bomb fuse sound effect is playing, stop it and destroy it.
                //4- Create a new bomb fuse sound effect, then play it.
                //5- Create a particle emitter node, position it so that it's at the end of the bomb image's fuse, and add it to the container.
            
            //1
            enemy = SKSpriteNode()
            enemy.zPosition = 1
            enemy.name = "bombContainer"
            
            //2
            let bombImage = SKSpriteNode(imageNamed: "sliceBomb")
            bombImage.name = "bomb"
            enemy.addChild(bombImage)
            
            //3
            if bombSoundEffect != nil {
                bombSoundEffect.stop()
                bombSoundEffect = nil
            }
            
            //4
            let path = Bundle.main.path(forResource: "sliceBombFuse", ofType: "caf")
            let url = URL(fileURLWithPath: path!)
            let sound = try! AVAudioPlayer(contentsOf: url)
            bombSoundEffect = sound
            bombSoundEffect.play()
            
            //5
            let emitter = SKEmitterNode(fileNamed: "sliceFuse")!
            emitter.position = CGPoint(x: 76, y: 64)
            enemy.addChild(emitter)
            
            
        }else{
            enemy = SKSpriteNode(imageNamed: "penguin")
            run(SKAction.playSoundFileNamed("launch.caf", waitForCompletion: false))
            enemy.name = "enemy"
        }
        
        //set position for enemy
            //1- Give the enemy a random position off the bottom edge of the screen.
            //2- Create a random angular velocity, which is how fast something should spin.
            //3- Create a random X velocity (how far to move horizontally) that takes into account the enemy's position.
            //4- Create a random Y velocity just to make things fly at different speeds.
            //5- Give all enemies a circular physics body where the collisionBitMask is set to 0 so they don't collide.
        
        //1
        let randomPosition = CGPoint(x: RandomInt(min: 64, max: 960), y: -128)
        enemy.position  = randomPosition
        
        //2
        let randomAngularVelocity = CGFloat(RandomInt(min: -6, max: 6))
        var randomXVelocity = 0
        
        //3
        if randomPosition.x < 256 {
            randomXVelocity = RandomInt(min: 8, max: 15)
        }else if randomPosition.x < 512 {
            randomXVelocity = RandomInt(min: 3, max: 5)
        }else if randomPosition.x < 768 {
            randomXVelocity = -RandomInt(min: 3, max: 5)
        }else{
            randomXVelocity = -RandomInt(min: 8, max: 15)
        }
        
        //4
        let randomYVelocity = RandomInt(min: 24, max: 32)
        
        //5
        enemy.physicsBody = SKPhysicsBody(circleOfRadius: 64)
        enemy.physicsBody!.velocity = CGVector(dx: randomXVelocity*40, dy: randomYVelocity*40)
        enemy.physicsBody!.angularVelocity = randomAngularVelocity
        enemy.physicsBody!.collisionBitMask = 0 //collisionBitMask is set to 0 so they don't collide.
        
        
        addChild(enemy)
        activeEnemies.append(enemy)
        
    }
    
    
    func tossEnemies() {
        if gameEnded {
            return
        }
        
        popupTime *= 0.991
        chainDelay *= 0.99
        physicsWorld.speed *= 1.02
        
        
        //Each sequence in our array creates one or more enemies, then waits for them to be destroyed before continuing. Enemy chains are different: they create five enemies with a short break between, and don't wait for each one to be destroyed before continuing.
        let sequenceType = sequence[sequencePosition]
        
        switch sequenceType {
        case .oneNoBomb:
            createEnemy(forceBomb: .never)
        case .one:
            createEnemy(forceBomb: .random)
        case .twoWithOneBomb:
            createEnemy(forceBomb: .never)
            createEnemy(forceBomb: .always)
        case .two:
            createEnemy()
            createEnemy()
        case .three:
            createEnemy()
            createEnemy()
            createEnemy()
        case .four:
            createEnemy()
            createEnemy()
            createEnemy()
            createEnemy()
        case .chain:
            createEnemy()
            
            DispatchQueue.main.asyncAfter(deadline: .now() + (chainDelay / 5.0)){[unowned self] in self.createEnemy() }
            DispatchQueue.main.asyncAfter(deadline: .now() + (chainDelay / 5.0 * 2)){[unowned self] in self.createEnemy() }
            DispatchQueue.main.asyncAfter(deadline: .now() + (chainDelay / 5.0 * 3)){[unowned self] in self.createEnemy() }
            DispatchQueue.main.asyncAfter(deadline: .now() + (chainDelay / 5.0 * 4)){[unowned self] in self.createEnemy() }
            
        case .fastChain:
            createEnemy()
            
            //If we assume for a moment that chainDelay is 10 seconds, then
                //That makes chainDelay / 10.0 equal to 1 second
                //That makes chainDelay / 10.0 * 2 equal to 2 seconds.
                //That makes chainDelay / 10.0 * 3 equal to three seconds.
                //That makes chainDelay / 10.0 * 4 equal to four seconds.
            
            DispatchQueue.main.asyncAfter(deadline: .now() + (chainDelay / 10.0)){[unowned self] in self.createEnemy() }
            DispatchQueue.main.asyncAfter(deadline: .now() + (chainDelay / 10.0 * 2)){[unowned self] in self.createEnemy() }
            DispatchQueue.main.asyncAfter(deadline: .now() + (chainDelay / 10.0 * 3)){[unowned self] in self.createEnemy() }
            DispatchQueue.main.asyncAfter(deadline: .now() + (chainDelay / 10.0 * 4)){[unowned self] in self.createEnemy() }
            
        }
        
        sequencePosition += 1
        
        nextSequenceQueued = false //The nextSequenceQueued property is more complicated. If it's false, it means we don't have a call to tossEnemies() in the pipeline waiting to execute. It gets set to true only in the gap between the previous sequence item finishing and tossEnemies() being called. Think of it as meaning, "I know there aren't any enemies right now, but more will come shortly."
    }
    
    //MARK: - LIFE PROCESSING
    func subtractLife() {
        lives -= 1
        run(SKAction.playSoundFileNamed("wrong", waitForCompletion: false))
        
        var life: SKSpriteNode
        if lives == 2 {
            life = livesImage[0]
        }else if lives == 1 {
            life = livesImage[1]
        }else{
            life = livesImage[2]
             endGame(triggeredByBomb: false)
        }
        
        life.texture = SKTexture(imageNamed: "sliceLifeGone")   // using SKTexture to modify the contents of a sprite node without having to recreate it, just like in project 14.
        life.xScale = 1.3
        life.yScale = 1.3
        life.run(SKAction.scale(to: 1, duration: 0.1))
        
        
    }
    
    //MARK: - ENDGAME PROCESSING
    func endGame(triggeredByBomb: Bool) {
        if gameEnded {
            return
        }
        
        gameEnded = true
        physicsWorld.speed = 0
        isUserInteractionEnabled = false
        
        if bombSoundEffect != nil {
            bombSoundEffect.stop()
            bombSoundEffect = nil
        }
        
        if triggeredByBomb {
            livesImage[0].texture = SKTexture(imageNamed: "sliceLifeGone")
            livesImage[1].texture = SKTexture(imageNamed: "sliceLifeGone")
            livesImage[2].texture = SKTexture(imageNamed: "sliceLifeGone")
        }
        
        if activeEnemies.count>0 {
            for node in activeEnemies {
                node.removeFromParent()
            }
            
            activeEnemies.removeAll(keepingCapacity: true)
        }
        
    }
   
}
