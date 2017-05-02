//
//  stitching.cpp
//  Illuminati
//
//  Created by Samssonart on 5/2/17.
//  Copyright © 2017 Samssonart. All rights reserved.
//

#include "stitching.h"


Mat stitch (vector<Mat>& images)
{
    Mat pano;
    Ptr<Stitcher> stitcher = Stitcher::create(Stitcher::PANORAMA, false);
    Stitcher::Status status = stitcher->stitch(images, pano);
    
    if (status != Stitcher::OK)
    {
        //cout << "Can't stitch images, error code = " << int(status) << endl;
        return Mat::zeros(1, 1, CV_64F);
    }
    
    return pano;
    
}
