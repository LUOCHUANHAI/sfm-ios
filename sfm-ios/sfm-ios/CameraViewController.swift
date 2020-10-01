//
//  ViewController.swift
//  sfm-ios
//
//  Created by luochuanhai on 2020/5/22.
//  Copyright © 2020 luochuanhai. All rights reserved.
//

import Foundation
import UIKit
import SwiftUI

protocol CameraViewControllerDelegate: class {
    
    func returnCameraController(cameraController: CameraController)
    func returnFrame(image: UIImage)
    
}


class CameraViewController: UIViewController, FrameExtractorDelegate {
    
    var cameraController: CameraController!
    weak var delegate: CameraViewControllerDelegate?
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.delegate?.returnCameraController(cameraController: cameraController)
        cameraController.delegate = self
        
    }
    
    init() {
        
        self.cameraController = CameraController()
        super.init(nibName: nil, bundle: nil)
    }
    
    init(cameraController: CameraController) {
        
        self.cameraController = cameraController
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    func captured(image: UIImage) {
        
        self.delegate?.returnFrame(image: image)
    }
    
}


struct CameraView : UIViewControllerRepresentable {
    
    class Coordinator: NSObject, CameraViewControllerDelegate {
        
        var parentCameraView: CameraView
        
        init(_ parentCameraView: CameraView) {
            self.parentCameraView = parentCameraView
        }
        
        func returnCameraController(cameraController: CameraController) {
            
            DispatchQueue.main.async {
                self.parentCameraView.cameraController = cameraController
            }

        }
        
        func returnFrame(image: UIImage) {
            
            if parentCameraView.readyToCollectFrame ?? true {
                
                print("\nGot an \(image.size.height * image.scale)*\(image.size.width * image.scale) UIImage!", Date())
                self.parentCameraView.frame = image
            }
        }
        
    }
    
    @Binding var cameraController: CameraController?
    @Binding var frame: UIImage?
    @Binding var readyToCollectFrame: Bool?
    
    func makeCoordinator() -> Coordinator {
        
        Coordinator(self)
        
    }
    
    func makeUIViewController(context: UIViewControllerRepresentableContext<CameraView>) -> CameraViewController {
        
        var cameraViewController: CameraViewController
        
        if cameraController == nil {
            cameraViewController = CameraViewController()
            
        } else {
            cameraViewController = CameraViewController(cameraController: cameraController!)
        }
        
        cameraViewController.delegate = context.coordinator
        
        return cameraViewController
        
    }

    func updateUIViewController(_ uiViewController: CameraViewController, context: UIViewControllerRepresentableContext<CameraView>) {
        
    }
}
