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
import os.log

struct CameraInputBridgeView: UIViewRepresentable {
    let cameraManager: CameraManager
    private var inputView: UICameraInputView = .init()
    
    init(_ cameraManager: CameraManager) { self.cameraManager = cameraManager }
}

extension CameraInputBridgeView {
    func makeUIView(context: Context) -> some UIView {
        inputView.cameraManager = cameraManager
        return inputView.view
    }
    func updateUIView(_ uiView: UIViewType, context: Context) {}
}

extension CameraInputBridgeView: Equatable {
    static func == (lhs: Self, rhs: Self) -> Bool { true }
}

// MARK: - UIViewController
@MainActor
fileprivate class UICameraInputView: UIViewController {
    var cameraManager: CameraManager!
    private let log = OSLog(subsystem: Bundle.main.bundleIdentifier!, category: "GestureRecognizers")
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupCameraManager()
        setupTapGesture()
        setupPinchGesture()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        cameraManager.fixCameraRotation()
    }
}

// MARK: - Setup
private extension UICameraInputView {
    func setupCameraManager() {
        cameraManager.setup(in: view)
    }
    
    func setupTapGesture() {
        DispatchQueue.main.async {
            let tapRecognizer = UITapGestureRecognizer(target: self, action: #selector(self.handleTapGesture))
            tapRecognizer.cancelsTouchesInView = false
            self.view.addGestureRecognizer(tapRecognizer)
            os_log("Tap gesture recognizer added on main thread", log: self.log, type: .info)
        }
    }
    
    func setupPinchGesture() {
        DispatchQueue.main.async {
            let pinchRecognizer = UIPinchGestureRecognizer(target: self, action: #selector(self.handlePinchGesture))
            pinchRecognizer.cancelsTouchesInView = false
            self.view.addGestureRecognizer(pinchRecognizer)
            os_log("Pinch gesture recognizer added on main thread", log: self.log, type: .info)
        }
    }
}

// MARK: - Gestures

// MARK: Tap
private extension UICameraInputView {
    @objc @MainActor func handleTapGesture(_ tap: UITapGestureRecognizer) {
        let touchPoint = tap.location(in: view)
        os_log("Tap gesture recognized at point: %{public}@", log: log, type: .info, "\(touchPoint)")
        setCameraFocus(touchPoint)
    }
    
    func setCameraFocus(_ touchPoint: CGPoint) {
        do {
            try cameraManager.setCameraFocus(touchPoint)
        } catch {
            os_log("Failed to set camera focus: %{public}@", log: log, type: .error, "\(error)")
        }
    }
}

// MARK: Pinch
private extension UICameraInputView {
    @objc @MainActor func handlePinchGesture(_ pinch: UIPinchGestureRecognizer) {
        os_log("Pinch gesture state: %{public}@", log: log, type: .info, "\(pinch.state.rawValue)")
        if pinch.state == .changed {
            let desiredZoomFactor = cameraManager.attributes.zoomFactor + atan2(pinch.velocity, 33)
            os_log("Pinch gesture recognized with desired zoom factor: %{public}f", log: log, type: .info, desiredZoomFactor)
            changeZoomFactor(desiredZoomFactor)
        }
    }
    
    func changeZoomFactor(_ desiredZoomFactor: CGFloat) {
        do {
            try cameraManager.changeZoomFactor(desiredZoomFactor)
        } catch {
            os_log("Failed to change zoom factor: %{public}@", log: log, type: .error, "\(error)")
        }
    }
}
