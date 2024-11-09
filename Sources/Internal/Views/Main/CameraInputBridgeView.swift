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
            print("Tap gesture recognizer added on main thread")
        }
    }
    
    func setupPinchGesture() {
        DispatchQueue.main.async {
            let pinchRecognizer = UIPinchGestureRecognizer(target: self, action: #selector(self.handlePinchGesture))
            pinchRecognizer.cancelsTouchesInView = false
            self.view.addGestureRecognizer(pinchRecognizer)
            print("Pinch gesture recognizer added on main thread")
        }
    }
}

// MARK: - Gestures

// MARK: Tap
private extension UICameraInputView {
    @objc @MainActor func handleTapGesture(_ tap: UITapGestureRecognizer) {
        let touchPoint = tap.location(in: view)
        print("Tap gesture recognized at point: \(touchPoint)")
        setCameraFocus(touchPoint)
    }
    
    func setCameraFocus(_ touchPoint: CGPoint) {
        do {
            try cameraManager.setCameraFocus(touchPoint)
        } catch {
            print("Failed to set camera focus: \(error)")
        }
    }
}

// MARK: Pinch
private extension UICameraInputView {
    @objc @MainActor func handlePinchGesture(_ pinch: UIPinchGestureRecognizer) {
        if pinch.state == .changed {
            let desiredZoomFactor = cameraManager.attributes.zoomFactor + atan2(pinch.velocity, 33)
            print("Pinch gesture recognized with desired zoom factor: \(desiredZoomFactor)")
            changeZoomFactor(desiredZoomFactor)
        }
    }
    
    func changeZoomFactor(_ desiredZoomFactor: CGFloat) {
        do {
            try cameraManager.changeZoomFactor(desiredZoomFactor)
        } catch {
            print("Failed to change zoom factor: \(error)")
        }
    }
}
