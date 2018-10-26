//
//  BuildingNode.swift
//  Project29
//
//  Created by Giang Bb on 9/7/17.
//  Copyright © 2017 Giang Bb. All rights reserved.
//
import SpriteKit
import UIKit

import GameplayKit      //As we need to generate random numbers,

class BuildingNode: SKSpriteNode {
        //Initially, this class needs to have three methods:
            //setup() will do the basic work required to make this thing a building: setting its name, texture, and physics
            //configurePhysics() will set up per-pixel physics for the sprite's current texture.
            //configurePhysics() will set up per-pixel physics for the sprite's current texture.
    
    var currentImage: UIImage!
    
    func setup() {
        name = "building"
        
        currentImage = drawBuilding(size: size)
        texture = SKTexture(image: currentImage)
        
        configurePhysics()
        
    }
    
    func configurePhysics() {
        physicsBody = SKPhysicsBody(texture: texture!, size: size)
        physicsBody!.isDynamic = false
        physicsBody!.categoryBitMask = CollisionTypes.building.rawValue
        physicsBody!.contactTestBitMask = CollisionTypes.banana.rawValue
    }
    
    
    //using Core Graphics in projectt 27
    func drawBuilding(size: CGSize) -> UIImage {
        //This method needs to:
            //1 - Create a new Core Graphics context the size of our building.
            //2 - Fill it with a rectangle that's one of three colors.
            //3 - Draw windows all over the building in one of two colors: there's either a light on (yellow) or not (gray).
            //4 - Pull out the result as a UIImage and return it for use elsewhere
        //I'm going to introduce a new way to create colors: hue, saturation and brightness, or HSB. Using this method of creating colors you specify values between 0 and 1 to control how saturated a color is (from 0 = gray to 1 = pure color) and brightness (from 0 = black to 1 = maximum brightness), and 0 to 1 for hue."Hue" is a value from 0 to 1 also, but it represents a position on a color wheel, like using a color picker on your Mac. Hues 0 and 1 both represent red, with all other colors lying in between.
        //Now, programmers often look at HSB and think it's much clumsier than straight RGB, but there are reasons for both. The helpful thing about HSB is that if you keep the saturation and brightness constant, changing the hue value will cycle through all possible colors – it's an easy way to generate matching pastel colors, for example.
        //1
        let renderer = UIGraphicsImageRenderer(size: size)
        let img = renderer.image { ctx in
            //2
            let rectangle = CGRect(x: 0, y: 0, width: size.width, height: size.height)
            var color: UIColor
            
            switch GKRandomSource.sharedRandom().nextInt(upperBound: 3) {
            case 0:
                color = UIColor(hue: 0.502, saturation: 0.98, brightness: 0.67, alpha: 1)
            case 1:
                color = UIColor(hue: 0.999, saturation: 0.99, brightness: 0.67, alpha: 1)
            default:
                color = UIColor(hue: 0, saturation: 0, brightness: 0.67, alpha: 1)
            }
            
            ctx.cgContext.setFillColor(color.cgColor)
            ctx.cgContext.addRect(rectangle)
            ctx.cgContext.drawPath(using: .fill)
            
            //3
            let lightOnColor = UIColor(hue: 0.190, saturation: 0.67, brightness: 0.99, alpha: 1)
            let lightOffColor = UIColor(hue: 0, saturation: 0, brightness: 0.34, alpha: 1)
            
            
            //stride(), which lets you loop from one number to another with a specific interval
            for row in stride(from: 10, to: Int(size.height - 10), by: 40){  //That means "count from 10 up to the height of the building minus 10, in intervals of 40." So, it will go 10, 50, 90, 130, and so on. Note that stride() has two variants: stride(from:to:by:) and stride(from:through:by). The first counts up to but excluding the to parameter, whereas the second counts up to and including the through parameter.
                
                for col in stride(from: 10, to: Int(size.width - 10), by: 40){
                    if RandomInt(min: 0, max: 1) == 0 {
                        ctx.cgContext.setFillColor(lightOnColor.cgColor)
                    }else{
                        ctx.cgContext.setFillColor(lightOffColor.cgColor)
                    }
                    
                    ctx.cgContext.fill(CGRect(x: col, y: row, width: 15, height: 20))   //The only thing new in there – and it's so tiny you probably didn't even notice – is use of .fill rather than .stroke to draw the rectangles. Using what you learned in project 27, can you think of another way of doing this? (Hint: have a look at the way the windows are drawn!)
                }
            }
            
            //4
        }
        
        return img
    }
    
    func hitAt(point: CGPoint)  {
        //And now for the part where we handle destroying chunks of the building. With your current knowledge of Core Graphics, this is something you can do by learning only one new thing: blend modes. When you draw anything to a Core Graphics context, you can set how it should be drawn. For example, should it be be drawn normally, or should it add to what's there to create a combination?
        //Core Graphics has quite a few blend modes that might look similar, but we're going to use one called .clear, which means "delete whatever is there already." When combined with the fact that we already have a property called currentImage you might be able to see how our destructible terrain technique will work!
        //Put simply, when we create the building we save its UIImage to a property of the BuildingNode class. When we want to destroy part of the building, we draw that image into a new context, draw an ellipse using .clear to blast a hole, then save that back to our currentImage property and update our sprite's texture.
        
        
        //Here's a full break down of what the method needs to do:
            //1. Figure out where the building was hit. Remember: SpriteKit's positions things from the center and Core Graphics from the bottom left!
            //2. Create a new Core Graphics context the size of our current sprite.
            //3. Draw our current building image into the context. This will be the full building to begin with, but it will change when hit.
            //4. Create an ellipse at the collision point. The exact co-ordinates will be 32 points up and to the left of the collision, then 64x64 in size - an ellipse centered on the impact point
            //5. Set the blend mode .clear then draw the ellipse, literally cutting an ellipse out of our image.
            //6. Convert the contents of the Core Graphics context back to a UIImage, which is saved in the currentImage property for next time we're hit, and used to update our building texture
            //7. Call configurePhysics() again so that SpriteKit will recalculate the per-pixel physics for our damaged building
        
        let convertedPoint = CGPoint(x: point.x + size.width / 2, y: abs(point.y - (size.height / 2)))
        
        let renderer = UIGraphicsImageRenderer(size: size)
        
        let img = renderer.image { ctx in
            currentImage.draw(at: CGPoint(x: 0, y: 0))
            
            ctx.cgContext.addEllipse(in: CGRect(x: convertedPoint.x - 32, y: convertedPoint.y - 32, width: 64, height: 64))
            ctx.cgContext.setBlendMode(.clear)
            ctx.cgContext.drawPath(using: .fill)
            
        }
        
        texture = SKTexture(image: img)
        currentImage = img
        
        configurePhysics()
        
    }

}
