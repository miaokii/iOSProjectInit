//
//  String+Ex.swift
//  MuYunControl
//
//  Created by miaokii on 2023/2/25.
//
import UIKit

extension String {
    /// 文本宽度
    func sizeWidth(font: UIFont = UIFont.systemFont(ofSize: UIFont.systemFontSize),
                  maxWidth width: CGFloat = UIScreen.main.bounds.width) -> CGSize {
        if self.isEmpty { return CGSize.init(width: 0, height: 0 ) }
        let attrStr = NSAttributedString.init(string: self, attributes: [NSAttributedString.Key.font : font])
        var range = NSMakeRange(0, attrStr.length)
        let dic = attrStr.attributes(at: 0, effectiveRange: &range)
        let sizeToFit = self.boundingRect(with: CGSize.init(width: width, height: CGFloat(MAXFLOAT)), options: [.usesLineFragmentOrigin, .usesFontLeading], attributes: dic, context: nil).size
        return sizeToFit
    }
    
    func size(using font: UIFont, availableWidth: CGFloat = .greatestFiniteMagnitude) -> CGSize {
        let size = CGSize(width: availableWidth, height: .greatestFiniteMagnitude)
        let options: NSStringDrawingOptions = [ .usesLineFragmentOrigin, .usesFontLeading ]
        let boundingRect = self.boundingRect(with: size, options: options, attributes: [ .font: font ], context: nil)
        let ceilSize = CGSize(width: ceil(boundingRect.width), height: ceil(boundingRect.height))
        return ceilSize
    }
    
    var notEmpty: Bool {
        return !isEmpty
    }
}

// MARK: - 拼音
extension String {
     /// 拼音
    var letters: String {
        let mutableString = NSMutableString(string: self)
        CFStringTransform(mutableString, nil, kCFStringTransformToLatin, false)
        CFStringTransform(mutableString, nil, kCFStringTransformStripDiacritics, false)
        let string = String(mutableString)
        return string.replacingOccurrences(of: " ", with: "")
    }
    
    /// 拼音首字母
    var firstLetter: String {
        return String(letters[0])
    }
    
    func pinyinSimple() -> String {
        return letters.components(separatedBy: " ").map{ $0.firstLetter }.joined()
    }
}

// 格式化金额
extension String {
    
    static func string(value: Double, formatter:(NumberFormatter)->Void) -> String {
        let amountFormatter = NumberFormatter.init()
        formatter(amountFormatter)
        return amountFormatter.string(from: NSNumber.init(value: value)) ?? ""
    }
    /// 格式化金额
    /// - Parameters:
    ///   - value: 金额值
    ///   - numberStyle: NumberFormatter.Style类型，表示格式化格式
    /// - Returns: 格式化后的值
    static func priceBy(value: Double, numberStyle: NumberFormatter.Style = .currency) -> String {
        let amountFormatter = NumberFormatter.init()
        amountFormatter.numberStyle = numberStyle
        return amountFormatter.string(from: NSNumber.init(value: value)) ?? ""
    }
        
    /// 格式化人名币金额，不显示羊角符
    /// - Parameter value: 金额值
    /// - Returns: 格式化后的值
    static func price_without_claw(value: Double) -> String {
        let price = priceBy(value: value)
        if price.hasPrefix("¥") || price.hasPrefix("￥") {
            return price[1..<price.count]
        }
        return price
    }
    
    /// 转换double为string
    /// - Parameters:
    ///   - value: double值
    ///   - numberStyle: 转换格式，默认decimal
    /// - Returns: 转换后值
    static func decimal(value: Double, style: NumberFormatter.Style = .decimal) -> String {
        let amountFormatter = NumberFormatter.init()
        amountFormatter.numberStyle = style
        return amountFormatter.string(from: NSNumber.init(value: value)) ?? ""
    }
    
