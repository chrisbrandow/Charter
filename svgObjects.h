//
//  svgObjects.h
//  charterCommandLine
//
//  Created by Christopher Brandow on 8/29/14.
//  Copyright (c) 2014 Flouu. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface svgObjects : NSObject

+ (NSString *)pointAtPoint:(NSPoint)p;
+ (NSString *)beginSVGCanvas:(NSSize)size;
+ (NSString *)svgPointFromPoint:(NSPoint)point minPoint:(NSPoint)minPoint andMaxPoint:(NSPoint)maxPoint;

@end
