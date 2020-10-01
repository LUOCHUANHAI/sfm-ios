//
//  ShapeReconstruction.cpp
//  sfm-ios
//
//  Created by luochuanhai on 2020/6/19.
//  Copyright © 2020 luochuanhai. All rights reserved.
//

#include "ShapeReconstruction.hpp"


void ShapeReconstruction::getMatchingsUsingGFTTDetectorAndOpticalFlow(Mat& previousFrame, Mat& frame, vector<Point2f>& goodPointsPreviousFrame, vector<Point2f>& goodPointsFrame, Mat& opticalFlow) {
    
    goodPointsPreviousFrame.clear();
    goodPointsFrame.clear();
    
    vector<KeyPoint> keypointsPreviousFrame;
    
    Ptr<GFTTDetector> gftt = GFTTDetector::create(500, 0.01, 10, 3, false, 0.04);
    gftt->detect(previousFrame, keypointsPreviousFrame);
    
    KeyPoint::convert(keypointsPreviousFrame, goodPointsPreviousFrame);
    
    for (int i=0; i<goodPointsPreviousFrame.size(); i++) {
        Point2f movement = opticalFlow.at<Vec2f>(goodPointsPreviousFrame.at(i).y, goodPointsPreviousFrame.at(i).x);
        goodPointsFrame.push_back(Point2f(goodPointsPreviousFrame.at(i).x + movement.x, goodPointsPreviousFrame.at(i).y + movement.y));
    }
    
}


void ShapeReconstruction::getMatchingsUsingGFTTDetectorAndORB(Mat& previousFrame, Mat& frame, vector<Point2f>& goodPointsPreviousFrame, vector<Point2f>& goodPointsFrame, double loweRatioThresh) {
    
    vector<KeyPoint> keypointsPreviousFrame, keypointsFrame;
    Mat descriptorsPreviousFrame, descriptorsFrame;
    
    Ptr<GFTTDetector> gftt = GFTTDetector::create(1000, 0.01, 1, 3, false, 0.04);
    
    gftt->detect(previousFrame, keypointsPreviousFrame);
    gftt->detect(frame, keypointsFrame);
    
    Ptr<ORB> detector = ORB::create();
    
    detector->compute(previousFrame, keypointsPreviousFrame, descriptorsPreviousFrame);
    detector->compute(frame, keypointsFrame, descriptorsFrame);
    
    Ptr<DescriptorMatcher> matcher = DescriptorMatcher::create(DescriptorMatcher::BRUTEFORCE);
    vector<vector<DMatch>> knnMatches;
    
    matcher->knnMatch( descriptorsPreviousFrame, descriptorsFrame, knnMatches, 2 );
    
    // Filter matches using the Lowe's ratio test.
    vector<DMatch> goodMatches;
    for (size_t i = 0; i < knnMatches.size(); i++)
    {
        if (knnMatches[i][0].distance < loweRatioThresh * knnMatches[i][1].distance)
        {
            goodMatches.push_back(knnMatches[i][0]);
        }
    }
    
    vector<Point2f> pointsPreviousFrame, pointsFrame;
    KeyPoint::convert(keypointsPreviousFrame, pointsPreviousFrame);
    KeyPoint::convert(keypointsFrame, pointsFrame);
    
    goodPointsPreviousFrame.clear();
    goodPointsFrame.clear();
    
    for (size_t i = 0; i < goodMatches.size(); i++)
    {
        goodPointsPreviousFrame.push_back(pointsPreviousFrame[goodMatches[i].queryIdx]);
        goodPointsFrame.push_back(pointsFrame[goodMatches[i].trainIdx]);
    }
}


