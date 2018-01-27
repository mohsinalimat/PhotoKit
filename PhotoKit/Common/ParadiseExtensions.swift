//
//  ParadiseExtensions.swift
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
import MobileCoreServices

public func UIImageSaveToCameraRoll(_ image: UIImage, completion: ((Bool, Error?) -> Swift.Void)? = nil) {
    PHPhotoLibrary.shared().performChanges({
        PHAssetChangeRequest.creationRequestForAsset(from: image)
    }, completionHandler: completion)
}

public func UIVideoSaveToCameraRoll(_ path: URL, completion: ((Bool, Error?) -> Swift.Void)? = nil) {
    PHPhotoLibrary.shared().performChanges({
        PHAssetChangeRequest.creationRequestForAssetFromVideo(atFileURL: path)
    }, completionHandler: completion)
}

public func thumbnail(of video: URL) -> UIImage? {
    do {
        let asset = AVURLAsset(url: video, options: nil)
        let imgGenerator = AVAssetImageGenerator(asset: asset)
        imgGenerator.appliesPreferredTrackTransform = true
        let cgImage = try imgGenerator.copyCGImage(at: CMTimeMakeWithSeconds(0.01, 24), actualTime: nil)
        let uiImage = UIImage(cgImage: cgImage)
        return uiImage
    } catch {
        return nil
    }
}

public extension UIColor {
    public class func hexColor(_ hexStr: NSString, alpha: CGFloat) -> UIColor {
        let realHexStr = hexStr.replacingOccurrences(of: "#", with: "")
        let scanner = Scanner(string: realHexStr as String)
        var color: UInt32 = 0
        if scanner.scanHexInt32(&color) {
            let r = CGFloat((color & 0xFF0000) >> 16) / 255
            let g = CGFloat((color & 0x00FF00) >> 8) / 255
            let b = CGFloat(color & 0x0000FF) / 255
            return UIColor(red: r, green: g, blue: b, alpha: alpha)
        } else {
            print("invalid hex string", terminator: "")
            return UIColor.white
        }
    }
}

public extension AVCaptureDevice {
    public static var isCameraAvailable: Bool {
        let status = AVCaptureDevice.authorizationStatus(for: AVMediaType.video)
        return status == AVAuthorizationStatus.authorized
    }
    
    public enum CurrentFlashMode {
        case off
        case on
        case auto
    }
    
    @available(iOS 10.0, *)
    public func getSettings(flashMode: CurrentFlashMode) -> AVCapturePhotoSettings {
        let settings = AVCapturePhotoSettings()
        
        if self.hasFlash {
            switch flashMode {
            case .auto: settings.flashMode = .auto
            case .on: settings.flashMode = .on
            default: settings.flashMode = .off
            }
        }
        return settings
    }
    
    @available(iOS 10.0, *)
    public static func deviceiOS10(_ types: [AVCaptureDevice.DeviceType] = [.builtInWideAngleCamera],
                                   at position: AVCaptureDevice.Position,
                                   mediaType: AVMediaType? = .video) -> AVCaptureDevice? {
        let devicesIOS10 = AVCaptureDevice.DiscoverySession.init(deviceTypes: [.builtInWideAngleCamera], mediaType: mediaType, position: position)
        for device in devicesIOS10.devices {
            if device.position == position {
                return device
            }
        }
        return nil
    }
    
    public static func device(at position: AVCaptureDevice.Position,
                              mediaType: AVMediaType? = .video) -> AVCaptureDevice? {
        let devices = AVCaptureDevice.devices()
        for device in devices {
            if device.position == position {
                if let t = mediaType {
                    if device.hasMediaType(t) {
                        return device
                    }
                } else {
                    return device
                }
            }
        }
        return nil
    }
}

public extension Bundle {
    public static var photoKit: Bundle {
        return Bundle.init(for: PhotoKit.self)
    }
}

public extension UIImage {
    public convenience init?(photoKit named: String) {
        self.init(named: named, in: Bundle.photoKit, compatibleWith: nil)
    }
    
    public static var arrowDropUp: UIImage? {
        return UIImage.init(photoKit: "arrow_up")
    }
    
    public static var arrowDropDown: UIImage? {
        return UIImage.init(photoKit: "arrow_down")
    }
    
    public static var pinRight: UIImage? {
        return UIImage.init(photoKit: "pin_right")
    }
    
    public static var pinLeft: UIImage? {
        return UIImage.init(photoKit: "pin_left")
    }
}

public extension Array where Element == ParadisePhotoResult {
    public var images: [UIImage] {
        return self.flatMap { (result) -> UIImage? in
            return result.image
        }
    }
    
    public var assets: [PHAsset] {
        return self.flatMap { (result) -> PHAsset? in
            return result.asset
        }
    }
}

public extension Array where Element == ParadiseVideoResult {
    public var images: [UIImage] {
        return self.flatMap { (result) -> UIImage? in
            return result.image
        }
    }
    
    public var urls: [URL] {
        return self.flatMap { (result) -> URL? in
            return result.url
        }
    }
    
    public var assets: [PHAsset] {
        return self.flatMap { (result) -> PHAsset? in
            return result.asset
        }
    }
}

