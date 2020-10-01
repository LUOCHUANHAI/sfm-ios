//
//  ShapeModel.cpp
//  sfm-ios
//
//  Created by luochuanhai on 2020/7/15.
//  Copyright © 2020 luochuanhai. All rights reserved.
//

#include "ShapeModel.hpp"


bool ShapeModel::feedAndUpdateShapeModel(vector<Point2f> &inliersPreviousFrameForDepthReconstruction, vector<Point2f> &inliersFrameForDepthReconstruction, vector<Point3f> &pointCloud, Mat& rotationMatrix) {
    
    if (pointPairs.size() == 4) {
        pointPairs.pop_front();
        pointPairs.pop_front();
    }
    
    pointPairs.push_back(inliersPreviousFrameForDepthReconstruction);
    pointPairs.push_back(inliersFrameForDepthReconstruction);
    
    if (pointClouds.size() == 2) {
        pointClouds.pop_front();
    }
    
    pointClouds.push_back(pointCloud);
    
    if (rotationMatrixs.size() == 2) {
        rotationMatrixs.pop_front();
    }
    
    rotationMatrixs.push_back(rotationMatrix);
    
    if (pointPairs.size() == 4 && pointClouds.size() == 2) {
        bool updated = updateShapeModelNew2();
        
        if (!updated) {
            
            pointPairs.pop_back();
            pointPairs.pop_back();
            pointClouds.pop_back();
            rotationMatrixs.pop_back();
            return false;
        } else {
            
            return true;
        }
        
    } else if (pointPairs.size() == 2 && pointClouds.size() == 1) {
        
        if (pointClouds.at(0).size() < minimumIntersectingPoints*3) {
            
            pointPairs.clear();
            pointClouds.clear();
            rotationMatrixs.clear();
            return false;
        } else {
            shapeModel = pointClouds.at(0);
            return true;
        }
    }
    
    return true;
}


vector<Point2f> ShapeModel::getIntersectingImagePoints(double threshold) {
    
    vector<Point2f> imagePoints;
    
    if (pointPairs.size() != 4) {
        
        return imagePoints;
    }
    
    for (int i=0; i<pointPairs.at(1).size(); i++) {
        Point2f imagePoint1 = pointPairs.at(1).at(i);
        
        for (int j=0; j<pointPairs.at(2).size(); j++) {
            Point2f imagePoint2 = pointPairs.at(2).at(j);
            
            if ( sqrt( pow(imagePoint1.x-imagePoint2.x, 2) + pow(imagePoint1.y-imagePoint2.y, 2) ) <= threshold) {
                
                imagePoints.push_back(imagePoint1);
            }
            
        }
    }
    
    return imagePoints;
}


vector<vector<Point3f>> ShapeModel::getIntersectingPointClouds(double threshold) {
    
    vector<Point3f> worldPoints1, worldPoints2;
    
    for (int i=0; i<pointPairs.at(1).size(); i++) {
        Point2f imagePoint1 = pointPairs.at(1).at(i);
        Point3f worldPoint1 = pointClouds.at(0).at(i);
        
        for (int j=0; j<pointPairs.at(2).size(); j++) {
            Point2f imagePoint2 = pointPairs.at(2).at(j);
            Point3f worldPoint2 = pointClouds.at(1).at(j);
            
            if ( sqrt( pow(imagePoint1.x-imagePoint2.x, 2) + pow(imagePoint1.y-imagePoint2.y, 2) ) <= threshold) {
                
                worldPoints1.push_back(worldPoint1);
                worldPoints2.push_back(worldPoint2);
            }
            
        }
    }
    
    vector<vector<Point3f>> intersectingPointClouds;
    intersectingPointClouds.push_back(worldPoints1);
    intersectingPointClouds.push_back(worldPoints2);
    
    return intersectingPointClouds;
}


