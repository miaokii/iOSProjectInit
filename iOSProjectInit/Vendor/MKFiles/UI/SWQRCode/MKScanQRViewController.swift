import UIKit
import AVFoundation
import Photos

struct MKScanQRAuth {
    
    /// 校验是否有相机权限
    /// - Parameter completion: 检测结果
    static func checkCamera(completion: @escaping (_ granted: Bool) -> Void) {
        let videoAuthStatus = AVCaptureDevice.authorizationStatus(for: .video)
        
        switch videoAuthStatus {
        // 已授权
        case .authorized:
            completion(true)
        // 未询问用户是否授权
        case .notDetermined:
            AVCaptureDevice.requestAccess(for: .video, completionHandler: { (granted) in
                completion(granted)
            })
        // 用户拒绝授权或权限受限
        case .denied, .restricted:
            let alter = UIAlertController.init(title: "提示", message: "请在”设置-隐私-相机”选项中，允许访问你的相机", preferredStyle: .alert)
            alter.addAction(UIAlertAction.init(title: "确定", style: .default, handler: nil))
            UIApplication.shared.keyWindow?.rootViewController?.present(alter, animated: true, completion: nil)
            completion(false)
        @unknown default:
            break
        }
    }
    
    /// 校验是否有相册权限
    static func checkAlbum(completion: @escaping (_ granted: Bool) -> Void) {
        let photoAuthStatus = PHPhotoLibrary.authorizationStatus()
        
        switch photoAuthStatus {
        // 已授权
        case .authorized, .limited:
            completion(true)
        // 未询问用户是否授权
        case .notDetermined:
            PHPhotoLibrary.requestAuthorization({ (status) in
                completion(status == .authorized)
            })
        // 用户拒绝授权或权限受限
        case .denied, .restricted:
            let alter = UIAlertController.init(title: "提示", message: "请在”设置-隐私-相机”选项中，允许访问你的相机", preferredStyle: .alert)
            alter.addAction(UIAlertAction.init(title: "确定", style: .default, handler: nil))
            UIApplication.shared.keyWindow?.rootViewController?.present(alter, animated: true, completion: nil)
            completion(false)
        @unknown default:
            break
        }
    }
}


class MKScanQRViewController: MKBaseViewController {
    
    var config = MKScanCodeConfig()
    private let session = AVCaptureSession()
    private var scannerView: MKScanView!
    
