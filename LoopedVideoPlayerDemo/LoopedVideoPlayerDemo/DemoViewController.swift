//
//  ViewController.swift
//  LoopedVideoPlayerDemo
//
//  Created by Mat Gadd on 08/11/2023.
//

import UIKit

import LoopedVideoPlayer

struct PlaylistItem: LoopedVideoPlayerPlaylistItem {
    let url: URL
    let title: String
    let subtitle: String
    let credit: String

    func equalTo(_ other: LoopedVideoPlayerPlaylistItem) -> Bool {
        self.url == other.url &&
        self.title == other.title &&
        self.subtitle == other.subtitle &&
        self.credit == other.credit
    }
}

class DemoViewController: UIViewController {

    internal var nativeView: DemoView {
        self.view as! DemoView
    }

    override func loadView() {
        self.view = DemoView()
    }

    private var playlist: [PlaylistItem]?
    private var playlistIndex: Array<PlaylistItem>.Index?

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

    private var isUsingLongNames: Bool = false

    @objc
    private func playSingleVideoButtonTapped(sender: UIButton) {
        defer { self.isUsingLongNames.toggle() }

        let formatName: (String) -> String = {
            guard self.isUsingLongNames else { return $0 }
            return Array<String>(repeating: $0, count: 8).joined(separator: " ")
        }

        let player = LoopedVideoPlayerViewController()
        let item = PlaylistItem(
            url: URL(string: "https://media.atat.co.uk/web-signstation.mp4")!,
            title: formatName("Web"),
            subtitle: formatName("Example subtitle"),
            credit: formatName("© 2023 Example")
        )
        player.prepareToPlay(item)
        self.present(player, animated: true)
    }

    @objc
    private func playPlaylistButtonTapped(sender: UIButton) {
        let title = "Bat"
        let mammalSubtitle = """
            nocturnal mouselike mammal with forelimbs modified to form membranous wings and anatomical adaptations \
            for echolocation by which they navigate
            """
        let objectSubtitle = "strike with, or as if with a baseball bat"

        let playlist: [any LoopedVideoPlayerPlaylistItem] = [
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

        let player = LoopedVideoPlayerViewController()
        player.prepareToPlay(playlist[1], playlist: playlist)
        self.present(player, animated: true)
    }
}