void ShapeReconstruction::getMatchingsUsingSURF(Mat& previousFrame, Mat& frame, vector<Point2f>& goodPointsPreviousFrame, vector<Point2f>& goodPointsFrame, int minHessian, double loweRatioThresh) {

    // Feature extraction using SURF.
    Ptr<SURF> detector = SURF::create( minHessian );
    vector<KeyPoint> keypointsPreviousFrame, keypointsFrame;
    Mat descriptorsLeft, descriptorsRight;
    
    detector->detectAndCompute(previousFrame, Mat(), keypointsPreviousFrame, descriptorsLeft);
    detector->detectAndCompute(frame, Mat(), keypointsFrame, descriptorsRight);
    
    // Matching descriptor vectors with a FLANN based matcher. Since SURF is a floating-point descriptor, NORM_L2 is used.
    Ptr<DescriptorMatcher> matcher = DescriptorMatcher::create(DescriptorMatcher::BRUTEFORCE);
    vector< vector<DMatch> > knnMatches;
    matcher->knnMatch( descriptorsLeft, descriptorsRight, knnMatches, 2 );

    // Filter matches using the Lowe's ratio test.
    vector<DMatch> goodMatches;
    for (size_t i = 0; i < knnMatches.size(); i++)
    {
        if (knnMatches[i][0].distance < loweRatioThresh * knnMatches[i][1].distance)
        {
            goodMatches.push_back(knnMatches[i][0]);
        }
    }
    
    vector<Point2f> pointsPreviousFrame, pointsFrame;
    KeyPoint::convert(keypointsPreviousFrame, pointsPreviousFrame);
    KeyPoint::convert(keypointsFrame, pointsFrame);
    
    goodPointsPreviousFrame.clear();
    goodPointsFrame.clear();
    
    for (size_t i = 0; i < goodMatches.size(); i++)
    {
        goodPointsPreviousFrame.push_back(pointsPreviousFrame[goodMatches[i].queryIdx]);
        goodPointsFrame.push_back(pointsFrame[goodMatches[i].trainIdx]);
    }

}


void ShapeReconstruction::getMatchingsUsingORB(Mat& previousFrame, Mat& frame, vector<Point2f>& goodPointsPreviousFrame, vector<Point2f>& goodPointsFrame, int nfeatures, int fastThreshold, double loweRatioThresh) {
    
    int edgeThreshold = 31;
    int patchSize = 31;
    int nlevels = 8;
    
    Ptr<ORB> detector = ORB::create(nfeatures, 1.2, nlevels, edgeThreshold, 0, 2, ORB::HARRIS_SCORE, patchSize, fastThreshold);
    
    vector<KeyPoint> keypointsPreviousFrame, keypointsFrame;
    Mat descriptorsPreviousFrame, descriptorsFrame;
    
    detector->detectAndCompute(previousFrame, Mat(), keypointsPreviousFrame, descriptorsPreviousFrame);
    detector->detectAndCompute(frame, Mat(), keypointsFrame, descriptorsFrame);
    
    Ptr<DescriptorMatcher> matcher = DescriptorMatcher::create(DescriptorMatcher::BRUTEFORCE_HAMMING);
    
    vector<vector<DMatch>> knnMatches;
    
    matcher->knnMatch( descriptorsPreviousFrame, descriptorsFrame, knnMatches, 2 );
    
    // Filter matches using the Lowe's ratio test.
    vector<DMatch> goodMatches;
    for (size_t i = 0; i < knnMatches.size(); i++)
    {
        if (knnMatches[i][0].distance < loweRatioThresh * knnMatches[i][1].distance)
        {
            goodMatches.push_back(knnMatches[i][0]);
        }
    }
    
    vector<Point2f> pointsPreviousFrame, pointsFrame;
    KeyPoint::convert(keypointsPreviousFrame, pointsPreviousFrame);
    KeyPoint::convert(keypointsFrame, pointsFrame);
    
    goodPointsPreviousFrame.clear();
    goodPointsFrame.clear();
    
    for (size_t i = 0; i < goodMatches.size(); i++)
    {
        goodPointsPreviousFrame.push_back(pointsPreviousFrame[goodMatches[i].queryIdx]);
        goodPointsFrame.push_back(pointsFrame[goodMatches[i].trainIdx]);
    }
}


void ShapeReconstruction::getDenseOpticalFlow(Mat& previousFrame, Mat& frame, Mat& opticalFlow) {
    
    calcOpticalFlowFarneback(previousFrame, frame, opticalFlow, 0.5, 3, 9, 5, 5, 1.1, OPTFLOW_FARNEBACK_GAUSSIAN);
    
}


void ShapeReconstruction::getDisparityMapFromOpticalFlow(Mat& opticalFlow, Mat& disparityMap) {
    
    Mat flowParts[2];
    split(opticalFlow, flowParts);
    
    Mat magnitude, angle;
    cartToPolar(flowParts[0], flowParts[1], magnitude, angle, true);
    
    magnitude.copyTo(disparityMap);
    
    double minValue, maxValue;
    minMaxLoc(disparityMap, &minValue, &maxValue);
    
    if (maxValue > 255.f) {
        normalize(disparityMap, disparityMap, 0.0f, 1.0f, NORM_MINMAX);
        disparityMap *= 255.f;
    }
}


