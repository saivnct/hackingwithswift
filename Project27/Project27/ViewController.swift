//
//  ViewController.swift
//  Project27
//
//  Created by Giang Bb on 7/28/17.
//  Copyright © 2017 Giang Bb. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    @IBOutlet weak var imgView: UIImageView!
    
    
    var currentDrawType = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        drawRectangle()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func drawRectangle() {
        
        //UIGraphicsImageRenderer class. This was introduced in iOS 10 to to allow fast and easy graphics rendering, while also quietly adding support for wide color devices like the iPad Pro. It works with closures, which might seem annoying if you’re still not comfortable with them, but has the advantage that you can build complex drawing instructions by composing functions.
        //Now, wait a minute: that class name starts with "UI", so what makes it anything to do with Core Graphics? Well, it isn’t a Core Graphics class; it’s are UIKit class, but it acts as a gateway to and from Core Graphics for UIKit-based apps like ours. You create a renderer object and start a rendering context, but everything between will be Core Graphics functions or UIKit methods that are designed to work with Core Graphics contexts.
        //In Core Graphics, a context is a canvas upon which we can draw, but it also stores information about how we want to draw (e.g., what should our line thickness be?) and information about the device we are drawing to. So, it's a combination of canvas and metadata all in one, and it's what you'll be using for all your drawing. This Core Graphics context is exposed to us when we render with UIGraphicsImageRenderer.
        //When you create a renderer, you get to specify how big it should be, whether it should be opaque or not, and what pixel to point scale you want. To kick off rendering you can either call the image() function to get back a UIImage of the results, or call the pngData() and jpegData() methods to get back a Data object in PNG or JPEG format respectively.
        
        let renderer = UIGraphicsImageRenderer(size: CGSize(width: 512, height: 512))   //we create a UIGraphicsImageRenderer with the size 512x512, leaving it with default values for scale and opacity – that means it will be the same scale as the device (e.g. 2x for retina) and transparent
        
        
        //Creating the renderer doesn’t actually start any rendering – that’s done in the image() method. This accepts a closure as its only parameter, which is code that should do all the drawing. It gets passed a single parameter that I’ve named ctx, which is a reference to a UIGraphicsImageRendererContext to draw to. This is a thin wrapper around another data type called CGContext, which is where the majority of drawing code lives.
        let img = renderer.image(){ ctx in
            //drawing code
            
            //Let's take a look at the five new methods you'll need to use to draw our box:
                //1. setFillColor() sets the fill color of our context, which is the color used on the insides of the rectangle we'll draw.
                //2. setStrokeColor() sets the stroke color of our context, which is the color used on the line around the edge of the rectangle we'll draw.
                //3. setLineWidth() adjusts the line width that will be used to stroke our rectangle. Note that the line is drawn centered on the edge of the rectangle, so a value of 10 will draw 5 points inside the rectangle and five points outside.
                //4. addRect() adds a CGRect rectangle to the context's current path to be drawn.
                //5. drawPath() draws the context's current path using the state you have configured
            //All five of those are called on the Core Graphics context that comes from ctx.cgContext, using a parameter that does the actual work. So for setting colors the parameter is the color to set (remember how to convert UIColor values to CGColor values? I hope so!), for setting the line width it's a number in points, for adding a rectangle path it's the CGRect of your rectangle, and for drawing it's a special constant that says whether you want just the fill, just the stroke, or both.
            let rectangle = CGRect(x: 0, y: 0, width: 512, height: 512)
            
            ctx.cgContext.setFillColor(UIColor.red.cgColor)
            ctx.cgContext.setStrokeColor(UIColor.black.cgColor)
            ctx.cgContext.setLineWidth(10)  //the stroke is centered on the edge of the path, meaning that a 10 point stroke is 5 points inside the path and 5 points outside.
            
            ctx.cgContext.addRect(rectangle)
            ctx.cgContext.drawPath(using: .fillStroke)
            
            
        }
        
        imgView.image = img
    }
    
    func drawCircle() {
        let renderer = UIGraphicsImageRenderer(size: CGSize(width: 512, height: 512))
        
        let img = renderer.image(){ctx in
            //the stroke is centered on the edge of the path, meaning that a 10 point stroke is 5 points inside the path and 5 points outside
            //The rectangle being used to define our circle is the same size as the whole context, meaning that it goes edge to edge – and thus the stroke gets clipped
            let rectangle = CGRect(x: 5, y: 5, width: 502, height: 502)
            
            ctx.cgContext.setFillColor(UIColor.red.cgColor)
            ctx.cgContext.setStrokeColor(UIColor.black.cgColor)
            ctx.cgContext.setLineWidth(10)
            
            ctx.cgContext.addEllipse(in: rectangle)
            ctx.cgContext.drawPath(using: .fillStroke)
        }
        
        imgView.image = img
    }
    
    
    //A different way of drawing rectangles is just to fill them directly with your target color.
    func drawCheckerboard() {
        let renderer = UIGraphicsImageRenderer(size: CGSize(width: 512, height: 512))
        
        let img = renderer.image(){ctx in
            ctx.cgContext.setFillColor(UIColor.black.cgColor)
            
            for row in 0..<8{
                for column in 0..<8{
                    if (row+column)%2 == 0{
                        ctx.cgContext.fill(CGRect(x: 64*column, y: 64*row, width: 64, height: 64))
                    }
                }
            }
        }
        
        imgView.image = img
        
        
        //another way - you can actually make checkerboards using a Core Image filter – check out CICheckerboardGenerator to see how!
    }
    
    func drawRotateSquare() {
        //This is going to demonstrate how we can apply transforms to our context before drawing, and how you can stroke a path without filling it
        //To make this happen, you need to know three new Core Graphics methods:
            //1. translateBy() translates (moves) the current transformation matrix.
            //2. rotate(by:) rotates the current transformation matrix.
            //3. strokePath() strokes the path with your specified line width, which is 1 if you don't set it explicitly.
        //The current transformation matrix is very similar to those CGAffineTransform modifications we used in project 15, except its application is a little different in Core Graphics. In UIKit, you rotate drawing around the center of your view, as if a pin was stuck right through the middle. In Core Graphics, you rotate around the top-left corner, so to avoid that we're going to move the transformation matrix half way into our image first so that we've effectively moved the rotation point.
        //This also means we need to draw our rotated squares so they are centered on our center: for example, setting their top and left coordinates to be -128 and their width and height to be 256.
        
        let renderer = UIGraphicsImageRenderer(size: CGSize(width: 512, height: 512))
        
        let img = renderer.image(){ctx in
            ctx.cgContext.translateBy(x: 256, y: 256)
            let rotation = 16
            let amount = Double.pi/Double(rotation)
            
            for _ in 0 ..< rotation {
                ctx.cgContext.rotate(by: CGFloat(amount))
                ctx.cgContext.addRect(CGRect(x: -128, y: -128, width: 256, height: 256))
            }
            
            ctx.cgContext.setStrokeColor(UIColor.black.cgColor)
            ctx.cgContext.strokePath()
        }
        
        imgView.image = img
    }
    
    func drawLines() {
        //I'm going to make this translate and rotate the CTM again, although this time the rotation will always be 90 degrees. This method is going to draw boxes inside boxes, always getting smaller, like a square spiral. It's going to do this by adding a line to more or less the same point inside a loop, but each time the loop rotates the CTM so the actual point the line ends has moved too. It will also slowly decrease the line length, causing the space between boxes to shrink like a spiral
        let renderer = UIGraphicsImageRenderer(size: CGSize(width: 512, height: 512))
        
        let img = renderer.image(){ctx in
            ctx.cgContext.translateBy(x: 256, y: 256)
            
            var first = true
            var length: CGFloat = 256
            
            for _ in 0 ..< 256 {
                ctx.cgContext.rotate(by: CGFloat.pi/2)
                
                if first {
                    ctx.cgContext.move(to: CGPoint(x: length, y: 50))
                    first = false
                }else{
                    ctx.cgContext.addLine(to: CGPoint(x: length, y: 50))
                }
                length *= 0.99
            }
            
            ctx.cgContext.setStrokeColor(UIColor.black.cgColor)
            ctx.cgContext.strokePath()
            
        }
        
        imgView.image = img
    }
    
    func drawImageAndText() {
        //If you have a string in Swift, how can you place it into a graphic? The answer is simpler than you think: all strings have a built-in method called draw(with:) that draws the string in a rectangle you specify. Even better, you get to customize the font and size, the formatting, the line wrapping and more all with that one method.
        //Remarkably, the same is true of UIImage: any image can be drawn straight to a context, and it will even take into account the coordinate reversal of Core Graphics.
        //before you're able to draw a string to the screen, you need to meet two more classes: UIFont and NSMutableParagraphStyle(). The former defines a font name and size, e.g. Helvetica Neue size 26, and the latter is used to describe paragraph formatting options, such as line height, indents and alignment.
        //When you draw a string to the screen, you do using a dictionary of attributes that describes all the options you want to apply. We want to apply a custom font and custom paragraph style – that bit is easy enough. But the keys for the dictionary are special Apple constants: NSFontAttributeName and NSParagraphStyleAttributeName
        
        //1. Create a renderer at the correct size.
        //2. Define a paragraph style that aligns text to the center.
        //3. Create an attributes dictionary containing that paragraph style, and also a font.
        //4. Draw a string to the screen using the attributes dictionary.
        //5. Load an image from the project and draw it to the context.
        //6. Update the image view with the finished result.
        
        //1
        let renderer = UIGraphicsImageRenderer(size: CGSize(width: 512, height: 512))
        
        let img = renderer.image(){ ctx in
            //2
            let paragraphStyle = NSMutableParagraphStyle()
            paragraphStyle.alignment = .center
            
            //3
            let attrs = [NSFontAttributeName: UIFont(name: "HelveticaNeue-Thin", size: 36), NSParagraphStyleAttributeName: paragraphStyle]
            
            //4
            let mystring: NSString = "Demo image of the mouse"
            mystring.draw(with: CGRect(x: 32, y: 32, width: 448, height: 448), options: .usesLineFragmentOrigin, attributes: attrs, context: nil)
            
            //5
            let mouse = UIImage(named: "mouse")
            mouse?.draw(at: CGPoint(x: 300, y: 150))
            
        }
        
        //6
        imgView.image = img
    }

    @IBAction func redrawTapped(_ sender: UIButton) {
        currentDrawType += 1
        if currentDrawType > 5 {
            currentDrawType = 0
        }
        
        switch currentDrawType {
        case 0:
            drawRectangle()
            break
        case 1:
            drawCircle()
            break
        case 2:
            drawCheckerboard()
        case 3:
            drawRotateSquare()
            break
        case 4:
            drawLines()
            break
        case 5:
            drawImageAndText()
            break
        default:
            break
        }
    }
    
    
}

