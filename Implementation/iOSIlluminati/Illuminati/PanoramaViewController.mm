//
//  PanoramaViewController.m
//  Illuminati
//
//  Created by Samssonart on 4/23/17.
//  Copyright © 2017 Samssonart. All rights reserved.
//

#import "PanoramaViewController.h"

@interface PanoramaViewController ()

@end

@implementation PanoramaViewController

@synthesize cvCamera, motionManager;

-(void)goToAR
{
    
    UIStoryboard* ARStoryboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    UIViewController* initialARVC = [ARStoryboard instantiateInitialViewController];
    [self presentViewController:initialARVC animated:false completion:nil];
    
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.motionManager = [[CMMotionManager alloc] init];
    //Gyroscope
    if([self.motionManager isGyroAvailable])
    {
        self.motionManager.gyroUpdateInterval = 0.1f;
        [self.motionManager startGyroUpdates];
    }
    else
    {
        NSLog(@"Gyroscope not Available!");
    }
    
    //Accelerometer
    if([self.motionManager isAccelerometerAvailable])
    {
        self.motionManager.accelerometerUpdateInterval = 0.1f;
        [self.motionManager startAccelerometerUpdates];
    }
    else
    {
        NSLog(@"Accelerometer not Available!");
    }


    self.cvCamera = [[CvVideoCamera alloc] initWithParentView:imageView];
    self.cvCamera.delegate = self;
    self.cvCamera.defaultAVCaptureDevicePosition = AVCaptureDevicePositionBack;
    self.cvCamera.defaultAVCaptureSessionPreset = AVCaptureSessionPreset1280x720;
    self.cvCamera.defaultAVCaptureVideoOrientation = AVCaptureVideoOrientationPortrait;
    self.cvCamera.defaultFPS = 30;
    //CGAffineTransform xform = CGAffineTransformMakeRotation(-M_PI / 2);
    //imageView.transform = xform;
    [self.cvCamera start];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

#pragma mark - Protocol CvVideoCameraDelegate
//On Cocoa it's trivial to use C++ code, it's enough to use the __cplusplus precompile directive
//and save the source file as .mm instead of .m for the compiler to understand that this is an Objective-C++ source (Obj-C mixed with C++)

#ifdef __cplusplus
- (void)processImage:(Mat&)image;
{
    // This is necessary to correct the image orientation
    Mat image_copy;
    cvtColor(image, image_copy, CV_BGRA2BGR);
    flip(image_copy, image_copy, 1);
    transpose(image_copy, image);

}
#endif

@end
