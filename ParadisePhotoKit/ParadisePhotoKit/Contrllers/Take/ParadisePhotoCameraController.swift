//
//  ParadisePhotoCameraController.swift
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

open class ParadisePhotoCameraController: ParadiseViewController, ParadiseSourceable, UIGestureRecognizerDelegate {
    
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
    
//    weak var delegate: HHCameraViewDelegate? = nil
    
    internal var session: AVCaptureSession?
    internal var device: AVCaptureDevice?
    internal var videoInput: AVCaptureDeviceInput?
    internal var imageOutput: AVCaptureStillImageOutput?
    internal var videoLayer: AVCaptureVideoPreviewLayer?
    
    internal var focusView: UIView?
    
    internal var flashOffImage: UIImage?
    internal var flashOnImage: UIImage?
    
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
        self.backButton.addTarget(self, action: #selector(closePanel), for: .touchUpInside)
        self.fakeNavigationBar.backgroundColor = ParadisePhotoKitConfiguration.fakeBarColor
        
        self.buttonsContainer.translates(subViews: self.shotButton, self.flipButton, self.flashButton)
        self.buttonsContainer.backgroundColor = ParadisePhotoKitConfiguration.fakeBarColor
        self.flashButton.top(16).left(16).size(24)
        self.flipButton.top(16).right(16).size(24)
        self.shotButton.centerHorizontally().centerVertically(-SafeAreaBottomPadding.default)
        
        let bundle = Bundle(for: self.classForCoder)
        
        flashOnImage = ParadisePhotoKitConfiguration.flashOnImage ?? UIImage(named: "ic_flash_on", in: bundle, compatibleWith: nil)
        flashOffImage = ParadisePhotoKitConfiguration.flashOffImage ?? UIImage(named: "ic_flash_off", in: bundle, compatibleWith: nil)
        let flipImage = ParadisePhotoKitConfiguration.flipImage ?? UIImage(named: "ic_loop", in: bundle, compatibleWith: nil)
        let shotImage = ParadisePhotoKitConfiguration.shotImage ?? UIImage(named: "ic_shutter", in: bundle, compatibleWith: nil)
        
        flashButton.tintColor = ParadisePhotoKitConfiguration.baseTintColor
        flipButton.tintColor  = ParadisePhotoKitConfiguration.baseTintColor
        shotButton.tintColor  = ParadisePhotoKitConfiguration.baseTintColor
        
        flashButton.setImage(flashOffImage?.withRenderingMode(.alwaysTemplate), for: .normal)
        flipButton.setImage(flipImage?.withRenderingMode(.alwaysTemplate), for: .normal)
        shotButton.setImage(shotImage?.withRenderingMode(.alwaysTemplate), for: .normal)
        
        self.view.layoutIfNeeded()
        
        self.initialize()
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
            
            imageOutput = AVCaptureStillImageOutput()
            
            session.addOutput(imageOutput!)
            
            videoLayer = AVCaptureVideoPreviewLayer.init(session: session)
            videoLayer?.frame = self.previewViewContainer.bounds
            videoLayer?.videoGravity = AVLayerVideoGravity.resizeAspectFill
            
            if let vl = self.videoLayer {
                self.previewViewContainer.layer.addSublayer(vl)
            }
            
            session.sessionPreset = AVCaptureSession.Preset.photo
            
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
        startCamera()
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
            stopCamera()
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
    
    @objc
    func shotButtonPressed(_ sender: UIButton) {
        guard let imageOutput = imageOutput else {
            return
        }
        
        DispatchQueue.global(qos: .default).async(execute: { () -> Void in
            let videoConnection = imageOutput.connection(with: AVMediaType.video)
            
            imageOutput.captureStillImageAsynchronously(from: videoConnection!) { (buffer, error) -> Void in
                
                self.stopCamera()
                
                guard let data = AVCaptureStillImageOutput.jpegStillImageNSDataRepresentation(buffer!),
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
                
                guard let img = cgImage.cropping(to: cropRect) else { return }
                
                let croppedUIImage = UIImage(cgImage: img, scale: 1.0, orientation: image.imageOrientation)
                
                DispatchQueue.main.async {
                    if ParadisePhotoKitConfiguration.shouldAutoSavesImage {
                        UIImageSaveToCameraRoll(croppedUIImage)
                    }
                    let result = ParadiseResult.init(source: self.sourceType, image: croppedUIImage, videoURL: nil, asset: nil, info: nil)
                    delegate.delegate?.photoKit(delegate, didGetPhotos: [result], from: self.sourceType)
                    
                    self.capturedImage = croppedUIImage
//                    self.startCamera()
                    self.preview()
                }
            }
        })
    }
    
    open var capturedImage: UIImage? = nil
    
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

internal extension ParadisePhotoCameraController {
    @objc
    internal func focus(_ recognizer: UITapGestureRecognizer) {
        let point = recognizer.location(in: self.view)
        let viewsize = self.view.bounds.size
        let newPoint = CGPoint(x: point.y/viewsize.height, y: 1.0-point.x/viewsize.width)
        
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
        do {
            if let device = device {
                guard device.hasFlash else { return }
                try device.lockForConfiguration()
                device.flashMode = AVCaptureDevice.FlashMode.off
                flashButton.setImage(flashOffImage?.withRenderingMode(.alwaysTemplate), for: UIControlState())
                device.unlockForConfiguration()
            }
        } catch _ {
            return
        }
    }
    
}

extension ParadisePhotoCameraController: ParadisePhotoPreviewDelegate, ParadisePhotoPreviewDataSource {
    
    @objc
    internal func preview() {
        let preview = ParadisePreviewController.init()
        preview.dataSource = self
        preview.delegate = self
        self.navigationController?.show(preview, sender: self)
    }
    
    public func previewer(_ previewController: ParadisePreviewController, requestImageForItemAt index: Int, completion: @escaping (UIImage?) -> Void) {
        completion(self.capturedImage)
    }
    
    public func numberOfItems(in previewController: ParadisePreviewController) -> Int {
        return (self.capturedImage == nil) ? 0 : 1
    }
    
    public func previewerDidFinish(_ previewController: ParadisePreviewController) {
        if let pk = self.photoKit {
            let result = ParadiseResult.init(source: self.sourceType, image: self.capturedImage, videoURL: nil, asset: nil, info: nil)
            pk.delegate?.photoKit(pk, didGetPhotos: [result], from: self.sourceType)
        } else {
            self.closePanel()
        }
    }
}


