//
//  DemoView.swift
//  LoopedVideoPlayerDemo
//
//  Created by Mat Gadd on 09/11/2023.
//

import Foundation
import UIKit

import LoopedVideoPlayer

class DemoView: BaseView {
    private let stackView: UIStackView = {
        let view = UIStackView(frame: .zero)
        view.translatesAutoresizingMaskIntoConstraints = false
        view.axis = .vertical
        view.isLayoutMarginsRelativeArrangement = true
        view.layoutMargins = UIEdgeInsets(top: 0, left: 20, bottom: 0, right: 20)
        return view
    }()

    private(set) lazy var playSingleVideoButton: UIButton = {
        let button = UIButton(type: .system)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()

    private(set) lazy var playPlaylistButton: UIButton = {
        let button = UIButton(type: .system)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()

    private(set) lazy var separatorView: UIView = {
        let view = UIView(frame: .zero)
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()

    private(set) lazy var playSingleVideoWithCustomUIButton: UIButton = {
        let button = UIButton(type: .system)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()

    private(set) lazy var playPlaylistWithCustomUIButton: UIButton = {
        let button = UIButton(type: .system)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()

    override func setupSubviews() {
        let background = UIColor(named: "background")
        self.backgroundColor = background

        self.separatorView.backgroundColor = .lightGray

        self.stackView.addArrangedSubview(self.playSingleVideoButton)
        self.stackView.addArrangedSubview(self.playPlaylistButton)
        self.stackView.addArrangedSubview(self.separatorView)
        self.stackView.addArrangedSubview(self.playSingleVideoWithCustomUIButton)
        self.stackView.addArrangedSubview(self.playPlaylistWithCustomUIButton)
        self.addSubview(self.stackView)
    }

    override func setupConstraints() {
        let layout = self.safeAreaLayoutGuide

        NSLayoutConstraint.activate([
            self.stackView.leadingAnchor.constraint(equalTo: layout.leadingAnchor),
            self.stackView.trailingAnchor.constraint(equalTo: layout.trailingAnchor),
            self.stackView.topAnchor.constraint(equalTo: layout.topAnchor),
            self.stackView.bottomAnchor.constraint(lessThanOrEqualTo: layout.bottomAnchor),

            self.separatorView.heightAnchor.constraint(equalToConstant: 1),
        ])
    }
}
