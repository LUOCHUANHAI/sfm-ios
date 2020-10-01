//
//  ContentViewSfM.swift
//  sfm-ios
//
//  Created by luochuanhai on 2020/5/22.
//  Copyright © 2020 luochuanhai. All rights reserved.
//

import SwiftUI
import SceneKit


final class Reconstruction: ObservableObject {
    
    var imagePair: [UIImage] = []
    var cameraMatrix: [Double] = []
    var reconstructionResults: NSArray = []
    var intermediateResults: NSArray = []
    var restart = false
    var isReconstructed = false
    var reconstructionMessge: String?
    var reconstructionImages: [UIImage]?
    var pointCloud: [NSArray]?
    
    var openCVWrapper = OpenCVWrapper()
    
    let backgroundImage = UIImage.imageWithColor(color: UIColor.black, size: CGSize(width: 480, height: 640))
    
    var frame: UIImage = UIImage.imageWithColor(color: UIColor.black, size: CGSize(width: 480, height: 640)) {
        didSet {
            //            UIImageWriteToSavedPhotosAlbum(self.frame, nil, nil, nil)
            
            if self.imagePair.count == 0 {
                self.imagePair.append(self.frame)
                
            } else if self.imagePair.count == 1 {
                self.imagePair.append(self.frame)
                
            } else if self.imagePair.count == 2 {
                self.imagePair.remove(at: 0)
                self.imagePair.append(self.frame)
            }
            
            if self.imagePair.count == 2 {
                
                let startTime = CFAbsoluteTimeGetCurrent()
                self.reconstructionResults = self.openCVWrapper.openCVReconstruction(self.imagePair, cameraMatrix: self.cameraMatrix, restart: self.restart as NSNumber)
                let timeElapsed = CFAbsoluteTimeGetCurrent() - startTime
                
                self.restart = false
                
                self.isReconstructed = self.reconstructionResults[0] as! Bool
                self.intermediateResults = self.reconstructionResults[1] as! NSArray
                
                self.reconstructionImages = (self.intermediateResults.subarray(with: NSMakeRange(0, 4)) as! [UIImage])
                
                self.pointCloud = (self.intermediateResults.object(at: 4) as! [NSArray])
                
                self.reconstructionMessge = (self.intermediateResults.lastObject as! String)
                self.reconstructionMessge! += "Time elapsed for this reconstuction: \(String(format: "%.3f", timeElapsed))s."
                
                print("Time elapsed for this reconstuction: \(String(format: "%.3f", timeElapsed))s.")
                
                if !self.isReconstructed {
                    
                    self.imagePair.remove(at: 1)
                }
                
            }
        }
    }
    
}

struct ContentViewSfM: View {
    
    @EnvironmentObject var settings: Settings
    @State var cameraController: CameraController?
    @State var frame: UIImage?
    @State var pointCloud: [NSArray]?
    @State var isReconstructed = true
    @State var isStoped = false
    
    @State var readyToCollectFrame: Bool?
    
    @State var initialFramesToDrop = 4
    @ObservedObject var reconstruction = Reconstruction()
    
    let backgroundImage = UIImage.imageWithColor(color: UIColor.black, size: CGSize(width: 480, height: 640))
    
    var body: some View {
        
        let frameBinding = Binding(get: {
            self.frame
            
        }, set: {
            if self.initialFramesToDrop == 0 {
                
                self.frame = $0
                
                if self.isReconstructed {
                    
                    self.readyToCollectFrame = false
                    self.isReconstructed = false
                    
                    DispatchQueue.main.async {
                        //                        self.reconstruction.cameraMatrix = Array(self.settings.calibrationResults![0...8])
                        self.reconstruction.cameraMatrix = Array([492.2415219849448, 0, 240.7835745868003, 0, 491.9988361974899, 311.0265083634545, 0, 0, 1])
                        
                        self.reconstruction.frame = self.frame!
                        
                        if self.isStoped {
                            self.readyToCollectFrame = false
                        } else {
                            self.readyToCollectFrame = true
                        }
                        
                        self.isReconstructed = true
                        self.pointCloud = self.reconstruction.pointCloud
                        
                    }
                }
            } else {
                
                self.initialFramesToDrop = self.initialFramesToDrop - 1
            }
            
        })
        
        
        return VStack(alignment: .center) {
            
            CameraView(cameraController: self.$cameraController, frame: frameBinding, readyToCollectFrame: self.$readyToCollectFrame)
            
            HStack {
                
                VStack {
                    Text("Pre-Points for Fundamental Matrix")
                        .font(.system(size: 9))
                        .frame(height: 25)
                    
                    Image(uiImage: self.reconstruction.reconstructionImages?[0] ?? backgroundImage)
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                }
                
                VStack {
                    Text("Points for Fundamental Matrix")
                        .font(.system(size: 9))
                        .frame(height: 25)
                    
                    Image(uiImage: self.reconstruction.reconstructionImages?[1] ?? backgroundImage)
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                }
                
                VStack {
                    Text("Points for Depth Reconstruction")
                        .font(.system(size: 9))
                        .frame(height: 25)
                    
                    Image(uiImage: self.reconstruction.reconstructionImages?[2] ?? backgroundImage)
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                }
                
                VStack {
                    Text("Intersecting Image Points")
                        .font(.system(size: 9))
                        .frame(height: 25)
                    
                    Image(uiImage: self.reconstruction.reconstructionImages?[3] ?? backgroundImage)
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                }
                
                
                
            }.frame(width: UIScreen.main.bounds.size.width)
            
            
            PointCloudView(pointCloud: self.$pointCloud, readyToCollectFrame: self.$readyToCollectFrame)
                .scaledToFill()
                .frame(width: UIScreen.main.bounds.size.width)
            
            
            Text(self.reconstruction.reconstructionMessge ?? "Runtime messages")
                .font(.system(size: 13))
                .frame(width: UIScreen.main.bounds.size.width-20, height: 150)
                .multilineTextAlignment(.leading)
            
            
            HStack(alignment: .center){
                
                Button(action:{
                    
                    self.isStoped = true
                }){
                    Text("Stop")
                        .font(.body)
                        .fontWeight(.bold)
                        .padding(3)
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .padding(5)
                        .border(Color.blue, width: 2)
                }
                
                Spacer().frame(width: 80)
                
                Button(action:{
                    
                    if self.isStoped {
                        
                        print("\nClear shape model ...")
                        
                        self.reconstruction.restart = true
                        self.reconstruction.imagePair.removeAll()
                        self.pointCloud?.removeAll()
                        
                        self.isStoped = false
                        
                        if self.isReconstructed {
                            
                            self.readyToCollectFrame = true
                        }
                    }
                    
                }){
                    Text("Restart")
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
            
        }
    }
}

struct ContentViewSfM_Previews: PreviewProvider {
    
    static var previews: some View {
        ContentViewSfM()
    }
    
}
