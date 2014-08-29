//
//  main.m
//  charterCommandLine
//
//  Created by Christopher Brandow on 8/19/14.
//  Copyright (c) 2014 Flouu. All rights reserved.
//
//  Testfile: /Users/Chris/Developer/Charter/TestFile.markdown

#import <Foundation/Foundation.h>
#import "CharterParser.h"

int main(int argc, const char * argv[])
{

    @autoreleasepool {
        
        // insert code here...
        
        if (argv[1]) {
            NSLog(@"includes an argument!");
            
            NSString *path = [NSString stringWithUTF8String:argv[1]];
            
            NSLog(@"Path: %@", path);
            
            NSError *error;
            NSString *fileStuff = [NSString stringWithContentsOfFile:path encoding:NSUTF8StringEncoding error:&error];
            
            
            NSLog(@"contents: %@", [CharterParser stringWithString:fileStuff]);

        } else {
            
            NSLog(@"No file was specified");
            
        }
        
        
    }
    return 0;
}

