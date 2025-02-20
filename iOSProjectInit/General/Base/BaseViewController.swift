//
//  BaseViewController.swift
//  RXCSaaS
//
//  Created by yoctech on 2023/10/23.
//

import UIKit
import HBDNavigationBar

class BaseViewController: MKBaseViewController { }

extension MKBaseViewController {
    func addTopLine() {
        let line = UIView.init(super: view, backgroundColor: .background)
        line.snp.makeConstraints { make in
            make.left.right.top.equalToSuperview()
            make.height.equalTo(1)
        }
    }
}

extension MKTableViewController where Element: Model {
    
    /// 刷新请求响应，出错时提示，成功时提示后刷新列表
    func refreshRequest(response: Result<AFResult<EmptyModel>, Error>) {
        switch response {
        case .success(let result):
            guard result.REQ_OK else {
                return HUD.flash(warning: result.msg)
            }
            HUD.flash(success: "操作成功") {
                self.requestFirstPageData()
            }
        case .failure(let error):
            HUD.flash(error: error)
        }
    }
    
    /// 刷新从网络中返回的数据
    /// 这个方法只适用于data返回的数据格式是 PageListModel<KakaJSON> 格式的
    /// - Parameter response: 请求结果
    @discardableResult
    func reloadList(response: Result<AFResult<ListModel<Element>>, Error>, showError: Bool = true) -> String? {
        var errorMsg: String?
        switch response{
        case .success(let result):
            if let list = result.data {
                page = list.pageNum
                totalPage = list.pages
                totalCount = list.total
                if page <= 1 {
                    dataSource.removeAll()
                }
                dataSource.append(contentsOf: list.list)
            } else {
                if showError {
                    HUD.flash(error: result.msg)
                }
                errorMsg = result.msg
                if page == 0 {
                    dataSource.removeAll()
                }
            }
        case .failure(let error):
            if showError {
                HUD.flash(error: error)
            }
            errorMsg = error.localizedDescription
        }
        reloadData()
        return errorMsg
    }

    /// 刷新从网络中返回的数据
    /// 这个方法只适用于data返回的数据格式是 模型继承自 KakaJSON
    /// 如果是分页结果，使用reloadList(response:)方法
    /// - Parameter response: 请求结果
    @discardableResult
    func reload(response: Result<AFResult<Element>, Error>, showError: Bool = true) -> String? {
        var errorMsg: String?
        switch response{
        case .success(let result):
            if let datas = result.datas {
                dataSource = datas
            }
            else if let data = result.data {
                dataSource = [data]
            } else {
                errorMsg = result.msg
                if showError {
                    HUD.flash(warning: result.msg)
                }
            }
        case .failure(let error):
            errorMsg = error.localizedDescription
            dataSource.removeAll()
            if showError {
                HUD.flash(error: error)
            }
        }
        reloadData()
        return errorMsg
    }
}


extension MKCollectionViewController where Element : Model {
    /// 刷新请求响应，出错时提示，成功时提示后刷新列表
    func refreshRequest(response: Result<AFResult<EmptyModel>, Error>) {
        switch response {
        case .success(let result):
            guard result.REQ_OK else {
                return HUD.flash(warning: result.msg)
            }
            HUD.flash(success: "操作成功") {
                self.requestFirstPageData()
            }
        case .failure(let error):
            HUD.flash(error: error)
        }
    }
    
    /// 刷新从网络中返回的数据
    /// 这个方法只适用于data返回的数据格式是 PageListModel<KakaJSON> 格式的
    /// - Parameter response: 请求结果
    @discardableResult
    func reloadList(response: Result<AFResult<ListModel<Element>>, Error>, showError: Bool = true) -> String? where Element : Model {
        var errorMsg: String?
        switch response{
        case .success(let result):
            if let list = result.data {
                page = list.pageNum
                totalPage = list.pages
                totalCount = list.total
                if page <= 1 {
                    dataSource.removeAll()
                }
                dataSource.append(contentsOf: list.list)
            } else {
                if showError {
                    HUD.flash(error: result.msg)
                }
                errorMsg = result.msg
                if page == 0 {
                    dataSource.removeAll()
                }
            }
        case .failure(let error):
            if showError {
                HUD.flash(error: error)
            }
            errorMsg = error.localizedDescription
        }
        reloadData()
        return errorMsg
    }
    
    /// 刷新从网络中返回的数据
    /// 这个方法只适用于data返回的数据格式是 模型继承自 KakaJSON
    /// 如果是分页结果，使用reloadList(response:)方法
    /// - Parameter response: 请求结果
    @discardableResult
    func reload(response: Result<AFResult<Element>, Error>, showError: Bool = true) -> String? where Element : Model {
        var errorMsg: String?
        switch response{
        case .success(let result):
            if let datas = result.datas {
                dataSource = datas
            }
            else if let data = result.data {
                dataSource = [data]
            } else {
                errorMsg = result.msg
                if showError {
                    HUD.flash(warning: result.msg)
                }
            }
        case .failure(let error):
            errorMsg = error.localizedDescription
            dataSource.removeAll()
            if showError {
                HUD.flash(error: error)
            }
        }
        reloadData()
        return errorMsg
    }
}
