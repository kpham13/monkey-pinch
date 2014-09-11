//
//  ViewController.swift
//  MonkeyPinch
//
//  Created by Kevin Pham on 9/10/14.
//  Copyright (c) 2014 Kevin Pham. All rights reserved.
//

import UIKit

class ViewController: UIViewController, UIGestureRecognizerDelegate {
                            
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // UIPanGestureRecognizer
    @IBAction func handlePan(recognizer:UIPanGestureRecognizer) {
        let translation = recognizer.translationInView(self.view) // Can retrieve the amount the user has moved their finger by calling translationInView.
        recognizer.view!.center = CGPoint(x:recognizer.view!.center.x + translation.x, y:recognizer.view!.center.y + translation.y) // Reference to monkey image view by calling recognizer.view.
        recognizer.setTranslation(CGPointZero, inView: self.view) // Extremely important to set the translation back to zero once you are done.
        
        // Gratuitous deceleration
        if recognizer.state == UIGestureRecognizerState.Ended {
            // 1 Figure out the length of the velocity vector (magnitude)
            let velocity = recognizer.velocityInView(self.view)
            let magnitude = sqrt((velocity.x * velocity.x) + (velocity.y * velocity.y))
            let slideMultiplier = magnitude / 200
            println("magnitude: \(magnitude), slideMultiplier: \(slideMultiplier)")
            
            // 2 If the length < 200, then decrease the base speed, otherwise increase it.
            let slideFactor = 0.1 * slideMultiplier     // Increase for more of a slide
            // 3 Calculate a final point based on velocity and the slideFactor.
            var finalPoint = CGPoint(x:recognizer.view!.center.x + (velocity.x * slideFactor),
                y:recognizer.view!.center.y + (velocity.y * slideFactor))
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
    
    // UIPinchGestureRecognizer
    @IBAction func handlePinch(recognizer : UIPinchGestureRecognizer) {
        recognizer.view!.transform = CGAffineTransformScale(recognizer.view!.transform,
            recognizer.scale, recognizer.scale)
        recognizer.scale = 1
    }
    
    // UIRotationGestureRecognizer
    @IBAction func handleRotate(recognizer : UIRotationGestureRecognizer) {
        recognizer.view!.transform = CGAffineTransformRotate(recognizer.view!.transform, recognizer.rotation)
        recognizer.rotation = 0
    }
    
    // Simultaneous gesture recognizers
    func gestureRecognizer(UIGestureRecognizer,
        shouldRecognizeSimultaneouslyWithGestureRecognizer:UIGestureRecognizer) -> Bool {
            return true
    }

}

