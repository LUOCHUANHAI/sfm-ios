//
//  ShapeReconstruction.hpp
//  sfm-ios
//
//  Created by luochuanhai on 2020/6/19.
//  Copyright © 2020 luochuanhai. All rights reserved.
//

#ifndef ShapeReconstruction_hpp
#define ShapeReconstruction_hpp


#include <stdio.h>
#include <iostream>
#include <opencv2/video/tracking.hpp>
#include <opencv2/calib3d.hpp>
#include <opencv2/xfeatures2d.hpp>
#include "ShapeModel.hpp"


using namespace std;

using namespace cv;
using namespace cv::xfeatures2d;



class ShapeReconstruction {
    
public:
    ShapeModel shapeModel;
    
public:
    void getMatchingsUsingGFTTDetectorAndOpticalFlow(Mat& previousFrame, Mat& frame, vector<Point2f>& goodPointsPreviousFrame, vector<Point2f>& goodPointsFrame, Mat& opticalFlow);
    
    void getMatchingsUsingGFTTDetectorAndORB(Mat& previousFrame, Mat& frame, vector<Point2f>& goodPointsPreviousFrame, vector<Point2f>& goodPointsFrame, double loweRatioThresh);
    
    void getMatchingsUsingSURF(Mat& previousFrame, Mat& frame, vector<Point2f>& goodPointsPreviousFrame, vector<Point2f>& goodPointsFrame, int minHessian, double loweRatioThresh);
    
    void getMatchingsUsingORB(Mat& previousFrame, Mat& frame, vector<Point2f>& goodPointsPreviousFrame, vector<Point2f>& goodPointsFrame, int nfeatures, int fastThreshold, double loweRatioThresh);
    
    void getSparseOpticalFlow(vector<Point2f>& pointsPreviousFrame, vector<Point2f>& pointsFrame, Mat& opticalFlow);
    
    void getDenseOpticalFlow(Mat& previousFrame, Mat& frame, Mat& opticalFlow);
    
    void getDisparityMapFromOpticalFlow(Mat& opticalFlow, Mat& disparityMap);
    
    void getAngleMapFromOpticalFlow(Mat& opticalFlow, Mat& angleMap);
    
    void getFundamentalMatrixAndInliers(Mat& fundamentalMatrix, vector<Point2f>& goodPointsPreviousFrame, vector<Point2f>& goodPointsFrame, vector<Point2f>& inliersPreviousFrame, vector<Point2f>& inliersFrame);
    
    void getEssentialFromFundamental(Mat& fundamentalMatrix, const Mat& cameraMatrix, Mat& essentialMatrix);
    
    void getSparseDepthUsingReprojectedDistanceError(Mat& previousFrame, Mat& frame, vector<Point2f>& pointsPreviousFrameForDepthReconstruction, vector<Point2f>& pointsFrameForDepthReconstruction, const Mat& cameraMatrix, Mat& rotationMatrix, Mat& translation, vector<double>& guessedDepths, vector<double>& minDistances);
    
    void getSparseDepthUsingReprojectedDistanceErrorWithOpticalFlow(Mat& previousFrame, Mat& frame, vector<Point2f>& points, Mat& denseOpticalFlow, const Mat& cameraMatrix, Mat& rotationMatrix, Mat& translation, vector<double>& guessedDepths, vector<double>& minDistances);
    
    void getWorldCoordinatesInCamera(vector<Point2f>& pointsPreviousFrame, vector<Point2f>& pointsFrame, vector<double>& guessedDepths, vector<double>& minDistances, const Mat& cameraMatrix, double threshold, vector<Point3f>& pointCloud, vector<Point2f>& inliersPreviousFrame, vector<Point2f>& inliersFrame);
    
};

#endif /* ShapeReconstruction_hpp */
