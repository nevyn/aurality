//
//  AuralityAppDelegate.m
//  Aurality
//
//  Created by Joachim Bengtsson on 2009-04-15.
//  Copyright Third Cog Software 2009. All rights reserved.
//

#import "AuralityAppDelegate.h"

@implementation AuralityAppDelegate

@synthesize window;


- (void)applicationDidFinishLaunching:(UIApplication *)application {    

    // Override point for customization after application launch
    [window makeKeyAndVisible];
	
	gameC = [[AuralityGameController alloc] init];
	[window addSubview:gameC.view];
}


- (void)dealloc {
    [window release];
    [super dealloc];
}


@end
