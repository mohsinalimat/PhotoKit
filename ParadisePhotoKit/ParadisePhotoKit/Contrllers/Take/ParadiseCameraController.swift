//
//  ParadiseCameraController.swift
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
import CoreMotion

open class ParadiseCameraController: ParadiseViewController, ParadiseSourceable, UIGestureRecognizerDelegate {
    
    open var sourceType: ParadiseSourceType {
        return ParadiseSourceType.camera(of: self.cameraType)
    }
    
    open let cameraType: ParadiseCameraType
    
    public required init(type: ParadiseCameraType) {
        self.cameraType = type
        super.init(nibName: nil, bundle: nil)
    }
    
    public required init?(coder aDecoder: NSCoder) {
        self.cameraType = .photo
        super.init(coder: aDecoder)
    }
    
    internal var previewViewContainer: UIView = UIView.init()
    internal var buttonsContainer: UIView = UIView.init()
    internal var shotButton: UIButton = UIButton.init()
    internal var flashButton: UIButton = UIButton.init()
    internal var flipButton: UIButton = UIButton.init()
    
    internal lazy var backButton: UIButton = {
        let button = UIButton.init()
        button.setImage(UIImage.pinLeft?.withRenderingMode(.alwaysTemplate), for: .normal)
        button.tintColor = UIColor.white
        return button
    }()
    
    internal let fakeNavigationBar: UIView = UIView.init()
    
    internal var initialCaptureDevicePosition: AVCaptureDevice.Position = .back
    
    internal var isRecording = false
    
    internal var session: AVCaptureSession?
    internal var device: AVCaptureDevice?
    internal var videoInput: AVCaptureDeviceInput?
    internal var imageOutput: AVCaptureStillImageOutput?
    internal var videoLayer: AVCaptureVideoPreviewLayer?
    internal var videoOutput: AVCaptureMovieFileOutput?
    
    internal var focusView: UIView?
    
    internal var flashOffImage: UIImage?
    internal var flashOnImage: UIImage?
    internal var videoStartImage: UIImage?
    internal var videoStopImage: UIImage?
    
    internal var motionManager: CMMotionManager?
    internal var currentDeviceOrientation: UIDeviceOrientation?
    
    open override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationController?.isNavigationBarHidden = true
        
        self.view.backgroundColor = ParadisePhotoKitConfiguration.darkBackgroundColor
        
        let bottomBarHeight: CGFloat = 140
        let bottomBarMargin: CGFloat = SafeAreaBottomPadding.default
        
        self.view.translates(subViews: self.previewViewContainer, self.buttonsContainer, self.fakeNavigationBar)
        self.view.layout(
            0,
            |self.previewViewContainer|,
            0
        )
        self.previewViewContainer.backgroundColor = UIColor.darkText
        self.previewViewContainer.clipsToBounds = true
        self.buttonsContainer.left(0).right(0).height(bottomBarHeight + bottomBarMargin).bottom(0)
        
