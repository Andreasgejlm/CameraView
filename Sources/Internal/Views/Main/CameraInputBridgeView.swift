//
//  CameraInputBridgeView.swift of MijickCameraView
//
//  Created by Tomasz Kurylik
//    - Twitter: https://twitter.com/tkurylik
//    - Mail: tomasz.kurylik@mijick.com
//    - GitHub: https://github.com/FulcrumOne
//
//  Copyright ©2024 Mijick. Licensed under MIT License.

import SwiftUI
import UIKit

struct CameraInputBridgeView {
    let cameraManager: CameraManager
    let inputView: UIView = .init()
}


// MARK: - PROTOCOLS CONFORMANCE

   
// MARK: UIViewRepresentable
extension CameraInputBridgeView: UIViewRepresentable {
    func makeUIView(context: Context) -> some UIView {
        setupCameraManager()

        return inputView
    }
    func updateUIView(_ uiView: UIViewType, context: Context) {}
    func makeCoordinator() -> Coordinator { .init(self) }

}

// MARK: - Setup
private extension CameraInputBridgeView {
    func setupCameraManager() {
        cameraManager.setup(in: inputView)
    }
}


extension CameraInputBridgeView: Equatable {
    static func ==(lhs: Self, rhs: Self) -> Bool { true }
}

// MARK: - LOGIC
extension CameraInputBridgeView { class Coordinator: NSObject { init(_ parent: CameraInputBridgeView) { self.parent = parent }
    let parent: CameraInputBridgeView
}}

// MARK: On Tap
extension CameraInputBridgeView.Coordinator {
    @objc func onTapGesture(_ tap: UITapGestureRecognizer) {
        do {
            let touchPoint = tap.location(in: parent.inputView)
            try parent.cameraManager.setCameraFocus(touchPoint)
        } catch {}
    }
}
