//
//  OpenCVWrapper.m
//
//  It's an Object-C file, allowing to use C++.
//
//  sfm-ios
//
//  Created by luochuanhai on 2020/5/21.
//  Copyright © 2020 luochuanhai. All rights reserved.
//


#import <opencv2/opencv.hpp>
#import "OpenCVWrapper.h"
#import <UIKit/UIKit.h>
#import <SceneKit/SceneKit.h>
#import <opencv2/imgcodecs/ios.h>
#include "CameraCalibration.hpp"
#include "ShapeReconstruction.hpp"
#include <sstream>


using namespace std;
using namespace cv;


@implementation OpenCVWrapper {
    CameraCalibration cameraCalibration;
    ShapeReconstruction shapeReconstruction;
}


- (NSString *) openCVVersionString {
    return [NSString stringWithFormat:@"OpenCV Version %s",  CV_VERSION];
}


- (NSMutableArray *) openCVDrawChessboardCorners:(UIImage *)uiimage chessboardPatternHeight: (NSNumber *)chessboardPatternHeight chessboardPatternWidth: (NSNumber *)chessboardPatternWidth {
    
    Mat image, imageToDraw;
    UIImageToMat(uiimage, image);
    cvtColor(image, image, CV_RGBA2BGR);
    
    
    
    const cv::Size chessboardDimension = cv::Size([chessboardPatternWidth intValue],[chessboardPatternHeight intValue]);
    
    vector<Vec2f> foundPoints;
    bool found = false;
    
    found = findChessboardCorners(image, chessboardDimension, foundPoints, CV_CALIB_CB_ADAPTIVE_THRESH + CV_CALIB_CB_NORMALIZE_IMAGE);
    
    NSMutableArray *result = [[NSMutableArray alloc] initWithCapacity:0];
    
    [result addObject:[NSNumber numberWithBool:found]];
    
    image.copyTo(imageToDraw);
    
    if (found) {
        
        drawChessboardCorners(imageToDraw, chessboardDimension, foundPoints, found);
        cvtColor(imageToDraw, imageToDraw, CV_BGR2RGBA);
        [result addObject:MatToUIImage(imageToDraw)];
        
    } else {
        
        cvtColor(imageToDraw, imageToDraw, CV_BGR2RGBA);
        [result addObject:MatToUIImage(imageToDraw)];
    }
    
    return result;
}