    static func decimal(value: Float, style: NumberFormatter.Style = .decimal) -> String {
        let amountFormatter = NumberFormatter.init()
        amountFormatter.numberStyle = style
        return amountFormatter.string(from: NSNumber.init(value: value)) ?? ""
    }
}

// MARK: - 截取
extension String{
    //获取子字符串
    func subString(range: Range<Int>) -> String? {
        if range.lowerBound < 0 || range.upperBound > self.count {
            return nil
        }
        let startIndex = self.index(self.startIndex, offsetBy:range.lowerBound)
        let endIndex   = self.index(self.startIndex, offsetBy:range.upperBound)
        return String(self[startIndex..<endIndex])
    }
}

// MARK: - subscript
public extension String {
    
    subscript(offset: Int) -> Character {
        get {
            return self[index(startIndex, offsetBy: offset)]
        }
        set {
            replaceSubrange(index(startIndex, offsetBy: offset)..<index(startIndex, offsetBy: offset + 1), with: [newValue])
        }
    }
    
    subscript(range: CountableRange<Int>) -> String {
        get {
            return String(self[index(startIndex, offsetBy: range.lowerBound)..<index(startIndex, offsetBy: range.upperBound)])
        }
        set {
            replaceSubrange(index(startIndex, offsetBy: range.lowerBound)..<index(startIndex, offsetBy: range.upperBound), with: newValue)
        }
    }
    
    subscript(location: Int, length: Int) -> String {
        get {
            return String(self[index(startIndex, offsetBy: location)..<index(startIndex, offsetBy: location + length)])
        }
        set {
            replaceSubrange(index(startIndex, offsetBy: location)..<index(startIndex, offsetBy: location + length), with: newValue)
        }
    }
    
    func asUrl() -> URL? {
        return URL(string: addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? "")
    }
}

// MARK: - 正则
extension String {
    
    /// 是否为电话号码
    var isPhone: Bool {
        //return ~/"^1\\d{10}$" ~= self
        return ~/"^1[3-9]\\d{9}" ~= self
    }
    
    /// 是否为金额，最多两位小数
    var isPrice: Bool {
        components(separatedBy: ".").count <= 2 && Double(self) != nil
    }
    
    /// 是否为字母或数字
    var isLettersOrNumbers: Bool {
        return ~/"^[0-9A-Za-z]+$" ~= self
    }
    
    /// 是否为字母和数字
    var isLetterAndNumbers: Bool {
        return ~/"^(?=.*\\d)(?=.*[a-zA-Z])[a-zA-Z0-9]{2,}$" ~= self
    }
    
    /// 是否为邮箱
    var isEmail: Bool {
        return ~/"^[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,4}$" ~= self
    }
    
    /// 是否未url
    var isURL: Bool {
        return ~/"^[a-zA-z]+://[^\\s]*$" ~= self
    }
    
    /// 是否为ip
    var isIP: Bool {
        let rc = ~/"^(\\d{1,3})\\.(\\d{1,3})\\.(\\d{1,3})\\.(\\d{1,3})$" ~= self
        guard rc else {
            return false
        }
        
        let componds = self.components(separatedBy: ".").compactMap{ Int($0) }
        for val in componds {
            if val > 255 {
                return false
            }
        }
        
        return true
    }
    
    /// 是否为特殊字符
    var isSpecialCharacters: Bool {
        let specialCharacters = "[~`!@#$%^&*()_+-=[]|{};':\",./<>?]{,} /"
        for ch in self {
            if !specialCharacters.contains(ch) {
                return false
            }
        }
        return true
    }
    
    /// 是否为中文字符
    var isChineseStrict: Bool {
        return ~/"^[\\u4e00-\\u9fbf\\278b-\\2792]+$" ~= self
    }
    
    /// 字母或数字
    var isAlphabetOrNum: Bool {
        let alphaNum = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789"
        let cs  = CharacterSet.init(charactersIn: alphaNum).inverted
        let filterd = components(separatedBy: cs).joined(separator: "")
        return self == filterd
    }
    