internal extension UIViewController {
    internal var extendedLayout: Bool {
        set {
            self.extendedLayoutIncludesOpaqueBars = newValue
            self.edgesForExtendedLayout = newValue ? .all : []
        }
        get {
            return self.edgesForExtendedLayout != []
        }
    }
}

public extension PHAsset {
    public var isGIF: Bool {
        guard self.mediaType == .image else {
            return false
        }
        guard let uniformTypeIdentifier = self.value(forKey: "uniformTypeIdentifier") as? String else {
            return false
        }
        return uniformTypeIdentifier == kUTTypeGIF as String
    }
}

internal extension PHAssetCollection {
    internal func assetsCount(of type: PHAssetMediaType) -> Int {
        let fetchOptions = PHFetchOptions.init()
        fetchOptions.predicate = NSPredicate(format: "mediaType == %d", type.rawValue)
        let result = PHAsset.fetchAssets(in: self, options: fetchOptions)
        return result.count
    }
}

internal extension TimeInterval {
    internal var formattedString: String {
        let interval = Int(self)
        let seconds = interval % 60
        let minutes = (interval / 60) % 60
        let hours = (interval / 3600)
        if hours > 0 {
            return String(format: "%02d:%02d:%02d", hours, minutes, seconds)
        } else {
            return String(format: "%02d:%02d", minutes, seconds)
        }
    }
    
    internal func format(units: NSCalendar.Unit = [.second, .minute, .hour],
                style: DateComponentsFormatter.UnitsStyle = .positional) -> String? {
        let formatter = DateComponentsFormatter.init()
        formatter.unitsStyle = style
        formatter.allowedUnits = units
        guard let result = formatter.string(from: self) else {
            return nil
        }
        guard !result.isEmpty else {
            return nil
        }
        if style == .positional && !result.contains(":") {
            if result.count == 1 {
                return "00:0\(result)"
            }
            return "00:\(result)"
        }
        return result
    }
}

internal extension IndexSet {
    
    internal func indexPathsFromIndexes(section: Int) -> [IndexPath] {
        var indexPaths: [IndexPath] = []
        indexPaths.reserveCapacity(self.count)
        (self as NSIndexSet).enumerate({idx, stop in
            indexPaths.append(IndexPath(item: idx, section: section))
        })
        return indexPaths
    }
}

internal extension UICollectionView {
    
    internal func indexPathsForElements(in rect: CGRect) -> [IndexPath] {
        let allLayoutAttributes = self.collectionViewLayout.layoutAttributesForElements(in: rect)
        if (allLayoutAttributes?.count ?? 0) == 0 {return []}
        
        var indexPaths: [IndexPath] = []
        indexPaths.reserveCapacity(allLayoutAttributes!.count)
        
        for layoutAttributes in allLayoutAttributes! {
            let indexPath = layoutAttributes.indexPath
            indexPaths.append(indexPath)
        }
        
        return indexPaths
    }
}

internal extension UIView {
    internal func addBottomBorder(_ color: UIColor, width: CGFloat) {
        let border = CALayer()
        border.borderColor = color.cgColor
        border.frame = CGRect(x: 0, y: self.frame.size.height - width, width:  self.frame.size.width, height: width)
        border.borderWidth = width
        self.layer.addSublayer(border)
    }
    
    @IBInspectable var shadowColor: CGColor? {
        get {
            return layer.shadowColor
        }
        set {
            layer.shadowColor = newValue
        }
    }
    
    @IBInspectable var shadowOffset: CGSize {
        get {
            return layer.shadowOffset
        }
        set {
            layer.shadowOffset = newValue
        }
    }
    
    @IBInspectable var shadowRadius: CGFloat {
        get {
            return layer.shadowRadius
        }
        set {
            layer.shadowRadius = newValue
        }
    }
    
    @IBInspectable var shadowOpacity: Float {
        get {
            return layer.shadowOpacity
        }
        set {
            layer.shadowOpacity = newValue
        }
    }
    
    @IBInspectable var cornerRadius: CGFloat {
        get {
            return layer.cornerRadius
        }
        set {
            layer.cornerRadius = newValue
            layer.masksToBounds = newValue > 0
        }
    }
    
    @IBInspectable var borderWidth: CGFloat {
        get {
            return layer.borderWidth
        }
        set {
            layer.borderWidth = newValue
        }
    }
    
    @IBInspectable var borderColor: UIColor? {
        get {
            guard let cg = self.layer.borderColor else {
                return nil
            }
            return UIColor.init(cgColor: cg)
        }
        set {
            layer.borderColor = newValue?.cgColor
        }
    }
}

internal extension UICollectionViewCell {
    private static func private_reusableCell<T: UICollectionViewCell>(dequeued collectionView: UICollectionView, identifier: String, for indexPath: IndexPath) -> T {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: identifier, for: indexPath)
        return cell as! T
    }
    
    internal static func reusableCell(dequeued collectionView: UICollectionView, identifier: String, for indexPath: IndexPath) -> Self {
        return self.private_reusableCell(dequeued: collectionView, identifier: identifier, for: indexPath)
    }
}