- (NSMutableArray *) openCVCalibrate:(NSArray *)uiimages chessboardSquareEdgeLength: (NSNumber *)chessboardSquareEdgeLength chessboardPatternHeight: (NSNumber *)chessboardPatternHeight chessboardPatternWidth: (NSNumber *)chessboardPatternWidth sensorHeight: (NSNumber *)sensorHeight sensorWidth: (NSNumber *)sensorWidth {
    
    vector<Mat> calibrationImages;
    Mat tempMat;
    
    for (int i=0; i < uiimages.count; i++) {
        UIImageToMat(uiimages[i], tempMat);
        cvtColor(tempMat, tempMat, CV_RGBA2BGR);
        calibrationImages.push_back(tempMat);
    }
    
    const float calibrationSquareEdgeLength = [chessboardSquareEdgeLength floatValue];
    const cv::Size chessboardDimension = cv::Size([chessboardPatternWidth intValue],[chessboardPatternHeight intValue]);
    Mat cameraMatrix, distortionCoefficients, perViewErrors;
    
    cameraCalibration.cameraCalibration(calibrationImages, chessboardDimension, calibrationSquareEdgeLength, cameraMatrix, distortionCoefficients, perViewErrors);
    
    NSMutableArray *calibrationResults = [[NSMutableArray alloc] initWithCapacity:0];
    
    uint16_t rows = cameraMatrix.rows;
    uint16_t columns = cameraMatrix.cols;
    for (int r=0; r<rows; r++) {
        for (int c=0; c<columns; c++) {
            [calibrationResults addObject:[NSNumber numberWithDouble:cameraMatrix.at<double>(r,c)]];
        }
    }
    
    for (int c=0; c<5; c++) {
        [calibrationResults addObject:[NSNumber numberWithDouble:distortionCoefficients.at<double>(0,c)]];
    }
    
    uint16_t width = calibrationImages.front().cols;
    uint16_t height = calibrationImages.front().rows;

    double apertureHeight = [sensorHeight doubleValue];
    double apertureWidth = [sensorWidth doubleValue];
    
    double fovx, fovy, focalLength, aspectRatio;
    Point2d principalPoint;
    calibrationMatrixValues(cameraMatrix, cv::Size(width, height), apertureWidth, apertureHeight, fovx, fovy, focalLength, principalPoint, aspectRatio);
    
    // cameraMatrix, distortionCoefficients, apertureWidth, apertureHight, fovx, fovy, focalLength, principalPoint.x, principalPoint.y, aspectRatio
    [calibrationResults addObject:[NSNumber numberWithDouble:apertureWidth]];
    [calibrationResults addObject:[NSNumber numberWithDouble:apertureHeight]];
    [calibrationResults addObject:[NSNumber numberWithDouble:fovx]];
    [calibrationResults addObject:[NSNumber numberWithDouble:fovy]];
    [calibrationResults addObject:[NSNumber numberWithDouble:focalLength]];
    [calibrationResults addObject:[NSNumber numberWithDouble:principalPoint.x]];
    [calibrationResults addObject:[NSNumber numberWithDouble:principalPoint.y]];
    [calibrationResults addObject:[NSNumber numberWithDouble:aspectRatio]];
    
    double minReprojectionError, maxReprojectionError;
    minMaxLoc(perViewErrors, &minReprojectionError, &maxReprojectionError);
    
    [calibrationResults addObject:[NSNumber numberWithDouble:minReprojectionError]];
    [calibrationResults addObject:[NSNumber numberWithDouble:maxReprojectionError]];
    
    return calibrationResults;
}


