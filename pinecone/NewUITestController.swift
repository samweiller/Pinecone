//
//  NewUITestController.swift
//  pinecone
//
//  Created by Sam Weiller on 1/17/16.
//  Copyright © 2016 saweiller. All rights reserved.
//

import Foundation
import UIKit

class NewUITestController: UIViewController {
    @IBOutlet weak var teamOneScoreLabel: UILabel!
    @IBOutlet weak var teamTwoScoreLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
    
        self.teamOneScoreLabel.layer.cornerRadius = (self.teamOneScoreLabel.frame.size.width / 2) + 14;
        self.teamOneScoreLabel.clipsToBounds = true;
        
        self.teamTwoScoreLabel.layer.cornerRadius = (self.teamTwoScoreLabel.frame.size.width / 2) + 14;
        self.teamTwoScoreLabel.clipsToBounds = true;
        
        self.teamOneScoreLabel.layer.borderWidth = 4.0;
        self.teamOneScoreLabel.layer.borderColor = UIColor.whiteColor()().CGColor
        
//        self.teamTwoScoreLabel.layer.borderWidth = 4.0;
//        self.teamTwoScoreLabel.layer.borderColor = UIColor.yellowColor().CGColor
    }
}