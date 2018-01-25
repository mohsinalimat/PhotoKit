//
//  ParadiseMachine.swift
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

public typealias ImageRequestCompletion = (_ result: ParadiseResult) -> Swift.Void
public typealias MultiImageRequestCompletion = (_ result: [ParadiseResult]) -> Swift.Void

open class ParadiseMachine {
    
    private init() {}
    
    // Check the status of authorization for PHPhotoLibrary
    open class func checkPhotoAuth(_ action: @escaping (_ authorized: Bool) -> Void) {
        PHPhotoLibrary.requestAuthorization { (status) -> Void in
            DispatchQueue.main.async {
                action(status == .authorized)
            }
        }
    }
    
    open class func request(image: ParadiseImageType,
                            form asset: PHAsset,
                            sourceMode: ParadiseSourceType?,
                            completion: @escaping ImageRequestCompletion) {
        self.request(images: image, form: [asset], sourceMode: sourceMode) { (results) in
            guard let r = results.first else {
                completion(ParadiseResult.init(source: nil, image: nil, videoURL: nil, asset: asset, info: nil))
                return
            }
            completion(r)
        }
    }
    
    open static var imageRequestOptions: PHImageRequestOptions {
        let options = PHImageRequestOptions()
        options.deliveryMode = .highQualityFormat
        options.isNetworkAccessAllowed = true
        options.resizeMode = .exact
        return options
    }
    
    open class func request(images: ParadiseImageType,
                            form assets: [PHAsset],
                            sourceMode: ParadiseSourceType?,
                            completion: @escaping MultiImageRequestCompletion) {
        
        guard !assets.isEmpty else {
            DispatchQueue.main.async(execute: {
                completion([])
            })
            return
        }
        
        let options = self.imageRequestOptions
        var results: [ParadiseResult] = []
        var counter: Int = 0
        for asset in assets {
            DispatchQueue.global(qos: .default).async(execute: {
                PHImageManager.default().requestImage(for: asset, targetSize: images.size, contentMode: .aspectFill, options: options) { image, info in
                    counter += 1
                    results.append(ParadiseResult.init(source: sourceMode, image: image, videoURL: nil, asset: asset, info: info))
                    if counter == assets.count {
                        DispatchQueue.main.async(execute: {
                            completion(results)
                        })
                    }
                }
            })
        }
    }
    
    open class func requestGIF(from asset: PHAsset, completion: @escaping (_ gif: UIImage?) -> Void) {
        let options = self.imageRequestOptions
        DispatchQueue.global(qos: .default).async(execute: {
            PHImageManager.default().requestImageData(for: asset, options: options, resultHandler: { (data, dataUTI, _, info) in
                if let data = data, let uti = dataUTI {
                    if uti == "com.compuserve.gif" {
                        let image = UIImage.gif(data: data)
                        DispatchQueue.main.async {
                            completion(image)
                        }
                        return
                    }
                }
                completion(nil)
            })
        })
    }
    
    open class func mp4(from original: URL, completion: @escaping (_ result: URL, _ error: Error?) -> Void) {
        
        let mp4Path = original.path.replacingOccurrences(of: ".mov", with: ".mp4")
        
        if FileManager.default.fileExists(atPath: mp4Path) {
            do {
                try FileManager.default.removeItem(atPath: mp4Path)
            } catch let error {
                print("CANNOT CONVERT TO MP4: \(error)")
                completion(original, VideoConversionError.cannotSave)
                return
            }
        }
        
        let mp4URL = URL.init(fileURLWithPath: mp4Path)
        
        let presets = [
            AVAssetExportPresetPassthrough,
            AVAssetExportPresetHighestQuality,
            AVAssetExportPresetMediumQuality,
            AVAssetExportPresetLowQuality]
        var presetCompatible: String?
        
        let avAsset = AVURLAsset.init(url: original)
        
        for preset in presets {
            if AVAssetExportSession.exportPresets(compatibleWith: avAsset).contains(preset) {
                presetCompatible = preset
                break
            }
        }
        
        guard let thePreset = presetCompatible  else {
            print("CANNOT CONVERT TO MP4")
            completion(original, VideoConversionError.noCompatiblePresets)
            return
        }
        
        guard let exportSession = AVAssetExportSession.init(asset: avAsset, presetName: thePreset) else {
            print("CANNOT CONVERT TO MP4")
            completion(original, VideoConversionError.cannotCreateExportSession)
            return
        }
        
        exportSession.outputURL = mp4URL
        exportSession.outputFileType = AVFileType.mp4
        
        exportSession.exportAsynchronously(completionHandler: {
            switch exportSession.status {
            case .failed, .cancelled:
                print("CANNOT CONVERT TO MP4: \(String.init(describing: exportSession.error))")
                completion(original, exportSession.error)
                break
            case .completed:
                print("MP4 FILE SAVED AT: \(mp4URL)")
                completion(mp4URL, nil)
                break
            default:
                break
            }
        })
    }
}