    convenience init(config: MKScanCodeConfig) {
        self.init(nibName: nil, bundle: nil)
        self.config = config
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationItem.title = config.scanType.rawValue
        if config.title.count > 0 {
            navigationItem.title = config.title
        }
        
        NotificationCenter.default.addObserver(self, selector: #selector(resumeScanning), name: UIApplication.didBecomeActiveNotification, object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(pauseScanning), name: UIApplication.willResignActiveNotification, object: nil)
        
        setupUI();
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        resumeScanning()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        // 关闭并隐藏手电筒
        scannerView.flashlight(on: false)
        scannerView.hideFlashLight()
    }
    
    private func setupUI() {
        view.backgroundColor = .black
        
        if config.album {
            let albumItem = UIBarButtonItem(title: "相册", style: .plain, target: self, action: #selector(showAlbum))
            albumItem.tintColor = .black
            navigationItem.rightBarButtonItem = albumItem;
        }
        
        scannerView = MKScanView(frame: view.bounds, config: config)
        view.addSubview(scannerView)
        
        // 校验相机权限
        MKScanQRAuth.checkCamera { (granted) in
            guard granted else {
                return
            }
            DispatchQueue.main.async {
                self.setupScanner()
            }
        }
    }
    
    /// 创建扫描器
    private func setupScanner() {
        
        guard let device = AVCaptureDevice.default(for: .video) else {
            return
        }
        
        guard let deviceInput = try? AVCaptureDeviceInput(device: device) else {
            return
        }
        
        let metadataOutput = AVCaptureMetadataOutput()
        metadataOutput.setMetadataObjectsDelegate(self, queue: .main)
        
        if config.scanArea == .def {
            metadataOutput.rectOfInterest = CGRect(x: scannerView.scanMinY/view.frame.size.height, y: scannerView.scanMinX/view.frame.size.width, width: scannerView.scanWidth/view.frame.size.height, height: scannerView.scanWidth/view.frame.size.width)
        }
        
        let videoDataOutput = AVCaptureVideoDataOutput()
        videoDataOutput.setSampleBufferDelegate(self, queue: .main)
        
        session.canSetSessionPreset(.high)
        if session.canAddInput(deviceInput) { session.addInput(deviceInput) }
        if session.canAddOutput(metadataOutput) { session.addOutput(metadataOutput) }
        if session.canAddOutput(videoDataOutput) { session.addOutput(videoDataOutput) }
        
        metadataOutput.metadataObjectTypes = config.scanType.metadataObjectTypes
        
        let videoPreviewLayer = AVCaptureVideoPreviewLayer(session: session)
        videoPreviewLayer.videoGravity = .resizeAspectFill
        videoPreviewLayer.frame = view.layer.bounds
        view.layer.insertSublayer(videoPreviewLayer, at: 0)
        
        session(run: true)
    }
    
    private func session(run: Bool) {
        DispatchQueue.global().async {
            if run {
                self.session.startRunning()
            } else if self.session.isRunning {
                self.session.stopRunning()
            }
        }
    }
    
    
    deinit {
        print("deinit \(NSStringFromClass(Self.classForCoder()))")
    }
}

// MARK: - 到相册选择
extension MKScanQRViewController {
    @objc private func showAlbum() {
        MKScanQRAuth.checkAlbum { (granted) in
            guard granted else {
                return
            }
            self.imagePicker()
        }
    }

    private func imagePicker() {
        DispatchQueue.main.async {
            let imagePicker = UIImagePickerController()
            imagePicker.sourceType = .photoLibrary
            imagePicker.delegate = self
            self.present(imagePicker, animated: true, completion: nil)
        }
    }
}

// MARK: - 扫一扫Api
extension MKScanQRViewController {
    
    /// 处理扫一扫结果
    ///
    /// - Parameter value: 扫描结果
    private func scanResult(value: String) {
        print("Scan Result: \(value)")
        if config.autoPop {
            self.navigationController?.popViewController(animated: true)
        }
        if let resultClosure = self.config.scanResult {
            resultClosure(value)
        }
    }
    
    /// 相册选取图片无法读取数据
    private func scanDidReadFailedFromAlbum() {
        let alter = UIAlertController.init(title: "提示", message: "没有发现二维码/条形码", preferredStyle: .alert)
        alter.addAction(UIAlertAction.init(title: "确定", style: .default, handler: nil))
        present(alter, animated: true, completion: nil)
    }
}

// MARK: - 扫描结果处理
extension MKScanQRViewController: AVCaptureMetadataOutputObjectsDelegate {
    
    func metadataOutput(_ output: AVCaptureMetadataOutput, didOutput metadataObjects: [AVMetadataObject], from connection: AVCaptureConnection) {

        // 扫描到数据
        guard metadataObjects.count > 0 else {
            return
        }
        pauseScanning()

        guard let metadataObject = metadataObjects[0] as? AVMetadataMachineReadableCodeObject,
              let stringValue = metadataObject.stringValue else {
            return
        }
        scanResult(value: stringValue)
    }
}

// MARK: - 监听光线亮度
extension MKScanQRViewController: AVCaptureVideoDataOutputSampleBufferDelegate {
    
    func captureOutput(_ output: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {
        let metadataDict = CMCopyDictionaryOfAttachments(allocator: nil, target: sampleBuffer, attachmentMode: kCMAttachmentMode_ShouldPropagate)
        
        guard let metadata = metadataDict as? [AnyHashable: Any],
              let exifMetadata = metadata[kCGImagePropertyExifDictionary as String] as? [AnyHashable: Any],
              let brightness = exifMetadata[kCGImagePropertyExifBrightnessValue as String] as? NSNumber else {
            return
        }
        // 亮度值
        let brightnessValue = brightness.floatValue
        if !scannerView.flashlightOn() {
            if brightnessValue < -4.0 {
                scannerView.showFlashLight()
            } else {
                scannerView.hideFlashLight()
            }
        }
    }
}

// MARK: - 识别选择图片
extension MKScanQRViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    internal func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        picker.dismiss(animated: true) {
            if !self.handlePickInfo(info) {
                self.scanDidReadFailedFromAlbum()
            }
        }
    }
    
    /// 识别二维码并返回识别结果
    private func handlePickInfo(_ info: [UIImagePickerController.InfoKey : Any]) -> Bool {
        guard let pickImage = info[.originalImage] as? UIImage else {
            return false
        }
        let ciImage = CIImage(cgImage: pickImage.cgImage!)
        let detector = CIDetector(ofType: CIDetectorTypeQRCode, context: nil, options: [CIDetectorAccuracy:CIDetectorAccuracyHigh])
        
        guard let features = detector?.features(in: ciImage),
              let firstFeature = features.first as? CIQRCodeFeature,
              let stringValue = firstFeature.messageString else {
            return false
        }
        scanResult(value: stringValue)
        return true
    }
}

// MARK: - 恢复/暂停扫一扫功能
extension MKScanQRViewController {
    /// 恢复扫一扫功能
    @objc private func resumeScanning() {
        session(run: true)
        scannerView.addScanLineAnimation()
    }
    
    /// 暂停扫一扫功能
    @objc private func pauseScanning() {
        session(run: false)
        scannerView.pauseScanLineAnimation()
    }
}
