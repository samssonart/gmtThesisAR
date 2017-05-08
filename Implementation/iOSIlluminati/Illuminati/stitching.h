//
//  stitching.h
//  Illuminati
//
//  Created by Samssonart on 5/2/17.
//  Copyright © 2017 Samssonart. All rights reserved.
//

#ifndef stitching_h
#define stitching_h

#include <iostream>
#include <algorithm>
#include <opencv2/core/utility.hpp>
#include <opencv2/imgproc.hpp>
#include "opencv2/highgui/highgui.hpp"
#include "opencv2/stitching.hpp"

using namespace cv;
using namespace std;

Mat stitch (vector <Mat> & images);
void lumaAnalizer(Mat cvPano);

#endif /* stitching_h */