void ShapeModel::getMeanPoints(vector<vector<Point3f>>& intersectingPointClouds, vector<Point3f>& meanPoints) {
    
    meanPoints.clear();
    
    for (int i=0; i<intersectingPointClouds.at(0).size(); i++) {
        float x = (intersectingPointClouds.at(0).at(i).x + intersectingPointClouds.at(1).at(i).x)/2.0;
        float y = (intersectingPointClouds.at(0).at(i).y + intersectingPointClouds.at(1).at(i).y)/2.0;
        float z = (intersectingPointClouds.at(0).at(i).z + intersectingPointClouds.at(1).at(i).z)/2.0;
        
        meanPoints.push_back(Point3f(x, y, z));
    }
    
}


void ShapeModel::transformToNewPointCloudCoord(vector<Point3f>& pointCloud, Point3f centroid, double centroidSize) {
    
    for (int i=0; i<pointCloud.size(); i++) {
        pointCloud.at(i).x *= centroidSize;
        pointCloud.at(i).y *= centroidSize;
        pointCloud.at(i).z *= centroidSize;
    }
    
    for (int i=0; i<pointCloud.size(); i++) {
        pointCloud.at(i).x += centroid.x;
        pointCloud.at(i).y += centroid.y;
        pointCloud.at(i).z += centroid.z;
    }
    
}


void ShapeModel::centerAndScalePointCloud(vector<Point3f>& pointCloud, Point3f centroid, double centroidSize) {
    
    for (int i=0; i<pointCloud.size(); i++) {
        pointCloud.at(i).x -= centroid.x;
        pointCloud.at(i).y -= centroid.y;
        pointCloud.at(i).z -= centroid.z;
    }
    
    for (int i=0; i<pointCloud.size(); i++) {
        pointCloud.at(i).x /= centroidSize;
        pointCloud.at(i).y /= centroidSize;
        pointCloud.at(i).z /= centroidSize;
    }
}


vector<double> ShapeModel::getCentroidSizeOfTwoIntersectingPointClouds(vector<vector<Point3f>>& intersectingPointClouds, vector<Point3f>& centroids) {
    
    double centroidSize1 = 0;
    double centroidSize2 = 0;
    
    Point3f centroid1 = centroids.at(0);
    Point3f centroid2 = centroids.at(1);
    
    for (int i=0; i<intersectingPointClouds.at(0).size(); i++) {
        centroidSize1 += (pow(intersectingPointClouds.at(0).at(i).x-centroid1.x, 2) + pow(intersectingPointClouds.at(0).at(i).y-centroid1.y, 2) + pow(intersectingPointClouds.at(0).at(i).z-centroid1.z, 2));
    }
    centroidSize1 = sqrt(centroidSize1);
    
    for (int i=0; i<intersectingPointClouds.at(1).size(); i++) {
        centroidSize2 += (pow(intersectingPointClouds.at(1).at(i).x-centroid2.x, 2) + pow(intersectingPointClouds.at(1).at(i).y-centroid2.y, 2) + pow(intersectingPointClouds.at(1).at(i).z-centroid2.z, 2));
    }
    centroidSize2 = sqrt(centroidSize2);
    
    
    vector<double> centroidSizes;
    centroidSizes.push_back(centroidSize1);
    centroidSizes.push_back(centroidSize2);
    
    return centroidSizes;
    
}


vector<Point3f> ShapeModel::getCentroidOfTwoIntersectingPointCloudsEigen(vector<vector<Point3f>>& intersectingPointClouds) {
    
    // convert a point3f vector to a 3x? mat
    Mat pointCloud1 = Mat(intersectingPointClouds.at(0)).reshape(1).t();
    Mat pointCloud2 = Mat(intersectingPointClouds.at(1)).reshape(1).t();
    
    Mat centroid1, centroid2;
    
    reduce(pointCloud1, centroid1, 1, CV_REDUCE_AVG);
    reduce(pointCloud2, centroid2, 1, CV_REDUCE_AVG);
    
    vector<Point3f> centroids;
    centroids.push_back(Point3f(centroid1));
    centroids.push_back(Point3f(centroid2));
    
    return centroids;
    
}


