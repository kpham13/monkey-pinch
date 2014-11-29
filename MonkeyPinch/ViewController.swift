//
//  ViewController.swift
//  MonkeyPinch
//
//  Created by Kevin Pham on 9/10/14.
//  Copyright (c) 2014 Kevin Pham. All rights reserved.
//

import UIKit
import AVFoundation

class ViewController: UIViewController, UIGestureRecognizerDelegate {
    
    var chompPlayer:AVAudioPlayer? = nil
    var hehePlayer:AVAudioPlayer? = nil
    
    @IBOutlet var monkeyPan: UIPanGestureRecognizer!
    @IBOutlet var bananaPan: UIPanGestureRecognizer!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Important part of audio playing code in viewDidLoad
        // 1 Create a filtered array of just the monkey and banana image views.
        let filteredSubviews = self.view.subviews.filter( {
            $0.isKindOfClass(UIImageView)
        })
        
        // 2 Cycle through the filtered array.
        for view in filteredSubviews {
            // 3 Create a UITapGestureRecognizer for each image view, specifying the callback.
            let recognizer = UITapGestureRecognizer(target: self, action:Selector("handleTap:"))
            // 4 Set the delegate of the recognizer programatically, and add the recognizer to the image view.
            recognizer.delegate = self
            view.addGestureRecognizer(recognizer)
            
            // UIGestureRecognizer Dependencies
            recognizer.requireGestureRecognizerToFail(monkeyPan)
            recognizer.requireGestureRecognizerToFail(bananaPan)
            
            // Custom UIGestureRecognizer
            let recognizer2 = TickleGestureRecognizer(target: self, action: Selector("handleTickle:"))
            recognizer2.delegate = self
            view.addGestureRecognizer(recognizer2)
        }
        
        self.chompPlayer = self.loadSound("chomp")
        self.hehePlayer = self.loadSound("hehehe1")
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - AVFOUNDATION SOUND
    
    func loadSound(filename:NSString) -> AVAudioPlayer {
        let url = NSBundle.mainBundle().URLForResource(filename, withExtension: "caf")
        var error:NSError? = nil
        let player = AVAudioPlayer(contentsOfURL: url, error: &error)
        if error != nil {
            println("Error loading \(url): \(error?.localizedDescription)")
        } else {
            player.prepareToPlay()
        }
        
        return player
    }
    
    // MARK: - PAN GESTURE RECOGNIZER
    
    @IBAction func handlePan(recognizer:UIPanGestureRecognizer) {
        //return // comment for panning, uncomment for tickling
        
        let translation = recognizer.translationInView(self.view) // Can retrieve the amount the user has moved their finger by calling translationInView.
        recognizer.view!.center = CGPoint(x:recognizer.view!.center.x + translation.x, y:recognizer.view!.center.y + translation.y) // Reference to monkey image view by calling recognizer.view.
        recognizer.setTranslation(CGPointZero, inView: self.view) // Extremely important to set the translation back to zero once you are done.
        
        // Gratuitous Deceleration
        if recognizer.state == UIGestureRecognizerState.Ended {
            // 1 Figure out the length of the velocity vector (magnitude)
            let velocity = recognizer.velocityInView(self.view)
            let magnitude = sqrt((velocity.x * velocity.x) + (velocity.y * velocity.y))
            let slideMultiplier = magnitude / 200
            println("magnitude: \(magnitude), slideMultiplier: \(slideMultiplier)")
            
            // 2 If the length < 200, then decrease the base speed, otherwise increase it.
            let slideFactor = 0.1 * slideMultiplier     // Increase for more of a slide
            // 3 Calculate a final point based on velocity and the slideFactor.
            var finalPoint = CGPoint(x:recognizer.view!.center.x + (velocity.x * slideFactor), y:recognizer.view!.center.y + (velocity.y * slideFactor))
            // 4 Make sure the final point is within the view's bounds.
            finalPoint.x = min(max(finalPoint.x, 0), self.view.bounds.size.width)
            finalPoint.y = min(max(finalPoint.y, 0), self.view.bounds.size.height)
            
            // 5 Animate the view to the final resting place.
            UIView.animateWithDuration(Double(slideFactor * 2),
                delay: 0,
                // 6 Use the "ease out" animation to slow down the movement over time.
                options: UIViewAnimationOptions.CurveEaseOut,
                animations: {recognizer.view!.center = finalPoint },
                completion: nil)
        }
        
    }
    
    // MARK: - PINCH GESTURE RECOGNIZER
    
    @IBAction func handlePinch(recognizer : UIPinchGestureRecognizer) {
        recognizer.view!.transform = CGAffineTransformScale(recognizer.view!.transform, recognizer.scale, recognizer.scale)
        recognizer.scale = 1
    }
    
    // MARK: - ROTATION GESTURE RECOGNIZER
    
    @IBAction func handleRotate(recognizer : UIRotationGestureRecognizer) {
        recognizer.view!.transform = CGAffineTransformRotate(recognizer.view!.transform, recognizer.rotation)
        recognizer.rotation = 0
    }
    
    // MARK: - TAP GESTURE RECOGNIZER
    
    func handleTap(recognizer: UITapGestureRecognizer) {
        self.chompPlayer?.play()
    }
    
    // MARK: - CUSTOM TICKLE GESTURE RECOGNIZER
    
    func handleTickle(recognizer:TickleGestureRecognizer) {
        self.hehePlayer?.play()
    }
    
    // MARK: - SIMULTANEOUS GESTURE RECOGNIZERS
    
    func gestureRecognizer(UIGestureRecognizer, shouldRecognizeSimultaneouslyWithGestureRecognizer:UIGestureRecognizer) -> Bool {
            return true
    }
    
}

