import UIKit
import Photos

/// 扫描器类型
///
/// - qr: 仅支持二维码
/// - bar: 仅支持条码
/// - both: 支持二维码以及条码
enum MKScanType: String {
    case qr = "二维码"
    case bar = "条码"
    case both = "二维码/条码"
    
    // 采集类型
    var metadataObjectTypes: [AVMetadataObject.ObjectType] {
        switch self {
        case .qr:
            return [.qr]
        case .bar:
            return [.ean13, .ean8, .upce, .code39, .code39Mod43, .code93, .code128, .pdf417]
        case .both:
            return [.qr, .ean13, .ean8, .upce, .code39, .code39Mod43, .code93, .code128, .pdf417]
        }
    }
}

/// 扫描区域
///
/// - def: 扫描框内
/// - fullscreen: 全屏
enum MKScanArea {
    case def
    case fullscreen
}

struct MKScanCodeConfig {
    /// 扫描器类型 默认支持二维码以及条码
    var scanType: MKScanType = .qr
    /// 扫描区域
    var scanArea: MKScanArea = .def
    /// 扫描成功自动退出
    var autoPop = true
    /// 导航栏标题
    var title = ""
    /// 从相册里选择
    var album = true
    /// 棱角颜色
    var scanCornerColor: UIColor = .white
    /// 棱角长度
    var scanCornerLength: CGFloat = 20
    /// 棱角宽度
    var scanCornerWidth: CGFloat = 3
    /// 边框颜色 默认白色
    var scanBorderColor: UIColor = .clear
    /// 扫描边框宽度
    var scanBorderWidth: CGFloat = 1
    /// 扫描器宽度
    var scanWidth: CGFloat = UIScreen.main.bounds.width * 0.7
    /// 扫描线颜色
    var scanLineColor: UIColor?
    /// 提示信息
    var scanHint: String?
    /// 提示信息颜色
    var scanHintColor: UIColor = .lightGray
    /// 提示信息字体
    var scanHintFont: UIFont = .systemFont(ofSize: 12)
    /// 扫描结果
    var scanResult: ((_ result: String) -> Void)?
    
    var navigationController = UINavigationController()
}
