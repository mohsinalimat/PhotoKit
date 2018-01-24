//
//  ParadiseLibraryController.swift
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

open class ParadiseLibraryController: ParadiseViewController, ParadiseSourceable {
    
    open var sourceType: ParadiseSourceType {
        return ParadiseSourceType.library(of: self.mediaType, limit: self.multiSelectionLimit)
    }
    
    open let mediaType: ParadiseLibraryMediaType
    
    public required init(type: ParadiseLibraryMediaType) {
        self.mediaType = type
        super.init(nibName: nil, bundle: nil)
    }
    
    public required init?(coder aDecoder: NSCoder) {
        self.mediaType = .photos
        super.init(coder: aDecoder)
    }
    
    open lazy var collectionFlowLayout: UICollectionViewFlowLayout = {
        let layout = UICollectionViewFlowLayout.init()
        layout.scrollDirection = .vertical
        layout.minimumLineSpacing = self.collectionItemMargin
        layout.minimumInteritemSpacing = self.collectionItemMargin
        return layout
    }()
    
    open lazy var collectionView: UICollectionView = {
        let collection = UICollectionView.init(frame: .zero, collectionViewLayout: self.collectionFlowLayout)
        let identifier = ParadisePhotoSelectionCollectionViewCell.reusableCellIdentifier
        let nib = UINib.init(nibName: identifier, bundle: Bundle.init(for: ParadisePhotoKit.self))
        collection.register(nib, forCellWithReuseIdentifier: identifier)
        collection.allowsSelection = true
        collection.allowsMultipleSelection = true
        collection.backgroundColor = UIColor.clear
        return collection
    }()
    
    internal let collectionCellSize = CGSize(width: 100, height: 100)
    
    internal let collectionEdgeMargin: CGFloat = 5
    internal let collectionItemMargin: CGFloat = 2
    
    open lazy var imageManager: PHCachingImageManager = PHCachingImageManager.init()
    
    internal var _assets: PHFetchResult<PHAsset>?
    internal var _fullAssets: PHFetchResult<PHAsset>?
    
    open var assets: PHFetchResult<PHAsset>? {
        get {
            if self.selectedAlbum == nil {
                return _fullAssets
            }
            return _assets
        }
    }
    
    open var assetsCount: Int {
        return self.assets?.count ?? 0
    }
    
    open func asset(at index: Int) -> PHAsset? {
        guard self.assets != nil else {
            return nil
        }
        guard index >= 0 && index < self.assetsCount else {
            return nil
        }
        return self.assets?[index]
    }
    
    open private(set) var albums: PHFetchResult<PHAssetCollection>?
    open private(set) var selectedAlbum: PHAssetCollection?
    
    open var albumsCount: Int {
        return self.albums?.count ?? 0
    }
    
    open func album(at index: Int) -> PHAssetCollection? {
        guard self.albums != nil else {
            return nil
        }
        guard index >= 0 && index < self.albumsCount else {
            return nil
        }
        return self.albums?[index]
    }
    
    open private(set) var selectedAssets: [PHAsset] = []
    
    open func selectedAsset(at index: Int) -> PHAsset? {
        guard index >= 0 && index < self.selectedAssets.count else {
            return nil
        }
        return self.selectedAssets[index]
    }
    
    /// Sorting condition
    open lazy var assetsFetchOptions: PHFetchOptions = {
        let options = PHFetchOptions.init()
        options.predicate = NSPredicate.init(format: "mediaType = %i", self.mediaType.fetchAssetMediaType.rawValue)
        options.sortDescriptors = [
            NSSortDescriptor(key: "creationDate", ascending: false)
        ]
        return options
    }()
    
    internal var previousPreheatRect: CGRect = .zero
    
