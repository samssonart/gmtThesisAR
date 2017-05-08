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
        cout << "Can't stitch images, error code = " << int(status) << endl;
        return Mat::zeros(1, 1, CV_64F);
    }
    
    return pano;
    
}

void lumaAnalizer(Mat cvPano)
{
    Mat gray;
    cvtColor(cvPano, gray, COLOR_BGR2GRAY);
    Mat blurred ;
    GaussianBlur(gray, blurred, Size(11,11), 0);
    threshold(blurred, gray, 230, 255, THRESH_BINARY);
    Mat erosionParams = getStructuringElement(MORPH_RECT,
                                              Size(5,5),
                                              Point(1,1));
    erode(gray, gray, erosionParams);
    dilate(gray, blurred, erosionParams);
    Mat stats, centroids;
    
    //int nLabels = connectedComponents(blurred, gray, 4);
    int nLabels = connectedComponentsWithStats(blurred, gray, stats, centroids);
    std::vector<int> plausibleAreas;
    
    //Print the statistics and centroids
    cout << "stats:" << endl << "(left,top,width,height,area)" << endl << stats << endl << endl;
    cout << "centroids:" << endl << "(x, y)" << endl << centroids << endl << endl;
    
    // Print individual stats for component 1 (this is just to have a quick sytax reference)
    //cout << "Component 1 stats:" << endl;
    //cout << "CC_STAT_LEFT   = " << stats.at<int>(1,CC_STAT_LEFT) << endl;
    //cout << "CC_STAT_TOP    = " << stats.at<int>(1,CC_STAT_TOP) << endl;
    //cout << "CC_STAT_WIDTH  = " << stats.at<int>(1,CC_STAT_WIDTH) << endl;
    //cout << "CC_STAT_HEIGHT = " << stats.at<int>(1,CC_STAT_HEIGHT) << endl;
    //cout << "CC_STAT_AREA   = " << stats.at<int>(1,CC_STAT_AREA) << endl;
    
    for (int l = 1; l < nLabels; ++l)
    {
        if(stats.at<int>(l,CC_STAT_AREA) > (stats.at<int>(0,CC_STAT_AREA)*0.0035f))
        {
            cout << "This one could be " << l << endl;
            plausibleAreas.push_back(l);
            
        }
        
    }
    cout << "Plausible areas " << plausibleAreas.size() << " out of " << nLabels << " total areas" << endl;
}
