//
//  GameScene.swift
//  Project14
//
//  Created by Giang Bui Binh on 7/3/17.
//  Copyright © 2017 giangbb. All rights reserved.
//

import SpriteKit
import GameplayKit

class GameScene: SKScene {
    
    var gameScore: SKLabelNode!
    var score: Int = 0 {
        didSet {
            gameScore.text = "Score \(score)"
        }
    }
    
    var slots = [WhackSlot]()
    
    //The show() method is going to be triggered by the view controller on a recurring basis, managed by a property we're going to create called popupTime. This will start at 0.85 (create a new enemy a bit faster than once a second), but every time we create an enemy we'll also decrease popupTime so that the game gets harder over time.
    var popupTime = 0.85
    
    
    //when popupTime gets so low that the game is effectively unplayable
    //To fix this final problem and bring the project to a close, we're going to limit the game to creating just 30 rounds of enemies
    var numberRound = 0
    
    
    override func didMove(to view: SKView) {
        let background = SKSpriteNode(imageNamed: "whackBackground")
        background.position = CGPoint(x: 512, y: 384)
        background.blendMode = .replace
        background.zPosition = -1
        addChild(background)
        
        gameScore = SKLabelNode(fontNamed: "Chalkduster")
        gameScore.text = "Score \(score)"
        gameScore.position = CGPoint(x: 8, y: 8)
        gameScore.horizontalAlignmentMode = .left
        gameScore.fontSize = 48
        addChild(gameScore)
        
        for i in 0..<5 {
            createSlot(at: CGPoint(x: 100 + (i*170), y: 410))
        }
        
        for i in 0..<4 {
            createSlot(at: CGPoint(x: 180 + (i*170), y: 320))
        }
        
        for i in 0..<5 {
            createSlot(at: CGPoint(x: 100 + (i*170), y: 230))
        }
        
        for i in 0..<4 {
            createSlot(at: CGPoint(x: 180 + (i*170), y: 140))
        }
        
        createEnemy()
        
    }
    
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        if let touch = touches.first {
            let location = touch.location(in: self)
            let tappedNode = nodes(at: location)
            
            for node in tappedNode{
                if node.name == "charFriend" {
                    let whackSlot = node.parent!.parent as! WhackSlot //It gets the parent of the parent of the node, and typecasts it as a WhackSlot. This line is needed because the player has tapped the penguin sprite node, not the slot – we need to get the parent of the penguin, which is the crop node it sits inside, then get the parent of the crop node, which is the WhackSlot object, which is what this code does.
                    if !whackSlot.isVisible {
                        continue
                    }
                    if whackSlot.isHit{
                        continue
                    }
                    
                    whackSlot.hit()
                    
                    score -= 5
                    
                    run(SKAction.playSoundFileNamed("whackBad.caf", waitForCompletion: false))
                    
                }else if node.name == "charEnemy" {
                    let whackSlot = node.parent!.parent as! WhackSlot //It gets the parent of the parent of the node, and typecasts it as a WhackSlot. This line is needed because the player has tapped the penguin sprite node, not the slot – we need to get the parent of the penguin, which is the crop node it sits inside, then get the parent of the crop node, which is the WhackSlot object, which is what this code does.
                    if !whackSlot.isVisible {
                        continue
                    }
                    if whackSlot.isHit{
                        continue
                    }
                    whackSlot.charNode.xScale = 0.85
                    whackSlot.charNode.yScale = 0.85
                    
                    whackSlot.hit()
                    
                    score += 1
                    
                    run(SKAction.playSoundFileNamed("whack.caf", waitForCompletion: false))
                }
            }
        }
    }
    
    
    //MARK: - process slot
    func createSlot(at position: CGPoint) {
        let slot = WhackSlot()
        slot.configure(at: position)
        addChild(slot)
        slots.append(slot)
    }
    
    
    //Decrease popupTime each time it's called. I'm going to multiply it by 0.991 rather than subtracting a fixed amount, otherwise the game gets far too fast.
//    Shuffle the list of available slots using the GameplayKit shuffle that we've used previously.
//    Make the first slot show itself, passing in the current value of popupTime for the method to use later.
//    Generate four random numbers to see if more slots should be shown. Potentially up to five slots could be shown at once.
//    Call itself again after a random delay. The delay will be between popupTime halved and popupTime doubled. For example, if popupTime was 2, the random number would be between 1 and 4.
    func createEnemy() {
        numberRound += 1
        if (numberRound>30){
            for slot in slots{
                slot.hide()
            }
            
            let gameOver = SKSpriteNode(imageNamed: "gameOver")
            gameOver.position = CGPoint(x: 512, y: 384)
            gameOver.zPosition = 1
            addChild(gameOver)
            
            return
        }
        
        popupTime *= 0.991
        
        slots = GKRandomSource.sharedRandom().arrayByShufflingObjects(in: slots) as! [WhackSlot]
        slots[0].show(hideTime: popupTime)
        
        if RandomInt(min: 0, max: 12) > 4 {
            slots[1].show(hideTime: popupTime)
        }
        if RandomInt(min: 0, max: 12) > 8 {
            slots[2].show(hideTime: popupTime)
        }
        
        if RandomInt(min: 0, max: 12) > 10 {
            slots[3].show(hideTime: popupTime)
        }
        if RandomInt(min: 0, max: 12) > 11 {
            slots[4].show(hideTime: popupTime)
        }
        
        let minDelay = popupTime / 2.0
        let maxDelay = popupTime * 2
        let delay = RandomDouble(min: minDelay, max: maxDelay)
        
        
        //Because createEnemy() calls itself, all we have to do is call it once in didMove(to: ) after a brief delay
        DispatchQueue.main.asyncAfter(deadline: .now() + delay){ [unowned self] in
            self.createEnemy()
        }
    }
    
}