    internal lazy var albumButton: ParadiseAlbumButton = {
        let button = ParadiseAlbumButton.init()
        button.titleLabel.text = "All Photos"
        button.addTarget(self, action: #selector(showAlbumList), for: UIControlEvents.touchUpInside)
        return button
    }()
    
    open internal(set) lazy var tableView: UITableView = {
        let table = UITableView.init(frame: .zero, style: UITableViewStyle.plain)
        table.tableFooterView = UIView.init()
        table.backgroundColor = UIColor.white
        table.clipsToBounds = true
        table.separatorInset = UIEdgeInsets.zero
        let identifier = ParadiseAlbumListTableViewCell.reusableCellIdentifier
        let nib = UINib.init(nibName: identifier, bundle: Bundle.init(for: ParadisePhotoKit.self))
        table.register(nib, forCellReuseIdentifier: identifier)
        return table
    }()
    
    open let tableViewCellHeight: CGFloat = 56
    open let tableViewCellVisibleLimit: Int = 4
    
    open var tableViewHeight: CGFloat {
        return self.tableViewCellHeight * CGFloat(self.tableViewCellVisibleLimit)
    }
    
    open internal(set) lazy var tableViewShadowView: UIView = {
        let shadow = UIView.init()
        shadow.backgroundColor = UIColor.white
        shadow.alpha = 0
        shadow.clipsToBounds = false
        shadow.shadowOffset = CGSize.init(width: 0, height: 3)
        shadow.shadowOpacity = 1
        shadow.shadowRadius = 5
        shadow.shadowColor = UIColor.init(white: 0, alpha: 0.4).cgColor
        return shadow
    }()
    
    open internal(set) lazy var tableViewShadowExtendedButton: UIButton = {
        let button = UIButton.init()
        button.addTarget(self, action: #selector(showAlbumList), for: UIControlEvents.touchUpInside)
        button.alpha = 0
        return button
    }()
    
    internal func updateTitle() {
//        self.navigationItem.title = "\(self.selectedAssets.count) / \(self.multiSelectionLimit)"
    }
    
    open override func viewDidLoad() {
        super.viewDidLoad()
        
        self.setupUIComponents()
        self.setupBarButtonItems(hasAlbum: false)
        self.checkPhotoAuth()
    }
    
    open func checkPhotoAuth() {
        // Never load photos Unless the user allows to access to photo album
        ParadiseMachine.checkPhotoAuth { (authorized) in
            if authorized {
                self.setupAlbums()
                self.setupFullAssets()
                self.setupBarButtonItems(hasAlbum: true)
                PHPhotoLibrary.shared().register(self)
            } else {
                if let pk = self.photoKit {
                    pk.delegate?.photoKitUnauthorized(pk)
                }
            }
        }
    }
    
    open func setupUIComponents() {
        self.view.backgroundColor = UIColor(red:0.99, green:1.00, blue:1.00, alpha:1.00)
        self.updateTitle()
        
        self.view.translates(subViews: self.collectionView, self.tableViewShadowView, self.tableViewShadowExtendedButton, self.tableView)
        self.view.layout(
            self.collectionEdgeMargin,
            |-self.collectionEdgeMargin-self.collectionView-self.collectionEdgeMargin-|,
            self.collectionEdgeMargin
        )
        self.collectionView.delegate = self
        self.collectionView.dataSource = self
        
        self.tableView.top(-self.tableViewHeight).left(0).right(0).height(self.tableViewHeight)
        self.tableView.delegate = self
        self.tableView.dataSource = self
        
        self.tableViewShadowView.followEdges(self.tableView)
        self.tableViewShadowExtendedButton.topAttribute == self.tableViewShadowView.bottomAttribute
        self.tableViewShadowExtendedButton.left(0).right(0).bottom(0)
    }
    
    open func setupBarButtonItems(hasAlbum: Bool) {
        self.navigationItem.rightBarButtonItem = UIBarButtonItem.init(image: UIImage.pinRight, style: .plain, target: self, action: #selector(preview))
        
        if hasAlbum {
            let albumItem = UIBarButtonItem.init(customView: self.albumButton)
            
            if let closeItem = self.navigationItem.leftBarButtonItem {
                self.navigationItem.leftBarButtonItems = [closeItem, albumItem]
            } else {
                let closeItem = UIBarButtonItem.init(barButtonSystemItem: .stop, target: self, action: #selector(closePanel))
                self.navigationItem.leftBarButtonItems = [closeItem, albumItem]
            }
        }
    }
    
    open func setupAlbums() {
        let theCollections = PHAssetCollection.fetchAssetCollections(with: PHAssetCollectionType.album, subtype: PHAssetCollectionSubtype.albumRegular, options: nil)
        self.albums = theCollections
        self.tableView.reloadData()
    }
    
    open func setupFullAssets() {
        let theAssets: PHFetchResult<PHAsset> = PHAsset.fetchAssets(with: self.mediaType.fetchAssetMediaType, options: self.assetsFetchOptions)
        self._fullAssets = theAssets
        if self.selectedAlbum == nil {
            self.collectionView.reloadData()
        }
    }
    
    open func setupAssets(of collection: PHAssetCollection?) {
        guard let theCollection = collection else {
            return
        }
        let theAssets: PHFetchResult<PHAsset> = PHAsset.fetchAssets(in: theCollection, options: self.assetsFetchOptions)
        self._assets = theAssets
        self.collectionView.reloadData()
    }

    @objc
    internal func finishSelection() {
        if let pk = self.photoKit {
            let collection = self.selectedAssets
            ParadiseMachine.request(images: .original, form: collection, sourceMode: self.sourceType, completion: { (results) in
                pk.delegate?.photoKit(pk, didGetPhotos: results, from: self.sourceType)
                self.dismiss(animated: true, completion: nil)
            })
        } else {
            self.dismiss(animated: true, completion: nil)
        }
    }
    
    @objc
    internal func showAlbumList() {
        let isShown = (self.tableView.topConstraint?.constant ?? 0) == 0
        self.albumButton.isSelected = !isShown
        let tableHeight = self.tableViewHeight
        UIView.animate(withDuration: 0.25) { [weak self] in
            let alpha: CGFloat = isShown ? 0 : 1
            self?.tableView.alpha = alpha
            self?.tableViewShadowView.alpha = alpha
            self?.tableViewShadowExtendedButton.alpha = alpha
            self?.tableView.topConstraint?.constant = isShown ? -tableHeight : 0
            self?.view.layoutIfNeeded()
        }
    }
    
    deinit {
        self.photoKit = nil
        PHPhotoLibrary.shared().unregisterChangeObserver(self)
    }
}

extension ParadiseLibraryController: PHPhotoLibraryChangeObserver {
    public func photoLibraryDidChange(_ changeInstance: PHChange) {
        DispatchQueue.main.async {
            guard let collection = self._assets else {
                return
            }
            guard let collectionChanges = changeInstance.changeDetails(for: collection) else {
                return
            }
            
//            self.selectedAssets.removeAll()
            self._assets = collectionChanges.fetchResultAfterChanges
            self.setupFullAssets()
            
            if !collectionChanges.hasIncrementalChanges || collectionChanges.hasMoves {
                self.collectionView.reloadData()
                
            } else {
                self.collectionView.performBatchUpdates({
                    if let removedIndexes = collectionChanges.removedIndexes, removedIndexes.count != 0 {
                        self.collectionView.deleteItems(at: removedIndexes.indexPathsFromIndexes(section: 0))
                    }
                    
                    if let insertedIndexes = collectionChanges.insertedIndexes, insertedIndexes.count != 0 {
                        self.collectionView.insertItems(at: insertedIndexes.indexPathsFromIndexes(section: 0))
                    }
                    
                    if let changedIndexes = collectionChanges.changedIndexes, changedIndexes.count != 0 {
                        self.collectionView.reloadItems(at: changedIndexes.indexPathsFromIndexes(section: 0))
                    }
                    
                }, completion: nil)
            }
            
            self.resetCachedAssets()
        }
    }
}

// MARK: - Asset Caching
extension ParadiseLibraryController {
    internal func resetCachedAssets() {
        self.imageManager.stopCachingImagesForAllAssets()
        self.previousPreheatRect = CGRect.zero
    }
    
    internal func updateCachedAssets() {
        var preheatRect = self.collectionView.bounds
        preheatRect = preheatRect.insetBy(dx: 0.0, dy: -0.5 * preheatRect.height)
        
        let delta = abs(preheatRect.midY - self.previousPreheatRect.midY)
        
        if delta > self.collectionView.bounds.height / 3.0 {
            
            var addedIndexPaths: [IndexPath]   = []
            var removedIndexPaths: [IndexPath] = []
            
            self.differenceBetween(self.previousPreheatRect, and: preheatRect, removedHandler: { removedRect in
                let indexPaths = self.collectionView.indexPathsForElements(in: removedRect)
                removedIndexPaths += indexPaths
            }, addedHandler: { addedRect in
                let indexPaths = self.collectionView.indexPathsForElements(in: addedRect)
                addedIndexPaths += indexPaths
            })
            
            let assetsToStartCaching = self.assetsAtIndexPaths(addedIndexPaths)
            let assetsToStopCaching = self.assetsAtIndexPaths(removedIndexPaths)
            
            self.imageManager.startCachingImages(for: assetsToStartCaching, targetSize: collectionCellSize, contentMode: .aspectFill, options: nil)
            
            self.imageManager.stopCachingImages(for: assetsToStopCaching, targetSize: collectionCellSize, contentMode: .aspectFill, options: nil)
            
            self.previousPreheatRect = preheatRect
        }
    }
    
    internal func differenceBetween(_ oldRect: CGRect, and newRect: CGRect, removedHandler: (CGRect)->Void, addedHandler: (CGRect)->Void) {
        
        if newRect.intersects(oldRect) {
            
            let oldMaxY = oldRect.maxY
            let oldMinY = oldRect.minY
            let newMaxY = newRect.maxY
            let newMinY = newRect.minY
            
            if newMaxY > oldMaxY {
                let rectToAdd = CGRect(x: newRect.origin.x, y: oldMaxY, width: newRect.size.width, height: (newMaxY - oldMaxY))
                addedHandler(rectToAdd)
            }
            
            if oldMinY > newMinY {
                let rectToAdd = CGRect(x: newRect.origin.x, y: newMinY, width: newRect.size.width, height: (oldMinY - newMinY))
                addedHandler(rectToAdd)
            }
            if newMaxY < oldMaxY {
                let rectToRemove = CGRect(x: newRect.origin.x, y: newMaxY, width: newRect.size.width, height: (oldMaxY - newMaxY))
                removedHandler(rectToRemove)
            }
            if oldMinY < newMinY {
                let rectToRemove = CGRect(x: newRect.origin.x, y: oldMinY, width: newRect.size.width, height: (newMinY - oldMinY))
                removedHandler(rectToRemove)
            }
        } else {
            addedHandler(newRect)
            removedHandler(oldRect)
        }
    }
    
    internal func assetsAtIndexPaths(_ indexPaths: [IndexPath]) -> [PHAsset] {
        if indexPaths.count == 0 { return [] }
        var assets: [PHAsset] = []
        assets.reserveCapacity(indexPaths.count)
        for indexPath in indexPaths {
            if let asset = self.assets?[indexPath.item] {
                assets.append(asset)
            }
        }
        return assets
    }
}

extension ParadiseLibraryController: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    public func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let identifier = ParadisePhotoSelectionCollectionViewCell.reusableCellIdentifier
        let cell = ParadisePhotoSelectionCollectionViewCell.reusableCell(dequeued: collectionView, identifier: identifier, for: indexPath)

        let currentTag = cell.tag + 1
        cell.tag = currentTag
        
//        cell.onSelection = {
//            self.selectItem(at: indexPath)
//        }
        
        let canBeSelected = self.selectedAssets.count < self.multiSelectionLimit
        
        if let asset = self.asset(at: indexPath.item) { // exists
            if let index = self.selectedAssets.index(of: asset) { // selected
                cell.setupContent(index: index, covered: false)
            } else { // not selected
                cell.setupContent(index: nil, covered: !canBeSelected)
            }
        } else { // not exists
            cell.setupContent(index: nil, covered: true)
        }
        
        if let asset = self.asset(at: indexPath.item) {
            switch asset.mediaType {
            case .unknown, .audio:
                cell.thumbnailView.image = nil
                cell.detailLabel.text = nil
                break
            default:
                if asset.mediaType == .video {
                    cell.detailLabel.text = asset.duration.formattedString//.format()
                } else {
                    cell.detailLabel.text = nil
                }
                self.imageManager.requestImage(for: asset, targetSize: collectionCellSize, contentMode: .aspectFill, options: nil) { result, info in
                    if cell.tag == currentTag {
                        cell.thumbnailView.image = result
                    }
                }
                break
            }
            return cell
        }
        
        cell.thumbnailView.image = nil
        cell.detailLabel.text = nil
        return cell
    }
    
    public func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    public func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.assetsCount
    }
    
    public func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        self.selectItem(at: indexPath)
    }
    
