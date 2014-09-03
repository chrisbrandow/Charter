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
    
        return [NSString stringWithFormat:@"<circle cx=\"%.0f%%\" cy=\"%.0f%%\" r=\"4\" />", p.x, p.y] ;

}

+ (NSString *)rectCenteredAtPoint:(NSPoint)p withSize:(NSSize)size {
    
//    return [NSString stringWithFormat:@"<rect width=\"%.0f\" height=\"%.0f\" x=\"%.0f\" y=\"%.0f\" style=\"fill:rgb(0,0,255);stroke-width:3;stroke:rgb(0,0,0)\" />", size.width, size.height, p.x, p.y];
    return [NSString stringWithFormat:@"<rect width=\"%.0f%%\" height=\"%.0f%%\" x=\"%.0f%%\" y=\"%.0f%%\" style=\"fill:rgb(0,0,255);stroke-width:3;stroke:rgb(0,0,0)\" />", 0., 0., 50., 50.];
    
}

+ (NSString *)beginSVGCanvas:(NSSize)size {
    
    return [[NSString stringWithFormat:@"<svg width=\"%.0f\" height=\"%.0f\" fill=red>", size.width, size.height] stringByAppendingString:@"<rect width=\"100%\" height=\"100%\" style=\"fill:rgb(200,229,222);stroke-width:3;stroke:rgb(0,0,0)\" />"];
    
}

+ (NSString *)mainChartCanvasFromChartSize:(NSSize)size {
    
    CGFloat minDimension = MIN(size.width, size.height);
    CGFloat axisBorder = 0.1*minDimension;
    CGFloat titleBorder = axisBorder;
    NSLog(@"maxdimension: %.2f", minDimension);
    //<svg width="540" height="360" x="40" y="0" fill=red>
    return [[NSString stringWithFormat:@"<svg width=\"%.0f\" height=\"%.0f\" x=\"%.0f\" y=\"%.0f\" fill=green>", size.width - axisBorder, size.height-axisBorder-titleBorder, axisBorder, titleBorder] stringByAppendingString:@"<rect width=\"100%\" height=\"100%\" style=\"fill:rgb(200,129,222);stroke-width:3;stroke:rgb(0,0,0)\" />"];

}

+ (NSString *)svgPointFromPoint:(NSPoint)point minPoint:(NSPoint)minPoint andMaxPoint:(NSPoint)maxPoint {

    CGFloat margin = 5;
    CGFloat xPercentage = 90*(point.x - minPoint.x)/(maxPoint.x - minPoint.x) + 5;
    CGFloat yPercentage = 100 -( 90*(point.y - minPoint.y)/(maxPoint.y - minPoint.y) + 5);
    
    NSLog(@"minx: %.2f", minPoint.x);
    NSLog(@"miny: %.2f", minPoint.y);
    NSLog(@"manx: %.2f", maxPoint.x);
    NSLog(@"many: %.2f", maxPoint.y);
    NSLog(@"xpercent: %.2f", xPercentage);
    NSLog(@"ypercent: %.2f", yPercentage);
    
    return [NSString stringWithFormat:@"<circle cx=\"%.0f%%\" cy=\"%.0f%%\" r=\"4\" />", xPercentage, yPercentage];
}

@end
