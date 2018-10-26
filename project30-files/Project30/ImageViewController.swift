//
//  ImageViewController.swift
//  Project30
//
//  Created by TwoStraws on 20/08/2016.
//  Copyright (c) 2016 TwoStraws. All rights reserved.
//

import UIKit

class ImageViewController: UIViewController {
	//if The ImageViewController has a property var owner: SelectionViewController! – that makes it a strong reference to the view controller that created it -> ImageViewController cannot be destroyed
    weak var owner: SelectionViewController!
    
	var image: String!
	var animTimer: Timer!

	var imageView: UIImageView!

	override func loadView() {
		super.loadView()
		
		view.backgroundColor = UIColor.black

		// create an image view that fills the screen
		imageView = UIImageView()
		imageView.contentMode = .scaleAspectFit
		imageView.translatesAutoresizingMaskIntoConstraints = false
		imageView.alpha = 0

		view.addSubview(imageView)

		// make the image view fill the screen
		imageView.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
		imageView.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
		imageView.topAnchor.constraint(equalTo: topLayoutGuide.bottomAnchor).isActive = true
		imageView.bottomAnchor.constraint(equalTo: bottomLayoutGuide.topAnchor).isActive = true

		// schedule an animation that does something vaguely interesting
		animTimer = Timer.scheduledTimer(withTimeInterval: 5, repeats: true) { timer in
			// do something exciting with our image
			self.imageView.transform = CGAffineTransform.identity

			UIView.animate(withDuration: 3) {
				self.imageView.transform = CGAffineTransform(scaleX: 0.8, y: 0.8)
			}
		}
	}

    override func viewDidLoad() {
        super.viewDidLoad()

		title = image.replacingOccurrences(of: "-Large.jpg", with: "")
        
        //When you create a UIImage using UIImage(named:) iOS loads the image and puts it into an image cache for reuse later. This is sometimes helpful, particularly if you know the image will be used again. But if you know it's unlikely to be reused or if it's quite large, then don't bother putting it into the cache – it will just add memory pressure to your app and probably flush out other more useful images!
//		let original = UIImage(named: image)!
        
        //so we can skip the image cache by creating our images using the UIImage(contentsOfFile:) initializer instead. This isn't as friendly as UIImage(named:) because you need to specify the exact path to an image rather than just its filename in your app bundle, but you already know how to use path(forResource:) so it's not so hard
        let path = Bundle.main.path(forResource: image, ofType: nil)!
        let original = UIImage(contentsOfFile: path)!

		let renderer = UIGraphicsImageRenderer(size: original.size)

		let rounded = renderer.image { ctx in
			ctx.cgContext.addEllipse(in: CGRect(origin: CGPoint.zero, size: original.size))
			ctx.cgContext.closePath()

			original.draw(at: CGPoint.zero)
		}

		imageView.image = rounded
    }

	override func viewDidAppear(_ animated: Bool) {
		super.viewDidAppear(animated)

		imageView.alpha = 0

		UIView.animate(withDuration: 3) { [unowned self] in
			self.imageView.alpha = 1
		}
	}

	override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
		let defaults = UserDefaults.standard
		var currentVal = defaults.integer(forKey: image)
		currentVal += 1

		defaults.set(currentVal, forKey:image)

		// tell the parent view controller that it should refresh its table counters when we go back
		owner.dirty = true
	}
    
    override func viewWillDisappear(_ animated: Bool) {
        //when you specify a target for your timer (what object should be told when the timer is up), the timer holds a strong reference to it so that it's definitely there when the timer is up. We're using self for the target, which means our view controller owns the timer strongly and the timer owns the view controller strongly, so we have a strong reference cycle
        super.viewWillDisappear(animated)
        animTimer.invalidate()
        
    }

}
