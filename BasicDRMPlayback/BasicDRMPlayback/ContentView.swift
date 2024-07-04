//
// Bitmovin Player iOS SDK
// Copyright (C) 2023, Bitmovin GmbH, All Rights Reserved
//
// This source code and its use and distribution, is subject to the terms
// and conditions of the applicable license agreement.
//

import BitmovinPlayer
import Combine
import SwiftUI

// You can find your player license key on the player license dashboard:
// https://bitmovin.com/dashboard/player/licenses
private let playerLicenseKey = "62b316b0-cf2e-4521-9b43-8ae717c2e6a5"
// You can find your analytics license key on the analytics license dashboard:
// https://bitmovin.com/dashboard/analytics/licenses
private let analyticsLicenseKey = "30d9190a-25a9-4189-8f90-d19f032ab565"

struct ContentView: View {
    private let player: Player
    private let playerViewConfig: PlayerViewConfig
    private let sourceConfig: SourceConfig
   
    init() {
        // Define needed resources
        guard let fairplayStreamUrl = URL(string: "https://video.gumlet.io/667d187c0fe372ddb1af923d/6684c88b5520f5d69dca952d/main.m3u8"),
              let certificateUrl = URL(string: "https://fairplay.gumlet.com/certificate/65e816bbb452c86f03c39dad"),
              let licenseUrl = URL(string: "https://fairplay.gumlet.com/licence/65e816bbb452c86f03c39dad/6684c88b5520f5d69dca952d?expires=1720854439000&token=4f3aac223793ec2a57e9aeef1b0ed91f9e28a313") else {
            fatalError("Invalid URL(s) when setting up DRM playback sample")
        }
        // Create player configuration
        let playerConfig = PlayerConfig()

        // Set your player license key on the player configuration
        playerConfig.key = playerLicenseKey

        // Create analytics configuration with your analytics license key
        let analyticsConfig = AnalyticsConfig(licenseKey: analyticsLicenseKey)

        // Create player based on player and analytics configurations
        player = PlayerFactory.createPlayer(
            playerConfig: playerConfig,
            analytics: .enabled(
                analyticsConfig: analyticsConfig
            )
        )

        // Create player view configuration
        playerViewConfig = PlayerViewConfig()

        // create drm configuration
        let fpsConfig = FairplayConfig(license: licenseUrl, certificateURL: certificateUrl)

        fpsConfig.prepareContentId = { (contentId: String) -> String in
            print("prepareContentId: \(contentId)")
            return contentId.replacingOccurrences(of: "skd://", with: "")
        }
        
        fpsConfig.prepareMessage = { (spcData: Data, assetID: String) -> Data in
            print("prepareMessage" )
            
            let json: [String: Any] = ["spc": spcData.base64EncodedString(), "assetId": assetID]
            let jsonData = try! JSONSerialization.data(withJSONObject: json, options: [])
            return jsonData
        }
        fpsConfig.prepareLicense = { (ckcData: Data) -> Data in
            let data = Data(base64Encoded: ckcData.base64EncodedString())!
            let jsonObject = try! JSONSerialization.jsonObject(with: data, options: []) as! [String: Any]
            let ckcValue = jsonObject["ckc"] as! String
            let ckcData = Data(base64Encoded: ckcValue)!
            return ckcData
        }

        fpsConfig.licenseRequestHeaders = ["Content-Type": "application/json"]
        
        sourceConfig = SourceConfig(url: fairplayStreamUrl, type: .hls)
        sourceConfig.drmConfig = fpsConfig
    }

    var body: some View {
        ZStack {
            Color.black

            VideoPlayerView(
                player: player,
                playerViewConfig: playerViewConfig
            )
            .onReceive(player.events.on(PlayerEvent.self)) { (event: PlayerEvent) in
                dump(event, name: "[Player Event]", maxDepth: 1)
            }
            .onReceive(player.events.on(SourceEvent.self)) { (event: SourceEvent) in
                dump(event, name: "[Source Event]", maxDepth: 1)
            }
        }
        .padding()
        .onAppear {
            player.load(sourceConfig: sourceConfig)
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
