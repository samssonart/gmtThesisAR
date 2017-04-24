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

@synthesize cvCamera;

-(void)goToAR
{
    
    UIStoryboard* ARStoryboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    UIViewController* initialARVC = [ARStoryboard instantiateInitialViewController];
    [self presentViewController:initialARVC animated:false completion:nil];
    
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.cvCamera = [[CvVideoCamera alloc] initWithParentView:imageView];
    self.cvCamera.delegate = self;
    self.cvCamera.defaultAVCaptureDevicePosition = AVCaptureDevicePositionFront;
    self.cvCamera.defaultAVCaptureSessionPreset = AVCaptureSessionPreset1280x720;
    self.cvCamera.defaultAVCaptureVideoOrientation = AVCaptureVideoOrientationPortrait;
    self.cvCamera.defaultFPS = 30;
    [self.cvCamera start];
}

- (void)didReceiveMemoryWarning {
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
    // Do some OpenCV stuff with the image
    Mat image_copy;
    cvtColor(image, image_copy, CV_BGRA2BGR);
    
    // invert image
    bitwise_not(image_copy, image_copy);
    cvtColor(image_copy, image, CV_BGR2BGRA);
}
#endif

@end
