//
//  MKDatePickerView.swift
//  SwiftLib
//
//  Created by yoctech on 2023/3/10.
//

import UIKit

class MKDatePickerView: MKPopBottomView {
  
    enum DateEle: Int, CaseIterable {
      case year
      case month
      case day
      case hours
      case minute
      case second
      
      var unit: String {
          switch self {
          case .year: return "年"
          case .month: return "月"
          case .day: return "日"
          case .hours: return "时"
          case .minute: return "分"
          case .second: return "秒"
          }
      }
    }

    enum Mode {
      case date
      case countDownTimer(minuteInterval: Int)
      case dateAndTime
      case time
        
      case dateWithJoin(eles: [DateEle], unit: Bool)
      
      var dateMode: UIDatePicker.Mode? {
          switch self {
          case .date: return .date
          case .dateAndTime: return .dateAndTime
          case .countDownTimer: return .countDownTimer
          case .time: return .time
          default: return nil
          }
      }
      
      var title: String {
          switch self {
          case .date, .dateAndTime, .dateWithJoin:
              return "请选择日期"
          case .countDownTimer:
              return "选择倒计时"
          case .time:
              return "选择时间"
          }
      }
    }
    var mode: Mode = .date
    var minDate: Date!
    var maxDate: Date!
    var date = Date()
    var choosedDateClosure: ((Date)->Void)?
    var choosedDatesClosure: (([Date])->Void)?
    /// 返回计时器选中的时，分，秒
    var countDownTimeClosure: ((TimeInterval, TimeInterval, TimeInterval)->Void)?
    var timeClosure: ((String)->Void)?

    private lazy var datePicker: UIDatePicker = {
        let picker = UIDatePicker.init(frame: .zero)
        if #available(iOS 13.4, *) {
            picker.preferredDatePickerStyle = .wheels
        } else {
            // Fallback on earlier versions
        }
        picker.calendar = calendar
        picker.locale = calendar.locale
      contentView.addSubview(picker)
      picker.snp.makeConstraints { make in
          make.left.right.equalToSuperview()
          make.top.equalTo(navBarView.snp.bottom)
          make.bottom.equalTo(-safeAreaBottom)
          make.height.equalTo(200)
      }
      return picker
    }()

    private lazy var pickerView: UIPickerView = {
        let picker = UIPickerView.init(frame: .zero)
      contentView.addSubview(picker)
      picker.snp.makeConstraints { make in
          make.left.right.equalToSuperview()
          make.top.equalTo(navBarView.snp.bottom)
          make.bottom.equalTo(-safeAreaBottom)
          make.height.equalTo(200)
      }
      return picker
    }()

    private lazy var pickerSource = [[String]]()
    private var fontSize: CGFloat = 19
    private var rowFont: UIFont {
        .regular(fontSize)
    }

    private lazy var calendar: Calendar = {
      var cal = Calendar.init(identifier: .gregorian)
      cal.locale = .init(identifier: "zh_Hans_CN")
        cal.timeZone = TimeZone.current
      return cal
    }()

    
    // dateWithJoin模式下的元素构成
    private var dateEles = [DateEle]()
    // 显示单位
    private var dateEleUnit = false

    convenience init(mode: Mode = .date) {
      self.init()
      self.mode = mode
    }

    override func appendSubviews() {
      super.appendSubviews()
        title = "选择日期"
        confirmTitle = "确定"
        date = Date()
        let line = UIView.init(super: navBarView, backgroundColor: .systemBackground)
        line.snp.makeConstraints { make in
            make.left.right.bottom.equalToSuperview()
            make.height.equalTo(1)
        }
    }

    override func dynamicSubviews() {
        super.dynamicSubviews()
        switch mode {
        case let .dateWithJoin(eles, unit):
            // 如果包含天，则必须包含年和月
            guard eles.notEmpty else {
                return
            }
            if eles.contains(.day) && (!eles.contains(.month) ||  !eles.contains(.year)) {
                assert(false, "必须包含年和月")
            }
            /// 排序，按照 年月日时分秒 排列
            dateEles = eles.sorted(by: { le, re in
                le.rawValue < re.rawValue
            })
            if dateEles.count >= 5 {
                fontSize = 17
            } else {
                fontSize = 19
            }
            dateEleUnit = unit
        default:
            break
        }
              
        title = mode.title
        
        if maxDate == nil {
            maxDate = calendar.date(byAdding: .year, value: 10, to: date)
        }
        if minDate == nil {
            minDate = calendar.date(byAdding: .year, value: -10, to: date)
        }
        
        if date < minDate {
            date = minDate
        }
        
        else if date > maxDate {
            date = maxDate
        }
        
        if let dateMode = mode.dateMode {
          datePicker.datePickerMode = dateMode
          datePicker.maximumDate = maxDate
          datePicker.minimumDate = minDate
          datePicker.date = date
          switch mode {
              case .countDownTimer(let minuteInterval):
                  datePicker.minuteInterval = minuteInterval
              default: break
          }
        } else if dateEles.count > 0 {
          pickerView.delegate = self
          pickerView.dataSource = self
          makeSource(autoSelected: true)
        } 
    }

    override func confirmHandle() {
      if let dateMode = mode.dateMode {
          if dateMode == .countDownTimer {
              let second = Int(datePicker.countDownDuration);
              let hours = second / 3600
              let minutes = (second%3600) / 60
              let sec = second%60
              countDownTimeClosure?(TimeInterval(hours), TimeInterval(minutes), TimeInterval(sec))
          } else if dateMode == .time {
              let formatter = DateFormatter.init()
              formatter.timeStyle = .short
              formatter.locale = calendar.locale
              timeClosure?(formatter.string(from: datePicker.date))
          } else {
              choosedDateClosure?(datePicker.date)
          }
      } else if pickerSource.count > 0 {
          choosedDateClosure?(date)
      } else {
          switch mode {
          case .dateWithJoin:
              choosedDateClosure?(date)
          default:
              break
          }
      }
      super.confirmHandle()
    }
}

