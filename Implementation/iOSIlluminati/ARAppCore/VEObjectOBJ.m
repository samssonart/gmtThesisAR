//
//  VEObjectOBJ.m
//  ARToolKit for iOS
//
//  Disclaimer: IMPORTANT:  This Daqri software is supplied to you by Daqri
//  LLC ("Daqri") in consideration of your agreement to the following
//  terms, and your use, installation, modification or redistribution of
//  this Daqri software constitutes acceptance of these terms.  If you do
//  not agree with these terms, please do not use, install, modify or
//  redistribute this Daqri software.
//
//  In consideration of your agreement to abide by the following terms, and
//  subject to these terms, Daqri grants you a personal, non-exclusive
//  license, under Daqri's copyrights in this original Daqri software (the
//  "Daqri Software"), to use, reproduce, modify and redistribute the Daqri
//  Software, with or without modifications, in source and/or binary forms;
//  provided that if you redistribute the Daqri Software in its entirety and
//  without modifications, you must retain this notice and the following
//  text and disclaimers in all such redistributions of the Daqri Software.
//  Neither the name, trademarks, service marks or logos of Daqri LLC may
//  be used to endorse or promote products derived from the Daqri Software
//  without specific prior written permission from Daqri.  Except as
//  expressly stated in this notice, no other rights or licenses, express or
//  implied, are granted by Daqri herein, including but not limited to any
//  patent rights that may be infringed by your derivative works or by other
//  works in which the Daqri Software may be incorporated.
//
//  The Daqri Software is provided by Daqri on an "AS IS" basis.  DAQRI
//  MAKES NO WARRANTIES, EXPRESS OR IMPLIED, INCLUDING WITHOUT LIMITATION
//  THE IMPLIED WARRANTIES OF NON-INFRINGEMENT, MERCHANTABILITY AND FITNESS
//  FOR A PARTICULAR PURPOSE, REGARDING THE DAQRI SOFTWARE OR ITS USE AND
//  OPERATION ALONE OR IN COMBINATION WITH YOUR PRODUCTS.
//
//  IN NO EVENT SHALL DAQRI BE LIABLE FOR ANY SPECIAL, INDIRECT, INCIDENTAL
//  OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF
//  SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS
//  INTERRUPTION) ARISING IN ANY WAY OUT OF THE USE, REPRODUCTION,
//  MODIFICATION AND/OR DISTRIBUTION OF THE DAQRI SOFTWARE, HOWEVER CAUSED
//  AND WHETHER UNDER THEORY OF CONTRACT, TORT (INCLUDING NEGLIGENCE),
//  STRICT LIABILITY OR OTHERWISE, EVEN IF DAQRI HAS BEEN ADVISED OF THE
//  POSSIBILITY OF SUCH DAMAGE.
//
//  Copyright 2015 Daqri LLC. All Rights Reserved.
//  Copyright 2010-2015 ARToolworks, Inc. All rights reserved.
//
//  Author(s): Philip Lamb
//

#import "VEObjectOBJ.h"
#import "VirtualEnvironment.h"
#import <OpenGLES/ES1/gl.h>
#import <OpenGLES/ES1/glext.h>
#import "glStateCache.h"
#import <stdio.h>
#import <stdlib.h>
#import <string.h>
#import <sys/param.h> // MAXPATHLEN
#import <Eden/EdenMath.h>
#import <Eden/glm.h>
#import <CoreGraphics/CoreGraphics.h>

#import "ARView.h"
#import "ARViewController.h"

@implementation VEObjectOBJ {
    GLMmodel *glmModel;
}

NSDictionary * LightDictionary;
NSMutableArray * lightValues;
UIImage* envMap;
uint m_envMap;

+ (void)load
{
    NSString *bundlePath = [[NSBundle mainBundle] bundlePath];
    lightValues = [[NSMutableArray alloc] init];
    NSArray * lightComponents;
    envMap = [UIImage imageWithContentsOfFile:[bundlePath stringByAppendingPathComponent:@"Data2/environment.jpg"]];
    if(envMap != nil) NSLog(@"Environment map succesfully loaded");
    m_envMap = CreateTextureData(envMap);
    VEObjectRegistryRegister(self, @"obj");
    LightDictionary = [NSDictionary dictionaryWithContentsOfFile: [[NSBundle mainBundle] pathForResource:@"Data2/Lights" ofType:@"plist"]];
    BOOL fileExists = [[NSFileManager defaultManager] fileExistsAtPath:[[NSBundle mainBundle] pathForResource:@"Data2/Lights" ofType:@"plist"]];
    if(!fileExists){ NSLog(@"Error loading lights file");}
    else
    {
        for (id key in LightDictionary)
        {
            NSLog(@"key: %@, value: %@ \n", key, [LightDictionary objectForKey:key]);
            lightComponents = [[LightDictionary objectForKey:key] componentsSeparatedByString:@","];
            if([lightComponents count]>1 && lightComponents != nil)
            {
                [lightValues addObject:lightComponents];
                NSLog(@"Value added");
            }
            lightComponents = nil;
        }
    }
    
}

