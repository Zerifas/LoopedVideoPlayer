//
//  ViewController.swift
//  LoopedVideoPlayerDemo
//
//  Created by Mat Gadd on 08/11/2023.
//

import UIKit

import LoopedVideoPlayer

typealias PlaylistItem = LoopedVideoPlayerPlaylistItem

class DemoViewController: UIViewController {

    internal lazy var nativeView = DemoView()
    internal lazy var favoriteButton: UIButton = {
        let button = UIButton(type: .system)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.addTarget(self, action: #selector(customButtonTapped(sender:)), for: .touchUpInside)
        return button
    }()

    private var playlist: [PlaylistItem] = []
    private var currentItem: PlaylistItem?

    private var favoriteURLs: Set<URL> = []

    private var isUsingLongNames: Bool = false


    override func loadView() {
        self.view = self.nativeView
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        self.setupButtons()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.playSingleVideoButtonTapped(sender: self.nativeView.playSingleVideoButton)
    }

    private func setupButtons() {
        self.setupPlaySingleVideoButton()
        self.setupPlayPlaylistButton()
        self.setupPlaySingleVideoWithCustomUIButton()
        self.setupPlayPlaylistWithCustomUIButton()
    }

    private func setupPlaySingleVideoButton() {
        let button = self.nativeView.playSingleVideoButton
        button.setTitle("Play Single Video", for: .normal)
        button.addTarget(
            self,
            action: #selector(self.playSingleVideoButtonTapped(sender:)),
            for: .touchUpInside
        )
    }

    private func setupPlayPlaylistButton() {
        let button = self.nativeView.playPlaylistButton
        button.setTitle("Play Playlist", for: .normal)
        button.addTarget(
            self,
            action: #selector(self.playPlaylistButtonTapped(sender:)),
            for: .touchUpInside
        )
    }

    private func setupPlaySingleVideoWithCustomUIButton() {
        let button = self.nativeView.playSingleVideoWithCustomUIButton
        button.setTitle("Play Single Video (Custom UI)", for: .normal)
        button.addTarget(
            self,
            action: #selector(self.playSingleVideoWithCustomUITapped(sender:)),
            for: .touchUpInside
        )
    }

    private func setupPlayPlaylistWithCustomUIButton() {
        let button = self.nativeView.playPlaylistWithCustomUIButton
        button.setTitle("Play Playlist (Custom UI)", for: .normal)
        button.addTarget(
            self,
            action: #selector(self.playPlaylistWithCustomUITapped(sender:)),
            for: .touchUpInside
        )
    }

    @objc
    private func playSingleVideoButtonTapped(sender: UIButton) {
        self.setupSingleItemPlaylist()
        self.setupPlayer()
    }
    
    @objc
    private func playPlaylistButtonTapped(sender: UIButton) {
        self.setupMultiItemPlaylist()
        self.setupPlayer { player in
            guard let lastIndex = self.playlist.indices.last else { return }
            player.setCurrentIndex(lastIndex)
        }
    }

    @objc
    private func playSingleVideoWithCustomUITapped(sender: UIButton) {
        self.setupSingleItemPlaylist()
        self.setupPlayer { player in
            guard let item = self.playlist.first else { return }
            player.loopedPlayerView.trailingButton = self.setupFavoriteButton(for: item)
        }
    }

    @objc
    private func playPlaylistWithCustomUITapped(sender: UIButton) {
        self.setupMultiItemPlaylist()
        self.setupPlayer { player in
            guard let item = self.playlist.first else { return }
            player.loopedPlayerView.trailingButton = self.setupFavoriteButton(for: item)
        }
    }

    @objc
    private func customButtonTapped(sender: UIButton) {
        debugPrint("CUSTOM BUTTON!")

        guard let item = self.currentItem else { return }

        if self.favoriteURLs.contains(item.url) {
            self.favoriteURLs.remove(item.url)
        } else {
            self.favoriteURLs.insert(item.url)
        }

        _ = self.setupFavoriteButton(for: item)
    }

    private func setupSingleItemPlaylist() {
        defer { self.isUsingLongNames.toggle() }

        let formatName: (String) -> String = {
            guard self.isUsingLongNames else { return $0 }
            return Array<String>(repeating: $0, count: 8).joined(separator: " ")
        }

        let item = PlaylistItem(
            url: URL(string: "https://media.atat.co.uk/web-signstation.mp4")!,
            title: formatName("Web"),
            subtitle: formatName("Example subtitle"),
            credit: formatName("© 2023 Example")
        )
        self.playlist = [item]
    }

    private func setupMultiItemPlaylist() {
        let title = "Bat"
        let mammalSubtitle = """
            nocturnal mouselike mammal with forelimbs modified to form membranous wings and anatomical adaptations \
            for echolocation by which they navigate
            """
        let objectSubtitle = "strike with, or as if with a baseball bat"

        self.playlist = [
            PlaylistItem(
                url: URL(string: "https://media.atat.co.uk/bat-deafway.mp4")!,
                title: title,
                subtitle: mammalSubtitle,
                credit: "Deafway"
            ),
            PlaylistItem(
                url: URL(string: "https://media.atat.co.uk/bat-signmonkey.mp4")!,
                title: title,
                subtitle: mammalSubtitle,
                credit: "Sign Monkey"
            ),
            PlaylistItem(
                url: URL(string: "https://media.atat.co.uk/bat-uploads.mp4")!,
                title: title,
                subtitle: mammalSubtitle,
                credit: ""
            ),
            PlaylistItem(
                url: URL(string: "https://media.atat.co.uk/bat-signstation.mp4")!,
                title: title,
                subtitle: objectSubtitle,
                credit: "SignStation"
            ),
        ]
    }

    private func setupFavoriteButton(for item: PlaylistItem) -> UIButton? {
        guard #available(iOS 13, *) else { return nil }

        let isFavorite = self.favoriteURLs.contains(item.url)
        let imageName = isFavorite ? "star.fill" : "star"
        self.favoriteButton.setImage(UIImage(systemName: imageName), for: .normal)

        return self.favoriteButton
    }

    typealias SetupCallback = (LoopedVideoPlayerViewController) -> Void

    private func setupPlayer(_ setup: SetupCallback? = nil) {
        let player = LoopedVideoPlayerViewController()
        player.dataSource = self
        player.delegate = self
        player.reloadData()
        setup?(player)
        self.present(player, animated: true)
    }
}

extension DemoViewController: LoopedVideoPlayerDelegate {
    func loopedVideoPlayer(_ player: LoopedVideoPlayerViewController, willPlay item: LoopedVideoPlayerPlaylistItem, forItemAt index: Int) {
        debugPrint("willPlay \(item) forItemAt \(index)")
        self.currentItem = item
        _ = self.setupFavoriteButton(for: item)
    }
}

extension DemoViewController: LoopedVideoPlayerDataSource {
    func numberOfItems(for player: LoopedVideoPlayer.LoopedVideoPlayerViewController) -> Int {
        debugPrint("numberOfItems(for:) = \(self.playlist.count)")
        return self.playlist.count
    }
    
    func loopedVideoPlayer(_ player: LoopedVideoPlayer.LoopedVideoPlayerViewController, itemAt index: Int) -> LoopedVideoPlayer.LoopedVideoPlayerPlaylistItem {
        debugPrint("loopedVideoPlayer(_: itemAt:\(index)) = \(self.playlist[index])")
        return self.playlist[index]
    }
}
