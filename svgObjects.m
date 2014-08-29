//
//  svgObjects.m
//  charterCommandLine
//
//  Created by Christopher Brandow on 8/29/14.
//  Copyright (c) 2014 Flouu. All rights reserved.
//

#import "svgObjects.h"

@implementation svgObjects

+ (NSString *)pointAtPoint:(NSPoint)p {
    
        return [NSString stringWithFormat:@"<circle cx=\"%.0f%%\" cy=\"%.0f%%\" r=\"4\" />", p.x, p.y];

}
@end
