//
//  ParadiseDefines.swift
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

internal enum SafeAreaBottomPadding: CGFloat {
    case normal = 0
    case iPhoneX = 16
    
    static var `default`: CGFloat {
        if UIApplication.iPhoneX {
            return self.iPhoneX.rawValue
        }
        return self.normal.rawValue
    }
}

internal enum StatusBarHeight: CGFloat {
    case normal = 20
    case iPhoneX = 44
    
    static var `default`: CGFloat {
        if UIApplication.iPhoneX {
            return self.iPhoneX.rawValue
        }
        return self.normal.rawValue
    }
}

internal extension UIApplication {
    internal class var iPhoneX: Bool {
        #if os(iOS)
            guard UIDevice.current.userInterfaceIdiom == .phone else {
                return false
            }
            let height = UIScreen.main.fixedCoordinateSpace.bounds.size.height
            return height == 812
        #else
            return false
        #endif
    }
}

public enum ParadiseLibraryMediaType: String {
    case photos = "Photos"
    case videos = "Videos"
//    case all    = "Library"
    
    public var fetchAssetMediaType: PHAssetMediaType {
        switch self {
        case .photos:
            return PHAssetMediaType.image
        default:
            return PHAssetMediaType.video
        }
    }
    
    public var localizedTitle: String {
        return NSLocalizedString("\(self.rawValue) Library", comment: "")
    }
}

public enum ParadisePreviewMode: String {
    case photos = "Photos"
    case videos = "Videos"
    
    public var fetchAssetMediaType: PHAssetMediaType {
        switch self {
        case .photos:
            return PHAssetMediaType.image
        default:
            return PHAssetMediaType.video
        }
    }
    
    public var localizedTitle: String {
        return NSLocalizedString("\(self.rawValue) Preview", comment: "")
    }
}

public enum ParadiseCameraType: String {
    case photo = "Photo"
    case video = "Video"
    
    public var localizedTitle: String {
        return NSLocalizedString("\(self.rawValue) Camera", comment: "")
    }
}

public enum ParadiseSourceType: Equatable {
    case library(of: ParadiseLibraryMediaType, limit: Int)
    case camera(of: ParadiseCameraType)
    
    public static var `default`: ParadiseSourceType {
        return ParadiseSourceType.library(of: .photos, limit: 1)
    }
    
    public static func ==(lhs: ParadiseSourceType, rhs: ParadiseSourceType) -> Bool {
        switch (lhs, rhs) {
        case let (.library(of: a, limit: b), .library(of: c, limit: d)):
            return a == c && b == d
        case let (.camera(of: a), .camera(of: b)):
            return a == b
        default:
            return false
        }
    }
    
    public var localizedTitle: String {
        switch self {
        case .library(of: let type, limit: _):
            return type.localizedTitle
        case .camera(of: let type):
            return type.localizedTitle
        }
    }
}

public enum ParadiseVideoFormat: String {
    case mov = "mov"
    case mp4 = "mp4"
    
    public var formatExtension: String {
        return self.rawValue
    }
    
    public var mimeType: String {
        switch self {
        case .mov:
            return "video/quicktime"
        case .mp4:
            return "video/mp4"
        }
    }
}

public enum ParadiseImageType: Equatable {
    case thumbnail(size: CGSize)
    case original
    
    public static func ==(lhs: ParadiseImageType, rhs: ParadiseImageType) -> Bool {
        switch (lhs, rhs) {
        case let (.thumbnail(size: a), thumbnail(size: b)):
            return a == b
        case (.original, .original):
            return true
        default:
            return false
        }
    }
    
    public var size: CGSize {
        switch self {
        case .thumbnail(size: let s):
            return s
        default:
            return PHImageManagerMaximumSize
        }
    }
}

public enum VideoConversionError: Error {
    case cannotSave
    case noCompatiblePresets
    case cannotCreateExportSession
    case unknown
    
    public var localizedDescription: String {
        switch self {
        case .cannotSave:
            return "Cannot Save"
        case .noCompatiblePresets:
            return "Cannot Find Any Compatible Presets"
        case .cannotCreateExportSession:
            return "Cannot Create Export Session"
        default:
            return "Unknown"
        }
    }
}
