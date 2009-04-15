//
//  AuralityAppDelegate.h
//  Aurality
//
//  Created by Joachim Bengtsson on 2009-04-15.
//  Copyright Third Cog Software 2009. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AuralityGameController.h"
@interface AuralityAppDelegate : NSObject <UIApplicationDelegate> {
    UIWindow *window;
	AuralityGameController *gameC;
}

@property (nonatomic, retain) IBOutlet UIWindow *window;

@end