- (NSMutableArray *) openCVReconstruction:(NSArray *)uiimages cameraMatrix: (NSArray *)cameraMatrix restart: (NSNumber *) restart {
    
    std::ostringstream messageStream;
    
    bool reconstructionRestart = [restart boolValue];
    
    if (reconstructionRestart) {
        unsigned long preModelSize = shapeReconstruction.shapeModel.getShapeModel().size();
        
        shapeReconstruction.shapeModel.clearShapeModel();
        
        if (shapeReconstruction.shapeModel.getShapeModel().size() == 0) {
            
            cout << preModelSize << " world points in the pre-shape model are cleared." << endl;
            messageStream << preModelSize << " world points in the pre-shape model are cleared." << endl;
        }
        
    }
    
    
    unsigned long count = [cameraMatrix count];
    double K[9];
    
    for (int i=0; i<count; i++) {
        K[i] = [[cameraMatrix objectAtIndex:i] doubleValue];
    }
    
    const Mat cameraMatrixMat = (Mat_<double>(3,3) << K[0], K[1], K[2], K[3], K[4], K[5], K[6], K[7], K[8]);
    
    NSMutableArray *intermediateResults = [[NSMutableArray alloc] initWithCapacity:0];
    
    Mat previousFrame, frame;
    
    UIImageToMat(uiimages[0], previousFrame);
    UIImageToMat(uiimages[1], frame);
    
    cvtColor(previousFrame, previousFrame, CV_RGBA2GRAY);
    cvtColor(frame, frame, CV_RGBA2GRAY);
    
    
    // Extract good matchings.
    vector<Point2f> pointsPreviousFrameForFundamentalMatrix, pointsFrameForFundamentalMatrix;
    
    shapeReconstruction.getMatchingsUsingSURF(previousFrame, frame, pointsPreviousFrameForFundamentalMatrix, pointsFrameForFundamentalMatrix, 100, 0.5);
    
    cout << pointsPreviousFrameForFundamentalMatrix.size() << " matchings for calculating fundamental matrix." << endl;
    messageStream << pointsPreviousFrameForFundamentalMatrix.size() << " matchings for calculating fundamental matrix." << endl;
    
    
    // add matched feature points images into intermediateResults
    {
        Mat previousFrameToReturn, frameToReturn;
        previousFrame.copyTo(previousFrameToReturn);
        frame.copyTo(frameToReturn);
        cvtColor(previousFrameToReturn, previousFrameToReturn, CV_GRAY2BGR);
        cvtColor(frameToReturn, frameToReturn, CV_GRAY2BGR);
        
        for (int i=0; i<pointsPreviousFrameForFundamentalMatrix.size(); i++) {
            circle(previousFrameToReturn, pointsPreviousFrameForFundamentalMatrix.at(i), 3, Scalar(0,0,255));
        }
        
        for (int i=0; i<pointsFrameForFundamentalMatrix.size(); i++) {
            circle(frameToReturn, pointsFrameForFundamentalMatrix.at(i), 3, Scalar(0,0,255));
        }
        
        cvtColor(previousFrameToReturn, previousFrameToReturn, CV_BGR2RGBA);
        cvtColor(frameToReturn, frameToReturn, CV_BGR2RGBA);
        [intermediateResults addObject:MatToUIImage(previousFrameToReturn)];
        [intermediateResults addObject:MatToUIImage(frameToReturn)];
    }
    
    
    if (pointsPreviousFrameForFundamentalMatrix.size() < 100) {
        
        Mat blackImage = Mat::zeros(640, 480, CV_8UC3);
        blackImage.convertTo(blackImage, CV_BGR2RGBA);
        
        [intermediateResults addObject:MatToUIImage(blackImage)];
        [intermediateResults addObject:MatToUIImage(blackImage)];
        
        
        vector<Point3f> model = shapeReconstruction.shapeModel.getShapeModel();
        cout <<  model.size() << " world points in the shape model." << endl;
        messageStream << model.size() << " world points in the shape model." << endl;
        
        NSMutableArray *pointCloudNSArray = [[NSMutableArray alloc] initWithCapacity:0];
        
        for (int i=0; i<model.size(); i++) {
            
            NSArray *point = [NSArray arrayWithObjects:[NSNumber numberWithFloat:model.at(i).x], [NSNumber numberWithFloat:model.at(i).y], [NSNumber numberWithFloat:model.at(i).z], nil];
            [pointCloudNSArray addObject:point];
        }
        
        [intermediateResults addObject:pointCloudNSArray];
        
        
        cout << "Not enough feature points to calculate fundamental matrix! Move the camera back a little, and shoot again." << endl;
        messageStream << "Not enough feature points to calculate fundamental matrix! Move the camera back a little, and shoot again." << endl;
        messageStream << endl;
        
        string messageStr = messageStream.str();
        NSString *message = [NSString stringWithCString:messageStr.c_str() encoding:[NSString defaultCStringEncoding]];
        [intermediateResults addObject:message];
        
        NSMutableArray *reconstructionResults = [[NSMutableArray alloc] initWithCapacity:0];
        
        [reconstructionResults addObject:[NSNumber numberWithBool:false]];
        
        [reconstructionResults addObject:intermediateResults];
        return reconstructionResults;
    }
    
    
    // Extract fundamental matrix.
    Mat fundamentalMatrix;
    vector<Point2f> inliersPreviousFrameForFundamentalMatrix, inliersFrameForFundamentalMatrix;
    
    shapeReconstruction.getFundamentalMatrixAndInliers(fundamentalMatrix, pointsPreviousFrameForFundamentalMatrix, pointsFrameForFundamentalMatrix, inliersPreviousFrameForFundamentalMatrix, inliersFrameForFundamentalMatrix);
    
    cout << inliersPreviousFrameForFundamentalMatrix.size() << " inliers for calculating fundamental matrix." << endl;
    messageStream << inliersPreviousFrameForFundamentalMatrix.size() << " inliers for calculating fundamental matrix." << endl;
    
    
    // Extract essential matrix.
    Mat essentialMatrix;
    
    shapeReconstruction.getEssentialFromFundamental(fundamentalMatrix, cameraMatrixMat, essentialMatrix);
    
    
    // Extract rotation matrix & translation between shooting points.
    Mat rotationMatrix, translation;
    
    recoverPose(essentialMatrix, inliersPreviousFrameForFundamentalMatrix, inliersFrameForFundamentalMatrix, cameraMatrixMat, rotationMatrix, translation);
    
    
    // Calculate sparse depth map.
    vector<Point2f> pointsPreviousFrameForDepthReconstruction, pointsFrameForDepthReconstruction;
//    shapeReconstruction.getMatchingsUsingORB(previousFrame, frame, pointsPreviousFrameForDepthReconstruction, pointsFrameForDepthReconstruction, 1000, 20, 0.7);
    shapeReconstruction.getMatchingsUsingGFTTDetectorAndORB(previousFrame, frame, pointsPreviousFrameForDepthReconstruction, pointsFrameForDepthReconstruction, 0.7);
//    shapeReconstruction.getMatchingsUsingSURF(previousFrame, frame, pointsPreviousFrameForDepthReconstruction, pointsFrameForDepthReconstruction, 100, 0.7);
    
    cout << pointsPreviousFrameForDepthReconstruction.size() << " candidates for calculating point cloud." << endl;
    messageStream << pointsPreviousFrameForDepthReconstruction.size() << " candidates for calculating point cloud." << endl;
    
    vector<double> guessedDepths, minDistances;
    shapeReconstruction.getSparseDepthUsingReprojectedDistanceError(previousFrame, frame, pointsPreviousFrameForDepthReconstruction, pointsFrameForDepthReconstruction, cameraMatrixMat, rotationMatrix, translation, guessedDepths, minDistances);
    
    
    // Recover world coordinates.
    vector<Point2f> inliersPreviousFrameForDepthReconstruction, inliersFrameForDepthReconstruction;
    vector<Point3f> pointCloud;
    
    shapeReconstruction.getWorldCoordinatesInCamera(pointsPreviousFrameForDepthReconstruction, pointsFrameForDepthReconstruction, guessedDepths, minDistances, cameraMatrixMat, 1, pointCloud, inliersPreviousFrameForDepthReconstruction, inliersFrameForDepthReconstruction);
    
    cout << inliersPreviousFrameForDepthReconstruction.size() << " points for calculating point cloud. " << endl;
    messageStream << inliersPreviousFrameForDepthReconstruction.size() << " points for calculating point cloud. " << endl;
    
    
    // add inliersPreviousFrameForDepthReconstruction image into intermediateResults
    {
        Mat previousFrameToReturn;
        previousFrame.copyTo(previousFrameToReturn);
        cvtColor(previousFrameToReturn, previousFrameToReturn, CV_GRAY2BGR);

        for (int i=0; i<inliersPreviousFrameForDepthReconstruction.size(); i++) {
            circle(previousFrameToReturn, inliersPreviousFrameForDepthReconstruction.at(i), 3, Scalar(0,0,255));
        }

        cvtColor(previousFrameToReturn, previousFrameToReturn, CV_BGR2RGBA);
        [intermediateResults addObject:MatToUIImage(previousFrameToReturn)];
    }
    
    
    // Update the shape model
    bool updated = shapeReconstruction.shapeModel.feedAndUpdateShapeModel(inliersPreviousFrameForDepthReconstruction, inliersFrameForDepthReconstruction, pointCloud, rotationMatrix);
    
    if (!updated) {
        
        Mat blackImage = Mat::zeros(640, 480, CV_8UC3);
        blackImage.convertTo(blackImage, CV_BGR2RGBA);
        [intermediateResults addObject:MatToUIImage(blackImage)];
        
        
        vector<Point3f> model = shapeReconstruction.shapeModel.getShapeModel();
        cout << model.size() << " world points in the shape model." << endl;
        messageStream << model.size() << " world points in the shape model." << endl;
        
        NSMutableArray *pointCloudNSArray = [[NSMutableArray alloc] initWithCapacity:0];
        
        for (int i=0; i<model.size(); i++) {
            
            NSArray *point = [NSArray arrayWithObjects:[NSNumber numberWithFloat:model.at(i).x], [NSNumber numberWithFloat:model.at(i).y], [NSNumber numberWithFloat:model.at(i).z], nil];
            [pointCloudNSArray addObject:point];
        }
        
        [intermediateResults addObject:pointCloudNSArray];
        
        
        cout << "Shape model isn't updated! Move the camera back a little, and shoot again." << endl;
        messageStream << "Shape model isn't updated! Move the camera back a little, and shoot again." << endl;
        messageStream << endl;
        
        string messageStr = messageStream.str();
        NSString *message = [NSString stringWithCString:messageStr.c_str() encoding:[NSString defaultCStringEncoding]];
        [intermediateResults addObject:message];
        
        NSMutableArray *reconstructionResults = [[NSMutableArray alloc] initWithCapacity:0];
        
        [reconstructionResults addObject:[NSNumber numberWithBool:false]];
        [reconstructionResults addObject:intermediateResults];
        return reconstructionResults;
    }
    
    
    // add intersectingImagePoints image into intermediateResults
    {
        Mat previousFrameToReturn;
        previousFrame.copyTo(previousFrameToReturn);
        cvtColor(previousFrameToReturn, previousFrameToReturn, CV_GRAY2BGR);
        
        vector<Point2f> intersectingImagePoints = shapeReconstruction.shapeModel.getIntersectingImagePoints(1);
        
        cout << intersectingImagePoints.size() << " intersecting world points." << endl;
        messageStream << intersectingImagePoints.size() << " intersecting world points." << endl;
        
        for (int i=0; i<intersectingImagePoints.size(); i++) {
            
            circle(previousFrameToReturn, intersectingImagePoints.at(i), 3, Scalar(0,0,255));
        }
        
        cvtColor(previousFrameToReturn, previousFrameToReturn, CV_BGR2RGBA);
        [intermediateResults addObject:MatToUIImage(previousFrameToReturn)];
    }
    
    
    // add point cloud to reconstruction results
    vector<Point3f> model = shapeReconstruction.shapeModel.getShapeModel();
    
    cout << model.size() << " world points in the shape model." << endl;
    messageStream << model.size() << " world points in the shape model." << endl;
    
    NSMutableArray *pointCloudNSArray = [[NSMutableArray alloc] initWithCapacity:0];
    
    for (int i=0; i<model.size(); i++) {
        
        NSArray *point = [NSArray arrayWithObjects:[NSNumber numberWithFloat:model.at(i).x], [NSNumber numberWithFloat:model.at(i).y], [NSNumber numberWithFloat:model.at(i).z], nil];
        [pointCloudNSArray addObject:point];
    }
    
    [intermediateResults addObject:pointCloudNSArray];
    
    
    // add running message to intermediate results and return reconstruction results
    messageStream << endl;
    
    string messageStr = messageStream.str();
    NSString *message = [NSString stringWithCString:messageStr.c_str() encoding:[NSString defaultCStringEncoding]];
    [intermediateResults addObject:message];
    
    NSMutableArray *reconstructionResults = [[NSMutableArray alloc] initWithCapacity:0];
    
    [reconstructionResults addObject:[NSNumber numberWithBool:true]];
    [reconstructionResults addObject:intermediateResults];
    return reconstructionResults;
}


@end
