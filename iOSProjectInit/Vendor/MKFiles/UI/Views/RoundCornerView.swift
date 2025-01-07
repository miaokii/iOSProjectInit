//
//  RoundCornerView.swift
//  MuYunControl
//
//  Created by miaokii on 2023/7/16.
//

import UIKit

class RoundCornerView: KKView {
    var corner: UIRectCorner = []
    var radius: CGFloat = 5
    lazy var label: UILabel = {
        let label = UILabel.init(superView: self, text: "", textColor: .textColorBlack, font: .regular(13), aligment: .center)
        label.snp.makeConstraints { make in
            make.left.equalTo(5)
            make.right.equalTo(-5)
            make.top.equalTo(3)
            make.bottom.equalTo(-3)
        }
        return label
    }()
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        let path = UIBezierPath.init(roundedRect: bounds, byRoundingCorners: corner, cornerRadii: .init(width: radius, height: radius))
        let shapeLayer = CAShapeLayer.init()
        shapeLayer.path = path.cgPath
        
        layer.mask = shapeLayer
    }
}
