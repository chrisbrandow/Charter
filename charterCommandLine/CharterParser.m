//
//  CharterParser.m
//  charterCommandLine
//
//  Created by Christopher Brandow on 8/19/14.
//  Copyright (c) 2014 Flouu. All rights reserved.
//

#import "CharterParser.h"
#import "svgObjects.h"

@implementation CharterParser

+ (NSString *)stringWithString:(NSString *)inputString {
    


    NSString *outputString = inputString;
    
    NSError *error = nil;
    NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:@"!\\{([^\\}]*)\\}\\s*?\\{([^\\}]*)\\}" options:NSRegularExpressionDotMatchesLineSeparators error:&error];
    
    if (regex && !error){

    
    
        NSArray *matches = [regex matchesInString:outputString
                                      options:0
                                        range:NSMakeRange(0, [outputString length])];
        NSLog(@"match count %zd", matches.count);
        
        outputString = [self getSVGForMatches:matches inString:outputString];
    }
    return outputString;
    
}

+ (NSString *)getSVGForMatches:(NSArray *)matches inString:(NSString *)inputString {
    
    NSString *outputString = [NSString stringWithString:inputString];
    
    for (int i = (int)matches.count - 1; i >= 0; i--) {
        NSTextCheckingResult *match = matches[i];

        NSRange matchRange = [match range];
    
        NSRange firstHalfRange = [match rangeAtIndex:1];
        NSRange secondHalfRange = [match rangeAtIndex:2];
        
        NSString *firstBlockString = [inputString substringWithRange:firstHalfRange];
        NSString *secondBlockString = [inputString substringWithRange:secondHalfRange];
        
        NSLog(@"first Block: %@", firstBlockString);
        NSLog(@"second Block: %@", secondBlockString);
        
        NSDictionary *firstBlockParameters = [self parametersFromFirstBlock:firstBlockString];// = [self parametersFromFirstBlock] //fill with a method/function using string from firsthalfrange
        NSDictionary *secondBlockParameters = [self parametersFromSecondBlock:secondBlockString];
        
        NSString *SVGForPlot = [self SVGFromFirstBlockParameters:firstBlockParameters andSecondBlockParameters:secondBlockParameters];
        NSLog(@"sVGSDDADFS %@", SVGForPlot);
        NSLog(@"first params: %@", firstBlockParameters);
        NSLog(@"second params: %@", secondBlockParameters);
        outputString = [outputString stringByReplacingCharactersInRange:matchRange withString:@"*graph goes here*"]; //fill with a method using both dictionaries
        
    }
    
    return outputString;
    
}

+ (NSDictionary *)parametersFromFirstBlock:(NSString *)firstBlock {
    
    NSMutableDictionary *firstBlockComponents = [NSMutableDictionary new];
    
    [firstBlock enumerateLinesUsingBlock:^(NSString *line, BOOL *stop) {

        NSError *error = nil;
        NSUInteger columnHeaderCount = NSNotFound;

        //this needs to accomadate other " mark types
        NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:@"[“\"”](.+?)[“\"”]" options:NSRegularExpressionDotMatchesLineSeparators error:&error];


        if (regex && !error){
            columnHeaderCount = [regex numberOfMatchesInString:line options:0 range:NSMakeRange(0, line.length)];
            NSRange titleRange = [regex rangeOfFirstMatchInString:line options:0 range:NSMakeRange(0, line.length)];

            if (columnHeaderCount) {
                //                NSLog(@"ch count: %zd", columnHeaderCount);
                NSString *title = [line substringWithRange:titleRange];
                title = [title substringFromIndex:1];
                title = [title substringToIndex:title.length-1];
                firstBlockComponents[@"title"] =  title;// [regex stringByReplacingMatchesInString:line options:0 range:NSMakeRange(0, line.length) withTemplate:@"$1"]; //
            }
            
        }
    }];

    return firstBlockComponents;

}

