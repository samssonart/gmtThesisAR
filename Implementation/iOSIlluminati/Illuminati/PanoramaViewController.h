//
//  PanoramaViewController.h
//  Illuminati
//
//  Created by Samssonart on 4/23/17.
//  Copyright © 2017 Samssonart. All rights reserved.
//

#import <opencv2/videoio/cap_ios.h>
using namespace cv;

#import <UIKit/UIKit.h>
#import <CoreMotion/CoreMotion.h>
#import <CoreLocation/CoreLocation.h>
#import "CVWrapper.h"

@interface PanoramaViewController : UIViewController<CvPhotoCameraDelegate, CLLocationManagerDelegate>
{
    
    IBOutlet UIImageView *pitchIndicator;
    IBOutlet UIImageView *imageView;
    UIImage* panoramaRes;
    CvPhotoCamera* cvCamera;
    CMMotionManager* motionManager;
    CLLocationManager* locationManager;
    

}

-(IBAction)goToAR;
-(void)stitchImages;
-(void)saveImages;

@property (nonatomic, retain) CvPhotoCamera* cvCamera;
@property (nonatomic, retain) CMMotionManager* motionManager;
@property (nonatomic, retain) CLLocationManager* locationManager;
@property (nonatomic, retain) UIImage* panoramaRes;

@end
