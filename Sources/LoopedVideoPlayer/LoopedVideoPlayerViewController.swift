//
//  LoopedVideoPlayerViewController.swift
//  LoopedVideoPlayer
//
//  Created by Mat Gadd on 08/11/2023.
//

import AVFoundation
import Foundation
import UIKit

public protocol LoopedVideoPlayerPlaylistItem {
    var url: URL { get }
    var title: String { get }
    var subtitle: String { get }
    var credit: String { get }

    func equalTo(_ other: any LoopedVideoPlayerPlaylistItem) -> Bool
}

// TODO: Is there a proper way to conform to Equatable instead of this?
private extension LoopedVideoPlayerPlaylistItem {
    func equalTo(_ other: Self) -> Bool {
        self.url == other.url &&
        self.title == other.title &&
        self.subtitle == other.subtitle &&
        self.credit == other.credit
    }
}

protocol LoopedVideoPlayerViewControllerProtocol {
    func prepareToPlay(_ item: any LoopedVideoPlayerPlaylistItem)
    func prepareToPlay(_ item: any LoopedVideoPlayerPlaylistItem, playlist: [any LoopedVideoPlayerPlaylistItem])
}

@objc
public class LoopedVideoPlayerViewController: UIViewController, LoopedVideoPlayerViewControllerProtocol {
    private var notificationCenter: NotificationCenter?
    private var playerLooper: AVPlayerLooper?
    private var observers: [NSObjectProtocol] = []

    private var currentItem: (any LoopedVideoPlayerPlaylistItem)?
    private var playlist: [any LoopedVideoPlayerPlaylistItem]?

    private var loopedPlayerView: LoopedVideoPlayerView {
        self.view as! LoopedVideoPlayerView
    }

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
        self.view = LoopedVideoPlayerView()
    }

    public override func viewDidLoad() {
        super.viewDidLoad()

        self.loopedPlayerView.closeButton.addTarget(self, action: #selector(self.closeButtonTapped(sender:)), for: .touchUpInside)
        self.loopedPlayerView.previousButton.addTarget(self, action: #selector(self.previousButtonTapped(sender:)), for: .touchUpInside)
        self.loopedPlayerView.nextButton.addTarget(self, action: #selector(self.nextButtonTapped(sender:)), for: .touchUpInside)
    }

    public override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.updateNavigationUI()
    }

    public override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.loopedPlayerView.playerView.player?.play()
    }

    public override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.loopedPlayerView.playerView.player?.pause()
    }

    // MARK: - LoopedVideoPlayerViewControllerProtocol

    public func prepareToPlay(_ item: any LoopedVideoPlayerPlaylistItem) {
        let playerItem = AVPlayerItem(url: item.url)
        let queuePlayer = AVQueuePlayer(playerItem: playerItem)
        queuePlayer.isMuted = true

        self.playerLooper = AVPlayerLooper(player: queuePlayer, templateItem: playerItem)

        self.loopedPlayerView.playerView.player = queuePlayer
        self.loopedPlayerView.titleLabel.text = item.title
        self.loopedPlayerView.subtitleLabel.text = item.subtitle
        self.loopedPlayerView.creditLabel.text = item.credit
    }

    public func prepareToPlay(_ item: any LoopedVideoPlayerPlaylistItem, playlist: [any LoopedVideoPlayerPlaylistItem]) {
        guard !playlist.isEmpty, playlist.map({ $0.url }).contains(item.url) else { return }

        self.playlist = playlist
        self.currentItem = item
        self.prepareToPlay(item)

        self.updateNavigationUI()
    }

    // MARK: - Actions

    @objc
    private func closeButtonTapped(sender: UIButton) {
        self.dismiss(animated: true)
    }

    @objc
    private func previousButtonTapped(sender: UIButton) {
        defer { self.updateNavigationUI() }

        guard
            let playlist,
            let currentItem,
            let currentIndex = playlist.firstIndex(where: { $0.equalTo(currentItem) })
        else {
            return
        }

        let previousIndex = playlist.index(before: currentIndex) // TODO: Could this crash?
        guard playlist.indices.contains(previousIndex) else {
            fatalError("Invalid array index")
        }

        let newItem = playlist[previousIndex]
        self.currentItem = playlist[previousIndex]
        self.prepareToPlay(newItem)
        self.loopedPlayerView.playerView.player?.play()
    }

    @objc
    private func nextButtonTapped(sender: UIButton) {
        defer { self.updateNavigationUI() }

        guard
            let playlist,
            let currentItem,
            let currentIndex = playlist.firstIndex(where: { $0.equalTo(currentItem) })
        else {
            return
        }

        let nextIndex = playlist.index(after: currentIndex) // TODO: Could this crash?
        guard playlist.indices.contains(nextIndex) else {
            fatalError("Invalid array index")
        }

        let newItem = playlist[nextIndex]
        self.currentItem = playlist[nextIndex]
        self.prepareToPlay(newItem)
        self.loopedPlayerView.playerView.player?.play()
    }

    private func updateNavigationUI() {
        guard
            let playlist,
            !playlist.isEmpty,
            let currentItem,
            let currentIndex = playlist.firstIndex(where: { $0.url == currentItem.url })
        else {
            self.loopedPlayerView.previousButton.isHidden = true
            self.loopedPlayerView.nextButton.isHidden = true
            return
        }

        self.loopedPlayerView.previousButton.isHidden = currentIndex == playlist.startIndex
        self.loopedPlayerView.nextButton.isHidden = currentIndex == playlist.endIndex - 1
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
