//
//  VerticalGameViewController.swift
//  pinecone
//
//  Created by Sam Weiller on 1/10/16.
//  Copyright © 2016 saweiller. All rights reserved.
//

//

import UIKit
import Parse
import AVFoundation

class VerticalGameViewController: UIViewController {
    
    @IBOutlet weak var doneWithTurnButton: UIButton!
    
    @IBOutlet weak var controlMarkerTeamOne: UIImageView!
    @IBOutlet weak var controlMarkerTeamTwo: UIImageView!
    
    @IBOutlet weak var leftTeamScoreLabel: UILabel!
    @IBOutlet weak var rightTeamScoreLabel: UILabel!
    
    @IBOutlet weak var currentPointsLabel: UILabel!
    
    @IBOutlet weak var timerLabel: UILabel!
    
    @IBOutlet weak var theActiveWordLabel: UILabel!
    
    var audioPlayer:AVAudioPlayer!
    
    // some Global variables
    var teamInControl: Int = 1
    var teamOneScore: Int = 0
    var teamTwoScore: Int = 0
    var remainingTurns: Int = 5
    var currentPoints: Int = 0
    var timerMaximum: Int = 30
    var count: Int = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.theActiveWordLabel.text = ""
        self.currentPointsLabel.text = ""
        self.timerLabel.text = ""
        
        activatePineconeOn(teamInControl)
        
        self.leftTeamScoreLabel.text = String(teamOneScore)
        self.rightTeamScoreLabel.text = String(teamTwoScore)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    var timer = NSTimer()
    
    //    // Grab word from parse and display it
    //    @IBAction func newWordButton(sender: AnyObject) {
    //        var theChosenWord: String = ""
    //        theActiveWordLabel.hidden = false
    //
    //        var numberOfWords: UInt32 = 208
    //
    //        let randomNumber = Int(arc4random_uniform(numberOfWords))
    //        print(randomNumber)
    //
    //        let query2 = PFQuery(className:"WordList")
    //        query2.whereKey("index", equalTo:randomNumber)
    //
    //        query2.findObjectsInBackgroundWithBlock {
    //            (objects: [PFObject]?, error: NSError?) -> Void in
    //
    //            if error == nil {
    //                if let objects = objects {
    //                    for object in objects {
    //                        theChosenWord = object["words"] as! String
    //                        print(theChosenWord)
    //                        self.theActiveWordLabel.text = theChosenWord.capitalizedString
    //                    }
    //                }
    //            } else {
    //                // Log details of the failure
    //                print("Error: \(error!) \(error!.userInfo)")
    //            }
    //        }
    //    }
    
    @IBOutlet weak var theNewWordButtonOutlet: UIButton!
    
    @IBOutlet weak var startTurnButtonOutlet: UIButton!
    // Begin turn (timer, hide new word button, etc.)
    
    @IBAction func startTurnButton(sender: AnyObject) {
        var theChosenWord: String = ""
        self.theActiveWordLabel.text = ""
        theActiveWordLabel.hidden = false
        
        var numberOfWords: UInt32 = 200
        
        let randomNumber = Int(arc4random_uniform(numberOfWords))
        print(randomNumber)
        
        let query2 = PFQuery(className:"WordList")
        query2.whereKey("index", equalTo:randomNumber)
        
        query2.findObjectsInBackgroundWithBlock {
            (objects: [PFObject]?, error: NSError?) -> Void in
            
            if error == nil {
                if let objects = objects {
                    for object in objects {
                        theChosenWord = object["words"] as! String
                        print(theChosenWord)
                        if (theChosenWord == ""){
                            theChosenWord = "pinecone"
                        }
                        self.theActiveWordLabel.text = theChosenWord.capitalizedString
                    }
                }
            } else {
                // Log details of the failure
                print("Error: \(error!) \(error!.userInfo)")
            }
        }
        
        timerLabel.hidden = false
        currentPointsLabel.hidden = false
        startTurnButtonOutlet.hidden = true
        //        theNewWordButtonOutlet.hidden = true
        //        timer = NSTimer.scheduledTimerWithTimeInterval(1.0, target: self, selector: "update", userInfo: nil, repeats: true)
        doneWithTurnButton.hidden = false
        playWithTurnsLeft(remainingTurns)
    }
    
    @IBOutlet weak var stageInstructionsText: UILabel!
    
    func playWithTurnsLeft(var remainingTurns: Int){
        currentPoints = remainingTurns + 1
        count = timerMaximum // number of seconds per turn
        
        timer = NSTimer.scheduledTimerWithTimeInterval(1.0, target: self, selector: "update", userInfo: nil, repeats: true)
        
        doneWithTurnButton.hidden = false
        
        self.currentPointsLabel.text = String(currentPoints)
        self.timerLabel.text = String(count)
        
        timer.fire()
    }
    
    func update() {
        if(count > 0)
        {
            self.timerLabel.text = String(count--)
        } else if (count == 0) {
            self.timerLabel.text = "0"
            endOfTheTurn()
        }
    }
    
    @IBOutlet weak var gotItButtonOutlet: UIButton!
    @IBOutlet weak var missedItButtonOutlet: UIButton!
    
    @IBAction func doneWithTurnButtonAction(sender: AnyObject) {
        count = 0
        timer.invalidate()
        endOfTheTurn()
    }
    
    func endOfTheTurn() {
        timer.invalidate()
        doneWithTurnButton.hidden = true
        gotItButtonOutlet.hidden = false
        missedItButtonOutlet.hidden = false
        self.timerLabel.text = "0"
    }
    
    @IBAction func gotItButtonAction(sender: AnyObject) {
        // add points
        if (teamInControl == 1){
            teamOneScore += currentPoints
            self.leftTeamScoreLabel.text = String(teamOneScore)
        } else if (teamInControl == 2){
            teamTwoScore += currentPoints
            self.rightTeamScoreLabel.text = String(teamTwoScore)
        }
        
        // start over
        timerLabel.hidden = true
        currentPointsLabel.hidden = true
        gotItButtonOutlet.hidden = true
        missedItButtonOutlet.hidden = true
        theActiveWordLabel.hidden = true
        
        startTurnButtonOutlet.hidden = false
        //        theNewWordButtonOutlet.hidden = false
        
        remainingTurns = 5
        
        if (teamInControl == 1){
            teamInControl = 2
        } else if ( teamInControl == 2) {
            teamInControl = 1
        }
        
        activatePineconeOn(teamInControl)
    }
    
    @IBAction func missedItButtonAction(sender: AnyObject) {
        // reduce point value
        remainingTurns--
        
        // change control
        // OH GOD THIS IS DONE TERRIBLY! IT SHOULD BE 1 & 0 OR 1 & -1! HAAAAALP!
        if (teamInControl == 1){
            teamInControl = 2
        } else if ( teamInControl == 2) {
            teamInControl = 1
        }
        
        activatePineconeOn(teamInControl)
        
        // start again
        gotItButtonOutlet.hidden = true
        missedItButtonOutlet.hidden = true
        
        playWithTurnsLeft(remainingTurns)
    }
    
    func activatePineconeOn(teamInControl: Int){
        if (teamInControl == 1){
            controlMarkerTeamOne.hidden = false
            controlMarkerTeamTwo.hidden = true
        } else if (teamInControl == 2) {
            controlMarkerTeamOne.hidden = true
            controlMarkerTeamTwo.hidden = false
        }
    }
}