extension MKDatePickerView: UIPickerViewDataSource, UIPickerViewDelegate {
  
    private func judgeBounds(cur: inout Int, start: Int, end: Int) {
        if cur < start { cur = start }
//        else if cur > end { cur = end }
    }
    
  // 自定义的日期元素，需要构建数据源
  private func makeSource(autoSelected: Bool = false) {
      var sources = [[String]]()
      var selIndex = [Int]()
      
      var startYear = 0
      var endYear = 0
      var curYear = 0
      
      var startMonth = 0
      var endMonth = 0
      var curMonth = 0
      
      var startDay = 0
      var endDay = 0
      var curDay = 0
      
      var startHours = -1
      var endHours = -1
      var curHours = -1
      
      var startMinute = -1
      var endMinute = -1
      var curMinute = -1
      
      for eleRawValue in 0...dateEles.last!.rawValue {
          let ele = DateEle.init(rawValue: eleRawValue)!
          let unit = dateEleUnit ? ele.unit : ""
          switch ele {
          case .year:
              startYear = calendar.component(.year, from: minDate)
              endYear = calendar.component(.year, from: maxDate)
              
              curYear = calendar.component(.year, from: date)
              judgeBounds(cur: &curYear, start: startYear, end: endYear)
              
              if dateEles.contains(.year) {
                  let years = (startYear...endYear).map {"\($0)\(unit)"}
                  sources.append(years)
                  selIndex.append(curYear-startYear)
              }
              
          case .month:
              startMonth = 1
              endMonth = 12
              
              if (curYear == startYear) {
                  startMonth = calendar.component(.month, from: minDate)
              } else if (curYear == endYear) {
                  endMonth = calendar.component(.month, from: maxDate)
              }
              
              curMonth = calendar.component(.month, from: date)
              judgeBounds(cur: &curMonth, start: startMonth, end: endMonth)
              
              if dateEles.contains(.month) {
                  let months = (startMonth...endMonth).map {"\($0)\(unit)"}
                  sources.append(months)
                  selIndex.append(curMonth-startMonth)
              }

          case .day:
              
              startDay = 1
              // 本月最多有多少天
              endDay = calendar.range(of: .day, in: .month, for: date)?.count ?? 31

              if curYear == startYear, curMonth == startMonth {
                  startDay = calendar.component(.day, from: minDate)
              } else if curYear == endYear, curMonth == endMonth {
                  endDay = calendar.component(.day, from: maxDate)
              }
              
              curDay = calendar.component(.day, from: date)
              judgeBounds(cur: &curDay, start: startDay, end: endDay)
              
              if dateEles.contains(.day) {
                  let days = (startDay...endDay).map {"\($0)\(unit)"}
                  sources.append(days)
                  selIndex.append(curDay-startDay)
              }
              
          case .hours:
              if (curDay > 0) {
                  if curYear == startYear, curMonth == startMonth, curDay == startDay {
                      startHours = calendar.component(.hour, from: minDate)
                  } else {
                      startHours = 0
                  }
                  
                  if curYear == endYear, curMonth == endMonth, curDay == endDay {
                      endHours = calendar.component(.hour, from: maxDate)
                  } else {
                      endHours = 23
                  }
              } else {
                  startHours = 0
                  endHours = 23
              }
              curHours = calendar.component(.hour, from: date)
              judgeBounds(cur: &curHours, start: startHours, end: endHours)
              
              if dateEles.contains(.hours) {
                  let hours = (startHours...endHours).map {"\($0)\(unit)"}
                  sources.append(hours)
                  selIndex.append(curHours-startHours)
              }
              
          case .minute:
              startMinute = 0
              endMinute = 59
              if curHours > -1, curDay > 0 {
                  if curYear == startYear, curMonth == startMonth, curDay == startDay, curHours == startHours {
                      startMinute = calendar.component(.minute, from: minDate)
                  } else {
                      startMinute = 0
                  }
                  
                  if curYear == endYear, curMonth == endMonth, curDay == endDay, curHours == endHours {
                      endMinute = calendar.component(.minute, from: maxDate)
                  } else {
                      endMinute = 59
                  }
              }
              curMinute = calendar.component(.minute, from: date)
              judgeBounds(cur: &curDay, start: startMinute, end: endMinute)
              
              if dateEles.contains(.minute) {
                  let minutes = (startMinute...endMinute).map {"\($0)\(unit)"}
                  sources.append(minutes)
                  selIndex.append(curMinute-startMinute)
              }
          case .second:
              var startSecond = 0
              var endSecond = 59
              if curMinute > -1, curDay > 0, curHours > -1 {
                  if curYear == startYear, curMonth == startMonth, curDay == startDay, curHours == startHours, curMinute == startMinute {
                      startSecond = calendar.component(.second, from: minDate)
                  } else {
                      startSecond = 0
                  }
                  
                  if curYear == endYear, curMonth == endMonth, curDay == endDay, curHours == endHours, curMinute == endMinute {
                      endSecond = calendar.component(.second, from: maxDate)
                  } else {
                      endSecond = 59
                  }
              }
              
              var curSecond = calendar.component(.second, from: date)
              judgeBounds(cur: &curSecond, start: startSecond, end: endSecond)
              
              if dateEles.contains(.second) {
                  let seconds = (startSecond...endSecond).map {"\($0)\(unit)"}
                  sources.append(seconds)
                  selIndex.append(curSecond-startSecond)
              }
          }
      }
      
      /// 数据源变化，刷新
      var sourceChanged = pickerSource.isEmpty
      for (idx, source) in pickerSource.enumerated() {
          if source.count != sources[idx].count {
              sourceChanged = true
              break
          }
      }
      
      guard sourceChanged else {
          return
      }
      pickerSource = sources
      pickerView.reloadAllComponents()
      
      for (idx, selIndex) in selIndex.enumerated() {
          pickerView.selectRow(selIndex, inComponent: idx, animated: autoSelected)
      }
  }
  
