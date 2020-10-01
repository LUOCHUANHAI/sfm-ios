//
//  Calibration.cpp
//  sfm-ios
//
//  Created by luochuanhai on 2020/5/27.
//  Copyright © 2020 luochuanhai. All rights reserved.
//

#include "CameraCalibration.hpp"


void CameraCalibration::createKnownBoardPosition(cv:: Size chessboardDimension, float squareEdgeLength, vector<Point3f>& corners){
    
    for (int i=0; i<chessboardDimension.height; i++) {
        for (int j=0; j<chessboardDimension.width; j++) {
            corners.push_back(Point3f(j*squareEdgeLength, i*squareEdgeLength, 0.0f));
        }
    }
}


void CameraCalibration::getChessboardCorners(vector<Mat> images, cv::Size chessboardDimension, vector<vector<Point2f>>& allFoundCorners) {
    
    for (int i=0; i<images.size(); i++) {
        
        vector<Point2f> pointBuf;
        
        bool found = findChessboardCorners(images.at(i), chessboardDimension, pointBuf, CV_CALIB_CB_ADAPTIVE_THRESH + CV_CALIB_CB_NORMALIZE_IMAGE);
        
        if (found) {
            allFoundCorners.push_back(pointBuf);
        }
        
    }
    
}


void CameraCalibration::cameraCalibration(vector<Mat> calibrationImages, cv::Size chessboardDimension, float squareEdgeLength, Mat& cameraMatrix, Mat& distortionCoefficients, Mat& perViewErrors) {
    
    vector<vector<Point2f>> chessboardImagesCorners;
    
    getChessboardCorners(calibrationImages, chessboardDimension, chessboardImagesCorners);
    
    vector<vector<Point3f>> worldCorners(1);
    
    createKnownBoardPosition(chessboardDimension, squareEdgeLength, worldCorners[0]);
    worldCorners.resize(chessboardImagesCorners.size(), worldCorners[0]);
    
    vector<Mat> rVectors, tVectors;
    Mat stdDeviationsIntrinsics, stdDeviationsExtrinsics;
    
    calibrateCamera(worldCorners, chessboardImagesCorners, chessboardDimension, cameraMatrix, distortionCoefficients, rVectors, tVectors, stdDeviationsIntrinsics, stdDeviationsExtrinsics, perViewErrors, 0, TermCriteria(TermCriteria::COUNT+TermCriteria::EPS, 100, DBL_EPSILON));
    
}
