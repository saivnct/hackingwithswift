//
//  SelectionViewController.swift
//  Project30
//
//  Created by TwoStraws on 20/08/2016.
//  Copyright (c) 2016 TwoStraws. All rights reserved.
//

import GameplayKit
import UIKit

class SelectionViewController: UITableViewController {
	var items = [String]() // this is the array that will store the filenames to load
	
	var dirty = false

    override func viewDidLoad() {
        super.viewDidLoad()

		title = "Reactionist"

		tableView.rowHeight = 90
		tableView.separatorStyle = .none

		// load all the JPEGs into our array
		let fm = FileManager.default

		if let tempItems = try? fm.contentsOfDirectory(atPath: Bundle.main.resourcePath!) {
			for item in tempItems {
				if item.range(of: "Large") != nil {
					items.append(item)
				}
			}
		}
    }

	override func viewWillAppear(_ animated: Bool) {
		super.viewWillAppear(animated)

		if dirty {
			// we've been marked as needing a counter reload, so reload the whole table
			tableView.reloadData()
		}
	}

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

	override func numberOfSections(in tableView: UITableView) -> Int {
        // Return the number of sections.
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // Return the number of rows in the section.
        return items.count * 10
    }


    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        //The allocations instrument will tell you how many of these objects are persistent (created and still exist) and how many are transient (created and since destroyed). Notice how just swiping around has created a large number of transient UIImageView and UITableViewCell objects?
        //This is happening because each time the app needs to show a cell, it creates it then creates all the subviews inside it – namely an image view and a label, plus some hidden views we don’t usually care about. iOS works around this cost by using the method dequeueReusableCell(withIdentifier:)
        var cell = tableView.dequeueReusableCell(withIdentifier: "Cell")
        if cell == nil {
            cell = UITableViewCell(style: .default, reuseIdentifier: "Cell")
        }
        
//        let cell = UITableViewCell(style: .default, reuseIdentifier: "Cell")
        
        //The other solution you could use is to register a class with the table view for the reuse identifier "Cell". Using this method you could leave the original line of code as-is, but add this to viewDidLoad():
        //tableView.register(UITableViewCell.self, forCellReuseIdentifier: "Cell")
        
        //new other solution
//        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        

		// find the image for this cell, and load its thumbnail
		let currentImage = items[indexPath.row % items.count]
		let imageRootName = currentImage.replacingOccurrences(of: "Large", with: "Thumb")
		let path = Bundle.main.path(forResource: imageRootName, ofType: nil)!
		let original = UIImage(contentsOfFile: path)!

        
        //The problem is that the images being loaded are 750x750 pixels at 1x resolution, so 1500x1500 at 2x and 2250x2250 at 3x. If you look at viewDidLoad() you’ll see that the row height is 90 points, so we’re loading huge pictures into a tiny space. On iPhone 7, that means loading a 1500x1500 image, creating a second render buffer that size, rendering the image into it, and so on.
        //Clearly those images don’t need to be anything like that size, but sometimes you don’t have control over it. In this app you might be able to go back to the original designer and ask them to provide smaller assets, or if you were feeling ready for a fight you could resize them yourself, but what if you had fetched these assets from a remote server? And wait until you see the size of the images in the detail view – those images might only take up 500KB on disk, but when they are uncompressed by iOS they’ll need around 45 MB of RAM!
        let renderRect = CGRect(origin: CGPoint.zero, size: CGSize(width: 90, height: 90))
        
        
		let renderer = UIGraphicsImageRenderer(size: renderRect.size)

		let rounded = renderer.image { ctx in
			ctx.cgContext.addEllipse(in: renderRect)
			ctx.cgContext.clip()    //As you know, you can create a path and draw it using two separate Core Graphics commands, but instead of running the draw command you can take the existing path and use it for clipping instead. This has the effect of only drawing things that lie inside the path, so when the UIImage is drawn only the parts that lie inside the elliptical clipping path are visible, thus rounding the corners

			original.draw(in: renderRect)
		}

		cell!.imageView?.image = rounded

		// give the images a nice shadow to make them look a bit more dramatic
		cell!.imageView?.layer.shadowColor = UIColor.black.cgColor
		cell!.imageView?.layer.shadowOpacity = 1
		cell!.imageView?.layer.shadowRadius = 10
		cell!.imageView?.layer.shadowOffset = CGSize.zero
        cell!.imageView?.layer.shadowPath = UIBezierPath(ovalIn: CGRect(x: 0, y: 0, width: 90, height: 90)).cgPath   //We can tell iOS not to automatically calculate the shadow path for our images (take lot of calculating) by giving it the exact shadow path to use. The easiest way to do this is to create a new UIBezierPath that describes our image (an ellipse with width 90 and height 90), then convert it to a CGPath because CALayer doesn't understand what UIBezierPath is

		// each image stores how often it's been tapped
		let defaults = UserDefaults.standard
		cell!.textLabel?.text = "\(defaults.integer(forKey: currentImage))"

		return cell!
    }

	override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
		let vc = ImageViewController()
		vc.image = items[indexPath.row % items.count]
		vc.owner = self

		// mark us as not needing a counter reload when we return
		dirty = false

		// add to our view controller cache and show
		navigationController!.pushViewController(vc, animated: true)
	}
}