void ShapeReconstruction::getFundamentalMatrixAndInliers(Mat& fundamentalMatrix, vector<Point2f>& goodPointsPreviousFrame, vector<Point2f>& goodPointsFrame, vector<Point2f>& inliersPreviousFrame, vector<Point2f>& inliersFrame) {
    
    Mat inliersMask;
    
    fundamentalMatrix = findFundamentalMat(goodPointsPreviousFrame, goodPointsFrame, CV_FM_RANSAC, 0.1, 0.99, inliersMask);
    
    inliersPreviousFrame.clear();
    inliersFrame.clear();
    
    for (int r=0; r<inliersMask.rows; r++) {
        if (int(inliersMask.at<uchar>(r,0)) == 1) {
            inliersPreviousFrame.push_back(goodPointsPreviousFrame.at(r));
            inliersFrame.push_back(goodPointsFrame.at(r));
        }
    }
    
}

void ShapeReconstruction::getEssentialFromFundamental(Mat& fundamentalMatrix, const Mat& cameraMatrix, Mat& essentialMatrix) {
    
    essentialMatrix = cameraMatrix.t()*fundamentalMatrix*cameraMatrix;
    
}


void ShapeReconstruction::getSparseDepthUsingReprojectedDistanceError(Mat& previousFrame, Mat& frame, vector<Point2f>& pointsPreviousFrameForDepthReconstruction, vector<Point2f>& pointsFrameForDepthReconstruction, const Mat& cameraMatrix, Mat& rotationMatrix, Mat& translation, vector<double>& guessedDepths, vector<double>& minDistances) {
    
    Mat cameraMatrixInv = cameraMatrix.inv();
    Mat part1 = cameraMatrix*rotationMatrix*cameraMatrixInv;
    Mat part2 = cameraMatrix*rotationMatrix*translation;
    
    guessedDepths.clear();
    minDistances.clear();
    
    for (int i = 0; i < pointsPreviousFrameForDepthReconstruction.size(); i++) {
        
        Point2f pointPreviousFrame = pointsPreviousFrameForDepthReconstruction.at(i);
        Point2f pointFrame = pointsFrameForDepthReconstruction.at(i);
        
        if (sqrt(pow(pointPreviousFrame.x - pointFrame.x, 2) + pow(pointPreviousFrame.y - pointFrame.y, 2)) < 1) {
            guessedDepths.push_back(0);
            minDistances.push_back(numeric_limits<double>::max());
            continue;
        }
        
        Point2f bestGuessedPointFrame;
        
        Mat pointPreviousFrameMat = Mat(pointPreviousFrame).t();
        
        Mat pointPreviousFrameHomo;
        convertPointsToHomogeneous(pointPreviousFrameMat, pointPreviousFrameHomo);
        pointPreviousFrameHomo = pointPreviousFrameHomo.reshape(1).t();
        pointPreviousFrameHomo.convertTo(pointPreviousFrameHomo, CV_64FC1);
        
        double minDistance, bestDepth;
        
        bestDepth = 0;
        minDistance = numeric_limits<double>::max();
        
        for (int j=300; j<500; j++) {
            double depth = j/10.;
            
            Mat guessedPointFrameHomo = part1*depth*pointPreviousFrameHomo + part2;
            
            Mat guessedPointFrame;
            convertPointsFromHomogeneous(guessedPointFrameHomo.t(), guessedPointFrame);
            
            double distance = sqrt(pow(guessedPointFrame.at<Vec2d>(0, 0)[0] - pointFrame.x, 2) + pow(guessedPointFrame.at<Vec2d>(0, 0)[1] - pointFrame.y, 2));
            
            if (distance < minDistance) {
                
                minDistance = distance;
                bestDepth = depth;
                bestGuessedPointFrame = Point2f(guessedPointFrame.at<Vec2d>(0, 0)[0], guessedPointFrame.at<Vec2d>(0, 0)[1]);
            }
            else {
                if ((distance-minDistance)/minDistance > 0.1) {
                    break;
                }
            }
            
        }
        
        guessedDepths.push_back(bestDepth);
        minDistances.push_back(minDistance);
    }
}


