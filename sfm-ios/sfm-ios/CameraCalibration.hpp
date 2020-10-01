//
//  Calibration.hpp
//  sfm-ios
//
//  Created by luochuanhai on 2020/5/27.
//  Copyright © 2020 luochuanhai. All rights reserved.
//

#ifndef Calibration_hpp
#define Calibration_hpp

#include <stdio.h>
#include <iostream>
#include <opencv2/calib3d.hpp>



using namespace std;
using namespace cv;



class CameraCalibration {

public:
    void createKnownBoardPosition(cv::Size chessboardDimension, float squareEdgeLength, vector<Point3f>& corners);

    void getChessboardCorners(vector<Mat> images, cv::Size chessboardDimension, vector<vector<Point2f>>& allFoundCorners);
    
    void cameraCalibration(vector<Mat> calibrationImages, cv::Size chessboardDimension, float squareEdgeLength, Mat& cameraMatrix, Mat& distortionCoefficients, Mat& perViewErrors);

};

#endif /* Calibration_hpp */
