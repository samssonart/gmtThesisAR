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

CLLocationDirection oldDirection;
NSMutableArray* capturedImages;
BOOL capturing = NO;
BOOL finishedCapturing = NO;
int photoCounter = 0;

@synthesize cvCamera, motionManager, locationManager, panoramaRes;



-(void)goToAR
{
    
    [self saveImages];
    [CVWrapper lumaAnalizer:panoramaRes];
    
    //UIStoryboard* ARStoryboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    //UIViewController* initialARVC = [ARStoryboard instantiateInitialViewController];
    //[self presentViewController:initialARVC animated:false completion:nil];
    
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    panoramaRes = [[UIImage alloc]init];
    //Attitude
    self.motionManager = [[CMMotionManager alloc]init];
    [self.motionManager setDeviceMotionUpdateInterval:0.01f];
    if (motionManager.deviceMotionAvailable)
    {
        [motionManager startDeviceMotionUpdatesToQueue:[NSOperationQueue mainQueue]withHandler:^(CMDeviceMotion *data, NSError *error)
        {
            //NSLog(@"Gravity: %f",data.attitude.pitch);
            //Move the arrow image so that it is centered when the device is upright
            [pitchIndicator setFrame:CGRectMake(20, data.attitude.pitch * 321.3333f, pitchIndicator.frame.size.width, pitchIndicator.frame.size.height)];
        }];
    }
    
    //Heading
    self.locationManager = [[CLLocationManager alloc] init];
    locationManager.delegate = self;
    locationManager.desiredAccuracy = kCLLocationAccuracyKilometer;
    locationManager.distanceFilter = 1000.0f;
    locationManager.headingFilter = 1.5;
    [locationManager startUpdatingHeading];
    oldDirection = 0;
    

    //CVCamera
    capturedImages = [[NSMutableArray alloc] init];
    self.cvCamera = [[CvPhotoCamera alloc] initWithParentView:imageView];
    self.cvCamera.delegate = self;
    self.cvCamera.defaultAVCaptureDevicePosition = AVCaptureDevicePositionBack;
    self.cvCamera.defaultAVCaptureSessionPreset = AVCaptureSessionPreset352x288;
    self.cvCamera.defaultAVCaptureVideoOrientation = AVCaptureVideoOrientationPortrait;
    self.cvCamera.defaultFPS = 30;
    [self.cvCamera start];
    [self.cvCamera lockFocus];
      
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)locationManager:(CLLocationManager *)manager didUpdateHeading:(CLHeading *)newHeading
{
    if (newHeading.headingAccuracy < 0 || finishedCapturing)
        return;
    
    // Use the true heading if it is valid.
    CLLocationDirection  theHeading = ((newHeading.trueHeading > 0) ? newHeading.trueHeading : newHeading.magneticHeading);
    
    //NSLog(@"Current heading: %f",theHeading);
    
    capturing = YES;
    //The device's camera has a roughly 35º FOV, so it's necessary to take snapshots every 17.5 - 18º (because the heading is in the center of the frame)
    if((abs(theHeading - oldDirection) > 15) && (abs(theHeading - oldDirection) < 17))
    {
        photoCounter++;
        if(photoCounter >= 22) finishedCapturing = YES;
        NSLog(@"Current heading: %f",theHeading);
        [cvCamera takePicture];
        oldDirection = theHeading;
        
        
    }
    
}

- (void)photoCamera:(CvPhotoCamera*)photoCamera capturedImage:(UIImage *)image
{
    [capturedImages addObject:image];
    if(finishedCapturing)
    {
        //[self stitchImages];
        [self saveImages];
        [CVWrapper lumaAnalizer:panoramaRes];
    }
    
}


- (void) saveImages
{
    NSString *bundlePath = [[NSBundle mainBundle] bundlePath];
    panoramaRes = [[UIImage alloc]initWithContentsOfFile:[bundlePath stringByAppendingPathComponent:@"Data2/environment.jpg"]];
    for (id image in capturedImages)
    {
       UIImageWriteToSavedPhotosAlbum(image, nil, nil, nil);
        
    }
    
}

-(void)stitchImages
{
    
    NSLog(@"Creating Panorama");
    panoramaRes = [CVWrapper processWithArray:capturedImages];
    if(panoramaRes.size.height < 10 || panoramaRes.size.width <10) return;
    
    UIImageWriteToSavedPhotosAlbum(panoramaRes, nil, nil, nil);
    
    NSData* imageData = UIImageJPEGRepresentation(panoramaRes, 0.9);
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);
    NSString *filePath = [[paths objectAtIndex:0] stringByAppendingPathComponent:@"pano.jpg"];
    NSError *writeError = nil;
    [imageData writeToFile:filePath options:NSDataWritingAtomic error:&writeError];
    
    if (writeError) {
        NSLog(@"Error writing file: %@", writeError);
    }
    
    
}


- (void)photoCameraCancel:(CvPhotoCamera*)camera;
{
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
