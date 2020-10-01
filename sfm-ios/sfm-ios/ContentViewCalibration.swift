//
//  ContentViewCalibration.swift
//  sfm-ios
//
//  Created by luochuanhai on 2020/5/22.
//  Copyright © 2020 luochuanhai. All rights reserved.
//


import SwiftUI



struct ContentViewCalibration: View {
    @EnvironmentObject var settings: Settings
    
    @State var cameraController: CameraController?
    
    @State var frame: UIImage?
    @State var drawedFrame: UIImage?
    @State var readyToCollectFrame: Bool?
    
    @State var calibrationImages: [UIImage] = []
    @State var isCalibrating = false
    @State var isCalibrated = false
    @State var chessboardSquareEdgeLength = ""
    @State var chessboardPatternHeight = ""
    @State var chessboardPatternWidth = ""
    @State var sensorHeight = ""
    @State var sensorWidth = ""
    @State var calibrateByShooting = false
    
    
    let backgroundImage = UIImage.imageWithColor(color: UIColor.black, size: CGSize(width: 480, height: 640))
    
    func calibrateCamera() {
        
        self.settings.calibrationResults = (self.settings.openCVWrapper.openCVCalibrate(self.calibrationImages, chessboardSquareEdgeLength: self.settings.chessboardSquareEdgeLength as NSNumber?, chessboardPatternHeight: self.settings.chessboardPatternHeight as NSNumber?, chessboardPatternWidth: self.settings.chessboardPatternWidth as NSNumber?, sensorHeight: self.settings.sensorHeight as NSNumber?, sensorWidth: self.settings.sensorWidth as NSNumber?) as! [Double])
    }
    
    
    var body: some View {
        
        let frameBinding = Binding(get: {
            
            self.frame
            
        }, set: {
            
            self.frame = $0
            
            if self.readyToCollectFrame ?? true {
                
                self.readyToCollectFrame = false
                
                DispatchQueue.main.async {
                    
                    let results = self.settings.openCVWrapper.openCVDrawChessboardCorners(self.frame ?? self.backgroundImage, chessboardPatternHeight: self.settings.chessboardPatternHeight as NSNumber?, chessboardPatternWidth: self.settings.chessboardPatternWidth as NSNumber?)
                    
                    self.drawedFrame = (results![1] as! UIImage)
                    
                    if results![0] as! Bool == true {
                        
                        self.calibrationImages.append(self.frame!)
                    }
                
                    self.readyToCollectFrame = true
                }
                
            }
        })
        
        return VStack(alignment: .center){
            
            if self.calibrateByShooting {
                
                CameraView(cameraController: self.$cameraController, frame: frameBinding, readyToCollectFrame: self.$readyToCollectFrame)
                
                Image(uiImage: self.drawedFrame ?? backgroundImage)
                    .resizable()
                    .scaledToFill()
                
                Spacer().frame(height: 30)
                
                if self.isCalibrating {
                    
                    if !self.isCalibrated {
                        
                        Text("Performing calibration ...").font(.caption).frame(height: 10)
                    } else {
                        
                        Text("Calibrated. Go back.").font(.caption).frame(height: 10)
                    }
                    
                } else {
                    
                    if self.calibrationImages.count <= settings.minimumFramesForCalibration {
                        
                        Text("\(self.calibrationImages.count) frames selected! Not ready for calibration.").font(.caption).frame(height: 10)
                    } else {
                        
                        Text("\(self.calibrationImages.count) frames selected! Ready for calibration.").font(.caption).frame(height: 10)
                    }
                    
                }
                
                Spacer().frame(height: 20)
                
                HStack(alignment: .center){

                    Button(action:{
                        if self.calibrationImages.count > self.settings.minimumFramesForCalibration {
                            
                            self.isCalibrating = true
                            self.readyToCollectFrame = false
                            
                            DispatchQueue.main.asyncAfter(deadline: .now()+0.5) {
                                
                                self.calibrateCamera()
                                self.settings.cameraController = self.cameraController
                                self.isCalibrated = true
                            }
                            
                        }
                        
                    }){
                        Text("Calibrate")
                            .font(.body)
                            .fontWeight(.bold)
                            .padding(3)
                            .background(Color.blue)
                            .foregroundColor(.white)
                            .padding(5)
                            .border(Color.blue, width: 2)
                    }
                }
                
                Spacer().frame(height: 80)
                
            } else {
                
                Group {
                    Text("Chessboard square edge length (mm):")
                        .font(.body)
                        .bold()
                    
                    TextField("22.2", text: self.$chessboardSquareEdgeLength)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .frame(width: 150)
                    
                    Spacer().frame(height: 10)
                    
                    Text("Chessboard pattern size:")
                        .font(.body)
                        .bold()
                    
                    HStack(alignment: .center) {
                        TextField("points_per_row", text: self.$chessboardPatternWidth)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                            .frame(width: 150)
                        
                        Text("x")
                            .font(.body)
                            .bold()
                        
                        TextField("points_per_colum", text: self.$chessboardPatternHeight)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                            .frame(width: 150)
                    }
                    
                    Spacer().frame(height: 10)
                    
                    Text("Physical size of the sensor (mm):")
                        .font(.body)
                        .bold()
                    
                    HStack(alignment: .center) {
                        TextField("4.55", text: self.$sensorHeight)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                            .frame(width: 150)
                        
                        Text("x")
                            .font(.body)
                            .bold()
                        
                        TextField("6.17", text: self.$sensorWidth)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                            .frame(width: 150)
                    }
                }
                
                Spacer().frame(height: 30)
                
                Button(action:{
                    
//                    self.settings.chessboardSquareEdgeLength = Double(self.chessboardSquareEdgeLength)
//                    self.settings.chessboardPatternHeight = Int(self.chessboardPatternHeight)
//                    self.settings.chessboardPatternWidth = Int(self.chessboardPatternWidth)
//                    self.settings.sensorHeight = Double(self.sensorHeight)
//                    self.settings.sensorWidth = Double(self.sensorWidth)
                    
                    self.settings.chessboardSquareEdgeLength = 22.2
                    self.settings.chessboardPatternHeight = 6
                    self.settings.chessboardPatternWidth = 9
                    self.settings.sensorHeight = 4.55
                    self.settings.sensorWidth = 6.17
                    
                    if self.settings.chessboardSquareEdgeLength != nil && self.settings.chessboardPatternHeight != nil && self.settings.chessboardPatternWidth != nil && self.settings.sensorHeight != nil && self.settings.sensorWidth != nil {
                        
                        self.calibrateByShooting = true
                        
                    }
                    
                }){
                    
                    Text("Calibrate by shooting")
                        .font(.body)
                        .fontWeight(.bold)
                        .padding(3)
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .padding(5)
                        .border(Color.blue, width: 2)
                }
                
                Spacer().frame(height: 350)
            }
        }
    }
}


struct ContentViewCalibration_Previews: PreviewProvider {
    
    static var previews: some View {
        ContentViewCalibration()
    }
}