void ShapeModel::rotatePointCloudEigen(vector<Point3f>& pointCloud, Mat& rotationMatrix) {
    
    Mat pointCloudMat = Mat(pointCloud).reshape(1).t();
    
    pointCloudMat.convertTo(pointCloudMat, rotationMatrix.type());
    
    Mat rotatedPointCloud;
    
    gemm(rotationMatrix, pointCloudMat, 1, pointCloudMat, 0, rotatedPointCloud);
    
    for (int c=0; c<rotatedPointCloud.cols; c++) {
        
        pointCloud.at(c) = Point3f(rotatedPointCloud.col(c));
    }
    
}


bool ShapeModel::updateShapeModelNew2() {
    
    vector<vector<Point3f>> intersectingPointClouds = getIntersectingPointClouds(1);
    
    if (intersectingPointClouds.at(0).size() < minimumIntersectingPoints) {
        return false;
    }
    
    vector<vector<Point3f>> intersectingPointCloudsBak = intersectingPointClouds;
    
    // Perform procustes transform.
    // Calculate centroids of two intersecting point clouds.
    vector<Point3f> centroids = getCentroidOfTwoIntersectingPointCloudsEigen(intersectingPointClouds);
    
    // Calculate centroid size of intersecting point clouds.
    vector<double> centroidSizes = getCentroidSizeOfTwoIntersectingPointClouds(intersectingPointClouds, centroids);
    
    // Center and scale the first intersecting point cloud.
    centerAndScalePointCloud(intersectingPointClouds.at(0), centroids.at(0), centroidSizes.at(0));
    
    // Rotate the first intersecting point cloud to the second intersecting point cloud coord.
    Mat rotationMatrix = rotationMatrixs.at(0);
    rotatePointCloudEigen(intersectingPointClouds.at(0), rotationMatrix);
    
    // Transform the first intersecting point cloud to the second intersecting point cloud center and scale.
    transformToNewPointCloudCoord(intersectingPointClouds.at(0), centroids.at(1), centroidSizes.at(1));
    
    // Get the mean points between the intersecting point clouds.
    vector<Point3f> meanPoints;
    getMeanPoints(intersectingPointClouds, meanPoints);
    
    // Remove intersecting points in the shape model.
    for (unsigned long i=0; i<intersectingPointCloudsBak.at(0).size(); i++) {
        for (unsigned long j=shapeModel.size()-1; j>=0 && j<shapeModel.size(); j--) {
            
            if (shapeModel.at(j).x == intersectingPointCloudsBak.at(0).at(i).x && shapeModel.at(j).y == intersectingPointCloudsBak.at(0).at(i).y && shapeModel.at(j).z == intersectingPointCloudsBak.at(0).at(i).z) {
                
                shapeModel.erase(shapeModel.begin()+j);
                break;
            }
        }
    }
    
    // Change the intersecting points in the second point cloud to their mean points.
    for (unsigned long i=0; i<intersectingPointCloudsBak.at(1).size(); i++) {
        for (unsigned long j=0; j<pointClouds.at(1).size(); j++) {
            
            if (pointClouds.at(1).at(j).x == intersectingPointCloudsBak.at(1).at(i).x && pointClouds.at(1).at(j).y == intersectingPointCloudsBak.at(1).at(i).y && pointClouds.at(1).at(j).z == intersectingPointCloudsBak.at(1).at(i).z) {
                
                pointClouds.at(1).at(j).x = meanPoints.at(i).x;
                pointClouds.at(1).at(j).y = meanPoints.at(i).y;
                pointClouds.at(1).at(j).z = meanPoints.at(i).z;
                break;
            }
        }
    }
    
    // Register the shape model to the second point cloud.
    centerAndScalePointCloud(shapeModel, centroids.at(0), centroidSizes.at(0));
    rotatePointCloudEigen(shapeModel, rotationMatrix);
    transformToNewPointCloudCoord(shapeModel, centroids.at(1), centroidSizes.at(1));
    
    shapeModel.insert(shapeModel.end(), pointClouds.at(1).begin(), pointClouds.at(1).end());
    
    return true;
}


void ShapeModel::clearShapeModel() {
    pointPairs.clear();
    pointClouds.clear();
    rotationMatrixs.clear();
    shapeModel.clear();
}


vector<Point3f> ShapeModel::getShapeModel() {
    
    return shapeModel;
}
