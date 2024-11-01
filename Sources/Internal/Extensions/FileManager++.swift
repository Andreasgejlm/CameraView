//
//  FileManager++.swift of MijickCameraView
//
//  Created by Tomasz Kurylik
//    - Twitter: https://twitter.com/tkurylik
//    - Mail: tomasz.kurylik@mijick.com
//    - GitHub: https://github.com/FulcrumOne
//
//  Copyright ©2024 Mijick. Licensed under MIT License.


import SwiftUI

// MARK: - Preparing place for video output
extension FileManager {
    static func prepareURLForVideoOutput() -> URL? {
        guard let fileUrl = createFileUrl() else { return nil }

        clearPlaceIfTaken(fileUrl)
        return fileUrl
    }
}
private extension FileManager {
    static func createFileUrl() -> URL? {
        if let saveFolder = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
            .first?
            .appendingPathComponent(".temp") {
            try? FileManager.default.createDirectory(at: saveFolder, withIntermediateDirectories: true)
            return saveFolder.appendingPathComponent(videoPath)
        }
        return nil
    }
    static func clearPlaceIfTaken(_ url: URL) {
        try? FileManager.default.removeItem(at: url)
    }
}
private extension FileManager {
    static var videoPath: String { "video.mp4" }
}