void ShapeReconstruction::getSparseDepthUsingReprojectedDistanceErrorWithOpticalFlow(Mat& previousFrame, Mat& frame, vector<Point2f>& pointsPreviousFrameForDepthReconstruction, Mat& denseOpticalFlow, const Mat& cameraMatrix, Mat& rotationMatrix, Mat& translation, vector<double>& guessedDepths, vector<double>& minDistances) {
    
    Mat cameraMatrixInv = cameraMatrix.inv();
    
    guessedDepths.clear();
    minDistances.clear();
    
    for (int i = 0; i < pointsPreviousFrameForDepthReconstruction.size(); i++) {
        
        Point2f pointPreviousFrame = pointsPreviousFrameForDepthReconstruction.at(i);
        Point2f movement = denseOpticalFlow.at<Vec2f>(pointPreviousFrame.y, pointPreviousFrame.x);
        Point2f pointFrame = Point2f(pointPreviousFrame.x + movement.x, pointPreviousFrame.y + movement.y);
        
        if (pointFrame.x <=0 || pointFrame.y <= 0) {
            
            guessedDepths.push_back(0);
            minDistances.push_back(numeric_limits<double>::max());
            continue;
        }
        
        Mat pointPreviousFrameMat = Mat(pointPreviousFrame).t();
        
        Mat pointPreviousFrameHomo;
        convertPointsToHomogeneous(pointPreviousFrameMat, pointPreviousFrameHomo);
        pointPreviousFrameHomo = pointPreviousFrameHomo.reshape(1).t();
        pointPreviousFrameHomo.convertTo(pointPreviousFrameHomo, CV_64FC1);
        
        double minDistance, bestDepth;
        
        bestDepth = 0;
        minDistance = numeric_limits<double>::max();
        
        for (int j=1; j<200; j++) {
            double depth = j;
            
            Mat guessedPointFrameHomo = cameraMatrix*rotationMatrix*(cameraMatrixInv*depth*pointPreviousFrameHomo + translation);
            
            Mat guessedPointFrame;
            convertPointsFromHomogeneous(guessedPointFrameHomo.t(), guessedPointFrame);
            
            double distance = sqrt(pow(guessedPointFrame.at<Vec2d>(0, 0)[0] - pointFrame.x, 2) + pow(guessedPointFrame.at<Vec2d>(0, 0)[1] - pointFrame.y, 2));
            
            if (distance < minDistance) {
                
                minDistance = distance;
                bestDepth = depth;
            }
            else {
                if ((distance-minDistance)/minDistance > 0.1) {
                    break;
                }
            }
            
        }
        
        guessedDepths.push_back(bestDepth);
        minDistances.push_back(minDistance);
    }
    
}



void ShapeReconstruction::getWorldCoordinatesInCamera(vector<Point2f>& pointsPreviousFrame, vector<Point2f>& pointsFrame, vector<double>& guessedDepths, vector<double>& minDistances, const Mat& cameraMatrix, double threshold, vector<Point3f>& pointCloud, vector<Point2f>& inliersPreviousFrame, vector<Point2f>& inliersFrame) {

    pointCloud.clear();
    inliersPreviousFrame.clear();
    inliersFrame.clear();
    
    Mat cameraMatrixInv = cameraMatrix.inv();
    
    for (int i=0; i<pointsPreviousFrame.size(); i++) {
        
        if (minDistances.at(i) <= threshold) {
            
            Point2f pointPreviousFrame = pointsPreviousFrame.at(i);
            Point2f pointFrame = pointsFrame.at(i);
            
            double depth = guessedDepths.at(i);
            
            Mat pointPreviousFrameHomo = (Mat_<double>(3,1) << pointPreviousFrame.x, pointPreviousFrame.y, 1);
            
            Mat worldPoint = cameraMatrixInv*depth*pointPreviousFrameHomo;
            
            inliersPreviousFrame.push_back(pointPreviousFrame);
            inliersFrame.push_back(pointFrame);
            
            pointCloud.push_back(Point3f(worldPoint.at<double>(0,0), worldPoint.at<double>(1,0), worldPoint.at<double>(2,0)));
        }
    }
}