+ (NSDictionary *)parametersFromSecondBlock:(NSString *)secondBlockText {

    NSMutableDictionary *secondBlockComponents = [NSMutableDictionary new];

    NSMutableCharacterSet *skippedCharacters = [NSMutableCharacterSet punctuationCharacterSet];
    [skippedCharacters formUnionWithCharacterSet:[NSCharacterSet whitespaceCharacterSet]];

    //regex for "title lines"
    //regex for min-max lines
    //scan for data

    __block CGFloat xMax = -CGFLOAT_MAX;
    __block CGFloat yMax = -CGFLOAT_MAX;
    __block CGFloat xMin = CGFLOAT_MAX;
    __block CGFloat yMin = CGFLOAT_MAX;


    NSMutableArray *points = [NSMutableArray new];
    NSMutableArray *columnHeaders = [NSMutableArray new];
    NSMutableArray *axisParameters = [NSMutableArray new];

    [secondBlockText enumerateLinesUsingBlock:^(NSString *line, BOOL *stop) {
        NSScanner *scanner = [NSScanner scannerWithString:line];

        NSError *error = nil;
        NSUInteger columnHeaderCount = NSNotFound;
        NSUInteger minMaxCount = NSNotFound;

        //this needs to accomadate other " mark types
        NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:@"[“\"”].+?[“\"”]" options:NSRegularExpressionDotMatchesLineSeparators error:&error];


        if (regex && !error){
            columnHeaderCount = [regex numberOfMatchesInString:line options:0 range:NSMakeRange(0, line.length)];
            if (columnHeaderCount) {
                //                NSLog(@"ch count: %zd", columnHeaderCount);
            }

        }

        //        NSLog(@"colunh count: %zd", columnHeaderCount);


        regex = [NSRegularExpression regularExpressionWithPattern:@"\\d*\\.?\\d*->\\d*\\.?\\d*" options:0 error:&error];

        if (regex && !error){
            minMaxCount = [regex numberOfMatchesInString:line options:0 range:NSMakeRange(0, line.length)];
            if (minMaxCount) {
                               NSLog(@"mm count %zd", minMaxCount);
            }
        }

        if (columnHeaderCount) {
            [columnHeaders addObject:line];
                        NSLog(@"ch non-data line: %@", line);

        } else if (minMaxCount){
            [axisParameters addObject:line];
                        NSLog(@"minimax line: %@", line);

        } else {
            double x, y;

            BOOL bx, by;
            bx = [scanner scanDouble:&x];
            by = [scanner scanDouble:&y];

            if (bx && by) {
                xMax = (x > xMax)?x:xMax;
                yMax = (y > yMax)?y:yMax;
                xMin = (x < xMin)?x:xMin;
                yMin = (y < yMin)?y:yMin;

                CGPoint point = CGPointMake(x, y);

                [points addObject:[NSValue valueWithPoint:point]];

            } else {
                //                NSLog(@"didn't parse: %@", line);

            }

        }

    }];


    secondBlockComponents[@"xMin"] = @(xMin);
    secondBlockComponents[@"xMax"] = @(xMax);
    secondBlockComponents[@"yMin"] = @(yMin);
    secondBlockComponents[@"yMax"] = @(yMax);
    secondBlockComponents[@"data"] = points;

    //    NSLog(@"second block: %@", secondBlockComponents);

    return [secondBlockComponents copy];
}

+ (NSString *)SVGFromFirstBlockParameters:(NSDictionary *)firstBlockParameters andSecondBlockParameters:(NSDictionary *)secondBlockParameters {
    
    NSArray *points = secondBlockParameters[@"data"];
    
    NSString *svg = [svgObjects pointAtPoint:[points.firstObject pointValue]];
    return svg;
}
@end


