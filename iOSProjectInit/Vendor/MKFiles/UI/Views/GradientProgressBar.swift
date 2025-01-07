//
//  File.swift
//  MuYunControl
//
//  Created by miaokii on 2023/8/1.
//

import Foundation
import UIKit
import SnapKit

class GradientProgressBar: UIView {

    private let gradientLayer = CAGradientLayer()
    private let progressLayer = CALayer()

    var minimumValue: Float = 0.0 {
        didSet { updateProgress() }
    }

    var maximumValue: Float = 1.0 {
        didSet { updateProgress() }
    }

    var currentValue: Float = 0.0 {
        didSet { updateProgress() }
    }

    var gradientStartColor: UIColor = .blue {
        didSet { updateGradientColors() }
    }

    var gradientEndColor: UIColor = .green {
        didSet { updateGradientColors() }
    }

    var trackColor: UIColor = .lightGray {
        didSet { updateTrackColor() }
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupLayers()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupLayers()
    }

    private func setupLayers() {
        // 设置进度条颜色渐变
        gradientLayer.colors = [gradientStartColor.cgColor, gradientEndColor.cgColor]
        gradientLayer.startPoint = CGPoint(x: 0.0, y: 0.5)
        gradientLayer.endPoint = CGPoint(x: 1.0, y: 0.5)
        layer.addSublayer(gradientLayer)

        // 设置进度条图层
        progressLayer.backgroundColor = UIColor.clear.cgColor
        layer.addSublayer(progressLayer)

        // 更新进度条显示
        updateProgress()
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        gradientLayer.frame = bounds
        updateProgress()
    }

    private func updateProgress() {
        // 计算进度值的百分比
        let progress = max(min((currentValue - minimumValue) / (maximumValue - minimumValue), 1.0), 0.0)

        // 更新进度条颜色渐变位置
        gradientLayer.frame = CGRect(x: 0, y: 0, width: bounds.width * CGFloat(progress), height: bounds.height)

        // 更新进度条图层
        progressLayer.frame = CGRect(x: 0, y: 0, width: bounds.width * CGFloat(progress), height: bounds.height)
    }

    private func updateGradientColors() {
        gradientLayer.colors = [gradientStartColor.cgColor, gradientEndColor.cgColor]
    }

    private func updateTrackColor() {
        backgroundColor = trackColor
    }
}
