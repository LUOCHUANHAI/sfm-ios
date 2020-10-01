//
//  ContentView.swift
//  sfm-ios
//
//  Created by luochuanhai on 2020/5/21.
//  Copyright © 2020 luochuanhai. All rights reserved.
//

import SwiftUI


// The struct ContentView: View creates a new struct called ContentView, saying that it conforms to the View protocol.
struct ContentViewHomepage: View {
    // The keyword "some" means “one specific sort of view must be sent back from this property.”
    
    @EnvironmentObject var settings: Settings
    
    func displayCalibrationResults() -> String {
        
        var tempStr = ""
        var calibrationResultsString = "cameraMatrix (in Pixels):\n"
        let cameraMatrix = Array(settings.calibrationResults![0...8])
        for rows in 0...2 {
            for cols in 0...2 {
                
                tempStr = String(format: "%.3f", cameraMatrix[rows*3+cols])
                calibrationResultsString += "\(tempStr)\t\t"
                
            }
            calibrationResultsString = calibrationResultsString.trimmingCharacters(in: .whitespacesAndNewlines)
            calibrationResultsString += "\n"
        }
        
        
        calibrationResultsString += "distortionCoefficients (k1, k2, p1, p2, k3):\n"
        let distortionCoefficients = Array(settings.calibrationResults![9...13])
        for index in 0...4 {
            tempStr = String(format: "%.3f", distortionCoefficients[index])
            calibrationResultsString += "\(tempStr)\t"
        }
        calibrationResultsString = calibrationResultsString.trimmingCharacters(in: .whitespacesAndNewlines)
        calibrationResultsString += "\n"


        let apertureWidth = settings.calibrationResults![14]
        tempStr = String(format: "%.3f", apertureWidth)
        calibrationResultsString += "apertureWidth: \(tempStr)\n"


        let apertureHeight = settings.calibrationResults![15]
        tempStr = String(format: "%.3f", apertureHeight)
        calibrationResultsString += "apertureHeight: \(tempStr)\n"


        let fovx = settings.calibrationResults![16]
        tempStr = String(format: "%.3f", fovx)
        calibrationResultsString += "fovx: \(tempStr)\n"


        let fovy = settings.calibrationResults![17]
        tempStr = String(format: "%.3f", fovy)
        calibrationResultsString += "fovy: \(tempStr)\n"


        let focalLength = settings.calibrationResults![18]
        tempStr = String(format: "%.3f", focalLength)
        calibrationResultsString += "focalLength: \(tempStr)\n"


        let principalPointX = settings.calibrationResults![19]
        tempStr = String(format: "%.3f", principalPointX)
        calibrationResultsString += "principalPoint.x: \(tempStr)\n"


        let principalPointY = settings.calibrationResults![20]
        tempStr = String(format: "%.3f", principalPointY)
        calibrationResultsString += "principalPoint.y: \(tempStr)\n"


        let aspectRatio = settings.calibrationResults![21]
        tempStr = String(format: "%.3f", aspectRatio)
        calibrationResultsString += "aspectRatio: \(tempStr)\n"


        let minReprojectionError = settings.calibrationResults![22]
        tempStr = String(format: "%.10f", minReprojectionError)
        calibrationResultsString += "minReprojectionError: \(tempStr)\n"


        let maxReprojectionError = settings.calibrationResults![23]
        tempStr = String(format: "%.10f", maxReprojectionError)
        calibrationResultsString += "maxReprojectionError: \(tempStr)\n"
        
        
        return calibrationResultsString
        
    }
    
    var body: some View {
        
        NavigationView {
            VStack(alignment: .center){
                
                Text("Realtime Shape-from-Motion")
                    .font(.title)
                
                Spacer().frame(height: 30)
                
                Text("based on \(settings.openCVWrapper.openCVVersionString())")
                    .font(.body)
                
                VStack(alignment: .center){
                    Spacer()
                    
                    NavigationLink(destination: ContentViewCalibration()){
                            Text("Camera Calibration")
                                .font(.title)
                                .fontWeight(.bold)
                                .padding(3)
                                .background(Color.blue)
                                .foregroundColor(.white)
                                .padding(5)
                                .border(Color.blue, width: 2)
                        }
                    
                    Spacer().frame(height: 5)
                    
                    if settings.calibrationResults?.count == 24 {
                        
                        Text(displayCalibrationResults())
                        .font(.caption)
                        .frame(width: 300)
                        .padding()
                        
                    } else {
                        
                        Text("Haven't been calibrated yet. Need more than \(settings.minimumFramesForCalibration) photos of a chessboard shot from various angles and various distances to perform calibration.")
                        .font(.caption)
                        .frame(width: 300)
                        .padding()
                    }
                    
                    Spacer().frame(height: 30)
                    
                    NavigationLink(destination: ContentViewSfM()){
                            Text("Reconstruction")
                                .font(.title)
                                .fontWeight(.bold)
                                .padding(3)
                                .background(Color.blue)
                                .foregroundColor(.white)
                                .padding(5)
                                .border(Color.blue, width: 2)
                    }
//                    .disabled(settings.cameraController == nil || settings.calibrationResults == nil)
                    
                    Spacer()
                }
            }
        }
        
    }
}


// This struct "ContentView_Previews" won’t actually form part of your final app that goes to the App Store, but is instead specifically for Xcode to use so it can show a preview of your UI design alongside your code.
struct ContentViewHomepage_Previews: PreviewProvider {
    static var previews: some View {
        ContentViewHomepage()
    }
}
