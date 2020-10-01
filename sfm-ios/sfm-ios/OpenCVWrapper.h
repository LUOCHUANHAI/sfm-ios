//
//  OpenCVWrapper.h
//  sfm-ios
//
//  Created by luochuanhai on 2020/5/21.
//  Copyright © 2020 luochuanhai. All rights reserved.
//

#ifndef OpenCVWrapper_h
#define OpenCVWrapper_h

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>


@interface OpenCVWrapper : NSObject

// In Objective-C syntax, the + indicates a class method; use - to indicate an instance method.
- (NSString *) openCVVersionString;


- (NSMutableArray *) openCVDrawChessboardCorners:(UIImage *)uiimage chessboardPatternHeight: (NSNumber *)chessboardPatternHeight chessboardPatternWidth: (NSNumber *)chessboardPatternWidth;


- (NSMutableArray *) openCVCalibrate:(NSArray *)uiimages chessboardSquareEdgeLength: (NSNumber *)chessboardSquareEdgeLength chessboardPatternHeight: (NSNumber *)chessboardPatternHeight chessboardPatternWidth: (NSNumber *)chessboardPatternWidth sensorHeight: (NSNumber *)sensorHeight sensorWidth: (NSNumber *)sensorWidth;


- (NSMutableArray *) openCVReconstruction:(NSArray *)uiimages cameraMatrix: (NSArray *)cameraMatrix restart: (NSNumber *) restart;


@end

#endif /* OpenCVWrapper_h */
