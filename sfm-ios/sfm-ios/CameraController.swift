//
//  CameraController.swift
//  sfm-ios
//
//  Created by luochuanhai on 2020/5/22.
//  Copyright © 2020 luochuanhai. All rights reserved.
//

import Foundation
import UIKit
import AVFoundation

protocol FrameExtractorDelegate: class {
    func captured(image: UIImage)
}

class CameraController: NSObject, AVCaptureVideoDataOutputSampleBufferDelegate {
    
    var captureSession: AVCaptureSession?
    var rearCamera: AVCaptureDevice?
    var rearCameraInput: AVCaptureDeviceInput?
    var rearCameraVideoOutput: AVCaptureVideoDataOutput?
    var previewLayer: AVCaptureVideoPreviewLayer?
    let context = CIContext()
    let instanceID = Int.random(in: 1...100)
    
    weak var delegate: FrameExtractorDelegate?
    
    enum CameraControllerError: Swift.Error {
        case captureSessionAlreadyRunning
        case captureSessionIsMissing
        case inputsAreInvalid
        case outputsAreInvalid
        case invalidOperation
        case noCamerasAvailable
    }
    
    func createCaptureSession(){
        self.captureSession = AVCaptureSession()
    }
    
    func configureCaptureDevices() throws {
        let camera = AVCaptureDevice.default(.builtInWideAngleCamera, for: AVMediaType.video, position: .back)
        
        self.rearCamera = camera
        
        try camera?.lockForConfiguration()
        camera?.focusMode = .autoFocus
        camera?.unlockForConfiguration()
        
    }
    
    func configureDeviceInputs() throws {
        guard let captureSession = self.captureSession else { throw CameraControllerError.captureSessionIsMissing }
        
        captureSession.sessionPreset = AVCaptureSession.Preset.vga640x480
        
        if let rearCamera = self.rearCamera {
            self.rearCameraInput = try AVCaptureDeviceInput(device: rearCamera)
            
            if captureSession.canAddInput(self.rearCameraInput!) { captureSession.addInput(self.rearCameraInput!)
            }
            else {
                throw CameraControllerError.inputsAreInvalid
            }
            
        }
        else {
            throw CameraControllerError.noCamerasAvailable
        }
        
        try self.rearCamera?.lockForConfiguration()
        self.rearCamera?.activeVideoMinFrameDuration = CMTimeMake(value: 1, timescale: 4)
        self.rearCamera?.activeVideoMaxFrameDuration = CMTimeMake(value: 1, timescale: 4)
        self.rearCamera?.setExposureModeCustom(duration: CMTimeMake(value: 1, timescale: 100), iso: 200, completionHandler: nil)
        self.rearCamera?.unlockForConfiguration()
        
    }
    
    func configureVideoOutput() throws {
        guard let captureSession = self.captureSession else { throw CameraControllerError.captureSessionIsMissing }
        
        self.rearCameraVideoOutput = AVCaptureVideoDataOutput()
        self.rearCameraVideoOutput?.setSampleBufferDelegate(self, queue: DispatchQueue(label: "rear camera video buffer"))
        
        if captureSession.canAddOutput(self.rearCameraVideoOutput!) {
            captureSession.addOutput(self.rearCameraVideoOutput!)
        }
        else {
            throw CameraControllerError.outputsAreInvalid
        }
        
        guard let connection = rearCameraVideoOutput?.connection(with: AVFoundation.AVMediaType.video) else { return }
        
        guard connection.isVideoOrientationSupported else { return }
        guard connection.isVideoMirroringSupported else { return }
        connection.videoOrientation = .portrait
        
        captureSession.startRunning()
        
    }
    
    func removeVideoOuput() throws {
        guard let captureSession = self.captureSession else { throw CameraControllerError.captureSessionIsMissing }
        captureSession.removeOutput(self.rearCameraVideoOutput!)
    }
    
    func prepare(){
        
        do {
            
            self.createCaptureSession()
            try self.configureCaptureDevices()
            try self.configureDeviceInputs()
            try self.configureVideoOutput()
            
        } catch CameraControllerError.captureSessionAlreadyRunning {
            print("CameraControllerError.captureSessionAlreadyRunning")
        } catch CameraControllerError.captureSessionIsMissing {
            print("CameraControllerError.captureSessionIsMissing")
        } catch CameraControllerError.inputsAreInvalid {
            print("CameraControllerError.inputsAreInvalid")
        } catch CameraControllerError.invalidOperation {
            print("CameraControllerError.invalidOperation")
        } catch CameraControllerError.noCamerasAvailable {
            print("CameraControllerError.noCamerasAvailable")
        } catch CameraControllerError.outputsAreInvalid {
            print("CameraControllerError.outputsAreInvalid")
        } catch {
            print("CameraControllerError.UnknownError")
        }
        
    }
    
    override init() {
        super.init()
        prepare()
    }
    
    func imageFromSampleBuffer(sampleBuffer: CMSampleBuffer) -> UIImage? {
        guard let imageBuffer = CMSampleBufferGetImageBuffer(sampleBuffer) else { return nil }
        let ciImage = CIImage(cvPixelBuffer: imageBuffer)
        guard let cgImage = context.createCGImage(ciImage, from: ciImage.extent) else { return nil }
        return UIImage(cgImage: cgImage)
    }
    
    func captureOutput(_ output: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {
        guard let uiImage = imageFromSampleBuffer(sampleBuffer: sampleBuffer) else { return }
        
        DispatchQueue.main.async {
            self.delegate?.captured(image: uiImage)
        }
    }
    
}