    public func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let countPerRow = 3
        let width = (collectionView.frame.width - CGFloat(countPerRow - 1) * self.collectionItemMargin) / CGFloat(countPerRow)
        return CGSize(width: width, height: width)
    }
    
    public func selectItem(at indexPath: IndexPath) {
        guard let asset = self.asset(at: indexPath.item) else {
            return
        }
        
        if let index = self.selectedAssets.index(of: asset) {
            self.selectedAssets.remove(at: index)
            self.collectionView.deselectItem(at: indexPath, animated: true)
        } else {
            guard self.selectedAssets.count < self.multiSelectionLimit else {
                return
            }
            self.selectedAssets.append(asset)
            self.collectionView.selectItem(at: indexPath, animated: true, scrollPosition: UICollectionViewScrollPosition())
        }
        let visible = self.collectionView.indexPathsForVisibleItems
        self.collectionView.reloadItems(at: visible)
        self.updateTitle()
    }
}

extension ParadiseLibraryController: ParadisePhotoPreviewDelegate, ParadisePhotoPreviewDataSource {
    
    @objc
    internal func preview() {
        let preview = ParadisePhotoPreviewController.init()
        preview.dataSource = self
        preview.delegate = self
        self.navigationController?.show(preview, sender: self)
    }
    
    public func previewer(_ previewController: ParadisePhotoPreviewController, assetForItemAt index: Int) -> PHAsset? {
        return self.selectedAsset(at: index)
    }
    
