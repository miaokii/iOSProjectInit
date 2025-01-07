//
//  TableView.swift
//  RXCSaaS
//
//  Created by yoctech on 2023/12/26.
//

import UIKit
import DZNEmptyDataSet
import TextAttributes

class TableView: UITableView, DZNEmptyDataSetSource, DZNEmptyDataSetDelegate {
    
    var showEmpty: Bool = false {
        didSet {
            if showEmpty {
                emptyDataSetSource = self
                emptyDataSetDelegate = self
            } else {
                emptyDataSetSource = nil
                emptyDataSetDelegate = nil
            }
        }
    }
    
    var emptyTitle = "暂无数据"
    
    override init(frame: CGRect, style: UITableView.Style) {
        super.init(frame: frame, style: style)
        showEmpty = true
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    
    // MARK: - empty
    func image(forEmptyDataSet scrollView: UIScrollView!) -> UIImage! {
        .init(named: "img_no_data")
    }
    
    func title(forEmptyDataSet scrollView: UIScrollView!) -> NSAttributedString! {
        return .init(string: emptyTitle, attributes: TextAttributes.init().font(.systemFont(ofSize: 12)).foregroundColor(.textColorLightGray).alignment(.center))
    }

    func emptyDataSetShouldFade(in scrollView: UIScrollView!) -> Bool {
        return true
    }
    
    func emptyDataSetShouldAllowScroll(_ scrollView: UIScrollView!) -> Bool {
        return true
    }
    
    func verticalOffset(forEmptyDataSet scrollView: UIScrollView!) -> CGFloat {
        return -40
    }
}
