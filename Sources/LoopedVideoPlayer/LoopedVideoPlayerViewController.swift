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
    func setCurrentIndex(_ index: Int)
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
    typealias CurrentItem = (index: Int, item: LoopedVideoPlayerPlaylistItem)

    public var dataSource: LoopedVideoPlayerDataSource?
    public weak var delegate: LoopedVideoPlayerDelegate?

    private var currentItem: CurrentItem?

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
        guard self.currentItem == nil else { return }
        _ = self.loadItemAt(0)
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
        self.currentItem = nil
        _ = self.loadItemAt(0)
    }

    public func setCurrentIndex(_ index: Int) {
        _ = self.loadItemAt(index)
    }

    // MARK: - Actions

    @objc
    private func closeButtonTapped(sender: UIButton) {
        self.dismiss(animated: true)
    }

    @objc
    private func previousButtonTapped(sender: UIButton) {
        guard
            let currentItemIndex = self.currentItem?.index,
            self.loadItemAt(currentItemIndex - 1)
        else {
            return
        }

        self.play()
    }

    @objc
    private func nextButtonTapped(sender: UIButton) {
        guard
            let currentItemIndex = self.currentItem?.index,
            self.loadItemAt(currentItemIndex + 1)
        else {
            return
        }

        self.play()
    }

    // MARK: - Internal

    private func play() {
        guard
            let player = self.loopedPlayerView.playerView.player,
            let currentItem = self.currentItem
        else { return }


        self.delegate?.loopedVideoPlayer(self, willPlay: currentItem.item, forItemAt: currentItem.index)
        player.play()
    }

    private func pause() {
        self.loopedPlayerView.playerView.player?.pause()
    }

    private func updateNavigationUI() {
        guard
            let itemCount = self.dataSource?.numberOfItems(for: self),
            let currentItemIndex = self.currentItem?.index
        else {
            self.loopedPlayerView.previousButton.isHidden = true
            self.loopedPlayerView.nextButton.isHidden = true
            return
        }

        self.loopedPlayerView.previousButton.isHidden = currentItemIndex == 0
        self.loopedPlayerView.nextButton.isHidden = currentItemIndex >= itemCount - 1
    }

    private func loadItemAt(_ index: Int) -> Bool {
        defer { self.updateNavigationUI() }

        guard let dataSource else { return false }
        let numberOfItems = dataSource.numberOfItems(for: self)
        guard (0..<numberOfItems).contains(index) else { return false }

        let item = dataSource.loopedVideoPlayer(self, itemAt: index)
        let playerItem = AVPlayerItem(url: item.url)
        let queuePlayer = AVQueuePlayer(playerItem: playerItem)

        self.playerLooper = AVPlayerLooper(player: queuePlayer, templateItem: playerItem)

        self.loopedPlayerView.playerView.player = queuePlayer
        self.loopedPlayerView.titleLabel.text = item.title
        self.loopedPlayerView.subtitleLabel.text = item.subtitle
        self.loopedPlayerView.creditLabel.text = item.credit.isEmpty ? " " : item.credit

        self.currentItem = (index, item)

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
