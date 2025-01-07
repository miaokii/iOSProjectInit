import KakaJSON

/// 请求结果
/// 
/// DataModel是最终转换为model的类型，遵守KakaJSON协议
/// 
/// 如果接口返回数据data是字典，最终转换data为DataModel类型
/// 
/// 如果接口返回数据data是数组，就取 datas，为[DataModel]?类型
struct AFResult<DataModel: Model>: Model {
    
    /// code等于0：失败，等于1：成功，等于401：token失效
    var code: Int = 0
    var subCode = 0
    var msg: String = ""
    var data: DataModel?
    var datas: [DataModel]?
    var dataDic: AFParam?
    var dataArr: [Any]?
    var success = true
    var dataString: String?
    
    /// 成功
    var REQ_OK: Bool {
        return code == 200
    }
    
    /// token 失效
    var REQ_LOGOUT: Bool {
        return code == 401 || code == 403
    }
    
    func kj_modelValue(from jsonValue: Any?, _ property: Property) -> Any? {
        if property.name == "data" {
            if let string = jsonValue as? String, let dic = string.dictionary {
                return dic
            }
        }
        return jsonValue
    }
        
    mutating func kj_didConvertToModel(from json: [String : Any]) {
        if let dic = json["data"] as? AFParam {
            self.dataDic = dic
        }
        else if let arr = json["data"] as? [Any] {
            self.dataArr = arr
        }
        else if let str = json["data"] as? String {
            self.dataString = str
        }
        
        if let error = json["error"] as? String {
            self.msg = error
        }
        
        if let dataArr = self.dataArr {
            self.datas = modelArray(from: dataArr, type: DataModel.self) as? [DataModel]
        }
    }
}

struct ListModel<M: Model>: Model {
    var total: Int = 0
    var pages: Int = 0
    var pageNum: Int = 0
    var pageSize: Int = 0
    var list = [M]()
    
    func kj_modelKey(from property: Property) -> ModelPropertyKey {
        if property.name == "list" {
            return ["records", property.name]
        }
        else if property.name == "pageNum" {
            return [property.name, "current"]
        }
        else if property.name == "pageSize" {
            return [property.name, "size"]
        }
        else {
            return property.name
        }
    }
}

struct EmptyModel: Model {
    var placeKey = ""
}
