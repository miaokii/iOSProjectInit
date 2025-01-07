//
//  MKTimeRangePickerView.swift
//  SwiftLib
//
//  Created by yoctech on 2023/6/1.
//

import UIKit


class MKTimeRangePickerView: MKPopBottomView {
    
    /// 开始时间，格式 00:00
    var startTime = "00:00"
    /// 结束时间，格式 00:00
    var endTime = "00:00"
    /// 限制最小时间，格式 00:00
    var minTime = "00:00"
    /// 限制最大时间，格式 00:00
    var maxTime = "23:59"
    /// 选择完成回调
    var timeRangeClosure:((String, String)->Void)?
    
    private var startPickerView: UIDatePicker!
    private var endPickerView: UIDatePicker!
    
    private var today = Date()
    
    private lazy var calendar: Calendar = {
        var cal = Calendar.init(identifier: .gregorian)
        cal.locale = .init(identifier: "zh_Hans_CN")
        cal.timeZone = TimeZone.current
        return cal
    }()
    
    override func setDefault() {
        super.setDefault()
        title = "选择时间区间"
        cancelTitle = "取消"
        confirmTitle = "确定"
    }
    
    override func appendSubviews() {
        super.appendSubviews()
        
        startPickerView = UIDatePicker.init(super: contentView)
        if #available(iOS 13.4, *) {
            startPickerView.preferredDatePickerStyle = .wheels
        } else {
            // Fallback on earlier versions
        }
        startPickerView.datePickerMode = .time
        
        startPickerView.calendar = calendar
        startPickerView.locale = calendar.locale
        contentView.addSubview(startPickerView)
        startPickerView.snp.makeConstraints { make in
            make.left.equalTo(15)
            make.top.equalTo(navBarView.snp.bottom)
            make.bottom.equalTo(-safeAreaBottom)
            make.height.equalTo(200)
            make.right.equalTo(contentView.snp.centerX).offset(-20)
        }
        
        endPickerView = UIDatePicker.init(super: contentView)
        if #available(iOS 13.4, *) {
            endPickerView.preferredDatePickerStyle = .wheels
        } else {
            // Fallback on earlier versions
        }
        endPickerView.datePickerMode = .time
        endPickerView.calendar = calendar
        endPickerView.locale = calendar.locale
        endPickerView.snp.makeConstraints { make in
            make.right.equalTo(-15)
            make.height.top.equalTo(startPickerView)
            make.left.equalTo(contentView.snp.centerX).offset(20)
        }
        
        let sepLine = UIView.init(super: contentView, backgroundColor: .black)
        sepLine.snp.makeConstraints { make in
            make.centerY.equalTo(startPickerView)
            make.centerX.equalToSuperview()
            make.width.equalTo(20)
            make.height.equalTo(2)
        }
        
        let hourLable1 = UILabel.init(superView: startPickerView, text: "时", textColor: .black, font: .medium(17))
        hourLable1.snp.makeConstraints { make in
            make.centerY.equalToSuperview()
            make.right.equalTo(startPickerView.snp.centerX).offset(-3)
        }
        
        let minuteLable1 = UILabel.init(superView: startPickerView, text: "分", textColor: .black, font: .medium(17))
        minuteLable1.snp.makeConstraints { make in
            make.centerY.equalToSuperview()
            make.right.equalTo(-15)
        }
        
        let hourLable2 = UILabel.init(superView: endPickerView, text: "时", textColor: .black, font: .medium(17))
        hourLable2.snp.makeConstraints { make in
            make.centerY.equalToSuperview()
            make.right.equalTo(endPickerView.snp.centerX).offset(-3)
        }
        
        let minuteLable2 = UILabel.init(superView: endPickerView, text: "分", textColor: .black, font: .medium(17))
        minuteLable2.snp.makeConstraints { make in
            make.centerY.equalToSuperview()
            make.right.equalTo(-15)
        }
        
        startPickerView.addTarget(self, action: #selector(startTimeChanged), for: .valueChanged)
    }
    
    override func dynamicSubviews() {
        makeStartSource()
        makeEndSource()
    }
    
    override func confirmHandle() {
        super.confirmHandle()
        let formatter = DateFormatter.init()
        formatter.timeStyle = .short
        formatter.calendar = calendar
        formatter.locale = calendar.locale
        let startTime = formatter.string(from: startPickerView.date)
        let endTime = formatter.string(from: endPickerView.date)
        timeRangeClosure?(startTime, endTime)
    }
}

extension MKTimeRangePickerView {
    
    private func makeStartSource() {
        
        let minDate = transfDate(time: minTime)
        let maxDate = transfDate(time: maxTime)
        let date = transfDate(time: startTime)
        
        startPickerView.minimumDate = minDate
        startPickerView.maximumDate = maxDate
        startPickerView.date = date
    }
    
    private func makeEndSource() {
        endPickerView.minimumDate = startPickerView.date
        endPickerView.maximumDate = startPickerView.maximumDate
        
        var date = transfDate(time: endTime)
        if date.compare(startPickerView.date) == .orderedAscending {
            date = calendar.date(byAdding: .minute, value: 1, to: startPickerView.date) ?? startPickerView.date
        }
        endPickerView.date = date
    }
    
    @objc private func startTimeChanged() {
        makeEndSource()
    }
    
    private func transfDate(time: String) -> Date {
        var component = calendar.dateComponents([.year, .month, .day, .hour, .minute], from: Date())
        var timeArr = time.components(separatedBy: ":").map { Int($0) ?? 0 }
        if timeArr.count < 2 {
            timeArr.append(0)
        }
        component.hour = timeArr[0]
        component.minute = timeArr[1]
        return calendar.date(from: component) ?? Date()
    }
}
