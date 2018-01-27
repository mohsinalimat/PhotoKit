//
//  Configuration.swift
//  ParadisePhotoKit
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
//  Created by Elias Abel on 2018/1/19.
//  Copyright © 2018年 Meniny Lab. All rights reserved.
//

import Foundation
import UIKit

open class ParadisePhotoKitConfiguration {
    open static var baseTintColor   = UIColor(red: 0.79, green: 0.78, blue: 0.78, alpha: 1)
    open static var tintColor       = UIColor(red: 0.26, green: 0.25, blue: 0.25, alpha: 1)
    open static var lightBackgroundColor = UIColor(red: 0.99, green: 0.99, blue: 0.99, alpha: 1)
    open static var darkBackgroundColor = UIColor.black//UIColor(red: 0.26, green: 0.25, blue: 0.25, alpha: 1)
    open static var borderColor     = UIColor(red: 0.64, green: 0.64, blue: 0.99, alpha: 1)
    
    open static var fakeBarColor    = UIColor.init(white: 0, alpha: 0.6)
    
    open static var checkImage: UIImage?
    open static var closeImage: UIImage?
    open static var flashOnImage: UIImage?
    open static var flashOffImage: UIImage?
    open static var flipImage: UIImage?
    open static var shotImage: UIImage?
    
    open static var videoStartImage: UIImage?
    open static var videoStopImage: UIImage?
    
    open static var shouldAutoSavesImage: Bool = true
    open static var shouldAutoSavesVideo: Bool = true
    
    open static var cameraRollTitle = "Library"
    open static var cameraTitle     = "Photo"
    open static var videoTitle      = "Video"
    open static var titleFont       = UIFont(name: "AvenirNext-DemiBold", size: 15)
    
//    open static var shouldAutoDismiss: Bool = true
    
    open static var autoConvertToMP4: Bool = true
}