  // 跟新选中的日期
  private func updateSelectedDate() {
      
      var dateComponents =
      calendar.dateComponents([.year, .month, .day, .hour, .minute, .second], from: Date())
      dateComponents.calendar = calendar
      
      var year = 0
      var month = 0
      
      for (component, ele) in dateEles.enumerated() {
          let row = pickerView.selectedRow(inComponent: component)
          let eleValue = pickerSource[component][row].dropLast(1)
          var eleInt = Int(eleValue) ?? 0
          
          switch ele {
          case .year:
              year = eleInt
              dateComponents.year = eleInt
          case .month:
              month = eleInt
              dateComponents.month = eleInt
          case .day:
              // 月份特殊处理，每个月天数可能不一样
              var newComponents = DateComponents()
              newComponents.calendar = calendar
              newComponents.year = year
              newComponents.month = month
              if let newDate = newComponents.date, let days = calendar.range(of: .day, in: .month, for: newDate)?.count {
                  if eleInt > days {
                      eleInt = days
                  }
              }
              dateComponents.day = eleInt
          case .hours:
              dateComponents.hour = eleInt
          case .minute:
              dateComponents.minute = eleInt
          case .second:
              dateComponents.second = eleInt
          }
      }
      
      date = dateComponents.date ?? Date()
      if date < minDate {
          date = minDate
      } else if date > maxDate {
          date = maxDate
      }
      
      makeSource()
  }
  
