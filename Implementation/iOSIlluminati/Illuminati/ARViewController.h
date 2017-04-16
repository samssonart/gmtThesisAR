//
//  ViewController.h
//  Illuminati
//
//  Created by Samssonart on 4/16/17.
//  Copyright © 2017 Samssonart. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>
#import <AR/ar.h>
#import <AR/video.h>
#import <AR/gsub_es.h>
#import "ARView.h"
#import "../ARAppCore/ARMarker.h"
#import "../ARAppCore/VirtualEnvironment.h"
#import <AR/sys/CameraVideo.h>

@interface ARViewController : UIViewController <CameraVideoTookPictureDelegate> {
}

- (IBAction)start;
- (IBAction)stop;
- (void) processFrame:(AR2VideoBufferT *)buffer;

@property (readonly) ARView *glView;
@property (readonly) NSMutableArray *markers;
@property (nonatomic, retain) VirtualEnvironment *virtualEnvironment;
@property (readonly) ARGL_CONTEXT_SETTINGS_REF arglContextSettings;

@property (readonly, nonatomic, getter=isRunning) BOOL running;
@property (nonatomic, getter=isPaused) BOOL paused;

// Frame interval defines how many display frames must pass between each time the
// display link fires. The display link will only fire 30 times a second when the
// frame internal is two on a display that refreshes 60 times a second. The default
// frame interval setting of one will fire 60 times a second when the display refreshes
// at 60 times a second. A frame interval setting of less than one results in undefined
// behavior.
@property (nonatomic) NSInteger runLoopInterval;

@property (nonatomic) BOOL markersHaveWhiteBorders;

@end

