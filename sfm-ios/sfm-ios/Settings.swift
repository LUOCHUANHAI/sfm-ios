//
//  Settings.swift
//  sfm-ios
//
//  Created by luochuanhai on 2020/5/22.
//  Copyright © 2020 luochuanhai. All rights reserved.
//


import SwiftUI
import Combine
import Foundation

class Settings: ObservableObject {

    @Published var openCVWrapper: OpenCVWrapper
    @Published var cameraController: CameraController?
    @Published var cameraView: CameraView?
    
    // cameraMatrix [3x3], distortionCoefficients [8x1], apertureWidth, apertureHight, fovx, fovy, focalLength, principalPoint.x, principalPoint.y, aspectRatio
    @Published var calibrationResults: [Double]?
    
    @Published var chessboardSquareEdgeLength: Double?
    @Published var chessboardPatternHeight: Int?
    @Published var chessboardPatternWidth: Int?
    
    // sensorWidth = 6.17 mm; sensorHeight = 4.55 mm
    @Published var sensorHeight: Double?
    @Published var sensorWidth: Double?
    @Published var minimumFramesForCalibration: Int = 20
    
    init() {
        
        self.openCVWrapper = OpenCVWrapper()
        self.cameraController = nil
        self.cameraView = nil
        self.calibrationResults = nil
        self.chessboardSquareEdgeLength = nil
        self.chessboardPatternHeight = nil
        self.chessboardPatternWidth = nil
        self.sensorHeight = nil
        self.sensorWidth = nil
    }
    
}