//From Working app
//
//#import "CBFViewController.h"
//#import "CBFParser.h"
//@interface CBFViewController () <UITextViewDelegate>
//
//@end
//
//@implementation CBFViewController
//
//- (void)viewDidLoad {
//    [super viewDidLoad];
//    //    self.inputTextView.text = @"!{test\n}{\n1.1\n2.3 34";
//	// Do any additional setup after loading the view, typically from a nib.
//    NSLog(@"%@", [CBFParser SVGFromText:self.inputTextView.text]);
//}
//
//- (void)didReceiveMemoryWarning {
//    [super didReceiveMemoryWarning];
//    // Dispose of any resources that can be recreated.
//}
//
//- (IBAction)makePlotAction:(id)sender {
//    
//    //get components from the textView:
//    NSDictionary *firstBlockComponents = [self parseFirstBlock:[[self componentsOfMatchingSyntax] objectAtIndex:0]];
//    NSDictionary *secondBlockComponents = [self parseSecondBlock:[[self componentsOfMatchingSyntax] objectAtIndex:1]];
//    
//    NSArray *plotInfo = @[firstBlockComponents,secondBlockComponents];
//    //need first block component still
//    
//    //convert components into scaled values
//    //construct the svg syntax from these values
//    [self.plotWebView loadHTMLString:[self constructSVGStringFromComponents:plotInfo] baseURL:nil];
//}
//
//- (NSDictionary *)parseFirstBlock:(NSString *)firstBlockText {
//    
//    NSMutableDictionary *firstBlockComponents = [NSMutableDictionary new];
//    
//    [firstBlockText enumerateLinesUsingBlock:^(NSString *line, BOOL *stop) {
//        
//        NSError *error = nil;
//        NSUInteger columnHeaderCount = NSNotFound;
//        
//        //this needs to accomadate other " mark types
//        NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:@"[“\"”](.+?)[“\"”]" options:NSRegularExpressionDotMatchesLineSeparators error:&error];
//        
//        
//        if (regex && !error){
//            columnHeaderCount = [regex numberOfMatchesInString:line options:0 range:NSMakeRange(0, line.length)];
//            NSRange titleRange = [regex rangeOfFirstMatchInString:line options:0 range:NSMakeRange(0, line.length)];
//            
//            if (columnHeaderCount) {
//                //                NSLog(@"ch count: %zd", columnHeaderCount);
//                NSString *title = [line substringWithRange:titleRange];
//                title = [title substringFromIndex:1];
//                title = [title substringToIndex:title.length-1];
//                firstBlockComponents[@"title"] =  title;// [regex stringByReplacingMatchesInString:line options:0 range:NSMakeRange(0, line.length) withTemplate:@"$1"]; //
//            }
//            
//        }
//    }];
//    
//    return firstBlockComponents;
//    
//}
//
//- (NSDictionary *)parseSecondBlock:(NSString *)secondBlockText {
//    
//    NSMutableDictionary *secondBlockComponents = [NSMutableDictionary new];
//    
//    NSMutableCharacterSet *skippedCharacters = [NSMutableCharacterSet punctuationCharacterSet];
//    [skippedCharacters formUnionWithCharacterSet:[NSCharacterSet whitespaceCharacterSet]];
//    
//    //regex for "title lines"
//    //regex for min-max lines
//    //scan for data
//    
//    __block CGFloat xMax = -CGFLOAT_MAX;
//    __block CGFloat yMax = -CGFLOAT_MAX;
//    __block CGFloat xMin = CGFLOAT_MAX;
//    __block CGFloat yMin = CGFLOAT_MAX;
//    
//    
//    NSMutableArray *points = [NSMutableArray new];
//    NSMutableArray *columnHeaders = [NSMutableArray new];
//    NSMutableArray *axisParameters = [NSMutableArray new];
//    
//    [secondBlockText enumerateLinesUsingBlock:^(NSString *line, BOOL *stop) {
//        NSScanner *scanner = [NSScanner scannerWithString:line];
//        
//        NSError *error = nil;
//        NSUInteger columnHeaderCount = NSNotFound;
//        NSUInteger minMaxCount = NSNotFound;
//        
//        //this needs to accomadate other " mark types
//        NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:@"[“\"”].+?[“\"”]" options:NSRegularExpressionDotMatchesLineSeparators error:&error];
//        
//        
//        if (regex && !error){
//            columnHeaderCount = [regex numberOfMatchesInString:line options:0 range:NSMakeRange(0, line.length)];
//            if (columnHeaderCount) {
//                //                NSLog(@"ch count: %zd", columnHeaderCount);
//            }
//            
//        }
//        
//        //        NSLog(@"colunh count: %zd", columnHeaderCount);
//        
//        
//        regex = [NSRegularExpression regularExpressionWithPattern:@"\\d*\\.?\\d*->\\d*\\.?\\d*" options:0 error:&error];
//        
//        if (regex && !error){
//            minMaxCount = [regex numberOfMatchesInString:line options:0 range:NSMakeRange(0, line.length)];
//            if (minMaxCount) {
//                //                NSLog(@"mm count %zd", minMaxCount);
//            }
//        }
//        
//        if (columnHeaderCount) {
//            [columnHeaders addObject:line];
//            //            NSLog(@"ch non-data line: %@", line);
//            
//        } else if (minMaxCount){
//            [axisParameters addObject:line];
//            //            NSLog(@"minimax line: %@", line);
//            
//        } else {
//            double x, y;
//            
//            BOOL bx, by;
//            bx = [scanner scanDouble:&x];
//            by = [scanner scanDouble:&y];
//            
//            if (bx && by) {
//                xMax = (x > xMax)?x:xMax;
//                yMax = (y > yMax)?y:yMax;
//                xMin = (x < xMin)?x:xMin;
//                yMin = (y < yMin)?y:yMin;
//                
//                CGPoint point = CGPointMake(x, y);
//                
//                [points addObject:[NSValue valueWithCGPoint:point]];
//                
//            } else {
//                //                NSLog(@"didn't parse: %@", line);
//                
//            }
//            
//        }
//        
//    }];
//    
//    
//    secondBlockComponents[@"xMin"] = @(xMin);
//    secondBlockComponents[@"xMax"] = @(xMax);
//    secondBlockComponents[@"yMin"] = @(yMin);
//    secondBlockComponents[@"yMax"] = @(yMax);
//    secondBlockComponents[@"data"] = points;
//    
//    //    NSLog(@"second block: %@", secondBlockComponents);
//    
//    return [secondBlockComponents copy];
//}
//
//- (NSString *)constructSVGStringFromComponents:(NSArray *)Components {
//    
//    NSDictionary *firstBlock = Components[0];
//    NSDictionary *secondBlock = Components[1];
//    //    NSLog(@"title: %@", firstBlock[@"title"]);
//    //    NSLog(@"data: %@", secondBlock[@"data"]);
//    
//    CGFloat xMax, xMin, yMax, yMin;
//    xMax = [secondBlock[@"xMax"] floatValue];
//    xMin = [secondBlock[@"xMin"] floatValue];
//    yMax = [secondBlock[@"yMax"] floatValue];
//    yMin = [secondBlock[@"yMin"] floatValue];
//    
//    NSMutableArray *scaledValues = [NSMutableArray new];
//    CGFloat insetPercentage = .05;
//    
//    for (int i = 0; i < [secondBlock[@"data"] count]; i++) {
//        NSValue *v = secondBlock[@"data"][i];
//        
//        //        NSLog(@"x: %.3f y: %.3f",2*insetPercentage*(([v CGPointValue].x -xMin)/(xMax - xMin))+insetPercentage, (yMax - [v CGPointValue].y)/(yMax - yMin));
//        
//        CGPoint plotPoint = CGPointMake((1-2*insetPercentage)*(([v CGPointValue].x -xMin)/(xMax - xMin))+insetPercentage, (1-2*insetPercentage)*(yMax - [v CGPointValue].y)/(yMax - yMin)+insetPercentage);
//        [scaledValues addObject:[NSValue valueWithCGPoint:plotPoint]];
//    }
//    CGFloat xDim = 300;
//    CGFloat yDim = 200;
//    
//    NSString *SVGString = [NSString stringWithFormat:@"<html><body>Hello, how are you doing, here is a graph of interest: ", xDim, yDim];
//    
//    if (firstBlock[@"title"]) {
//        SVGString = [SVGString stringByAppendingString:[NSString stringWithFormat:@"\n<text x=\"25%%\" y=\"10%%\" font-size=\"14\" fill=\"black\" style=\"stroke:transparent\" >%@</text>", firstBlock[@"title"]]];
//    }
//    for (int i = 0; i < [secondBlock[@"data"] count]; i++) {
//        
//        SVGString = [SVGString stringByAppendingString:[NSString stringWithFormat:@"<circle cx=\"%.0f%%\" cy=\"%.0f%%\" r=\"4\" />", 100*[scaledValues[i] CGPointValue].x, 100*[scaledValues[i] CGPointValue].y]];
//        //        SVGString = [SVGString stringByAppendingString:[NSString stringWithFormat:@"<circle cx=\"5%%\" cy=\"92%%\" r=\"4\" />", 100*[scaledValues[i] CGPointValue].x, 100*[scaledValues[i] CGPointValue].y]];
//        
//    }
//    //
//    //    <line x1=\"3%\" y1=\"95%\" x2=\"100%\" y2=\"95%\" />
//    //    <line x1=\"3%\" y1=\"0%\" x2=\"3%\" y2=\"95%\"  />
//    //    <text x=\"5%\" y=\"99%\" font-size=\"14\" style=\"stroke:transparent\" >1</text>
//    //    <text x=\"95%\" y=\"99%\" font-size=\"14\" style=\"stroke:transparent\" >7</text>
//    //    <text x=\"1%\" y=\"95%\" font-size=\"14\" style=\"stroke:transparent\" >2</text>
//    //    <text x=\"1%\" y=\"5%\" font-size=\"14\" style=\"stroke:transparent\" >8</text>
//    SVGString = [SVGString stringByAppendingString:@"<svg fill=\"black\">"];
//    SVGString = [SVGString stringByAppendingString:[NSString stringWithFormat:@"<text x=\"5%%\" y=\"100%%\" font-size=\"%.0f\" style=\"stroke:transparent\" >%.1f</text>", yDim*.05, xMin]];
//    SVGString = [SVGString stringByAppendingString:[NSString stringWithFormat:@"<text x=\"95%%\" y=\"100%%\" font-size=\"%.0f\" style=\"stroke:transparent\" >%.1f</text>", yDim*.05, xMax]];
//    SVGString = [SVGString stringByAppendingString:[NSString stringWithFormat:@"<text x=\"1%%\" y=\"95%%\" font-size=\"11\" style=\"stroke:transparent\" >%.1f</text>", yMin]];
//    SVGString = [SVGString stringByAppendingString:[NSString stringWithFormat:@"<text x=\"1%%\" y=\"5%%\" font-size=\"11\" style=\"stroke:transparent\" >%.1f</text>", yMax]];
//    SVGString = [SVGString stringByAppendingString:[NSString stringWithFormat:@"<text x=\"50%%\" y=\"100%%\" font-size=\"11\" style=\"stroke:transparent\" >%@</text>", @"Time"]];
//    SVGString = [SVGString stringByAppendingString:[NSString stringWithFormat:@"<text x=\"1%%\" y=\"50%%\" font-size=\"11\" transform=\"rotate(270,3,80)\" style=\"stroke:transparent\" >%@</text>", @"Velocity"]];
//    
//    SVGString = [SVGString stringByAppendingString:@"<svg stroke=\"black\">"];
//    SVGString = [SVGString stringByAppendingString:@"<line x1=\"3%\" y1=\"0%\" x2=\"3%\" y2=\"95%\"  /><line x1=\"3%\" y1=\"95%\" x2=\"100%\" y2=\"95%\" /></svg></body></html>"];
//    //    NSLog(@"svgstring %@", SVGString);
//    
//    
//    //    NSLog(@"%@", testSVGString);
//    //createSVGHeader
//    //setDimensions
//    //setColors
//    //addTitle
//    //setType
//    //setAxesScale
//    //addPoints
//    //setAxesLabels
//    
//    //    <circle cx=\"80%\" cy=\"26%\" r=\"4\" />
//    //    <circle cx=\"95%\" cy=\"5%\" r=\"4\" />
//    //    <svg stroke=\"black\" fill=\"black\">
//    //    <line x1=\"3%\" y1=\"95%\" x2=\"100%\" y2=\"95%\" />
//    //    <line x1=\"3%\" y1=\"0%\" x2=\"3%\" y2=\"95%\"  />
//    //    <text x=\"5%\" y=\"99%\" font-size=\"14\" style=\"stroke:transparent\" >1</text>
//    //    <text x=\"95%\" y=\"99%\" font-size=\"14\" style=\"stroke:transparent\" >7</text>
//    //    <text x=\"1%\" y=\"95%\" font-size=\"14\" style=\"stroke:transparent\" >2</text>
//    //    <text x=\"1%\" y=\"5%\" font-size=\"14\" style=\"stroke:transparent\" >8</text>
//    //    <svg stroke=\"black\" fill=\"black\" />
//    //    <text x=\"10\" y=\"200\" font-size=\"14\" fill=\"black\" style=\"stroke:transparent\"";
//    //    <svg />
//    return SVGString;
//}
//
//- (NSArray *)componentsOfMatchingSyntax {
//    
//    NSMutableArray *componentsOfPlotSyntax = [[NSMutableArray alloc] init];
//    NSString *testString = self.inputTextView.text;
//    
//    NSError *error = nil;
//    NSUInteger matchCount = NSNotFound;
//    NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:@"^?[^!]+(!\\{?[^\\{]+\\}\\s?)(\\{?[^\\{\\}]+\\})" options:NSRegularExpressionAnchorsMatchLines error:&error];
//    if (regex && !error){
//        matchCount = [regex numberOfMatchesInString:testString options:0 range:NSMakeRange(0, testString.length)];
//        
//        [componentsOfPlotSyntax addObject:[regex stringByReplacingMatchesInString:testString options:0 range:NSMakeRange(0, testString.length) withTemplate:@"$1"]];
//        [componentsOfPlotSyntax addObject:[regex stringByReplacingMatchesInString:testString options:0 range:NSMakeRange(0, testString.length) withTemplate:@"$2"]];
//    }
//    
//    return [componentsOfPlotSyntax copy];
//}
//
//-(void)textViewDidEndEditing:(UITextView *)textView {
//    
//    [self makePlotAction:nil];
//}
//
//
//
//
//#import "CBFParser.h"
//
//static NSArray *textBlocks(NSString *allText) {
//    //could make this recursive and return an array
//    
//    NSMutableArray *componentsOfPlotSyntax = [[NSMutableArray alloc] init];
//    NSString *testString = allText;
//    
//    NSError *error = nil;
//    NSUInteger matchCount = NSNotFound;
//    NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:@"^?[^!]+(!\\{?[^\\{]+\\}\\s?)(\\{?[^\\{\\}]+\\})" options:NSRegularExpressionAnchorsMatchLines error:&error];
//    if (regex && !error) {
//        
//        matchCount = [regex numberOfMatchesInString:testString options:0 range:NSMakeRange(0, testString.length)];
//        
//        [componentsOfPlotSyntax addObject:[regex stringByReplacingMatchesInString:testString options:0 range:NSMakeRange(0, testString.length) withTemplate:@"$1"]];
//        [componentsOfPlotSyntax addObject:[regex stringByReplacingMatchesInString:testString options:0 range:NSMakeRange(0, testString.length) withTemplate:@"$2"]];
//        
//    }
//    return [NSArray arrayWithArray:componentsOfPlotSyntax];
//}
//
//static NSDictionary *parametersFromFirstString(NSString *firstString) {
//    return @{@"title":@"A Title"};
//}
//
//static NSDictionary *parametersFromSecondString(NSString *secondString) {
//    return @{@"width":@(600)};
//}
//
//static NSString *SVGFromParameterBlocks(NSDictionary *first, NSDictionary *second, NSDictionary *third) {
//    return @"SVG text";
//}
//
//@implementation CBFParser
//
//+ (NSString *)SVGFromText:(NSString *)chartDownText {
//    
//    NSArray *blocks = textBlocks(chartDownText);
//    
//    NSString *firstBlockString = blocks[0];
//    NSString *secondBlockString = blocks[1];
//    
//    NSLog(@"first functional block: %@", firstBlockString);
//    NSLog(@"second functional block: %@", secondBlockString);
//    
//    NSDictionary *firstBlockParameters = parametersFromFirstString(firstBlockString);
//    NSDictionary *secondBlockParameters = parametersFromSecondString(secondBlockString);
//    
//    
//    NSString *SVGText = SVGFromParameterBlocks(firstBlockParameters, secondBlockParameters, nil);
//    
//    return SVGText;
//}
//
//@end

