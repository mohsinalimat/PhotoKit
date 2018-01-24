//
//  ViewController.swift
//  ParadisePhotoKit
//
//  Created by 李二狗 on 2018/1/24.
//  Copyright © 2018年 Meniny Lab. All rights reserved.
//

import UIKit

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
        print(#function)
    }
    
    func photoKitDidCancel(_ photoKit: ParadisePhotoKit) {
        print(#function)
    }
    
    func photoKit(_ photoKit: ParadisePhotoKit, didGetPhotos photos: [ParadiseResult], from source: ParadiseSourceType) {
        print(#function)
        print(photos.images)
    }
    
    func photoKit(_ photoKit: ParadisePhotoKit, didGetVideos videos: [ParadiseResult], from source: ParadiseSourceType) {
        print(#function)
        print(videos.videoURLs)
    }
}

