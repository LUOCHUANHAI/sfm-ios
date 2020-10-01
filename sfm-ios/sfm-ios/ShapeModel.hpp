//
//  ShapeModel.hpp
//  sfm-ios
//
//  Created by luochuanhai on 2020/7/15.
//  Copyright © 2020 luochuanhai. All rights reserved.
//

#ifndef ShapeModel_hpp
#define ShapeModel_hpp


#include <stdio.h>
#include <opencv2/opencv.hpp>


using namespace std;
using namespace cv;


class ShapeModel {
    
private:
    deque<vector<Point2f>> pointPairs;
    deque<vector<Point3f>> pointClouds;
    deque<Mat> rotationMatrixs;
    vector<Point3f> shapeModel;
    int minimumIntersectingPoints = 20;
    
public:
    bool feedAndUpdateShapeModel(vector<Point2f> &inliersPreviousFrameForDepthReconstruction, vector<Point2f> &inliersFrameForDepthReconstruction, vector<Point3f> &pointCloud, Mat& rotationMatrix);
    
    vector<Point2f> getIntersectingImagePoints(double threshold);
    
    vector<vector<Point3f>> getIntersectingPointClouds(double threshold);
    
    void getMeanPoints(vector<vector<Point3f>>& intersectingPointClouds, vector<Point3f>& meanPoints);
    
    void transformToNewPointCloudCoord(vector<Point3f>& pointCloud, Point3f centroid, double centroidSize);
    
    void centerAndScalePointCloud(vector<Point3f>& pointCloud, Point3f centroid, double centroidSize);
    
    vector<double> getCentroidSizeOfTwoIntersectingPointClouds(vector<vector<Point3f>>& intersectingPointClouds, vector<Point3f>& centroids);
    
    vector<Point3f> getCentroidOfTwoIntersectingPointCloudsEigen(vector<vector<Point3f>>& intersectingPointClouds);
    
    void rotatePointCloudEigen(vector<Point3f>& pointCloud, Mat& rotationMatrix);
    
    bool updateShapeModelNew2();
    
    void clearShapeModel();
    
    vector<Point3f> getShapeModel();
};



#endif /* ShapeModel_hpp */
