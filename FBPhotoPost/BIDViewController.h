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
    kAPIGraphUserPhotosPost
} apiCall;

@class BIDAppDelegate;

@interface BIDViewController : UIViewController<FBRequestDelegate,FBDialogDelegate, UIImagePickerControllerDelegate,UINavigationControllerDelegate,CLLocationManagerDelegate>
{
    int currentAPICall;
}

//Location Manager and Variable
@property (retain,nonatomic) CLLocationManager *locationManager;
@property (retain, nonatomic) NSString *latLocation;
@property (retain, nonatomic) NSString *longLocation;

//UI
@property (weak, nonatomic) IBOutlet UIImageView *imagePreview;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *logoutBtn;
@property (weak, nonatomic) IBOutlet UILabel *statusLabel;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *cameraBtn;

//Temp Image
@property (retain, nonatomic) UIImage *tempImage;

//Flag
@property (nonatomic) BOOL uploadFlag;


//Check Facebook Login Status and Update the Labels
- (BOOL) fbCheckLoginStatus;

//New thread for UI updating
- (void) UIUpdateThread;

//Rotate the image based on the camera orientation (FB did not support the orientation)
- (UIImage*)imageWithImage:(UIImage*)sourceImage;

//
- (void) postImageToFacebook;



@end
