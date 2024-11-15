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
fileprivate class UICameraInputView: UIViewController {
    var cameraManager: CameraManager!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupCameraManager()
        NotificationCenter.default.addObserver(self, selector: #selector(appWillEnterForeground), name: UIApplication.willEnterForegroundNotification, object: nil)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setupCameraManager()
        // Restore any camera state if needed
    }
    
    @objc func appWillEnterForeground() {
        setupCameraManager()
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
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
}

