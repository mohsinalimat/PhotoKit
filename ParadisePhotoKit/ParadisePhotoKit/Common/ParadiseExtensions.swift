//
//  ParadiseExtensions.swift
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

public extension UIImage {
    public static var arrowDropUp: UIImage? {
        return UIImage.init(named: "arrow drop up")
    }
    
    public static var arrowDropDown: UIImage? {
        return UIImage.init(named: "arrow drop down")
    }
    
    public static var pinRight: UIImage? {
        return UIImage.init(named: "Pin ri")
    }
    
    public static var pinLeft: UIImage? {
        return UIImage.init(named: "Pin Left")
    }
}

public extension Array where Element == ParadiseResult {
    public var images: [UIImage] {
        return self.flatMap { (result) -> UIImage? in
            return result.image
        }
    }
    
    public var videoURLs: [URL] {
        return self.flatMap { (result) -> URL? in
            return result.videoURL
        }
    }
    
    public var assets: [PHAsset] {
        return self.flatMap { (result) -> PHAsset in
            return result.asset
        }
    }
    
    public var informations: [[AnyHashable: Any]] {
        return self.flatMap { (result) -> [AnyHashable: Any]? in
            return result.info
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
