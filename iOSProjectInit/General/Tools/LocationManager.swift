//
//  LocationManager.swift
//  XinCar
//
//  Created by yoctech on 2025/1/9.
//

import Foundation
import CoreLocation

class LocationManager: NSObject {
    
    private static let share = LocationManager()
    private static var permissionAllow: Bool {
        share.manager.authorizationStatus == .authorizedAlways ||
        share.manager.authorizationStatus == .authorizedWhenInUse
    }
    private static var permissionNotDetermined: Bool {
        share.manager.authorizationStatus == .notDetermined
    }
    
    private var manager: CLLocationManager!
    private var locationCallBack: ((CLLocation?, String)->Void)?
    private var locationPlacemarkCallBack:((CLLocation?, CLPlacemark?, String)->Void)?
    private lazy var geoCoder = CLGeocoder()
    
    static func requestLocaion( locationCallBack:@escaping ((CLLocation?, String)->Void)) {
        share.locationCallBack = locationCallBack
        if permissionNotDetermined  {
            return
        }
        guard permissionAllow else {
            return share.alertNowAllow()
        }
        share.manager.startUpdatingLocation()
    }
    
    static func requsetLocationPlacemark(locationPlacemarkCallBack:@escaping ((CLLocation?, CLPlacemark?, String)->Void)) {
        share.locationPlacemarkCallBack = locationPlacemarkCallBack
        if permissionNotDetermined  {
            return
        }
        guard permissionAllow else {
            return share.alertNowAllow()
        }
        share.manager.startUpdatingLocation()
    }
    
    private override init() {
        super.init()
        manager = CLLocationManager.init()
        manager.delegate = self
        
        let status = manager.authorizationStatus
        switch status {
        // 未授权
        case .notDetermined:
            // 请求权限
            manager.requestWhenInUseAuthorization()
        // 权限拒绝
        case .denied:
            alertNowAllow()
        // 前台使用
        case .authorizedWhenInUse:
            break
        default:
            break
        }
    }
    
    private func alertNowAllow() {
        MKAlertView.alertDanger(message: "未获取到位置权限，请前往设置授权", cancelTitle: "取消", cancel: { [weak self] in
            self?.clearCallback()
        }, confirmTitle: "设置") {
            let url = UIApplication.openSettingsURLString
            if let url = URL.init(string: url), UIApplication.shared.canOpenURL(url) {
                UIApplication.shared.open(url)
            }
        }
    }
    
    deinit {
        print("deinit LocationManager")
    }
    
    private func callback(location: CLLocation?, placeMark: CLPlacemark? = nil ,msg: String = "") {
        if let locationPlacemarkCallBack = locationPlacemarkCallBack, let location = location {
            geoCoder.reverseGeocodeLocation(location, preferredLocale: .init(identifier: "zh_Hans_CN")) { placeMarks, error in
                locationPlacemarkCallBack(location, placeMarks?.first, error?.localizedDescription ?? msg)
            }
        } else {
            locationCallBack?(location, msg)
        }
        clearCallback()
    }
    
    private func clearCallback() {
        locationCallBack = nil
        locationPlacemarkCallBack = nil
    }
}

extension LocationManager: CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        switch status {
        case .authorizedAlways, .authorizedWhenInUse:
            if locationCallBack != nil || locationPlacemarkCallBack != nil {   
                manager.startUpdatingLocation()
            }
        default:
            break
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        manager.stopUpdatingLocation()
        guard let location = locations.first else {
            callback(location: nil, msg: "获取位置信息失败")
            return
        }
        callback(location: location, msg: "")
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print(error)
        manager.stopUpdatingLocation()
        callback(location: nil, msg: error.localizedDescription)
    }
}
