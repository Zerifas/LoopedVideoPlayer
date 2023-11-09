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

    override func setupSubviews() {
        self.backgroundColor = .systemBackground
        self.addSubview(self.playSingleVideoButton)
        self.addSubview(self.playPlaylistButton)
    }

    override func setupConstraints() {
        let layout = self.safeAreaLayoutGuide

        NSLayoutConstraint.activate([
            self.playSingleVideoButton.leadingAnchor.constraint(greaterThanOrEqualTo: layout.leadingAnchor),
            self.playSingleVideoButton.trailingAnchor.constraint(lessThanOrEqualTo: layout.trailingAnchor),
            self.playSingleVideoButton.topAnchor.constraint(equalToSystemSpacingBelow: layout.topAnchor, multiplier: 1),
            self.playSingleVideoButton.centerXAnchor.constraint(equalTo: layout.centerXAnchor),
        ])

        NSLayoutConstraint.activate([
            self.playPlaylistButton.leadingAnchor.constraint(greaterThanOrEqualTo: layout.leadingAnchor),
            self.playPlaylistButton.trailingAnchor.constraint(lessThanOrEqualTo: layout.trailingAnchor),
            self.playPlaylistButton.topAnchor.constraint(equalToSystemSpacingBelow: self.playSingleVideoButton.bottomAnchor, multiplier: 1),
            self.playPlaylistButton.centerXAnchor.constraint(equalTo: layout.centerXAnchor),
        ])
    }
}
