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
        int rows = images[0].rows;
        int cols = images[0].cols * (int)images.size();
        Mat pano2(rows,cols,CV_8UC3);
        for(int i=0;i<images.size();++i)
        {
            images[i].copyTo(pano2(Rect(images[i].cols*i,0,images[i].cols,images[i].rows)));
        }
        return pano2;
    }
    
    return pano;
    
}

void lumaAnalizer(Mat cvPano)
{
    vector<int> plausibleAreas;
    vector<LightParams> sceneLights;
    Mat gray;
    cvtColor(cvPano, gray, COLOR_BGR2GRAY);
    Mat blurred ;
    GaussianBlur(gray, blurred, Size(15,15), 0);
    threshold(blurred, gray, 210, 255, THRESH_BINARY);
    Mat erosionParams = getStructuringElement(MORPH_RECT,
                                              Size(5,5),
                                              Point(1,1));
    erode(gray, gray, erosionParams);
    dilate(gray, blurred, erosionParams);
    Mat stats, centroids;
    
    int nLabels = connectedComponentsWithStats(blurred, gray, stats, centroids);
    
    //Print the statistics and centroids
    cout << "stats:" << endl << "(left,top,width,height,area)" << endl << stats << endl << endl;
    cout << "centroids:" << endl << "(x, y)" << endl << centroids << endl << endl;
    
    for (int l = 1; l < nLabels; ++l)
    {
        if(stats.at<int>(l,CC_STAT_AREA) > (stats.at<int>(0,CC_STAT_AREA)*0.0025f))
        {
            //cout << "This one could be " << l << endl;
            plausibleAreas.push_back(l);
            
        }
        
    }
    
    float x = 0.0f;
    float y = 0.0f;
    Vec3f lightPos;
    
    for(int l = 0;l<plausibleAreas.size();++l)
    {
        
        x = centroids.at<double>((double)plausibleAreas[l],0);
        y = centroids.at<double>((double)plausibleAreas[l],1);
        
        float rho = x * (360.0f/cvPano.cols);
        float phi = abs(cvPano.rows*0.5 - y)*(120.0f/cvPano.rows);
        
        x = rho*cos(phi*0.01745329252f);//Degrees to radians conversion constant
        y = rho*sin(phi*0.01745329252f);
        
        lightPos[0] = x;
        lightPos[1] = y;
        lightPos[2] = 4.0f;
        
        LightParams currentParams;
        currentParams.position = lightPos;
        sceneLights.push_back(currentParams);
        
    }

    //cout << "Plausible areas " << plausibleAreas.size() << " out of " << nLabels << " total areas" << endl;
}