    public func numberOfItems(in previewController: ParadisePhotoPreviewController) -> Int {
        return self.selectedAssets.count
    }
    
    public func previewerDidFinish(_ previewController: ParadisePhotoPreviewController) {
        self.finishSelection()
    }
}

extension ParadiseLibraryController: UITableViewDelegate, UITableViewDataSource {
    public func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    
    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            return 1
        }
        return self.albumsCount
    }
    
    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: ParadiseAlbumListTableViewCell.reusableCellIdentifier) as! ParadiseAlbumListTableViewCell
        if indexPath.section == 0 {
            cell.albumTitleLabel.text = NSLocalizedString("All Albums", comment: "")
            cell.albumContentsCountLabel.text = "\(self._fullAssets?.count ?? 0)"
        } else {
            let album = self.album(at: indexPath.row)
            cell.albumTitleLabel.text = album?.localizedTitle
            let count = album?.assetsCount(of: self.mediaType.fetchAssetMediaType)
            cell.albumContentsCountLabel.text = "\(count ?? 0)"
        }
        cell.albumCoverView.image = nil
        cell.accessoryType = .disclosureIndicator
        return cell
    }
    
    public func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return self.tableViewCellHeight
    }
    
    public func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.showAlbumList()
        tableView.deselectRow(at: indexPath, animated: true)
        if indexPath.section == 0 {
            if self.selectedAlbum != nil {
                self.selectedAlbum = nil
                self.collectionView.reloadData()
            }
        } else {
            let album = self.album(at: indexPath.row)
            if self.selectedAlbum != album {
                self.selectedAlbum = album
                self.setupAssets(of: self.selectedAlbum)
            }
        }
    }
}




