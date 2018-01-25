//
//  ParadisePhotoPreviewController.swift
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
import Photos
import JustLayout

open class ParadisePhotoPreviewController: ParadiseViewController {
    
    open weak var dataSource: ParadisePhotoPreviewDataSource? = nil
    open weak var delegate: ParadisePhotoPreviewDelegate? = nil
    
    public init() {
        super.init(nibName: nil, bundle: nil)
    }
    
    public required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    open lazy var collectionFlowLayout: UICollectionViewFlowLayout = {
        let layout = UICollectionViewFlowLayout.init()
        layout.scrollDirection = .horizontal
        layout.minimumLineSpacing = self.collectionItemMargin
        layout.minimumInteritemSpacing = self.collectionItemMargin
        return layout
    }()
    
    internal let collectionItemMargin: CGFloat = 5
    internal let collectionEdgeMargin: CGFloat = 5
    internal let collectionHeight: CGFloat = 48
    internal let bottomHeight: CGFloat = 48
    internal var barBottomMargin: CGFloat {
        return UIApplication.iPhoneX ? SafeAreaBottomPadding.iPhoneX.rawValue : 0
    }
    internal var imageViewHeight: CGFloat {
        return self.view.bounds.height - self.collectionHeight - self.bottomHeight - self.collectionEdgeMargin * 2 - self.barBottomMargin
    }
    
    public var collectionCellSize: CGSize {
        return CGSize.init(width: self.collectionHeight, height: self.collectionHeight)
    }
    
    open lazy var collectionView: UICollectionView = {
        let collection = UICollectionView.init(frame: .zero, collectionViewLayout: self.collectionFlowLayout)
        let identifier = ParadisePhotoPreviewCollectionViewCell.reusableCellIdentifier
        let nib = UINib.init(nibName: identifier, bundle: Bundle.init(for: ParadisePhotoKit.self))
        collection.register(nib, forCellWithReuseIdentifier: identifier)
        collection.allowsSelection = true
        collection.allowsMultipleSelection = true
        collection.backgroundColor = UIColor.clear
        return collection
    }()
    
    open lazy var imageView: ParadiseImageView = {
        let frame = CGRect.init(x: 0, y: 0, width: self.view.bounds.width, height: self.imageViewHeight)
        let imgView = ParadiseImageView.init(frame: frame)
//        imgView.contentMode = .scaleAspectFill
        imgView.clipsToBounds = true
        imgView.backgroundColor = UIColor.clear
        return imgView
    }()
    
    open lazy var bottomBar: UIView = {
        let bar = UIView.init()
        bar.clipsToBounds = true
        bar.backgroundColor = UIColor.clear
        return bar
    }()
    
    open override func viewDidLoad() {
        super.viewDidLoad()
        
        self.setupUIComponents()
        
        if (self.dataSource?.numberOfItems(in: self) ?? 0) > 0 {
            self.loadImage(at: IndexPath.init(item: 0, section: 0))
        }
    }
    
    open func setupUIComponents() {
        
        self.navigationItem.leftBarButtonItem = nil
        self.navigationItem.rightBarButtonItem = UIBarButtonItem.init(image: UIImage.pinRight, style: .plain, target: self, action: #selector(doneAction))
        
        self.view.backgroundColor = UIColor.black
        
        self.view.translates(subViews: self.imageView, self.collectionView, self.bottomBar)
        
        self.view.layout(
            0,
            |-0-self.imageView-0-|,
            self.collectionEdgeMargin,
            |-self.collectionEdgeMargin-self.collectionView.height(self.collectionHeight)-self.collectionEdgeMargin-|,
            self.collectionEdgeMargin,
            |-0-self.bottomBar.height(self.bottomHeight)-0-|,
            self.barBottomMargin
        )
        self.collectionView.delegate = self
        self.collectionView.dataSource = self
    }
    
    @objc
    internal func doneAction() {
        self.delegate?.previewerDidFinish(self)
    }
}

extension ParadisePhotoPreviewController: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    public func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let identifier = ParadisePhotoPreviewCollectionViewCell.reusableCellIdentifier
        let cell = ParadisePhotoPreviewCollectionViewCell.reusableCell(dequeued: collectionView, identifier: identifier, for: indexPath)
        
        let currentTag = cell.tag + 1
        cell.tag = currentTag
        
        cell.backgroundColor = UIColor.clear
        cell.contentView.backgroundColor = cell.backgroundColor
        cell.cornerRadius = 3
        cell.clipsToBounds = true
        
        if let asset = self.dataSource?.previewer(self, assetForItemAt: indexPath.item) { // exists
            
            switch asset.mediaType {
            case .unknown, .audio:
                cell.thumbnailView.image = nil
                break
            default:
                ParadiseMachine.request(image: .original, form: asset, sourceMode: nil, completion: { (results) in
                    if cell.tag == currentTag {
                        cell.thumbnailView.image = results.image
                    }
                })
                break
            }
            return cell
        }
        
        cell.thumbnailView.image = nil
        return cell
    }
    
    public func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    public func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.dataSource?.numberOfItems(in: self) ?? 0
    }
    
    public func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        self.loadImage(at: indexPath)
    }
    
    public func loadImage(at indexPath: IndexPath) {
        if let asset = self.dataSource?.previewer(self, assetForItemAt: indexPath.item) {
            if asset.isGIF {
                ParadiseMachine.requestGIF(from: asset, completion: { (gif) in
                    if let gif = gif {
                        self.imageView.image = gif
                    } else {
                        self.loadImageFromCell(at: indexPath, asset: asset)
                    }
                })
                return
            }
            self.loadImageFromCell(at: indexPath, asset: asset)
        }
    }
    
    public func loadImageFromCell(at indexPath: IndexPath, asset: PHAsset?) {
        guard let cell = collectionView.cellForItem(at: indexPath) as? ParadisePhotoPreviewCollectionViewCell,
            let image = cell.thumbnailView.image else {
                if let asset = asset {
                    ParadiseMachine.request(image: .original, form: asset, sourceMode: nil, completion: { (result) in
                        self.imageView.image = result.image
                    })
                }
                return
        }
        self.imageView.image = image
    }
    
    public func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return self.collectionCellSize
    }
    
}
