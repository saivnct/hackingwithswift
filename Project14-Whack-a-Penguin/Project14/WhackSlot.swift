//
//  WhackSlot.swift
//  Project14
//
//  Created by Giang Bui Binh on 7/3/17.
//  Copyright © 2017 giangbb. All rights reserved.
//

import UIKit
import SpriteKit
//We want each hole to do as much work itself as possible, so rather than clutter our game scene with code we're going to create a subclass of SKNode that will encapsulate all hole related functionality.

//You've already met SKSpriteNode, SKLabelNode and SKEmitterNode, and they all come from SKNode. This base class doesn't draw images like sprites or hold text like labels; it just sits in our scene at a position, holding other nodes as children.
class WhackSlot: SKNode {
    
    //add a property to this class in which we'll store the penguin picture node:
    var charNode: SKSpriteNode!
    
    //The two things a slot needs to know are "am I currently visible to be whacked by the player?" and "have I already been hit?" The former avoids players tapping on slots that are supposed to be invisible; the latter so that players can't whack a penguin more than once
    var isVisible = false
    var isHit = false
    
   
    
    //You might wonder why we aren't using an initializer for this purpose, but the truth is that if you created a custom initializer you get roped into creating others because of Swift's required init rules. If you don't create any custom initializers (and don't have any non-optional properties) Swift will just use the parent class's init() methods.
    
    
    func configure(at position: CGPoint) {
        self.position = position
        let sprite = SKSpriteNode(imageNamed: "whackHole")
        addChild(sprite)
        
        
        //SKCropNode. This is a special kind of SKNode subclass that uses an image as a cropping mask: anything in the colored part will be visible, anything in the transparent part will be invisible
        //By default, nodes don't crop, they just form part of a node tree. The reason we need the crop node is to hide our penguins: we need to give the impression that they are inside the holes, sliding out for the player to whack, and the easiest way to do that is just to have a crop mask shaped like the hole that makes the penguin invisible when it moves outside the mask
        //The easiest way to demonstrate the need for SKCropNode is to give it a nil mask – this will effectively stop the crop node from doing anything, thus allowing you to see the trick behind our game.
        let cropNode = SKCropNode()
        cropNode.position = CGPoint(x: 0, y: 15)    //we create a new SKCropNode and position it slightly higher than the slot itself. The number 15 isn't random – it's the exact number of points required to make the crop node line up perfectly with the hole graphics. We also give the crop node a zPosition value of 1, putting it to the front of other nodes, which stops it from appearing behind the hole
        cropNode.zPosition = 1
        cropNode.maskNode = SKSpriteNode(imageNamed: "whackMask") //Remember, with crop nodes everything with a color is visible, and everything transparent is invisible, so the whackMask.png will show all parts of the character that are above the hole
        
        charNode = SKSpriteNode(imageNamed: "penguinGood")
        charNode.position = CGPoint(x: 0, y: -90)
        charNode.name = "character"
        cropNode.addChild(charNode)
        // the character node is added to the crop node, and the crop node added to the slot. This is because the crop node only crops nodes that are inside it, so we need to have a clear hierarchy: the slot has the hole and crop node as children, and the crop node has the character node as a child.
        
        addChild(cropNode)
        
    }
    
    //The show() method is going to be triggered by the view controller on a recurring basis, managed by a property we created called popupTime
    func show(hideTime: Double) {
        if isVisible{
            return
        }
        charNode.xScale = 1
        charNode.yScale = 1
        
        charNode.run(SKAction.moveBy(x: 0, y: 80, duration: 0.05))
        isVisible = true
        isHit = false
        
        if RandomInt(min: 0, max: 2) == 0 {
            charNode.texture = SKTexture(imageNamed: "penguinGood")
            charNode.name="charFriend"
        }else{
            charNode.texture = SKTexture(imageNamed: "penguinEvil")
            charNode.name="charEnemy"
        }
        
        
        //We want to trigger this method automatically after a period of time, and, through extensive testing (that is, sitting around playing) I have determined the optimal hide time to be 3.5x popupTime.
        DispatchQueue.main.asyncAfter(deadline: .now() + (hideTime * 3.5)){ [unowned self] in
            self.hide()
        }
        
    }
    
    func hide() {
        if !isVisible {
            return
        }
        
        charNode.run(SKAction.moveBy(x: 0, y: -80, duration: 0.05))
        isVisible = false
    }
    
    func hit() {
        isHit = true
        
        let delay = SKAction.wait(forDuration: 0.25)
        let hide = SKAction.moveBy(x: 0, y: -80, duration: 0.5)
        let notVisible = SKAction.run { [unowned self] in
            self.isVisible = false;
        }
        
        charNode.run(SKAction.sequence([delay, hide, notVisible]))
        
    }
}
