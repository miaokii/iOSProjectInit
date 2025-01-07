import UIKit
import Photos

private let scanLineHeight: CGFloat = 10
private let scanLineAnmationKey = "scanLineAnmationKey" /** 扫描线条动画Key值 */
private var flashlightKey: Void?

class MKScanView: UIView {
    
    /** 扫描器宽度 */
    var scanWidth: CGFloat!
    /** 扫描器初始x值 */
    var scanMinX: CGFloat!
    /** 扫描器初始y值 */
    var scanMinY: CGFloat!
    
    var config: MKScanCodeConfig!
    
    /// 提示
    private var tipLab = UILabel()
    
    private var scanLine: UIImageView!
    
    /** 手电筒开关 */
    private lazy var flashlightBtn: UIButton = {
        let tempFlashlightBtn = UIButton(type: .custom)
        tempFlashlightBtn.isEnabled = false
        tempFlashlightBtn.alpha = 0
        tempFlashlightBtn.addTarget(self, action: #selector(flashlightClicked), for: .touchUpInside)
        tempFlashlightBtn.setImage(.init(named: "Flashlight_Off"), for: .normal)
        tempFlashlightBtn.setImage(.init(named: "Flashlight_On"), for: .selected)
        addSubview(tempFlashlightBtn)
        tempFlashlightBtn.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.init(item: tempFlashlightBtn, attribute: .centerX, relatedBy: .equal, toItem: self, attribute: .centerX, multiplier: 1, constant: 0).isActive = true
        NSLayoutConstraint.init(item: tempFlashlightBtn, attribute: .top, relatedBy: .equal, toItem: tipLab, attribute: .bottom, multiplier: 1, constant: 30).isActive = true
        
        return tempFlashlightBtn
    }()
    
    init(frame: CGRect, config: MKScanCodeConfig) {
        super.init(frame: frame)
        self.config = config
        
        scanWidth = config.scanWidth
        scanMinX = (frame.size.width - scanWidth)/2
        scanMinY = (frame.size.height - scanWidth)/2 - 50
        
        setScanView()
    }
    
    private func setScanView() {
        backgroundColor = .clear
      
        scanLine = UIImageView(frame: CGRect(x: scanMinX, y: scanMinY, width: scanWidth, height: scanLineHeight))
        addSubview(scanLine)
        var image = UIImage.init(named: "ScannerLine")
        if let lineColor = config.scanLineColor {
            image = image?.withTintColor(lineColor, renderingMode: .alwaysOriginal)
        }
        scanLine.image = image
        
        tipLab.textAlignment = .center
        tipLab.textColor = config.scanHintColor
        tipLab.font = config.scanHintFont
        if let text = config.scanHint {
            tipLab.text = text
        } else {
            tipLab.text = "将\(config.scanType.rawValue)放入框内，即可自动扫描"
        }
        addSubview(tipLab)
        tipLab.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint(item: tipLab, attribute: .centerX, relatedBy: .equal, toItem: self, attribute: .centerX, multiplier: 1, constant: 0).isActive = true
        NSLayoutConstraint(item: tipLab, attribute: .top, relatedBy: .equal, toItem: self, attribute: .top, multiplier: 1, constant: scanMinY + scanWidth + 20).isActive = true
        NSLayoutConstraint(item: tipLab, attribute: .width, relatedBy: .lessThanOrEqual, toItem: self, attribute: .width, multiplier: 1, constant: scanMinX*2).isActive = true
    }
    
    override func draw(_ rect: CGRect) {
        super.draw(rect)
        
        // 半透明区域
        UIColor(white: 0, alpha: 0.7).setFill()
        UIRectFill(rect)
        
        // 透明区域
        let scanRect = CGRect(x: scanMinX, y: scanMinY, width: scanWidth, height: scanWidth)
        UIColor.clear.setFill()
        UIRectFill(scanRect)
        
        // 边框
        let borderPath = UIBezierPath(rect: CGRect(x: scanMinX, y: scanMinY, width: scanWidth, height: scanWidth))
        borderPath.lineCapStyle = .round
        borderPath.lineWidth = config.scanBorderWidth
        config.scanBorderColor.set()
        borderPath.stroke()
        
        // 边角
        for index in 0...3 {
            let tempPath = UIBezierPath()
            tempPath.lineWidth = config.scanCornerWidth
            config.scanCornerColor.set()
            
            switch index {
                // 左上角棱角
            case 0:
                tempPath.move(to: CGPoint(x: scanMinX + config.scanCornerLength, y: scanMinY))
                tempPath.addLine(to: CGPoint(x: scanMinX, y: scanMinY))
                tempPath.addLine(to: CGPoint(x: scanMinX, y: scanMinY + config.scanCornerLength))
                // 右上角
            case 1:
                tempPath.move(to: CGPoint(x: scanMinX + scanWidth - config.scanCornerLength, y: self.scanMinY))
                tempPath.addLine(to: CGPoint(x: scanMinX + scanWidth, y: scanMinY))
                tempPath.addLine(to: CGPoint(x: scanMinX + scanWidth, y: scanMinY + config.scanCornerLength))
                // 左下角
            case 2:
                tempPath.move(to: CGPoint(x: scanMinX, y: scanMinY + scanWidth - config.scanCornerLength))
                tempPath.addLine(to: CGPoint(x: scanMinX, y: scanMinY + scanWidth))
                tempPath.addLine(to: CGPoint(x: scanMinX + config.scanCornerLength, y: scanMinY + scanWidth))
                // 右下角
            case 3:
                tempPath.move(to: CGPoint(x: scanMinX + scanWidth - config.scanCornerLength, y: scanMinY + scanWidth))
                tempPath.addLine(to: CGPoint(x: scanMinX + scanWidth, y: scanMinY + scanWidth))
                tempPath.addLine(to: CGPoint(x: scanMinX + scanWidth, y: scanMinY + scanWidth - config.scanCornerLength))
            default:
                break
            }
            tempPath.stroke()
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
}

// MARK: - 扫描线条动画
extension MKScanView {
    
    /// 添加扫描线条动画
    func addScanLineAnimation() {
        // 若已添加动画，则先移除动画再添加
        self.scanLine.layer.removeAllAnimations()
        
        let lineAnimation = CABasicAnimation(keyPath: "transform")
        lineAnimation.toValue = NSValue(caTransform3D: CATransform3DMakeTranslation(0, scanWidth - scanLineHeight, 1))
        lineAnimation.duration = 4
        lineAnimation.repeatCount = MAXFLOAT
        self.scanLine.layer.add(lineAnimation, forKey: scanLineAnmationKey)
        // 重置动画运行速度为1.0
        self.scanLine.layer.speed = 1.0
    }
    
    /** 暂停扫描器动画 */
    func pauseScanLineAnimation() {
        // 取出当前时间，转成动画暂停的时间
        let pauseTime = self.scanLine.layer.convertTime(CACurrentMediaTime(), from: nil)
        // 设置动画的时间偏移量，指定时间偏移量的目的是让动画定格在该时间点的位置
        self.scanLine.layer.timeOffset = pauseTime
        // 将动画的运行速度设置为0， 默认的运行速度是1.0
        self.scanLine.layer.speed = 0
    }
}

// MARK: - 显示/隐藏手电筒
extension MKScanView {
    
    /// 显示手电筒
    func showFlashLight(animated: Bool = true) {
        if animated {
            UIView.animate(withDuration: 0.25, animations: {
                self.flashlightBtn.alpha = 1.0
            }, completion: { (finished) in
                self.flashlightBtn.isEnabled = true
            })
        }
        else {
            self.flashlightBtn.alpha = 1.0
            self.flashlightBtn.isEnabled = true
        }
    }
    
    /// 隐藏手电筒
    func hideFlashLight(animated: Bool = true) {
        self.flashlightBtn.isEnabled = false
        if animated {
            UIView.animate(withDuration: 0.25, animations: {
                self.flashlightBtn.alpha = 0
            })
        }
        else {
            self.flashlightBtn.alpha = 0
        }
    }
}

// MARK: - 设置/获取手电筒开关状态
extension MKScanView {
    
    @objc private func flashlightClicked(button: UIButton) {
        button.isSelected = !button.isSelected
        flashlight(on: button.isSelected)
    }
    
    /// 设置手电筒开关
    func flashlight(on: Bool) {
        Self.flashlight(on: on)
        objc_setAssociatedObject(self, &flashlightKey, on, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
    }
    
    /// 获取手电筒当前开关状态
    func flashlightOn() -> Bool {
        return objc_getAssociatedObject(self, &flashlightKey) as? Bool ?? false
    }
    
    /// 手电筒开关
    static func flashlight(on: Bool) {
        guard let device = AVCaptureDevice.default(for: .video) else {
            return
        }
        if device.hasFlash && device.hasTorch {
            try? device.lockForConfiguration()
            device.torchMode = on ? .on:.off
            device.unlockForConfiguration()
        }
    }
}
