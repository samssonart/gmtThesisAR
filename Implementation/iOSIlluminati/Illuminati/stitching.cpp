//
//  stitching.cpp
//  Illuminati
//
//  Created by Samssonart on 5/2/17.
//  Copyright © 2017 Samssonart. All rights reserved.
//

#include "stitching.h"

ARHandle *arHandle;
AR3DHandle *ar3DHandle;
ARPattHandle *arPattHandle;
ARMarkerInfo *markerInfo;
int markerNum;
int patt_id;
ARdouble err;
ARParamLT *gCparamLT = NULL;


float distanceToMarker(Mat panoramic)
{
    float dist = 0.0f;
    int markerPixelHeight = 180;
    
    Mat image1 = panoramic;
    Mat bgraMat;
    cvtColor(image1, bgraMat, CV_BGR2RGBA);
    
    //2.4 is the device camera focal legth, 90 is the physical height of the marker and 31 is the sensor height. All measured in millimeters
    //dist = (2.4f * 90.0f * image1.rows) / ((float)markerPixelHeight * 31.0f);
    dist = (90.0f * 1400.0f) / markerPixelHeight;
    
    return dist;
    
}


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

vector<LightParams> lumaAnalizer(Mat cvPano)
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
    
    for (unsigned int l = 1; l < nLabels; ++l)
    {
        if(stats.at<int>(l,CC_STAT_AREA) > (stats.at<int>(0,CC_STAT_AREA)*0.0025f))
        {
            //cout << "This one could be " << l << endl;
            plausibleAreas.push_back(l);
            
        }
        
    }
    
    float x = 0.0f;
    float y = 0.0f;
    float z = 0.0f;
    Vec3f lightPos;
    
    for(unsigned int l = 0;l<plausibleAreas.size();++l)
    {
        
        x = centroids.at<double>((double)plausibleAreas[l],0);
        y = centroids.at<double>((double)plausibleAreas[l],1);
        
        float rho = (x * 360.0f)/cvPano.cols;
        cout << "Angle h: "<< rho << endl;
        
        float phi = 90.0f - (y * 180.0f)/cvPano.rows;
        if (phi < 0.0f ) phi = 360.0f + phi;
        
        float gammma = 90.0f - rho;
        
        
        cout << "Angle v: "<< phi << endl;
        
        x = cos(rho*0.01745329252f);
        y = cos(phi*0.01745329252f);
        z = cos(gammma*0.01745329252f);

        if(centroids.at<double>((double)plausibleAreas[l],0) > cvPano.cols/2)
        {
            x *= -1;
        }
        
        lightPos[0] = x;
        lightPos[1] = y;
        lightPos[2] = z;
        
        LightParams currentParams;
        currentParams.position = lightPos;
        sceneLights.push_back(currentParams);
        
    }

    return sceneLights;
    //cout << "Plausible areas " << plausibleAreas.size() << " out of " << nLabels << " total areas" << endl;
}