uint CreateTextureData(UIImage* uiimage)
{
    CGImageRef image = uiimage.CGImage;
    const int width = CGImageGetWidth(image);
    const int height = CGImageGetHeight(image);
    
    const int dataSize = width * height * 4;
    uint8_t* textureData = (uint8_t*)malloc(dataSize);
    CGContextRef textureContext = CGBitmapContextCreate(textureData, width, height, 8, width * 4,
                                                      CGImageGetColorSpace(image), kCGImageAlphaPremultipliedLast);
    CGContextDrawImage(textureContext, CGRectMake(0.0, 0.0, (CGFloat)width, (CGFloat)height), image);
    CGContextRelease(textureContext);
    
    uint handle;
    glGenTextures(1, &handle);
    glBindTexture(GL_TEXTURE_2D, handle);
    glTexImage2D(GL_TEXTURE_2D, 0, GL_RGBA, width, height, 0, GL_RGBA, GL_UNSIGNED_BYTE, textureData);
    
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_LINEAR);
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_LINEAR);
    
    glTexParameterf(GL_TEXTURE_2D, GL_TEXTURE_WRAP_S, GL_REPEAT);
    glTexParameterf(GL_TEXTURE_2D, GL_TEXTURE_WRAP_T, GL_REPEAT);
    
    glBindTexture(GL_TEXTURE_2D, 0);
    free(textureData);
    
    return handle;
}

- (void)setupEnvMap
{
    float worldToView[16];
    glGetFloatv(GL_MODELVIEW_MATRIX, worldToView);
    glMatrixMode(GL_TEXTURE);
    float mat[16] = {
        0.5f * worldToView[0], -0.5 * worldToView[4], 0, 0,
        0.5f * worldToView[1], -0.5 * worldToView[5], 0, 0,
        0.5f * worldToView[2], -0.5 * worldToView[6], 0, 0,
        0.5f, 0.5, 0, 1};
    glLoadMatrixf(mat);
    glBindTexture(GL_TEXTURE_2D, m_envMap);
}



- (id) initFromFile:(NSString *)file translation:(const ARdouble [3])translation rotation:(const ARdouble [4])rotation scale:(const ARdouble [3])scale config:(char *)config
{
    if ((self = [super initFromFile:file translation:translation rotation:rotation scale:scale config:config])) {
        
        // Process config, if supplied.
        BOOL flipV = FALSE;
        if (config) {
            char *a = config;
            for (;;) {
                while( *a == ' ' || *a == '\t' ) a++; // Skip whitespace.
                if( *a == '\0' ) break; // End of string.
                
                if (strncmp(a, "TEXTURE_FLIPV", 13) == 0) flipV = TRUE;
                
                while( *a != ' ' && *a != '\t' && *a != '\0') a++; // Move to next token.
            }
        }
        
        glmModel = glmReadOBJ3([file UTF8String], 0, FALSE, flipV); // 0 -> contextIndex, FALSE -> read textures later.
        if (!glmModel) {
            NSLog(@"Error: Unable to load model %@.\n", file);
            [self release];
            return (nil);
        }

        if (scale && (scale[0] != 1.0f || scale[1] != 1.0f || scale[2] != 1.0f)) glmScale(glmModel, (scale[0] + scale[1] + scale[2]) / 3.0f);
        if (translation && (translation[0] != 0.0f || translation[1] != 0.0f || translation[2] != 0.0f)) glmTranslate(glmModel, translation);
        if (rotation && (rotation[0] != 0.0f)) glmRotate(glmModel, rotation[0]*DTOR, rotation[1], rotation[2], rotation[3]);
        glmCreateArrays(glmModel, GLM_SMOOTH | GLM_MATERIAL | GLM_TEXTURE);
        
        _drawable = TRUE;

    }
    return (self);
}

- (void) wasAddedToEnvironment:(VirtualEnvironment *)environment
{
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(draw:) name:ARViewDrawPreCameraNotification object:environment.arViewController.glView];
    
    [super wasAddedToEnvironment:environment];
}

- (void) willBeRemovedFromEnvironment:(VirtualEnvironment *)environment
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:ARViewDrawPreCameraNotification object:environment.arViewController.glView];
    
    [super willBeRemovedFromEnvironment:environment];
}

