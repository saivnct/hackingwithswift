//
//  RecordWhistleViewController.swift
//  Project33
//
//  Created by Giang Bb on 10/29/18.
//  Copyright © 2018 Giang Bb. All rights reserved.
//
import AVFoundation
import UIKit

class RecordWhistleViewController: UIViewController,AVAudioRecorderDelegate {

    var stackView: UIStackView!
    
    var recordButton: UIButton!
    
    var recordingSession: AVAudioSession!
    var whistleRecorder: AVAudioRecorder!
    
    var playButton: UIButton!
    
    var whistlePlayer: AVAudioPlayer!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        //we're going to be doing all the view layout in code to make it easier to follow
        view.backgroundColor = UIColor.gray
        
        stackView = UIStackView()
        stackView.spacing = 30
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.distribution = UIStackView.Distribution.fillEqually
        stackView.alignment = .center
        stackView.axis = .vertical
        view.addSubview(stackView)
        
        stackView.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
        stackView.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
        stackView.centerYAnchor.constraint(equalTo: view.centerYAnchor).isActive = true
        
        
        //setting up the recording environment
        //We'll use the requestRecordPermission() method of the audio session to ask the user whether we can record or not, and give that a trailing closure to execute when the user makes a choice
        //As with reading photos, we also need to add a string to the Info.plist file explaining to the user what we intend to do with the audio. So, open the Info.plist file now, select any row, then click the + next that appears next to it. Select the key name “Privacy - Microphone Usage Description” then give it the value “We need to record your whistle.”
        recordingSession = AVAudioSession.sharedInstance()
        
