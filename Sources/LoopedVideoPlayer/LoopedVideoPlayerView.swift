//
//  LoopedVideoPlayerView.swift
//  LoopedVideoPlayer
//
//  Created by Mat Gadd on 08/11/2023.
//

import Foundation
import UIKit

public class LoopedVideoPlayerView: BaseView {
    let closeButton: UIButton = .makeLargeButton(systemName: "xmark", tintColor: .white)

    let titleLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = UIFont.preferredFont(forTextStyle: .title1)
        label.numberOfLines = 1
        label.textAlignment = .center
        label.textColor = UIColor.white

        label.layer.shadowColor = UIColor.black.cgColor
        label.layer.shadowOffset = CGSize(width: 0, height: 1)
        label.layer.shadowOpacity = 1.0
        label.layer.shadowRadius = 2.0
        label.layer.masksToBounds = false
        label.layer.shouldRasterize = true

        return label
    }()

    public var trailingButton: UIButton? {
        didSet {
            if let oldValue {
                oldValue.removeFromSuperview()
            }

            if let trailingButton {
                self.addTrailingButton(trailingButton)
            }
        }
    }

    let subtitleLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = UIFont.preferredFont(forTextStyle: .subheadline)
        label.lineBreakMode = .byWordWrapping
        label.numberOfLines = 2
        label.textAlignment = .center
        label.textColor = UIColor.white

        label.layer.shadowColor = UIColor.black.cgColor
        label.layer.shadowOffset = CGSize(width: 0, height: 1)
        label.layer.shadowOpacity = 1.0
        label.layer.shadowRadius = 1.5
        label.layer.masksToBounds = false
        label.layer.shouldRasterize = true

        return label
    }()

    let creditLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = UIFont.preferredFont(forTextStyle: .caption1)
        label.numberOfLines = 1
        label.textAlignment = .center
        label.textColor = UIColor.white

        label.layer.shadowColor = UIColor.black.cgColor
        label.layer.shadowOffset = CGSize(width: 0, height: 1)
        label.layer.shadowOpacity = 1.0
        label.layer.shadowRadius = 1.5
        label.layer.masksToBounds = false
        label.layer.shouldRasterize = true

        return label
    }()

    let previousButton: UIButton = .makeLargeButton(systemName: "chevron.backward", tintColor: .white)
    let nextButton: UIButton = .makeLargeButton(systemName: "chevron.forward", tintColor: .white)

    let playerView: PlayerView = {
        let view = PlayerView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()

    public override func setupSubviews() {
        self.backgroundColor = .black

        // Must add this first, or rearrange subviews later.
        self.addSubview(self.playerView)

        self.addSubview(self.closeButton)
        self.addSubview(self.titleLabel)
        self.addSubview(self.subtitleLabel)
        self.addSubview(self.previousButton)
        self.addSubview(self.nextButton)
        self.addSubview(self.creditLabel)
    }

    // MARK: - Constraints

    public override func setupConstraints() {
        let layout = self.safeAreaLayoutGuide

        self.setupCloseButtonConstraints(layout)
        self.setupTitleLabelConstraints(layout)
        self.setupSubtitleLabelConstraints(layout)
        self.setupPlaylistButtonConstraints(layout)
        self.setupCreditLabelConstraints(layout)
        self.setupPlayerViewConstraints(layout)
    }

    private func setupCloseButtonConstraints(_ layout: UILayoutGuide) {
        self.closeButton.setContentHuggingPriority(.defaultHigh, for: .horizontal)

        NSLayoutConstraint.activate([
            self.closeButton.leadingAnchor.constraint(equalToSystemSpacingAfter: layout.leadingAnchor, multiplier: 1),
            self.closeButton.topAnchor.constraint(equalToSystemSpacingBelow: layout.topAnchor, multiplier: 1),
            self.closeButton.widthAnchor.constraint(greaterThanOrEqualToConstant: 44),
            self.closeButton.heightAnchor.constraint(equalTo: self.closeButton.widthAnchor),
        ])
    }

    private func setupTitleLabelConstraints(_ layout: UILayoutGuide) {
        self.titleLabel.setContentHuggingPriority(.defaultLow, for: .horizontal)

        NSLayoutConstraint.activate([
            self.titleLabel.leadingAnchor.constraint(equalToSystemSpacingAfter: self.closeButton.trailingAnchor, multiplier: 1),
            self.titleLabel.centerXAnchor.constraint(equalTo: self.centerXAnchor),
            self.titleLabel.centerYAnchor.constraint(equalTo: self.closeButton.centerYAnchor),
        ])
    }

    private func setupSubtitleLabelConstraints(_ layout: UILayoutGuide) {
        NSLayoutConstraint.activate([
            self.subtitleLabel.leadingAnchor.constraint(equalToSystemSpacingAfter: layout.leadingAnchor, multiplier: 1),
            layout.trailingAnchor.constraint(equalToSystemSpacingAfter: self.subtitleLabel.trailingAnchor, multiplier: 1),
            self.subtitleLabel.topAnchor.constraint(equalToSystemSpacingBelow: self.titleLabel.bottomAnchor, multiplier: 1),
        ])
    }

    private func setupPlaylistButtonConstraints(_ layout: UILayoutGuide) {
        NSLayoutConstraint.activate([
            self.previousButton.leadingAnchor.constraint(equalToSystemSpacingAfter: layout.leadingAnchor, multiplier: 1),
            self.previousButton.centerYAnchor.constraint(equalTo: self.creditLabel.centerYAnchor),
            self.previousButton.widthAnchor.constraint(greaterThanOrEqualToConstant: 44),
            self.previousButton.heightAnchor.constraint(equalTo: self.previousButton.widthAnchor),
        ])

        NSLayoutConstraint.activate([
            layout.trailingAnchor.constraint(equalToSystemSpacingAfter: self.nextButton.trailingAnchor, multiplier: 1),
            self.nextButton.centerYAnchor.constraint(equalTo: self.creditLabel.centerYAnchor),
            self.nextButton.widthAnchor.constraint(greaterThanOrEqualToConstant: 44),
            self.nextButton.heightAnchor.constraint(equalTo: self.nextButton.widthAnchor),
        ])
    }

    private func setupCreditLabelConstraints(_ layout: UILayoutGuide) {
        NSLayoutConstraint.activate([
            self.creditLabel.leadingAnchor.constraint(equalToSystemSpacingAfter: self.previousButton.trailingAnchor, multiplier: 1),
            self.nextButton.leadingAnchor.constraint(equalToSystemSpacingAfter: self.creditLabel.trailingAnchor, multiplier: 1),
            layout.bottomAnchor.constraint(equalToSystemSpacingBelow: self.creditLabel.bottomAnchor, multiplier: 2),
        ])
    }

    private func setupPlayerViewConstraints(_ layout: UILayoutGuide) {
        NSLayoutConstraint.activate([
            self.playerView.leadingAnchor.constraint(equalTo: layout.leadingAnchor),
            self.playerView.trailingAnchor.constraint(equalTo: layout.trailingAnchor),
            self.playerView.widthAnchor.constraint(equalTo: layout.widthAnchor),
            self.playerView.topAnchor.constraint(equalTo: layout.topAnchor),
            self.playerView.bottomAnchor.constraint(equalTo: layout.bottomAnchor),
        ])
    }

    private func addTrailingButton(_ button: UIButton) {
        let layout = self.safeAreaLayoutGuide

        self.addSubview(button)

        button.setContentHuggingPriority(.defaultHigh, for: .horizontal)

        NSLayoutConstraint.activate([
            button.trailingAnchor.constraint(equalToSystemSpacingAfter: layout.trailingAnchor, multiplier: 1),
            button.topAnchor.constraint(equalToSystemSpacingBelow: layout.topAnchor, multiplier: 1),
            button.widthAnchor.constraint(greaterThanOrEqualToConstant: 44),
            button.heightAnchor.constraint(greaterThanOrEqualToConstant: 44),
        ])
    }
}

@available(iOS 13.0, *)
private extension UIImage.SymbolConfiguration {
    static var large: Self {
        Self(scale: .large)
    }
}

private extension UIButton {
    static func makeLargeButton(systemName: String, tintColor: UIColor? = nil) -> Self {
        let button = Self()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.tintColor = tintColor

        button.layer.shadowColor = UIColor.black.cgColor
        button.layer.shadowOffset = CGSize(width: 0, height: 1)
        button.layer.shadowOpacity = 1.0
        button.layer.shadowRadius = 3.0
        button.layer.masksToBounds = false
        button.layer.shouldRasterize = true

        if #available(iOS 13, *) {
            let image = UIImage(systemName: systemName, withConfiguration: UIImage.SymbolConfiguration.large)
            button.setImage(image, for: .normal)
        } else {
            let title: String
            switch systemName {
            case "xmark": title = "✕"
            case "chevron.backward": title = "<"
            case "chevron.forward": title = ">"
            default: title = ""
            }

            let fontSize = UIFont.preferredFont(forTextStyle: .largeTitle).pointSize
            let font = UIFont(name: "Courier New", size: fontSize)
            button.titleLabel?.font = font
            button.setTitle(title, for: .normal)
        }

        return button
    }

}
