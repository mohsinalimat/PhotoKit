//
//  ParadiseAlbumButton.swift
//  PhotoKit
//
//  Blog  : https://meniny.cn
//  Github: https://github.com/Meniny
//
//  No more shall we pray for peace
//  Never ever ask them why
//  No more shall we stop their visions
//  Of selfdestructing genocide
//  Dogs on leads march to war
//  Go ahead end it all...
//
//  Blow up the world
//  The final silence
//  Blow up the world
//  I don't give a damn!
//
//  Screams of terror, panic spreads
//  Bombs are raining from the sky
//  Bodies burning, all is dead
//  There's no place left to hide
//  Dogs on leads march to war
//  Go ahead end it all...
//
//  Blow up the world
//  The final silence
//  Blow up the world
//  I don't give a damn!
//
//  (A voice was heard from the battle field)
//
//  "Couldn't care less for a last goodbye
//  For as I die, so do all my enemies
//  There's no tomorrow, and no more today
//  So let us all fade away..."
//
//  Upon this ball of dirt we lived
//  Darkened clouds now to dwell
//  Wasted years of man's creation
//  The final silence now can tell
//  Dogs on leads march to war
//  Go ahead end it all...
//
//  Blow up the world
//  The final silence
//  Blow up the world
//  I don't give a damn!
//
//  When I wrote this code, only I and God knew what it was.
//  Now, only God knows!
//
//  So if you're done trying 'optimize' this routine (and failed),
//  please increment the following counter
//  as a warning to the next guy:
//
//  total_hours_wasted_here = 0
//
//  Created by Elias Abel on 2018/1/24.
//  Copyright © 2018年 Meniny Lab. All rights reserved.
//

import Foundation
import UIKit
import JustLayout

open class ParadiseAlbumButton: UIView {
    open let titleLabel: UILabel = UILabel.init()
    open let imageView: UIImageView = UIImageView.init()
    open let actionButton: UIButton = UIButton.init()
    
    open func addTarget(_ target: Any?, action: Selector, for event: UIControlEvents) {
        self.actionButton.addTarget(target, action: action, for: event)
    }
    
    open func removeTarget(_ target: Any?, action: Selector, for event: UIControlEvents) {
        self.actionButton.removeTarget(target, action: action, for: event)
    }
    
    public init() {
        super.init(frame: .zero)
        self.configuration()
    }
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
        self.configuration()
    }
    
    public required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.configuration()
    }
    
    open var isSelected: Bool = false {
        didSet {
            if isSelected {
                self.imageView.image = UIImage.arrowDropUp
            } else {
                self.imageView.image = UIImage.arrowDropDown
            }
        }
    }
    
    private func configuration() {
        self.width(>=60).height(>=34)
        
        self.titleLabel.font = UIFont.systemFont(ofSize: 14)
        self.titleLabel.textAlignment = .center
        self.titleLabel.textColor = UIColor.darkText
        
        self.imageView.contentMode = .scaleAspectFit
        self.imageView.backgroundColor = UIColor.clear
        
        self.isSelected = false
        
        self.translates(subViews: self.titleLabel, self.imageView, self.actionButton)
        self.layout(
            8,
            |-8-self.titleLabel.height(18)-8-self.imageView.size(18)-8-|,
            8
        )
        self.actionButton.followEdges(self)
    }
}