    /// 包含字母或数字
    var isContainAlphabetAndNum: Bool {
        return ~/"^(?![0-9]+$)(?![a-zA-Z]+$)[0-9A-Za-z]{8,20}$" ~= self
    }
    
    /// 是否为中文
    var isChinese: Bool {
        //0x0000-0x007f为ASCII码
        //0x2000-0x206f常用标点
        //0x20A0-0x20CF：货币符号
        //0x3000-0x303f中文符号和标点
        //0x4e00-0x9fbf中文汉字
        //0xff00-0xffef半角和全角
        //0x278b-0x2792苹果手机中文9键输入时对应的2-9，1则为标点。
        return ~/"^[\\u0000-\\u007f\\u2000-\\u206f\\u20a0-\\u20cf\\u278b-\\u2792\\u3000-\\u303f\\u4e00-\\u9fbf\\uff00-\\uffef]+$" ~= self
    }
    
    var isPureChinese: Bool {
        return ~/"^[\\u4e00-\\u9fa5]+$" ~= self
    }
    
    /// 是否包含表情
    var isContainsEmoji: Bool {
        //2600-26FF：杂项符号 (Miscellaneous Symbols)
        //2700-27BF：印刷符号 (Dingbats)
        //27C0-27EF：杂项数学符号-A (Miscellaneous Mathematical Symbols-A)
        //2980-29FF：杂项数学符号-B (Miscellaneous Mathematical Symbols-B)
        //2A00-2AFF：追加数学运算符 (Supplemental Mathematical Operator)
        //2B00-2BFF：杂项符号和箭头 (Miscellaneous Symbols and Arrows)
        //e000-f8ff：自行使用区域 (Private Use Zone)
        //0001f000-0001ffff：表情符号
        return ~/"^([\u{2600}-\u{27ef}\u{2980}-\u{2bff}\u{e000}-\u{f8ff}\u{0001f000}-\u{0001ffff}]+)([\u{0000}-\u{0001ffff}]*)$" ~= self
    }
    
    /// 宽松的身份证号码校验
    var isIdCard: Bool {
        return ~/"^(\\d{14}|\\d{17})(\\d|[xX])$" ~= self
    }
    
    /// 严格的身份证号码校验
    var isIdCardStrict: Bool {
        if count != 18 {
            return false
        }
        // 正则表达式判断基本 身份证号是否满足格式
        guard ~/"^(\\d{6})(\\d{4})(\\d{2})(\\d{2})(\\d{3})([0-9]|X|x)$" ~= self else { return false }
        //如果通过该验证，说明身份证格式正确，但准确性还需计算
        //** 开始进行校验 *//
        //将前17位加权因子保存在数组里
        let idCardWiArray = ["7", "9", "10", "5", "8", "4", "2", "1", "6", "3", "7", "9", "10", "5", "8", "4", "2"]
        //这是除以11后，可能产生的11位余数、验证码，也保存成数组
        let idCardYArray = ["1", "0", "10", "9", "8", "7", "6", "5", "4", "3", "2"]
        //用来保存前17位各自乖以加权因子后的总和
        var idCardWiSum = 0
        for i in 0..<17 {
            let subStrIndex = Int(self[i, 1]) ?? 0
            let idCardWiIndex = Int(idCardWiArray[i]) ?? 0
            idCardWiSum += subStrIndex * idCardWiIndex
        }
        //计算出校验码所在数组的位置
        let idCardMod = idCardWiSum % 11
        //得到最后一位身份证号码
        let idCardLast = self[17, 1]
        //如果等于2，则说明校验码是10，身份证号码最后一位应该是X
        if idCardMod == 2 {
            if idCardLast != "x" && idCardLast != "X" {
                return false
            }
        } else {
            //用计算出的验证码与最后一位身份证号码匹配。
            //如果一致，说明通过，否则是无效的身份证号码
            if idCardLast != idCardYArray[idCardMod] {
                return false
            }
        }
        return true
    }
}
