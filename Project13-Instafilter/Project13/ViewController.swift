//
//  ViewController.swift
//  Project13
//
//  Created by Giang Bb on 7/1/17.
//  Copyright © 2017 Giang Bb. All rights reserved.
//

import UIKit
import CoreImage    //Core Image is yet another super-fast and super-powerful framework from Apple. It does only one thing, which is to apply filters to images that manipulate them in various ways

class ViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    var currentImage: UIImage! {
        didSet {
            appyChange()
        }
    }
    
    var context: CIContext!     //Core Image context, which is the Core Image component that handles rendering. We create it here and use it throughout our app
    var currentFilter: CIFilter!    // Core Image filter will store whatever filter we have activated. This filter will be given various input settings before we ask it to output a result for us to show in the image view
    
    let filterArr = ["CIBumpDistortion","CIGaussianBlur","CIPixellate","CISepiaTone","CITwirlDistortion","CIUnsharpMask","CIVignette"]
    
    
    //Connected properties
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var intensity: UISlider!
    
    

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        title = "CISepiaTone"
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(importPicture))
        
        //creates a default Core Image context, then creates an example filter that will apply a sepia tone effect to images. It's just for now; we'll let users change it soon enough.
        context = CIContext()
        currentFilter = CIFilter(name: "CISepiaTone")
        
        currentImage = UIImage(named: "nssl0091")
        
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @objc func importPicture() {
        let picker = UIImagePickerController()
        picker.allowsEditing = true
        picker.delegate = self
        picker.sourceType = .camera
        present(picker, animated: true)
    }
    //MARK: - implement UIImagePickerControllerDelegate
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        guard  let image = info[UIImagePickerControllerEditedImage] as? UIImage else {
            return
        }
        
        dismiss(animated: true)
        
        currentImage = image
    }
    
    //MARK: - Process image using CoreImage lib
    func applyProccessing() {
        let inputKey = currentFilter.inputKeys
        
        
        // There are four input keys we're going to manipulate across seven different filters. Sometimes the keys mean different things, and sometimes the keys don't exist, so we're going to apply only the keys that do exist with some cunning code
        //Each filter has an inputKeys property that returns an array of all the keys it can support. We're going to use this array in conjunction with the contains() method to see if each of our input keys exist, and, if it does, use it. Not all of them expect a value between 0 and 1, so I sometimes multiply the slider's value to make the effect more pronounced.
        if inputKey.contains(kCIInputIntensityKey){currentFilter.setValue(intensity.value, forKey: kCIInputIntensityKey)}
        if inputKey.contains(kCIInputRadiusKey){currentFilter.setValue(intensity.value * 200, forKey: kCIInputRadiusKey)}
        if inputKey.contains(kCIInputScaleKey){currentFilter.setValue(intensity.value * 10, forKey: kCIInputScaleKey)}
        if inputKey.contains(kCIInputCenterKey){currentFilter.setValue(CIVector(x: currentImage.size.width/2, y: currentImage.size.height/2), forKey: kCIInputCenterKey)}
        
        //creates a new data type called CGImage from the output image of the current filter. We need to specify which part of the image we want to render, but using currentFilter.outputImage!.extent means "all of it." Until this method is called, no actual processing is done, so this is the one that does the real work. This returns an optional CGImage so we need to check and unwrap with if let
        if let cgimg = context.createCGImage(currentFilter.outputImage!, from: currentFilter.outputImage!.extent){
            let proccessedImg = UIImage(cgImage: cgimg)
            imageView.image = proccessedImg
        }
        
    }
    
    func setfilter(action: UIAlertAction) {
        guard currentImage != nil && action.title != nil else {
            return
        }
        self.title = action.title!
        currentFilter = CIFilter(name: action.title!)
        
        appyChange()
    }
    
    func appyChange() {
        guard currentFilter != nil else {
            return
        }
        let beginImage = CIImage(image: currentImage)   //The CIImage data type is, for the sake of this project, just the Core Image equivalent of UIImage. Behind the scenes it's a bit more complicated than that, but really it doesn't matter
        currentFilter.setValue(beginImage, forKey: kCIInputImageKey)    //we send the result into the current Core Image Filter using the kCIInputImageKey
        
        applyProccessing();
    }
   
    @objc func image(_ image: UIImage, didFinishSavingWithError error: Error?, contextInfo: UnsafeRawPointer)  {
        if let error = error {
            //we got back an error
            let ac = UIAlertController(title: "Save error", message: error.localizedDescription, preferredStyle: .alert)
            ac.addAction(UIAlertAction(title: "OK", style: .default))
            present(ac, animated: true)
        }else {
            let ac = UIAlertController(title: "Save ok!", message: "Your image has been saved to photos", preferredStyle: .alert)
            ac.addAction(UIAlertAction(title: "OK", style: .default))
            present(ac, animated: true)
        }
    }

    
    
    
    
    
    //MARK: - Action From property
    
    @IBAction func save(_ sender: UIButton) {
        //UIImageWriteToSavedPhotosAlbum(). This method does exactly what its name says: give it a UIImage and it will write the image to the photo album
        //This method takes four parameters: the image to write, who to tell when writing has finished, what method to call, and any context. The context is just like the context value you can use with KVO, as seen in project 4, and again we're not going to use it here. The first two parameters are quite simple: we know what image we want to save (the processed one in the image view), and we also know that we want self (the current view controller) to be notified when writing has finished.
        //The third parameter can provided in two ways: vague and clean, or specific and ugly. It needs to be a selector that lists the method in our view controller that will be called, and it's specified using #selector
        //Previously we've had very simple selectors, like #selector(shareTapped). And we can use that approach here – Swift allows us to be really vague about the selector we intend to call, and this works just fine
        //Yes, that approach is nice and easy to read, but it's also very vague: it doesn't say what is actually going to happen. The alternative is to be very specific about the method we want called, so you can write this:
        //#selector(image(_:didFinishSavingWithError:contextInfo:))
        UIImageWriteToSavedPhotosAlbum(imageView.image!, self, #selector(image(_: didFinishSavingWithError: contextInfo:)), nil)
        
        //This second option is longer, but provides much more information both to Xcode and to other people reading your code, so it's generally preferred. To be honest, this particular callback is a bit of a wart in iOS, but the fact that it stands out so much is testament to the fact that there are so few warts around!
        //From here on it's easy, because we just need to write the didFinishSavingWithError method. This must show one of two messages depending on whether we get an error sent to us. The error might be, for example, that the user denied us permission to write to the photo album. This will be sent as an Error? object, so if it's nil we know there was no error.
        
//        This parameter is important because if an error has occurred (i.e., the error parameter is not nil) then we need to unwrap the Error object and use its localizedDescription property – this will tell users what the error message was in their own language.
    }
    
    
    @IBAction func changeFilter(_ sender: UIButton) {
        let ac = UIAlertController(title: "Choose Filter", message: nil, preferredStyle: .actionSheet)
        for filter in filterArr{
            ac.addAction(UIAlertAction(title: filter, style: .default, handler: setfilter))
        }
        ac.addAction(UIAlertAction(title: "Cancel", style: .default))
        present(ac, animated: true)
    }
    
    
    
    @IBAction func intensityChanged(_ sender: UISlider) {
        applyProccessing();
    }
    
    


}

