//
//  ParadiseVideoPlayerView.swift
//  ParadisePhotoKit
//
//  Created by Meniny on 2018-01-27.
//  Copyright © 2018年 Meniny Lab. All rights reserved.
//

import UIKit
import AVFoundation
import JustLayout

open class ParadiseVideoPlayerView: UIView {

    open var url: URL? {
        didSet {
            
            self.player?.pause()
            self.playerItem = nil
            self.playerLayer?.removeFromSuperlayer()
            self.playerLayer = nil
            
            self.player?.removeTimeObserver(self)
            self.player = nil
            
            if let u = self.url {
                let playerItem = AVPlayerItem.init(url: u)
                self.playerItem = playerItem
                
                let player = AVPlayer.init(playerItem: playerItem)
                self.player = player
                
                player.addPeriodicTimeObserver(forInterval: CMTimeMake(1, 20), queue: DispatchQueue.main) { [weak self] (time: CMTime) in
                    
                    let currentTime = CMTimeGetSeconds(time)
                    let totalTime = CMTimeGetSeconds(playerItem.duration)
                    
                    guard totalTime > 0, currentTime < totalTime else {
                        self?.progressView.setProgress(1, animated: true)
                        self?.replay()
                        return
                    }
                    
                    self?.progressView.setProgress(Float(currentTime / totalTime), animated: true)
                }
                
                let playerLayer = AVPlayerLayer.init(player: player)
                playerLayer.videoGravity = .resizeAspect
                playerLayer.contentsScale = UIScreen.main.scale
                
                self.playerLayer?.removeFromSuperlayer()
                self.playerLayer = playerLayer
                self.layer.addSublayer(playerLayer)
                
                playerLayer.frame = self.bounds
                
                let notification = NSNotification.Name.AVPlayerItemDidPlayToEndTime
                NotificationCenter.default.addObserver(self, selector: #selector(didEndPlaying), name: notification, object: nil)
                
                self.play()
            }
            
            self.bringSubview(toFront: self.opreationButton)
        }
    }
    open private(set) var playerItem: AVPlayerItem?
    open private(set) var player: AVPlayer?
    open private(set) var playerLayer: AVPlayerLayer?
    
    open private(set) lazy var progressView: UIProgressView = {
        let pv = UIProgressView.init(progressViewStyle: UIProgressViewStyle.default)
        pv.trackTintColor = UIColor.white
        pv.progressTintColor = ParadisePhotoKitConfiguration.borderColor
        return pv
    }()
    
    open private(set) lazy var opreationButton: UIButton = {
        let button = UIButton.init()
        button.setImage(UIImage.init(named: "ic_shutter"), for: .normal)
        button.setImage(UIImage.init(named: "ic_shutter_recording"), for: .selected)
        return button
    }()
    
    deinit {
        NotificationCenter.default.removeObserver(self)
        self.player?.removeTimeObserver(self)
    }
    private var availableDuration: TimeInterval {
        if let loadedTimeRanges = self.player?.currentItem?.loadedTimeRanges, let timeRange = loadedTimeRanges.first?.timeRangeValue {
            let start = CMTimeGetSeconds(timeRange.start)
            let duration = CMTimeGetSeconds(timeRange.duration)
            let result = start + duration
            return TimeInterval(result)
        }
        return 0
    }
    
    private func convert(second: TimeInterval) -> String {
        let date = Date.init(timeIntervalSince1970: second)
        let formatter = DateFormatter.init()
        
        if second / 3600 >= 1 {
            formatter.dateFormat = "HH:mm:ss"
        } else {
            formatter.dateFormat = "mm:ss"
        }
        return formatter.string(from: date)
    }
    
    public init() {
        super.init(frame: .zero)
        self.configuration()
    }
    
    public required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.configuration()
    }
    
    private func configuration() {
        self.translates(subViews: self.progressView, self.opreationButton)
        self.progressView.left(0).right(0).top(0).height(2)
        self.opreationButton.size(50).centerInContainer()
        self.opreationButton.addTarget(self, action: #selector(autoOperation), for: .touchUpInside)
    }
    
    open override func layoutSubviews() {
        super.layoutSubviews()
        self.playerLayer?.frame = CGRect.init(x: 0, y: 2, width: self.bounds.width, height: self.bounds.height - 2)
    }
    
    @objc
    open func autoOperation() {
        if self.opreationButton.isSelected {
            self.play()
        } else {
            self.pause()
        }
        self.opreationButton.isSelected = !self.opreationButton.isSelected
    }
    
    @objc
    open func play() {
        self.opreationButton.isSelected = false
        self.player?.play()
    }
    
    @objc
    open func pause() {
        self.opreationButton.isSelected = false
        self.player?.pause()
    }
    
    open func replay() {
        self.progressView.progress = 0
        self.opreationButton.isSelected = false
        self.player?.seek(to: CMTime.init(seconds: 0, preferredTimescale: CMTimeScale.init(1)))
        self.play()
    }
    
    @objc
    private func didEndPlaying() {
        self.replay()
    }
}
