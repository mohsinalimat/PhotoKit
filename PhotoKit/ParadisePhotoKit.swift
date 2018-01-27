//
//  ParadisePhotoKit.swift
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
//  Created by Elias Abel on 2018/1/24.
//  Copyright © 2018年 Meniny Lab. All rights reserved.
//

import Foundation
import UIKit
import Photos

open class ParadisePhotoKit {
    
    open weak var delegate: ParadisePhotoKitDelegate?
    
    open let controller: ParadiseViewController & ParadiseSourceable
    
    private var _multiSelectionLimit: Int = 1
    
    open var multiSelectionLimit: Int {
        set {
            _multiSelectionLimit = (newValue > 0) ? newValue : 1
        }
        get {
            return _multiSelectionLimit
        }
    }
    
    open var sourceType: ParadiseSourceType {
        return self.controller.sourceType
    }
    
    public convenience init() {
        self.init(source: .default)
    }
    
    public required init(source: ParadiseSourceType) {
        switch source {
        case .library(of: let type, limit: let limit):
            self.controller = ParadiseLibraryController.init(type: type)
            self.multiSelectionLimit = limit
            break
        case .camera(of: let type):
            self.controller = ParadiseCameraController.init(type: type)
            break
        }
    }
    
    open func presented(by sender: UIViewController,
                        animated: Bool = true,
                        completion: (() -> Void)?) {
        self.controller.photoKit = self
        let navigation = ParadiseNavigationController.init(rootViewController: self.controller)
        sender.present(navigation, animated: animated, completion: completion)
    }
    
    @discardableResult
    open class func present(_ source: ParadiseSourceType,
                            by sender: UIViewController,
                            animated: Bool = true,
                            completion: (() -> Void)? = nil) -> Self {
        
        let photoKit = self.init(source: source)
        photoKit.presented(by: sender, animated: animated, completion: completion)
        return photoKit
    }
    
    open class func show(alert: String,
                         message: String,
                         to controller: ParadiseViewController & ParadiseSourceable,
                         confirm: String?,
                         cancel: String,
                         action: @escaping (_ positive: Bool) -> Void) {
        
        let alertController = UIAlertController.init(title: alert, message: message, preferredStyle: .alert)
        let closure: ((UIAlertAction) -> Void) = { button in
            guard let t = button.title else {
                action(false)
                return
            }
            action(t != cancel)
        }
        if let cf = confirm {
            alertController.addAction(UIAlertAction.init(title: cf, style: .default, handler: closure))
        }
        alertController.addAction(UIAlertAction.init(title: cancel, style: .cancel, handler: closure))
        controller.present(alertController, animated: true, completion: nil)
    }
}
