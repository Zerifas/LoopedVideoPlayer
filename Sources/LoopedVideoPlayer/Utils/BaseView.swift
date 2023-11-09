//
//  BaseView.swift
//  LoopedVideoPlayer
//
//  Created by Mat Gadd on 08/11/2023.
//

import Foundation
import UIKit

public protocol BaseViewProtocol {
    func setupSubviews()
    func setupConstraints()
}

open class BaseView: UIView, BaseViewProtocol {
    public convenience init() {
        self.init(frame: .zero)
    }

    public override init(frame: CGRect) {
        super.init(frame: frame)
        self.setupSubviews()
        self.setupConstraints()
    }

    public required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    open func setupSubviews() {
    }

    open func setupConstraints() {
    }
}