        self.fakeNavigationBar.left(0).right(0).height(44 + StatusBarHeight.default).top(0)
        self.fakeNavigationBar.translates(subViews: self.backButton)
        self.backButton.left(0).bottom(0).size(44)
        self.backButton.addTarget(self, action: #selector(closePanelByCancel), for: .touchUpInside)
        self.fakeNavigationBar.backgroundColor = ParadisePhotoKitConfiguration.fakeBarColor
        
        self.buttonsContainer.translates(subViews: self.shotButton, self.flipButton, self.flashButton)
        self.buttonsContainer.backgroundColor = ParadisePhotoKitConfiguration.fakeBarColor
        self.flashButton.top(16).left(16).size(24)
        self.flipButton.top(16).right(16).size(24)
        self.shotButton.centerHorizontally().centerVertically(-SafeAreaBottomPadding.default)
        
        let bundle = Bundle(for: self.classForCoder)
        
        flashButton.tintColor = ParadisePhotoKitConfiguration.baseTintColor
        flipButton.tintColor  = ParadisePhotoKitConfiguration.baseTintColor
        shotButton.tintColor  = ParadisePhotoKitConfiguration.baseTintColor
        
        flashOnImage = ParadisePhotoKitConfiguration.flashOnImage ?? UIImage(named: "ic_flash_on", in: bundle, compatibleWith: nil)
        flashOffImage = ParadisePhotoKitConfiguration.flashOffImage ?? UIImage(named: "ic_flash_off", in: bundle, compatibleWith: nil)
        let flipImage = ParadisePhotoKitConfiguration.flipImage ?? UIImage(named: "ic_loop", in: bundle, compatibleWith: nil)
        
        flashButton.setImage(flashOffImage?.withRenderingMode(.alwaysTemplate), for: .normal)
        flipButton.setImage(flipImage?.withRenderingMode(.alwaysTemplate), for: .normal)
        
        if self.isPhotoMode {
            let shotImage = ParadisePhotoKitConfiguration.shotImage ?? UIImage(named: "ic_shutter", in: bundle, compatibleWith: nil)
            shotButton.setImage(shotImage?.withRenderingMode(.alwaysTemplate), for: .normal)
        } else {
            videoStartImage = ParadisePhotoKitConfiguration.videoStartImage ?? UIImage(named: "ic_shutter", in: bundle, compatibleWith: nil)
            videoStopImage = ParadisePhotoKitConfiguration.videoStopImage ?? UIImage(named: "ic_shutter_recording", in: bundle, compatibleWith: nil)
            shotButton.setImage(videoStartImage?.withRenderingMode(.alwaysTemplate), for: .normal)
            shotButton.setImage(videoStopImage?.withRenderingMode(.alwaysTemplate), for: .disabled)
        }
        
        self.view.layoutIfNeeded()
        
        self.initialize()
    }
    
    internal var isPhotoMode: Bool {
        return self.sourceType == ParadiseSourceType.camera(of: ParadiseCameraType.photo)
    }
    
    internal func initialize() {
        guard self.session == nil else {
            return
        }
        
        // AVCapture
        self.session = AVCaptureSession()
        
        guard let session = self.session else {
            return
        }
        
        let theDevices: [AVCaptureDevice]
        
        if #available(iOS 10.0, *) {
            let devicesIOS10 = AVCaptureDevice.DiscoverySession.init(deviceTypes: [.builtInWideAngleCamera], mediaType: .video, position: initialCaptureDevicePosition)
            theDevices = devicesIOS10.devices
        } else {
            theDevices = AVCaptureDevice.devices()
        }
        
        for device in theDevices {
            if device.position == initialCaptureDevicePosition {
                self.device = device
                if !device.hasFlash {
                    flashButton.isHidden = true
                }
            }
        }
        
