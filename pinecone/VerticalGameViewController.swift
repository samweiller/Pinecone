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
    
    // Initialize all Outlets here
    
    @IBOutlet weak var teamOneScoreLabel: UILabel!
    @IBOutlet weak var teamTwoScoreLabel: UILabel!
    
    @IBOutlet weak var timerLabel: UILabel!
    @IBOutlet weak var timerIcon: UIImageView!
    
    @IBOutlet weak var theActiveWordLabel: UILabel!
    
    @IBOutlet weak var showWordButtonLabel: UIButton!
    
    @IBOutlet weak var passButtonLabel: UIButton!
    @IBOutlet weak var playButtonLabel: UIButton!
    
    @IBOutlet weak var missedItButtonLabel: UIButton!
    @IBOutlet weak var gotItButtonLabel: UIButton!
    
    @IBOutlet weak var doneWithTurnButtonLabel: UIButton!
    
    @IBOutlet weak var remainingTurnsLabel: UILabel!
    
    // Initialize all variables and constants here
    var teamInControl: Int = 2
    var teamOneScore: Int = 0
    var teamTwoScore: Int = 0
    var remainingTurns: Int = 5
    var currentPoints: Int = 0
    var timerMaximum: Int = 30
    var count: Int = 0
    var audioPlayer:AVAudioPlayer!
    var timer: NSTimer = NSTimer()
    var theChosenWord: String = ""
    var numberOfWords: UInt32 = 200   // This should be dynamic. Get count of VALID words in Parse DB
    
    // VIEW DID LOAD IS HERE!
    override func viewDidLoad() {
        // Let's get this shit started.
        // GOALS: Zero everything out, display buttons that are needed before a turn starts
        
        super.viewDidLoad()
        
        changeTeamInControl()
        
        timerLabel.hidden = true
        timerIcon.hidden = true
        theActiveWordLabel.hidden = true
        showWordButtonLabel.hidden = false
        passButtonLabel.hidden = true
        playButtonLabel.hidden = true
        missedItButtonLabel.hidden = true
        gotItButtonLabel.hidden = true
        doneWithTurnButtonLabel.hidden = true
        remainingTurnsLabel.hidden = true
        
        self.theActiveWordLabel.text = ""
        self.timerLabel.text = ""
        
        self.teamOneScoreLabel.text = String(teamOneScore)
        self.teamTwoScoreLabel.text = String(teamTwoScore)
        
        // Round out text boxes
        self.teamOneScoreLabel.layer.cornerRadius = (self.teamOneScoreLabel.frame.size.width / 2) + 14;
        self.teamOneScoreLabel.clipsToBounds = true;
        
        self.teamTwoScoreLabel.layer.cornerRadius = (self.teamTwoScoreLabel.frame.size.width / 2) + 14;
        self.teamTwoScoreLabel.clipsToBounds = true;
    }
    
    @IBAction func showWordButton(sender: AnyObject) {
        self.theActiveWordLabel.text = ""
        theActiveWordLabel.hidden = false
        
        remainingTurns = 5
        
        let randomNumber = Int(arc4random_uniform(numberOfWords))
        print(randomNumber) // DEBUG LINE
        
        let query2 = PFQuery(className:"WordList")
        query2.whereKey("index", equalTo:randomNumber)
        
        query2.findObjectsInBackgroundWithBlock {
            (objects: [PFObject]?, error: NSError?) -> Void in
            if error == nil {
                if let objects = objects {
                    for object in objects {
                        self.theChosenWord = object["words"] as! String
                        print(self.theChosenWord)
                        if (self.theChosenWord == ""){
                            self.theChosenWord = "pinecone" // if no word returned, set the word to pinecone
                        }
                        self.theActiveWordLabel.text = self.theChosenWord.capitalizedString
                    }
                }
            } else {
                // Log details of the failure
                print("Error: \(error!) \(error!.userInfo)")
                self.theChosenWord = "pinecones" // if error, set the word to pinecones
            }
        }
        
        showWordButtonLabel.hidden = true
        playButtonLabel.hidden = false
        passButtonLabel.hidden = false
    }
    
    @IBAction func playButton(sender: AnyObject) {
        playWithTurnsLeft(remainingTurns)
    }
    
    @IBAction func passButton(sender: AnyObject) {
        changeTeamInControl()
        playWithTurnsLeft(remainingTurns)
    }
    
    func playWithTurnsLeft(remainingTurns: Int){
        timerLabel.hidden = false
        doneWithTurnButtonLabel.hidden = false
        playButtonLabel.hidden = true
        passButtonLabel.hidden = true
        remainingTurnsLabel.hidden = false

        
        if (remainingTurns >= 0){
            currentPoints = remainingTurns + 1
            count = timerMaximum // number of seconds per turn
            
            timer = NSTimer.scheduledTimerWithTimeInterval(1.0, target: self, selector: "update", userInfo: nil, repeats: true)
            
            doneWithTurnButtonLabel.hidden = false
            
            if (remainingTurns > 1){
                self.remainingTurnsLabel.text = "\(remainingTurns) turns left."
            } else if (remainingTurns == 1) {
                self.remainingTurnsLabel.text = "1 turn left."
            } else if (remainingTurns == 0) {
                self.remainingTurnsLabel.text = "Last turn! Make it count."
            }
            self.timerLabel.text = String(count)
            
            timer.fire()
        } else {
            currentPoints = 0
            changeTeamInControl()
            gotItButtonAction(1)
        }
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
    
    @IBAction func doneWithTurnButtonAction(sender: AnyObject) {
        count = 0
        timer.invalidate()
        endOfTheTurn()
    }
    
    func endOfTheTurn() {
        timer.invalidate()
        doneWithTurnButtonLabel.hidden = true
        gotItButtonLabel.hidden = false
        missedItButtonLabel.hidden = false
        self.timerLabel.text = "0"
    }
    
    @IBAction func gotItButtonAction(sender: AnyObject) {
        // add points
        if (teamInControl == 1){
            teamOneScore += currentPoints
            self.teamOneScoreLabel.text = String(teamOneScore)
        } else if (teamInControl == 2){
            teamTwoScore += currentPoints
            self.teamTwoScoreLabel.text = String(teamTwoScore)
        }
        
        // start over
        doneWithTurnButtonLabel.hidden = true
        showWordButtonLabel.hidden = false
        timerLabel.hidden = true
        gotItButtonLabel.hidden = true
        missedItButtonLabel.hidden = true
        theActiveWordLabel.hidden = true
        remainingTurnsLabel.hidden = true
        
        changeTeamInControl()
    }
    
    @IBAction func missedItButtonAction(sender: AnyObject) {
        remainingTurns--
        
        // change control
        changeTeamInControl()
        
        // start again
        gotItButtonLabel.hidden = true
        missedItButtonLabel.hidden = true
        
        playWithTurnsLeft(remainingTurns)
    }
    
    func changeTeamInControl(){
        if (teamInControl == 1){
            teamInControl = 2
            self.teamOneScoreLabel.layer.borderWidth = 0.0
            self.teamTwoScoreLabel.layer.borderWidth = 4.0
            self.teamTwoScoreLabel.layer.borderColor = UIColor.whiteColor().CGColor
        } else if ( teamInControl == 2) {
            teamInControl = 1
            self.teamTwoScoreLabel.layer.borderWidth = 0.0
            self.teamOneScoreLabel.layer.borderWidth = 4.0
            self.teamOneScoreLabel.layer.borderColor = UIColor.whiteColor().CGColor
        }
    }
}