  func numberOfComponents(in pickerView: UIPickerView) -> Int {
      return dateEles.count
  }
  func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
      return pickerSource[component].count
  }
  func pickerView(_ pickerView: UIPickerView, widthForComponent component: Int) -> CGFloat {
      let firstRowVal = pickerSource[component].first ?? ""
      let rowWidth = firstRowVal.size(using: rowFont, availableWidth: pickerView.frame.size.width).width
      
      var componentWidth: CGFloat = 0
      if pickerSource.count < 2 {
          componentWidth = rowWidth + 45
      } else if pickerSource.count < 4 {
          componentWidth = rowWidth + 35
      } else if pickerSource.count < 5 {
          componentWidth = rowWidth + 25
      } else {
          componentWidth = rowWidth + 15
      }
      
      return componentWidth
  }
  
  func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
      return pickerSource[component][row]
  }
  
  func pickerView(_ pickerView: UIPickerView, rowHeightForComponent component: Int) -> CGFloat {
      return 40
  }
  
  func pickerView(_ pickerView: UIPickerView, viewForRow row: Int, forComponent component: Int, reusing view: UIView?) -> UIView {
      var selectedLabel = view as? UILabel
      if selectedLabel == nil {
          let label = UILabel.init()
          label.font = rowFont
          label.textColor = .black
          label.adjustsFontSizeToFitWidth = true
          label.numberOfLines = 0
          label.textAlignment = .center
          selectedLabel = label
      }
      selectedLabel!.text = pickerSource[component][row]
      
      DispatchQueue.main.async {
          if let label = pickerView.view(forRow: row, forComponent: component) as? UILabel {
              label.textColor = .black
              label.font = .medium(self.fontSize)
          }
      }
      
      
      return selectedLabel!
  }
  
  func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
      updateSelectedDate()
  }
}

extension MKDatePickerView {}


//fileprivate extension String {
//  func size(font: UIFont, width: CGFloat) -> CGSize {
//      let att = [NSMutableAttributedString.Key.font: font]
//      return self.boundingRect(with: .init(width: width, height: .infinity), options: .usesLineFragmentOrigin, attributes: att, context: nil).size
//  }
//}
