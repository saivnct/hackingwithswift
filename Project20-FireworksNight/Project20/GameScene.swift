//
//  GameScene.swift
//  Project20
//
//  Created by Giang Bb on 7/14/17.
//  Copyright © 2017 Giang Bb. All rights reserved.
//

import SpriteKit
import GameplayKit

class GameScene: SKScene {
    
    //use this to call the launchFireworks() method every six seconds
    var gameTimer: Timer!
    
    var fireworks = [SKNode]()
    
    var scoreLabel: SKLabelNode!
    
    let leftEdge = -22
    let rightEdge = 1024+22
    let bottomEdge = -22
    
    var score: Int = 0{
        didSet{
            scoreLabel!.text = "Score: \(score)"
        }
    }
    
    
    override func didMove(to view: SKView) {
        
        let background = SKSpriteNode(imageNamed: "background")
        background.zPosition = -1
        background.blendMode = .replace
        background.position = CGPoint(x: 512, y: 384)
        addChild(background)
        
        scoreLabel = SKLabelNode(fontNamed: "Chalkduster")
        scoreLabel.fontSize = 48
        scoreLabel.position = CGPoint(x: 10, y: 720)
        scoreLabel.horizontalAlignmentMode = .left
        scoreLabel.text = "Score: 0"
        addChild(scoreLabel)
        
        //When you create an Timer you specify five parameters: how many seconds you want the delay to be, what object should be told when the timer fires, what method should be called on that object when the timer fires, any context you want to provide, and whether the time should repeat.
        gameTimer = Timer.scheduledTimer(timeInterval: 6, target: self, selector: #selector(lauchFireworks), userInfo: nil, repeats: true)
        
        
    }
    
    func lauchFireworks() {
        let movementAmout: CGFloat = 1800
        
        switch RandomInt(min: 0, max: 3) {
        case 0:
            createFirework(xMovement: 0, x: 512, y: bottomEdge)
            createFirework(xMovement: 0, x: 512-200, y: bottomEdge)
            createFirework(xMovement: 0, x: 512-100, y: bottomEdge)
            createFirework(xMovement: 0, x: 512+100, y: bottomEdge)
            createFirework(xMovement: 0, x: 512+200, y: bottomEdge)
            break
        case 1:
            createFirework(xMovement: 0, x: 512, y: bottomEdge)
            createFirework(xMovement: -200, x: 512-200, y: bottomEdge)
            createFirework(xMovement: -100, x: 512-100, y: bottomEdge)
            createFirework(xMovement: 100, x: 512+100, y: bottomEdge)
            createFirework(xMovement: 200, x: 512+200, y: bottomEdge)
            break
        case 2:
            createFirework(xMovement: movementAmout, x: leftEdge, y: bottomEdge)
            createFirework(xMovement: movementAmout, x: leftEdge, y: bottomEdge+100)
            createFirework(xMovement: movementAmout, x: leftEdge, y: bottomEdge+200)
            createFirework(xMovement: movementAmout, x: leftEdge, y: bottomEdge+300)
            createFirework(xMovement: movementAmout, x: leftEdge, y: bottomEdge+400)
            break

        case 3:
            createFirework(xMovement: -movementAmout, x: rightEdge, y: bottomEdge)
            createFirework(xMovement: -movementAmout, x: rightEdge, y: bottomEdge+100)
            createFirework(xMovement: -movementAmout, x: rightEdge, y: bottomEdge+200)
            createFirework(xMovement: -movementAmout, x: rightEdge, y: bottomEdge+300)
            createFirework(xMovement: -movementAmout, x: rightEdge, y: bottomEdge+400)
            break
            
        default:
            break
        }
        
        
    }
    
    //createFirework() method. This needs to accept three parameters: the X movement speed of the firework, plus X and Y positions for creation
    func createFirework(xMovement: CGFloat, x: Int, y: Int){
        //1- Create an SKNode that will act as the firework container, and place it at the position that was specified.
        //2- Create a rocket sprite node, give it the name "firework" so we know that it's the important thing, then add it to the container node
        //3- Give the firework sprite node one of three random colors: cyan, green or red. I've chosen cyan because pure blue isn't particularly visible on a starry sky background picture.
        //4- Create a UIBezierPath that will represent the movement of the firework.
        //5- Tell the container node to follow that path, turning itself as needed.
        //6- Create particles behind the rocket to make it look like the fireworks are lit.
        //7- Add the firework to our fireworks array and also to the scene.
        
        //1
        let node = SKNode()
        node.position = CGPoint(x: x, y: y)
        
        //2
        let firework = SKSpriteNode(imageNamed: "rocket")
        firework.name = "firework"
        node.addChild(firework)
        
        //3
        switch RandomInt(min: 0, max: 2) {
        case 0:
            // our rocket image is actually white, but by giving it .cyan with colorBlendFactor set to 1 (use the new color exclusively) it will appear cyan
            firework.color = .cyan
            firework.colorBlendFactor = 1
            break
        case 1:
            firework.color = .green
            firework.colorBlendFactor = 1
        case 2:
            firework.color = .red
            firework.colorBlendFactor = 1
        default:
            break
        }
        
        //4
        let path = UIBezierPath()
        path.move(to: CGPoint(x: 0, y: 0))
        path.addLine(to: CGPoint(x: xMovement, y: 1000))
        
        //5
        //follow(). This takes a CGPath as its first parameter (we'll pull this from the UIBezierPath) and makes the node move along that path. It doesn't have to be a straight line like we're using, any bezier path is fine
        //If you specify "asOffset" as true, it means any coordinates in your path are adjusted to take into account the node's position // lay toa do cua node lam goc
        //"orientToPath" makes a complicated task into an easy one. When it's set to true, the node will automatically rotate itself as it moves on the path so that it's always facing down the path
        let move = SKAction.follow(path.cgPath, asOffset: true, orientToPath: true, speed: 100)
        node.run(move)
        
        //6
        let emitter = SKEmitterNode(fileNamed: "fuse")!
        emitter.position = CGPoint(x: 0, y: -22)
        node.addChild(emitter)
        
        //7
        fireworks.append(node)
        addChild(node)
        
    }
    
    
    func explode(parent: SKNode) {
        let emitter = SKEmitterNode(fileNamed: "explode")!
        emitter.position = parent.position
        addChild(emitter)
        
        parent.removeFromParent()
    }
    
    func explodeFireworks() {
        var numExploded = 0
        
        for (index, parent) in fireworks.enumerated().reversed() {
            let firework = parent.children[0] as! SKSpriteNode
            if firework.name == "selected" {
                explode(parent: parent)
                fireworks.remove(at: index)
                numExploded += 1
            }
        }
        
        switch numExploded {
        case 0:
            //nothing - rubbish
            break
        case 1:
            score += 200
            break
        case 2:
            score += 500
            break
        case 3:
            score += 1500
            break
        case 4:
            score += 2500
            break
        default:
            score += 4000
            break
        }
    }
    
    
    //MARK: - touch Handler
    func checkTouches(_ touches: Set<UITouch>) {
        guard let touch = touches.first else {return}
        
        let location = touch.location(in: self)
        let nodesAtPoint = nodes(at: location)
        
        for node in nodesAtPoint {
            if node is SKSpriteNode {
                let sprite = node as! SKSpriteNode
                if sprite.name == "firework"{
                    sprite.name = "selected"
                    sprite.colorBlendFactor = 0
                    for parent in fireworks {
                        let firework = parent.children[0] as! SKSpriteNode
                        if firework.name == "selected" && firework.color != sprite.color{
                            firework.name = "firework"
                            firework.colorBlendFactor = 1
                        }
                    }
                }
            }
        }
        
        
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
       super.touchesBegan(touches, with: event)
        
        checkTouches(touches)
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesMoved(touches, with: event)
        
        checkTouches(touches)
    }
    
    
    override func update(_ currentTime: TimeInterval) {
        // Called before each frame is rendered
        for (index, parent) in fireworks.enumerated().reversed() {
            let firework = parent.children[0] as! SKSpriteNode
            let y = firework.position.y
            if y>900 {
                fireworks.remove(at: index)
                firework.removeFromParent()
            }
        }
    }
}