- (BOOL) isEqual: (float)a toNumber: (float)b
{
    if(fabsf(a-b)<0.00001f) return YES;
    else return NO;
    
}

-(void) draw:(NSNotification *)notification
{
    // Lighting setup.
    // Ultimately, this should be cached via the app-wide OpenGL state cache.
    int activeLights = 0;
    GLfloat lightPositions[7][4] = {{0}};
    const GLfloat lightWhite100[]        =    {1.00, 1.00, 1.00, 1.0};    // RGBA all on full.
    const GLfloat lightWhite75[]        =    {0.75, 0.75, 0.75, 1.0};    // RGBA all on three quarters.
    
    
    for(int i = 0; i<7;++i)
    {
        for(int j = 0;j<4;++j)
        {
            lightPositions[i][j] = [[[lightValues objectAtIndex:i] objectAtIndex:j] floatValue];
        }
        
        if([self isEqual:lightPositions[i][0] toNumber:0.0f] && [self isEqual:lightPositions[i][1] toNumber:0.0f] && [self isEqual:lightPositions[i][2] toNumber:0.0f])
        {
            
            break;
        }
        activeLights++;
    }
    
    /*
    const GLfloat lightPosition0[]     =    {[[[lightValues objectAtIndex:0] objectAtIndex:0] floatValue],
        [[[lightValues objectAtIndex:0] objectAtIndex:1] floatValue],
        [[[lightValues objectAtIndex:0] objectAtIndex:2] floatValue],
        [[[lightValues objectAtIndex:0] objectAtIndex:3] floatValue]}; // A directional light (i.e. non positional).
    
    const GLfloat lightPosition1[]     =    {[[[lightValues objectAtIndex:1] objectAtIndex:0] floatValue],
        [[[lightValues objectAtIndex:1] objectAtIndex:1] floatValue],
        [[[lightValues objectAtIndex:1] objectAtIndex:2] floatValue],
        [[[lightValues objectAtIndex:1] objectAtIndex:3] floatValue]};
    const GLfloat lightPosition2[]     =    {[[[lightValues objectAtIndex:2] objectAtIndex:0] floatValue],
        [[[lightValues objectAtIndex:2] objectAtIndex:1] floatValue],
        [[[lightValues objectAtIndex:2] objectAtIndex:2] floatValue],
        [[[lightValues objectAtIndex:2] objectAtIndex:3] floatValue]};
    const GLfloat lightPosition3[]     =    {1.0f, 1.0f, 2.0f, 0.0f};
    const GLfloat lightPosition4[]     =    {1.0f, 1.0f, 2.0f, 0.0f};
    const GLfloat lightPosition5[]     =    {1.0f, 1.0f, 2.0f, 0.0f};
    const GLfloat lightPosition6[]     =    {1.0f, 1.0f, 2.0f, 0.0f};
    const GLfloat lightPosition7[]     =    {1.0f, 1.0f, 2.0f, 0.0f};*/
    
    
    if (_visible) {
        glPushMatrix();
        glMultMatrixf(_poseInEyeSpace.T);
        glMultMatrixf(_localPose.T);
        if (_lit) {
            
            for(int l=0;l<activeLights;++l)
            {
                glLightfv(GL_LIGHT0+l, GL_DIFFUSE, lightWhite100);
                glLightfv(GL_LIGHT0+l, GL_SPECULAR, lightWhite100);
                glLightfv(GL_LIGHT0+l, GL_AMBIENT, lightWhite75);            // Default ambient = {0,0,0,0}.
                glLightfv(GL_LIGHT0+l, GL_POSITION, lightPositions[l]);
                glEnable(GL_LIGHT0+l);
                
            }
            /*
            glLightfv(GL_LIGHT0, GL_DIFFUSE, lightWhite100);
            glLightfv(GL_LIGHT0, GL_SPECULAR, lightWhite100);
            glLightfv(GL_LIGHT0, GL_AMBIENT, lightWhite75);            // Default ambient = {0,0,0,0}.
            glLightfv(GL_LIGHT0, GL_POSITION, lightPositions[0]);
            glEnable(GL_LIGHT0);
             */
            for(int nl = 7; nl >= 7-activeLights;--nl)
            {
                glDisable(GL_LIGHT0+nl);

                
            }
            glShadeModel(GL_SMOOTH);                // Do not flat shade polygons.
            [self setupEnvMap];
            glStateCacheEnableLighting();
        } else glStateCacheDisableLighting();
        glmDrawArrays(glmModel, 0);
        glPopMatrix();
        
    }
}

-(void) dealloc
{
    glmDelete(glmModel, 0); // Does an implicit glmDeleteArrays();

    [super dealloc];
}

@end
