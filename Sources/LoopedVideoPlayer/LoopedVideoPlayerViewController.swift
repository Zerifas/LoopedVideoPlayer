//
//  LoopedVideoPlayerViewController.swift
//  LoopedVideoPlayer
//
//  Created by Mat Gadd on 08/11/2023.
//

import AVFoundation
import Foundation
import UIKit

public struct LoopedVideoPlayerPlaylistItem: Equatable {
    public let url: URL
    public let title: String
    public let subtitle: String
    public let credit: String

    public init(url: URL, title: String, subtitle: String, credit: String) {
        self.url = url
        self.title = title
        self.subtitle = subtitle
        self.credit = credit
    }
}

public protocol LoopedVideoPlayerViewControllerProtocol {
    func reloadData()
}

public protocol LoopedVideoPlayerDelegate: AnyObject {
    func loopedVideoPlayer(_ player: LoopedVideoPlayerViewController, willPlay item: LoopedVideoPlayerPlaylistItem, forItemAt index: Int)
}

public protocol LoopedVideoPlayerDataSource {
    func numberOfItems(for player: LoopedVideoPlayerViewController) -> Int
    func loopedVideoPlayer(_ player: LoopedVideoPlayerViewController, itemAt: Int) -> LoopedVideoPlayerPlaylistItem
}

@objc
public class LoopedVideoPlayerViewController: UIViewController, LoopedVideoPlayerViewControllerProtocol {
    public var dataSource: LoopedVideoPlayerDataSource?
    public weak var delegate: LoopedVideoPlayerDelegate?

    private var currentItemIndex: Int = 0

    private var notificationCenter: NotificationCenter?
    private var playerLooper: AVPlayerLooper?
    private var observers: [NSObjectProtocol] = []

    public private(set) lazy var loopedPlayerView = LoopedVideoPlayerView()

    // MARK: - Initializers

    public override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
    }

    public convenience init(notificationCenter: NotificationCenter = .default) {
        self.init(nibName: nil, bundle: nil)

        self.notificationCenter = notificationCenter

        self.setupNotificationObservers()
    }

    public required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - View lifecycle

    public override func loadView() {
        self.view = self.loopedPlayerView
    }

    public override func viewDidLoad() {
        super.viewDidLoad()

        self.loopedPlayerView.closeButton.addTarget(self, action: #selector(self.closeButtonTapped(sender:)), for: .touchUpInside)
        self.loopedPlayerView.previousButton.addTarget(self, action: #selector(self.previousButtonTapped(sender:)), for: .touchUpInside)
        self.loopedPlayerView.nextButton.addTarget(self, action: #selector(self.nextButtonTapped(sender:)), for: .touchUpInside)
    }

    public override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        _ = self.prepareToPlayItem(at: self.currentItemIndex)
    }

    public override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.play()
    }

    public override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.pause()
    }

    // MARK: - LoopedVideoPlayerViewControllerProtocol

    public func reloadData() {
        self.currentItemIndex = 0
        self.updateNavigationUI()
    }

    // MARK: - Actions

    @objc
    private func closeButtonTapped(sender: UIButton) {
        self.dismiss(animated: true)
    }

    @objc
    private func previousButtonTapped(sender: UIButton) {
        guard self.prepareToPlayItem(at: self.currentItemIndex - 1) else { return }
        self.play()
    }

    @objc
    private func nextButtonTapped(sender: UIButton) {
        guard self.prepareToPlayItem(at: self.currentItemIndex + 1) else { return }
        self.play()
    }

    // MARK: - Internal

    private func play() {
        guard
            let player = self.loopedPlayerView.playerView.player,
            let item = self.dataSource?.loopedVideoPlayer(self, itemAt: self.currentItemIndex)
        else { return }

        self.delegate?.loopedVideoPlayer(self, willPlay: item, forItemAt: self.currentItemIndex)
        player.play()
    }

    private func pause() {
        self.loopedPlayerView.playerView.player?.pause()
    }

    private func updateNavigationUI() {
        guard let itemCount = self.dataSource?.numberOfItems(for: self) else {
            self.loopedPlayerView.previousButton.isHidden = true
            self.loopedPlayerView.nextButton.isHidden = true
            return
        }

        self.loopedPlayerView.previousButton.isHidden = self.currentItemIndex == 0
        self.loopedPlayerView.nextButton.isHidden = self.currentItemIndex >= itemCount - 1
    }

    private func prepareToPlayItem(at index: Int) -> Bool {
        defer { self.updateNavigationUI() }

        guard let dataSource else { return false }
        let numberOfItems = dataSource.numberOfItems(for: self)
        guard (0..<numberOfItems).contains(index) else { return false }

        self.currentItemIndex = index

        let item = dataSource.loopedVideoPlayer(self, itemAt: index)
        let playerItem = AVPlayerItem(url: item.url)
        let queuePlayer = AVQueuePlayer(playerItem: playerItem)

        self.playerLooper = AVPlayerLooper(player: queuePlayer, templateItem: playerItem)

        self.loopedPlayerView.playerView.player = queuePlayer
        self.loopedPlayerView.titleLabel.text = item.title
        self.loopedPlayerView.subtitleLabel.text = item.subtitle
        self.loopedPlayerView.creditLabel.text = item.credit.isEmpty ? " " : item.credit

        return true
    }

    // MARK: - Notifications

    private func applicationDidBecomeActive() {
        self.loopedPlayerView.playerView.player?.play()
    }

    private func applicationWillResignActive() {
        self.loopedPlayerView.playerView.player?.pause()
    }

    private func setupNotificationObservers() {
        self.observers = [
            self.setupApplicationDidBecomeActiveNotificationObserver(),
            self.setupApplicationWillResignActiveNotificationObserver(),
        ].compactMap { $0 }
    }

    private func setupApplicationDidBecomeActiveNotificationObserver() -> NSObjectProtocol? {
        self.notificationCenter?.addObserver(
            forName: UIApplication.didBecomeActiveNotification,
            object: nil,
            queue: .main,
            using: { [weak self] _ in
                self?.applicationDidBecomeActive()
            }
        )
    }

    private func setupApplicationWillResignActiveNotificationObserver() -> NSObjectProtocol? {
        self.notificationCenter?.addObserver(
            forName: UIApplication.willResignActiveNotification,
            object: nil,
            queue: .main,
            using: { [weak self] _ in
                self?.applicationWillResignActive()
            }
        )
    }

}
