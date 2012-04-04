//
//  BIDViewController.h
//  FBPhotoPost
//
//  Created by Yu-Jen Lin on 4/2/12.
//  Copyright (c) 2012 home. All rights reserved.
//
#import "FBConnect.h"
#import "BIDAppDelegate.h"
#import <CoreLocation/CoreLocation.h>
#import <UIKit/UIKit.h>

typedef enum apiCall {
    kAPILogout,
    kAPIGraphUserPermissionsDelete,
    kDialogPermissionsExtended,
    kDialogRequestsSendToMany,
    kAPIGetAppUsersFriendsNotUsing,
    kAPIGetAppUsersFriendsUsing,
    kAPIFriendsForDialogRequests,
    kDialogRequestsSendToSelect,
    kAPIFriendsForTargetDialogRequests,
    kDialogRequestsSendToTarget,
    kDialogFeedUser,
    kAPIFriendsForDialogFeed,
    kDialogFeedFriend,
    kAPIGraphUserPermissions,
    kAPIGraphMe,
    kAPIGraphUserFriends,
    kDialogPermissionsCheckin,
    kDialogPermissionsCheckinForRecent,
    kDialogPermissionsCheckinForPlaces,
    kAPIGraphPhotoData,
    kAPIGraphSearchPlace,
    kAPIGraphUserCheckins,
    kAPIGraphUserPhotosPost,
    kAPIGraphUserVideosPost,
} apiCall;

@class BIDAppDelegate;

@interface BIDViewController : UIViewController<FBRequestDelegate,FBDialogDelegate, UIImagePickerControllerDelegate,CLLocationManagerDelegate>
{
    int currentAPICall;
}
@property (weak, nonatomic) IBOutlet UIImageView *imagePreview;
@property (retain,nonatomic) CLLocationManager *locationManager;
@property (retain, nonatomic) NSString *latLocation;
@property (retain, nonatomic) NSString *longLocation;
@property (retain, nonatomic) UIImage *tempImage;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *logoutBtn;
@property (nonatomic) BOOL loginFlag;
@property (weak, nonatomic) IBOutlet UILabel *statusLabel;
- (UIImage*)imageWithImage:(UIImage*)sourceImage;
- (void) postImageToFacebook;
@end
