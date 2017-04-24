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

@interface PanoramaViewController : UIViewController<CvVideoCameraDelegate>
{
    
    IBOutlet UIImageView *imageView;
    CvVideoCamera* cvCamera;
    
}

-(IBAction)goToAR;

@property (nonatomic, retain) CvVideoCamera* cvCamera;


@end
