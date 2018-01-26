//
//  ViewController.swift
//  ParadisePhotoKit
//
//  Created by 李二狗 on 2018/1/24.
//  Copyright © 2018年 Meniny Lab. All rights reserved.
//

import UIKit
import SuperAlertController
import SuperAlertControllerExtensions
import Photos

class ViewController: UITableViewController {

    let sources: [ParadiseSourceType] = [
        ParadiseSourceType.library(of: ParadiseLibraryMediaType.photos, limit: 9),
        ParadiseSourceType.library(of: ParadiseLibraryMediaType.videos, limit: 1),
//        ParadiseSourceType.library(of: ParadiseLibraryMediaType.all),
        ParadiseSourceType.camera(of: ParadiseCameraType.photo),
        ParadiseSourceType.camera(of: ParadiseCameraType.video)
    ]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.tableView.register(UITableViewCell.self, forCellReuseIdentifier: "Cell")
        self.tableView.tableFooterView = UIView.init()
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell")
        let type = sources[indexPath.row]
        cell?.textLabel?.text = type.localizedTitle
        cell?.selectionStyle = .none
        cell?.accessoryType = .disclosureIndicator
        return cell!
    }

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return sources.count
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let type = sources[indexPath.row]
        let photoKit = ParadisePhotoKit.init(source: type)
        photoKit.delegate = self
        photoKit.presented(by: self, animated: true) {
            print(self)
        }
    }

}

extension ViewController: ParadisePhotoKitDelegate {
    
    func photoKitUnauthorized(_ photoKit: ParadisePhotoKit) {
        alert(#function)
    }
    
    func photoKitDidCancel(_ photoKit: ParadisePhotoKit) {
        alert(#function)
    }
    
    func photoKit(_ photoKit: ParadisePhotoKit, didSelectPhotos photos: [ParadisePhotoResult], from source: ParadiseSourceType) {
        
        alert(photos.images)
    }
    
    func photoKit(_ photoKit: ParadisePhotoKit, didCapturePhoto photo: UIImage, from source: ParadiseSourceType) {
        alert([photo])
    }
    
    func photoKit(_ photoKit: ParadisePhotoKit, didSelectVideos videos: [ParadiseVideoResult], from source: ParadiseSourceType) {
        alert(videos.images)
    }
    
    func photoKit(_ photoKit: ParadisePhotoKit, didCaptureVideo videoFile: URL, from source: ParadiseSourceType) {
        alert(videoFile)
    }

    public func alert(_ thing: Any) {
        let t = "\(type(of: self))"
        let m = "\(thing)"
        let done = UIAlertAction.init(title: "Done", style: .default, handler: nil)
        self.presentedViewController?.dismiss(animated: true, completion: {
            if let images = thing as? [UIImage] {
                let controller = SuperAlertController.init(style: .alert, source: self.view, title: t, message: m, tintColor: nil)
                controller.addImagePicker(.horizontal, paging: true, images: images)
                controller.addAction(done)
                self.present(controller, animated: true, completion: nil)
            } else {
                let controller = UIAlertController.init(title: t, message: m, preferredStyle: .alert)
                controller.addAction(done)
                self.present(controller, animated: true, completion: nil)
            }
        })
    }
}