        if let _device = device, let _videoInput = try? AVCaptureDeviceInput(device: _device) {
            videoInput = _videoInput
            session.addInput(videoInput!)
            
            if self.isPhotoMode  {
                imageOutput = AVCaptureStillImageOutput()
                if session.canAddOutput(imageOutput!) {
                    session.addOutput(imageOutput!)
                }
                session.sessionPreset = AVCaptureSession.Preset.photo
                
            } else {
                videoOutput = AVCaptureMovieFileOutput()
                let totalSeconds = 60.0 // Total Seconds of capture time
                let timeScale: Int32 = 30 // FPS
                let maxDuration = CMTimeMakeWithSeconds(totalSeconds, timeScale)
                videoOutput?.maxRecordedDuration = maxDuration
                // SET MIN FREE SPACE IN BYTES FOR RECORDING TO CONTINUE ON A VOLUME
                videoOutput?.minFreeDiskSpaceLimit = 1024 * 1024
                if session.canAddOutput(videoOutput!) {
                    session.addOutput(videoOutput!)
                }
            }
            
            videoLayer = AVCaptureVideoPreviewLayer.init(session: session)
            videoLayer?.frame = self.previewViewContainer.bounds
            videoLayer?.videoGravity = AVLayerVideoGravity.resizeAspectFill
            
            if let vl = self.videoLayer {
                self.previewViewContainer.layer.addSublayer(vl)
            }
            
            session.startRunning()
            
            // Focus View
            self.focusView         = UIView(frame: CGRect(x: 0, y: 0, width: 90, height: 90))
            let tapRecognizer      = UITapGestureRecognizer(target: self, action:#selector(focus(_:)))
            tapRecognizer.delegate = self
            self.previewViewContainer.addGestureRecognizer(tapRecognizer)
        }
        
        flashConfiguration()
        
        self.startCamera()
        
        NotificationCenter.default.addObserver(self, selector: #selector(willEnterForegroundNotification(_:)), name: NSNotification.Name.UIApplicationWillEnterForeground, object: nil)
        
        self.shotButton.addTarget(self, action: #selector(shotButtonPressed(_:)), for: .touchUpInside)
        self.flashButton.addTarget(self, action: #selector(flashButtonPressed(_:)), for: .touchUpInside)
        self.flipButton.addTarget(self, action: #selector(flipButtonPressed(_:)), for: .touchUpInside)
    }
    
    @objc func willEnterForegroundNotification(_ notification: Notification) {
        self.startCamera()
    }
    
    open override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        self.videoLayer?.frame = self.previewViewContainer.bounds
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    func startCamera() {
        switch AVCaptureDevice.authorizationStatus(for: AVMediaType.video) {
        case .authorized:
            session?.startRunning()
            
            motionManager = CMMotionManager()
            motionManager!.accelerometerUpdateInterval = 0.2
            motionManager!.startAccelerometerUpdates(to: OperationQueue()) { [unowned self] (data, _) in
                
                if let data = data {
                    if abs(data.acceleration.y) < abs(data.acceleration.x) {
                        self.currentDeviceOrientation = data.acceleration.x > 0 ? .landscapeRight : .landscapeLeft
                    } else {
                        self.currentDeviceOrientation = data.acceleration.y > 0 ? .portraitUpsideDown : .portrait
                    }
                }
            }
            break
        case .denied, .restricted:
            self.stopCamera()
            break
        default:
            break
        }
    }
    
    func stopCamera() {
        session?.stopRunning()
        motionManager?.stopAccelerometerUpdates()
        currentDeviceOrientation = nil
    }
    
    func toggleRecording() {
        guard let videoOutput = videoOutput else { return }
        
        self.isRecording = !self.isRecording
        let shotImage = self.isRecording ? videoStopImage : videoStartImage
        self.shotButton.setImage(shotImage, for: UIControlState())
        
        if self.isRecording {
            
            let outputPath = "\(NSTemporaryDirectory())output.mov"
            let outputURL = URL(fileURLWithPath: outputPath)
            
            let fileManager = FileManager.default
            if fileManager.fileExists(atPath: outputPath) {
                
                do {
                    try fileManager.removeItem(atPath: outputPath)
                } catch {
                    print("error removing item at path: \(outputPath)")
                    self.isRecording = false
                    return
                }
            }
            
            self.flipButton.isEnabled = false
            self.flashButton.isEnabled = false
            videoOutput.startRecording(to: outputURL, recordingDelegate: self)
            
        } else {
            
            videoOutput.stopRecording()
            self.flipButton.isEnabled = true
            self.flashButton.isEnabled = true
        }
    }
    
    @objc
    func shotButtonPressed(_ sender: UIButton) {
        if self.isPhotoMode {
            guard let imageOutput = imageOutput else {
                return
            }
            DispatchQueue.global(qos: .default).async(execute: { () -> Void in
                if let videoConnection = imageOutput.connection(with: AVMediaType.video) {
                    self.captureStillImage(from: videoConnection)
                }
            })
        } else {
            self.toggleRecording()
        }
    }
    
    func captureStillImage(from connection: AVCaptureConnection) {
        guard let imageOutput = imageOutput else {
            return
        }
        
        imageOutput.captureStillImageAsynchronously(from: connection) { (buffer, error) -> Void in
            
            guard let buffer = buffer else {
                return
            }
            
            self.stopCamera()
            
            guard let data = AVCaptureStillImageOutput.jpegStillImageNSDataRepresentation(buffer),
                let image = UIImage(data: data),
                let cgImage = image.cgImage,
                let delegate = self.photoKit,
                let videoLayer = self.videoLayer else {
                    self.startCamera()
                    return
            }
            
            let rect   = videoLayer.metadataOutputRectConverted(fromLayerRect: videoLayer.bounds)
            let width  = CGFloat(cgImage.width)
            let height = CGFloat(cgImage.height)
            
            let cropRect = CGRect(x: rect.origin.x * width,
                                  y: rect.origin.y * height,
                                  width: rect.size.width * width,
                                  height: rect.size.height * height)
            
            guard let img = cgImage.cropping(to: cropRect) else {
                self.startCamera()
                return
            }
            
            let croppedUIImage = UIImage(cgImage: img, scale: 1.0, orientation: image.imageOrientation)
            
            DispatchQueue.main.async {
                self.saveAndPreviewImage(croppedUIImage)
            }
        }
    }
    
    func saveAndPreviewImage(_ image: UIImage) {
        self.startCamera()
        if ParadisePhotoKitConfiguration.shouldAutoSavesImage {
            UIImageSaveToCameraRoll(image)
        }
        //                    let result = ParadisePhotoResult.init(source: self.sourceType, image: croppedUIImage, videoURL: nil, asset: nil, info: nil)
        //                    delegate.delegate?.photoKit(delegate, didGetPhotos: [result], from: self.sourceType)
        
        self.capturedImage = image
        //                    self.startCamera()
        self.preview()
    }
    
    open internal(set) var capturedImage: UIImage?
    open internal(set) var outputFileURL: URL?
    
    @objc
    func flipButtonPressed(_ sender: UIButton) {
        guard AVCaptureDevice.isCameraAvailable else { return }
        
        session?.stopRunning()
        
        do {
            session?.beginConfiguration()
            
            if let session = session {
                for input in session.inputs {
                    session.removeInput(input)
                }
                
                let position = (videoInput?.device.position == AVCaptureDevice.Position.front) ? AVCaptureDevice.Position.back : AVCaptureDevice.Position.front
                let device: AVCaptureDevice?
                if #available(iOS 10.0, *) {
                    device = AVCaptureDevice.deviceiOS10(at: position, mediaType: .video)
                } else {
                    device = AVCaptureDevice.device(at: position, mediaType: .video)
                }
                if let device = device {
                    videoInput = try AVCaptureDeviceInput.init(device: device)
                    if let videoInput = videoInput {
                        if session.canAddInput(videoInput) {
                            session.addInput(videoInput)
                        }
                    }
                }
            }
            session?.commitConfiguration()
        } catch {
        }
        session?.startRunning()
    }
    
    @objc
    func flashButtonPressed(_ sender: UIButton) {
        guard AVCaptureDevice.isCameraAvailable else { return }
        
        guard let device = device, device.hasFlash else { return }
        
        do {
            try device.lockForConfiguration()
            
            switch device.flashMode {
            case .off:
                device.flashMode = AVCaptureDevice.FlashMode.on
                flashButton.setImage(flashOnImage?.withRenderingMode(.alwaysTemplate), for: UIControlState())
                break
            case .on:
                device.flashMode = AVCaptureDevice.FlashMode.off
                flashButton.setImage(flashOffImage?.withRenderingMode(.alwaysTemplate), for: UIControlState())
                break
            default:
                break
            }
            
            device.unlockForConfiguration()
        } catch _ {
            flashButton.setImage(flashOffImage?.withRenderingMode(.alwaysTemplate), for: UIControlState())
            return
        }
    }
}

extension ParadiseCameraController: AVCaptureFileOutputRecordingDelegate {
    
    public func fileOutput(_ captureOutput: AVCaptureFileOutput, didStartRecordingTo fileURL: URL, from connections: [AVCaptureConnection]) {
    }
    
    public func fileOutput(_ captureOutput: AVCaptureFileOutput, didFinishRecordingTo outputFileURL: URL, from connections: [AVCaptureConnection], error: Error?) {
        
        self.shotButton.isUserInteractionEnabled = false
        self.flashButton.isUserInteractionEnabled = false
        self.flipButton.isUserInteractionEnabled = false
        
        if ParadisePhotoKitConfiguration.autoConvertToMP4 {
            ParadiseMachine.mp4(from: outputFileURL, completion: { (mp4, error) in
                if let error = error {
                    print(error)
                } else {
                    if ParadisePhotoKitConfiguration.shouldAutoSavesVideo {
                        UIVideoSaveToCameraRoll(mp4)
                    }
                    self.outputFileURL = mp4
                    self.preview()
                }
            })
        } else {
            self.outputFileURL = outputFileURL
            self.preview()
        }
    }
}

internal extension ParadiseCameraController {
    @objc
    internal func focus(_ recognizer: UITapGestureRecognizer) {
        let point = recognizer.location(in: self.view)
        let viewsize = self.view.bounds.size
        let newPoint = CGPoint(x: point.y / viewsize.height, y: 1 - point.x / viewsize.width)
        
        guard let device = AVCaptureDevice.default(for: AVMediaType.video) else {
            return
        }
        
        do {
            try device.lockForConfiguration()
        } catch _ {
            return
        }
        
        if device.isFocusModeSupported(AVCaptureDevice.FocusMode.autoFocus) == true {
            device.focusMode = AVCaptureDevice.FocusMode.autoFocus
            device.focusPointOfInterest = newPoint
        }
        
        if device.isExposureModeSupported(AVCaptureDevice.ExposureMode.continuousAutoExposure) == true {
            device.exposureMode = AVCaptureDevice.ExposureMode.continuousAutoExposure
            device.exposurePointOfInterest = newPoint
        }
        
        device.unlockForConfiguration()
        
        guard let focusView = self.focusView else { return }
        
        focusView.alpha = 0
        focusView.center = point
        focusView.backgroundColor = UIColor.clear
        focusView.layer.borderColor = UIColor(red: 1, green: 0.77, blue: 0.18, alpha: 1).cgColor
        focusView.layer.borderWidth = 2
        focusView.transform = CGAffineTransform(scaleX: 1, y: 1)
        self.view.addSubview(focusView)
        
        UIView.animate(withDuration: 0.8, delay: 0, usingSpringWithDamping: 0.8, initialSpringVelocity: 3, options: UIViewAnimationOptions.curveEaseIn, animations: {
                        focusView.alpha = 1
                        focusView.transform = CGAffineTransform(scaleX: 0.7, y: 0.7)
        }, completion: {(finished) in
            focusView.transform = CGAffineTransform(scaleX: 1, y: 1)
            focusView.removeFromSuperview()
        })
    }
    
    func flashConfiguration() {
        guard let device = device, device.hasFlash else {
            return
        }
        do {
            try device.lockForConfiguration()
            device.flashMode = AVCaptureDevice.FlashMode.off
            flashButton.setImage(flashOffImage?.withRenderingMode(.alwaysTemplate), for: UIControlState())
            device.unlockForConfiguration()
        } catch _ {
            return
        }
    }
    
}

extension ParadiseCameraController: ParadisePhotoPreviewDelegate, ParadisePhotoPreviewDataSource {
    
    @objc
    internal func preview() {
        DispatchQueue.main.async {
            self._preview()
        }
    }
    
    internal func _preview() {
        let preview = ParadisePreviewController.init()
        preview.dataSource = self
        preview.delegate = self
        preview.previewMode = self.isPhotoMode ? ParadisePreviewMode.photos : ParadisePreviewMode.videos
        self.navigationController?.show(preview, sender: self)
        
        self.shotButton.isUserInteractionEnabled = true
        self.flashButton.isUserInteractionEnabled = true
        self.flipButton.isUserInteractionEnabled = true
    }
    
    public func previewer(_ previewController: ParadisePreviewController, requestImageForItemAt index: Int, completion: @escaping (UIImage?) -> Void) {
        if let image = self.capturedImage {
            completion(image)
        } else if let path = self.outputFileURL {
            let image = thumbnail(of: path)
            completion(image)
        } else {
            completion(nil)
        }
    }
    
    public func previewer(_ previewController: ParadisePreviewController, requestVideoForItemAt index: Int, completion: @escaping (URL?) -> Void) {
        completion(self.outputFileURL)
    }
    
    public func numberOfItems(in previewController: ParadisePreviewController) -> Int {
        if self.capturedImage != nil {
            return 1
        }
        if self.outputFileURL != nil {
            return 1
        }
        return 0
    }
    
    public func previewerDidFinish(_ previewController: ParadisePreviewController) {
        if let pk = self.photoKit {
            if let image = self.capturedImage {
                pk.delegate?.photoKit(pk, didCapturePhoto: image, from: self.sourceType)
                self.dismiss(animated: true, completion: nil)
            } else if let url = self.outputFileURL {
                pk.delegate?.photoKit(pk, didCaptureVideo: url, from: self.sourceType)
                self.dismiss(animated: true, completion: nil)
            } else {
                self.closePanelByCancel()
            }
        } else {
            self.closePanelByCancel()
        }
    }
}


