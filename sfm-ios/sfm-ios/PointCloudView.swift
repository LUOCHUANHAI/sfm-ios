//
//  PointCloudView.swift
//  sfm-ios
//
//  Created by luochuanhai on 2020/6/29.
//  Copyright © 2020 luochuanhai. All rights reserved.
//

import Foundation
import SwiftUI
import SceneKit


struct PointCloudView: UIViewRepresentable {
    
    @Binding var pointCloud: [NSArray]?
    @Binding var readyToCollectFrame: Bool?
    
    
    func makeUIView(context: UIViewRepresentableContext<PointCloudView>) -> SCNView {
        
        let sceneView = SCNView(frame: CGRect(x:0 , y:0, width: 500, height: 500))
        
        sceneView.backgroundColor = UIColor.black
//        sceneView.allowsCameraControl = true
        
        return sceneView
        
    }
    
    func updateUIView(_ sceneView: SCNView, context: UIViewRepresentableContext<PointCloudView>) {
        
        let vertexSource: SCNGeometrySource?
        let pointCloudElement: SCNGeometryElement?
        
        if self.pointCloud == nil || self.pointCloud?.count == 0 {
            let vertices : [SCNVector3] = []
            vertexSource = SCNGeometrySource(vertices: vertices)
            
            let indexData = NSData(bytes: Array<UInt32>(0..<UInt32(vertices.count)), length: MemoryLayout<UInt32>.size * vertices.count)
            pointCloudElement = SCNGeometryElement(data: indexData as Data, primitiveType: .point, primitiveCount: vertices.count, bytesPerIndex: MemoryLayout<UInt32>.size)
            
        } else {
            var vertices: [SCNVector3] = []
            
            for point in self.pointCloud! {
                vertices.append(SCNVector3Make(point[0] as! Float, point[1] as! Float, point[2] as! Float))
            }
            
            vertexSource = SCNGeometrySource(vertices: vertices)
            
            let indexData = NSData(bytes: Array<UInt32>(0..<UInt32(self.pointCloud!.count)), length: MemoryLayout<UInt32>.size * self.pointCloud!.count)
            pointCloudElement = SCNGeometryElement(data: indexData as Data, primitiveType: .point, primitiveCount: self.pointCloud!.count, bytesPerIndex: MemoryLayout<UInt32>.size)
        }
        
        pointCloudElement!.pointSize = 3
        pointCloudElement!.minimumPointScreenSpaceRadius = 3
        pointCloudElement!.maximumPointScreenSpaceRadius = 3
        
        let geometry = SCNGeometry(sources: [vertexSource!], elements: [pointCloudElement!])
        geometry.firstMaterial?.diffuse.contents = UIColor.green
        
        let pointCloudNode = SCNNode()
        pointCloudNode.geometry = geometry
        
        let coordAxis = CoordAxis(length: 3)
        
        let pointCloudWithCoordAxis = SCNNode()
        pointCloudWithCoordAxis.addChildNode(pointCloudNode)
        pointCloudWithCoordAxis.addChildNode(coordAxis)
        
        let scene = SCNScene()
        pointCloudWithCoordAxis.eulerAngles = SCNVector3(Double.pi, 0, 0)
        
        scene.rootNode.addChildNode(pointCloudWithCoordAxis)
        pointCloudWithCoordAxis.position = SCNVector3(0, 0, -15)
        
        let camera = SCNCamera()
        scene.rootNode.camera = camera
        
        sceneView.backgroundColor = UIColor.black
        sceneView.scene = scene
        sceneView.allowsCameraControl = true
        
    }
}
