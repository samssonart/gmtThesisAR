//
//  CVWrapper.h
//  Illuminati
//
//  Created by Samssonart on 5/2/17.
//  Copyright © 2017 Samssonart. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "stitching.h"

@interface CVWrapper : NSObject

+ (UIImage*) processWithArray:(NSArray*)imageArray;
+ (Mat)cvMatFromUIImage:(UIImage *)image;
+ (UIImage *)UIImageFromCVMat:(Mat)cvMat;


@end
