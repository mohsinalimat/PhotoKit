//
//  ParadiseProtocols.swift
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
import Photos

public protocol ParadiseSourceable: class {
    var sourceType: ParadiseSourceType { get }
}

public protocol PhotoKitDelegate: class {
    /// Required function
    func photoKit(_ photoKit: PhotoKit, didSelectPhotos photos: [ParadisePhotoResult], from source: ParadiseSourceType)
    /// Required function
    func photoKit(_ photoKit: PhotoKit, didCapturePhoto photo: UIImage, from source: ParadiseSourceType)
    /// Required function
    func photoKit(_ photoKit: PhotoKit, didSelectVideos videos: [ParadiseVideoResult], from source: ParadiseSourceType)
    /// Required function
    func photoKit(_ photoKit: PhotoKit, didCaptureVideo videoFile: URL, from source: ParadiseSourceType)
    
    /// Optional function
    func photoKitDidCancel(_ photoKit: PhotoKit)
    /// Optional function
    func photoKitUnauthorized(_ photoKit: PhotoKit)
    /// Optional function
    func photoKit(_ photoKit: PhotoKit, showAlert title: String, message: String, to controller: ParadiseViewController & ParadiseSourceable, confirm: String?, cancel: String, action: @escaping (_ positive: Bool) -> Void)
}

public extension PhotoKitDelegate {
    public func photoKitDidCancel(_ photoKit: PhotoKit) {}
    public func photoKitUnauthorized(_ photoKit: PhotoKit) {}
    
    public func photoKit(_ photoKit: PhotoKit,
                         showAlert alert: String,
                         message: String,
                         to controller: ParadiseViewController & ParadiseSourceable,
                         confirm: String?,
                         cancel: String,
                         action: @escaping (_ positive: Bool) -> Void) {
        
        type(of: photoKit).show(alert: alert, message: message, to: controller, confirm: confirm, cancel: cancel, action: action)
    }
}

public protocol ParadisePhotoPreviewDataSource: class {
    func numberOfItems(in previewController: ParadisePreviewController) -> Int
    func previewer(_ previewController: ParadisePreviewController, assetForItemAt index: Int) -> PHAsset?
    func previewer(_ previewController: ParadisePreviewController, requestImageForItemAt index: Int, completion: @escaping (_ image: UIImage?) -> Void)
    func previewer(_ previewController: ParadisePreviewController, requestVideoForItemAt index: Int, completion: @escaping (_ path: URL?) -> Void)
}

public extension ParadisePhotoPreviewDataSource {
    public func previewer(_ previewController: ParadisePreviewController, assetForItemAt index: Int) -> PHAsset? { return nil }
    public func previewer(_ previewController: ParadisePreviewController, requestImageForItemAt index: Int, completion: @escaping (_ image: UIImage?) -> Void) {}
    public func previewer(_ previewController: ParadisePreviewController, requestVideoForItemAt index: Int, completion: @escaping (_ path: URL?) -> Void) {}
}

public protocol ParadisePhotoPreviewDelegate: class {
    func previewerDidFinish(_ previewController: ParadisePreviewController)
}
