//
//  ParadisePreviewController.swift
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

open class ParadisePreviewController: ParadiseViewController {
    
    open weak var dataSource: ParadisePhotoPreviewDataSource? = nil
    open weak var delegate: ParadisePhotoPreviewDelegate? = nil
    
    open var previewMode: ParadisePreviewMode = ParadisePreviewMode.photos
    
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
        collection.allowsMultipleSelection = false
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
    
    internal lazy var backButton: UIButton = {
        let button = UIButton.init()
        button.setImage(UIImage.pinLeft?.withRenderingMode(.alwaysTemplate), for: .normal)
        button.tintColor = UIColor.white
        return button
    }()
    
    internal lazy var doneButton: UIButton = {
        let button = UIButton.init()
        button.setImage(UIImage.pinRight?.withRenderingMode(.alwaysTemplate), for: .normal)
        button.tintColor = UIColor.white
        return button
    }()
    
    internal let fakeNavigationBar: UIView = UIView.init()
    
    open override func viewDidLoad() {
        super.viewDidLoad()
        
        self.setupUIComponents()
        
        self.dataSource?.previewer(self, requestImageForItemAt: 0, completion: { (img) in
            if self.imageView.image == nil {
                self.imageView.image = img
            }
        })
    }
    
    open func setupUIComponents() {
        
        self.navigationController?.isNavigationBarHidden = true
        self.view.backgroundColor = ParadisePhotoKitConfiguration.darkBackgroundColor
        
        let naviHeight: CGFloat = 44
        let fakeNaviHeight = StatusBarHeight.default + naviHeight
        
        self.view.translates(subViews: self.imageView, self.fakeNavigationBar, self.collectionView, self.bottomBar)
        self.view.layout(
            fakeNaviHeight,
            |-0-self.imageView-0-|,
            self.collectionEdgeMargin,
            |-self.collectionEdgeMargin-self.collectionView.height(self.collectionHeight)-self.collectionEdgeMargin-|,
            self.collectionEdgeMargin,
            |-0-self.bottomBar.height(self.bottomHeight)-0-|,
            self.barBottomMargin
        )
        self.collectionView.delegate = self
        self.collectionView.dataSource = self
        
        self.fakeNavigationBar.left(0).right(0).height(fakeNaviHeight).top(0)
        self.fakeNavigationBar.translates(subViews: self.backButton, self.doneButton)
        self.backButton.left(0).bottom(0).size(naviHeight)
        self.doneButton.right(0).bottom(0).size(naviHeight)
        self.backButton.addTarget(self, action: #selector(backAction), for: .touchUpInside)
        self.doneButton.addTarget(self, action: #selector(doneAction), for: .touchUpInside)
        self.fakeNavigationBar.backgroundColor = ParadisePhotoKitConfiguration.fakeBarColor
    }
    
    @objc
    internal func doneAction() {
        self.delegate?.previewerDidFinish(self)
    }
    
    @objc
    internal func backAction() {
        self.navigationController?.popViewController(animated: true)
    }
    
    var selectedIndex: IndexPath = IndexPath.init(item: 0, section: 0)
}

extension ParadisePreviewController: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    public func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let identifier = ParadisePhotoPreviewCollectionViewCell.reusableCellIdentifier
        let cell = ParadisePhotoPreviewCollectionViewCell.reusableCell(dequeued: collectionView, identifier: identifier, for: indexPath)
        
        cell.backgroundColor = UIColor.clear
        cell.contentView.backgroundColor = cell.backgroundColor
        cell.clipsToBounds = true
        
        cell.selectionView.borderColor = ParadisePhotoKitConfiguration.borderColor
        let borderWidth: CGFloat = (indexPath == self.selectedIndex) ? 2 : 0
        cell.selectionView.borderWidth = borderWidth
        
        self.dataSource?.previewer(self, requestImageForItemAt: indexPath.item, completion: { (img) in
            cell.thumbnailView.image = img
        })
        
        return cell
    }
    
    public func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    public func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.dataSource?.numberOfItems(in: self) ?? 0
    }
    
    public func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        self.selectedIndex = indexPath
        self.dataSource?.previewer(self, requestImageForItemAt: indexPath.item, completion: { (img) in
            if let img = img {
                if let current = self.imageView.image {
                    if img != current {
                        self.imageView.image = img
                    }
                } else {
                    self.imageView.image = img
                }
            }
            self.collectionView.reloadSections([0])
        })
    }
    
    public func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return self.collectionCellSize
    }
    
}
