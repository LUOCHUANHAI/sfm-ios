# sfm-ios

#### Description

This is the code implementation on iOS of a realtime SfM algorithm presented in the master disertation of "An analysis of realtime shape from motion" by Chuanhai Luo.

>Chuanhai Luo, **An Analysis of Realtime Shape from Motion**, M.Sc. Computer Science, The University of Manchester, submitted in September 2020. 

This implementation achieves a speed of 0.8 second per reconstruction for around 500 feature points. The top 2 time-comusing parts in this implementation is SURF features detection and depth searching by reprojection error. By the way, for the convenience of coding, the input for each reconstruction in this implementation is a pair of images, so that each image's SURF features are computed twice (except the first one), which is a waste of time. The following students in this project should consider to save the computed features and use them for reconstructions, which might save 1/4 to 1/3 of the reconstruction time.

#### Environment Setup
* OpenCV Homepage: [https://opencv.org](https://opencv.org)
* Setting up OpenCV and C++ development environment in Xcode for Computer Vision projects: [https://medium.com/@jaskaranvirdi/setting-up-opencv-and-c-development-environment-in-xcode-b6027728003](https://medium.com/@jaskaranvirdi/setting-up-opencv-and-c-development-environment-in-xcode-b6027728003)
* OpenCV with Swift - step by step: [https://medium.com/@yiweini/opencv-with-swift-step-by-step-c3cc1d1ee5f1](https://medium.com/@yiweini/opencv-with-swift-step-by-step-c3cc1d1ee5f1)

#### References

* Create a camera app with SwiftUI: [https://medium.com/@gaspard.rosay/create-a-camera-app-with-swiftui-60876fcb9118](https://medium.com/@gaspard.rosay/create-a-camera-app-with-swiftui-60876fcb9118)
* iOS — Camera Frames Extraction: [https://medium.com/ios-os-x-development/ios-camera-frames-extraction-d2c0f80ed05a](https://medium.com/ios-os-x-development/ios-camera-frames-extraction-d2c0f80ed05a)
* A SceneKit node showing the world origin and axis directions: [https://gist.github.com/cenkbilgen/ba5da0b80f10dc69c10ee59d4ccbbda6](https://gist.github.com/cenkbilgen/ba5da0b80f10dc69c10ee59d4ccbbda6)
