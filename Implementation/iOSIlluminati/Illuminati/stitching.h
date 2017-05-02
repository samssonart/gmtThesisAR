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
#include "opencv2/highgui/highgui.hpp"
#include "opencv2/stitching.hpp"

using namespace cv;
using namespace std;

Mat stitch (vector <Mat> & images);

#endif /* stitching_h */