        do {
            try recordingSession.setCategory(.playAndRecord, mode: .default, options: .defaultToSpeaker)
            try recordingSession.setActive(true)
            recordingSession.requestRecordPermission() { [unowned self] allowed in
                DispatchQueue.main.async {
                    if allowed {
                        self.loadRecordingUI()
                    } else {
                        self.loadFailUI()
                    }
                }
            }
        } catch {
            self.loadFailUI()
        }
    }
    
    
    func loadRecordingUI() {
        recordButton = UIButton()
        recordButton.translatesAutoresizingMaskIntoConstraints = false
        recordButton.setTitle("Tap to Record", for: .normal)
        recordButton.titleLabel?.font = UIFont.preferredFont(forTextStyle: .title1)
        recordButton.addTarget(self, action: #selector(recordTapped), for: .touchUpInside)
        stackView.addArrangedSubview(recordButton) //you should also be aware that you never add a subview to a UIStackView directly. Instead, you use its addArrangedSubview() method, which is what triggers the layout work
        
        playButton = UIButton()
        playButton.translatesAutoresizingMaskIntoConstraints = false
        playButton.setTitle("Tap to Play", for: .normal)
        playButton.isHidden = true
        playButton.alpha = 0 //By setting the button to be hidden and have alpha 0, we're saying "don't show it to the user, and don't let it take up any space in the stack view.
        playButton.titleLabel?.font = UIFont.preferredFont(forTextStyle: .title1)
        playButton.addTarget(self, action: #selector(playTapped), for: .touchUpInside)
        stackView.addArrangedSubview(playButton)
    }
    
    func loadFailUI() {
        let failLabel = UILabel()
        failLabel.font = UIFont.preferredFont(forTextStyle: .headline)
        failLabel.text = "Recording failed: please ensure the app has access to your microphone."
        failLabel.numberOfLines = 0 //numberOfLines to 0 means "wrap over as many lines as you need."
        
        stackView.addArrangedSubview(failLabel)
    }
    
    @objc func recordTapped() {
        if whistleRecorder == nil {
            startRecording()
            if !playButton.isHidden { //The isHidden property of any UIView subclass is a simple boolean, meaning that it's either true or false: a view is either hidden or it's not
                UIView.animate(withDuration: 0.35) { [unowned self] in
                    self.playButton.isHidden = true
                    self.playButton.alpha = 0
                }
            }
        } else {
            finishRecording(success: true)
        }
    }
    
    @objc func playTapped() {
        let audioURL = RecordWhistleViewController.getWhistleURL()
        
        do {
            whistlePlayer = try AVAudioPlayer(contentsOf: audioURL)
            whistlePlayer.play()
        } catch {
            let ac = UIAlertController(title: "Playback failed", message: "There was a problem playing your whistle; please try re-recording.", preferredStyle: .alert)
            ac.addAction(UIAlertAction(title: "OK", style: .default))
            present(ac, animated: true)
        }
    }
    
    //You need to tell iOS where to save the recording. This is done when you create the AVAudioRecorder object because iOS streams the audio to the file as it goes so it can write large files
//    class keyword at the beginning, which means you call them on the class not on instances of the class.This is important, because it means we can find the whistle URL from anywhere in our app rather than typing it in everywhere
    class func getDocumentsDirectory() -> URL {
        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        let documentsDirectory = paths[0]
        return documentsDirectory
    }
    
    class func getWhistleURL() -> URL {
        return getDocumentsDirectory().appendingPathComponent("whistle.m4a")
    }
    
    func startRecording() {
//        When we want to start recording, the app needs to do a few things:
//        1. Make the view have a red background color so the user knows they are in recording mode.
//        2. Change the title of the record button to say "Tap to Stop".
//        3. Use the getWhistleURL() method we just wrote to find where to save the whistle.
//        4. Create a settings dictionary describing the format, sample rate, channels and quality.
//        5. Create an AVAudioRecorder object pointing at our whistle URL, set ourselves as the delegate, then call its record() method.
        
        // 1
        view.backgroundColor = UIColor(red: 0.6, green: 0, blue: 0, alpha: 1)
        
        // 2
        recordButton.setTitle("Tap to Stop", for: .normal)
        
        // 3
        let audioURL = RecordWhistleViewController.getWhistleURL()
        print(audioURL.absoluteString)
        
        // 4
        //We'll be using Apple's AAC format because it gets the most quality for the lowest bitrate. For bitrate we'll use 12,000Hz, which, when combined with the High AAC quality, sounds good in my testing. We'll specify 1 for the number of channels, because iPhones only have mono input
        let settings = [
            AVFormatIDKey: Int(kAudioFormatMPEG4AAC),
            AVSampleRateKey: 12000,
            AVNumberOfChannelsKey: 1,
            AVEncoderAudioQualityKey: AVAudioQuality.high.rawValue
        ]
        
        do {
            // 5
            whistleRecorder = try AVAudioRecorder(url: audioURL, settings: settings)
            whistleRecorder.delegate = self
            whistleRecorder.record()
        } catch {
            finishRecording(success: false)
        }
    }
    
    //once recording has started, we naturally want to stop it at some point. For that, we're going to create a finishRecording() method, which will take one boolean parameter saying whether the recording was successful or not. It will make the view's background color green to show that recording is finished, then it will destroy the AVAudioRecorder object
    //The special part of this method lies in whether the recording was a success or not. If it was a success, we're going to set the record button's title to be "Tap to Re-record", but then show a new right bar button item in the navigation bar, letting users progress to the next stage of submission. So, they can submit what they have, or re-record as often as they want. If the record wasn't a success, we'll put the button's title back to being "Tap to Record" then show an error message
    func finishRecording(success: Bool) {
        view.backgroundColor = UIColor(red: 0, green: 0.6, blue: 0, alpha: 1)
        
        whistleRecorder.stop()
        whistleRecorder = nil
        
        if success {
            recordButton.setTitle("Tap to Re-record", for: .normal)
            
            if playButton.isHidden {
                UIView.animate(withDuration: 0.35) { [unowned self] in
                    self.playButton.isHidden = false
                    self.playButton.alpha = 1
                }
            }
            
            navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Next", style: .plain, target: self, action: #selector(nextTapped))
        } else {
            recordButton.setTitle("Tap to Record", for: .normal)
            
            let ac = UIAlertController(title: "Record failed", message: "There was a problem recording your whistle; please try again.", preferredStyle: .alert)
            ac.addAction(UIAlertAction(title: "OK", style: .default))
            present(ac, animated: true)
        }
    }
    
    @objc func nextTapped() {
        let vc = SelectGenreViewController()
        navigationController?.pushViewController(vc, animated: true)
    }
    
    //MARK: IMPLEMENT AVAudioRecorderDelegate
    // We already set our view controller to be the delegate of our AVAudioRecorder object, so we'll get sent a audioRecorderDidFinishRecording() message when recording finished. If the recording wasn't a success, we'll call finishRecording() so it can clean up and restore the view to its pre-recording state
    func audioRecorderDidFinishRecording(_ recorder: AVAudioRecorder, successfully flag: Bool) {
        if !flag {
            finishRecording(success: false)
        }
    }

}
