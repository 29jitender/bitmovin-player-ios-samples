//
// Bitmovin Player iOS SDK
// Copyright (C) 2021, Bitmovin GmbH, All Rights Reserved
//
// This source code and its use and distribution, is subject to the terms
// and conditions of the applicable license agreement.
//

import Foundation
import BitmovinPlayer

extension SamplesTableViewController {

    final class ViewModel {
        private var sections: [SourceConfigSection]

        init() {
            sections = []

            let hlsSection = SourceConfigSection(name: "HLS")
            sections.append(hlsSection)

            hlsSection.sourceConfigs.append(createArtOfMotionSourceConfig())
            hlsSection.sourceConfigs.append(createSintelSourceConfig())
            hlsSection.sourceConfigs.append(createAppleTestSequenceSimpleSourceConfig())
            hlsSection.sourceConfigs.append(createAppleTestSequenceAdvancedSourceConfig())
        }

        private func createArtOfMotionSourceConfig() -> SourceConfig {
            let sourceUrl = URL(string: "https://video.gumlet.io/667d187c0fe372ddb1af923d/6684c88b5520f5d69dca952d/main.m3u8")!
            let sourceConfig = SourceConfig(url: sourceUrl, type: .hls)
            
            sourceConfig.title = "Gumlet Video"
            sourceConfig.sourceDescription = "Single audio track"
            sourceConfig.posterSource = URL(string: "https://video.gumlet.io/6634bb6d5c3621a9dc4a9256/66503f5422751178729e5fff/thumbnail-1-0.png?v=1716535212456")!

            guard let fairplayStreamUrl = URL(string: "https://video.gumlet.io/667d187c0fe372ddb1af923d/6684c88b5520f5d69dca952d/main.m3u8"),
                  let certificateUrl = URL(string: "https://fairplay.gumlet.com/certificate/65e816bbb452c86f03c39dad"),
                  let licenseUrl = URL(string: "https://fairplay.gumlet.com/licence/65e816bbb452c86f03c39dad/6684c88b5520f5d69dca952d?expires=1720854414000&rental_duration=1296000&playback_duration=1296000&token=dd57583153f90af92140fdf5e3c0a050aa60930f") else {
                fatalError("Invalid URL(s) when setting up DRM playback sample")
            }
            
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
                print("prepareLicense" )
                let data = Data(base64Encoded: ckcData.base64EncodedString())!
                let jsonObject = try! JSONSerialization.jsonObject(with: data, options: []) as! [String: Any]
                let ckcValue = jsonObject["ckc"] as! String
                let ckcData = Data(base64Encoded: ckcValue)!
                return ckcData
            }
            
            fpsConfig.licenseRequestHeaders = ["Content-Type": "application/json"]
            sourceConfig.drmConfig = fpsConfig
            
            return sourceConfig
        }

        private func createSintelSourceConfig() -> SourceConfig {
            let sourceUrl = URL(string: "https://video.gumlet.io/6634bb6d5c3621a9dc4a9256/663caba172c9cd9a60a12bc1/main.m3u8")!
            let sourceConfig = SourceConfig(url: sourceUrl, type: .hls)
            
            sourceConfig.title = "Non DRM"
            sourceConfig.sourceDescription = "Multiple subtitle languages, Multiple audio tracks"
            sourceConfig.posterSource = URL(string: "https://video.gumlet.io/6634bb6d5c3621a9dc4a9256/663caba172c9cd9a60a12bc1/thumbnail-1-0.png?v=1715254586332")!

            return sourceConfig
        }

        private func createAppleTestSequenceSimpleSourceConfig() -> SourceConfig {
            let sourceUrl = URL(string: "https://fps.ezdrm.com/demo/video/ezdrm.m3u8")!
            let sourceConfig = SourceConfig(url: sourceUrl, type: .hls)
            
            sourceConfig.title = "Sample DRM"
            sourceConfig.sourceDescription = "Single audio track"
            
            
            guard let fairplayStreamUrl = URL(string: "https://fps.ezdrm.com/demo/video/ezdrm.m3u8"),
                         let certificateUrl = URL(string: "https://fps.ezdrm.com/demo/video/eleisure.cer"),
                         let licenseUrl = URL(string: "https://fps.ezdrm.com/api/licenses/09cc0377-6dd4-40cb-b09d-b582236e70fe") else {
                       fatalError("Invalid URL(s) when setting up DRM playback sample")
                   }
            let fpsConfig = FairplayConfig(license: licenseUrl, certificateURL: certificateUrl)

            fpsConfig.prepareMessage = { spcData, assetId in
                        spcData
            }

            fpsConfig.prepareCertificate = { (data: Data) -> Data in
                        
                        return data
            }
            sourceConfig.drmConfig = fpsConfig
            return sourceConfig
        }

        private func createAppleTestSequenceAdvancedSourceConfig() -> SourceConfig {
            let sourceUrl = URL(string: "https://devstreaming-cdn.apple.com/videos/streaming/examples/img_bipbop_adv_example_ts/master.m3u8")!
            let sourceConfig = SourceConfig(url: sourceUrl, type: .hls)

            sourceConfig.title = "Bipbop Advanced"
            sourceConfig.sourceDescription = "Single audio track, multiple subtitles"
            return sourceConfig
        }

        var numberOfSections: Int {
            return sections.count
        }

        func numberOfRows(in section: Int) -> Int {
            return sections[section].sourceConfigs.count
        }

        func sourceConfigSection(for section: Int) -> SourceConfigSection? {
            guard sections.indices.contains(section) else {
                return nil
            }
            return sections[section]
        }

        func item(for indexPath: IndexPath) -> SourceConfig? {
            guard let sourceConfigSection = self.sourceConfigSection(for: indexPath.section),
                  sourceConfigSection.sourceConfigs.indices.contains(indexPath.row) else {
                return nil
            }

            return sourceConfigSection.sourceConfigs[indexPath.row]
        }
    }

    final class SourceConfigSection {
        var name: String
        var sourceConfigs: [SourceConfig] = []

        init(name: String) {
            self.name = name
        }
    }
}
