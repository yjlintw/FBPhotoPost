//
//  BIDAppDelegate.h
//  FBPhotoPost
//
//  Created by Yu-Jen Lin on 4/2/12.
//  Copyright (c) 2012 home. All rights reserved.
//

#import "FBConnect.h"
#import <UIKit/UIKit.h>
//test commit
@interface BIDAppDelegate : UIResponder <UIApplicationDelegate, FBSessionDelegate>

@property (strong, nonatomic) UIWindow *window;
@property (retain, nonatomic) Facebook *facebook;

- (void)fbLogIn;
@end
