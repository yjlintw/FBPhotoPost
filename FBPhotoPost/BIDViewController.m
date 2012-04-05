//
//  BIDViewController.m
//  FBPhotoPost
//
//  Created by Yu-Jen Lin on 4/2/12.
//  Copyright (c) 2012 home. All rights reserved.
//

#import "BIDViewController.h"

@implementation BIDViewController
@synthesize imagePreview;
@synthesize locationManager;
@synthesize latLocation;
@synthesize longLocation;
@synthesize tempImage;
@synthesize logoutBtn;
@synthesize statusLabel;
@synthesize cameraBtn;
@synthesize uploadFlag;
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - View lifecycle
- (void)viewDidLoad
{
    [super viewDidLoad];
    
    //Set notification to check Login Status
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(fbCheckLoginStatus) name:@"checkLoginStatus" object:nil];

    //Set imagePreview view/scale mode
    [self.imagePreview setContentMode:UIViewContentModeScaleAspectFill];
    [self.imagePreview setClipsToBounds:YES];
    
    //
    [self.statusLabel setText:@"Press 'Camera' to take Photos"];
    
    //Initialize Flag
    uploadFlag = NO;
    
    //Login Facebook
    BIDAppDelegate *appDelegate = (BIDAppDelegate *)[[UIApplication sharedApplication] delegate];
    [appDelegate fbLogIn];
    
    //set up the gps monitor
    self.locationManager = [[CLLocationManager alloc] init];
    self.locationManager.delegate = self;
    self.locationManager.distanceFilter = kCLDistanceFilterNone; // whenever we move
    self.locationManager.desiredAccuracy = kCLLocationAccuracyHundredMeters; // 100 m
    [self.locationManager startUpdatingLocation];
    // Do any additional setup after loading the view, typically from a nib.
}

- (void)viewDidUnload
{
    [self setImagePreview:nil];
    [self setLogoutBtn:nil];
    [self setStatusLabel:nil];
    [self setCameraBtn:nil];
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)canBecomeFirstResponder 
{
    return YES;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [self becomeFirstResponder];
}

- (void)viewWillDisappear:(BOOL)animated
{
	[super viewWillDisappear:animated];
}

- (void)viewDidDisappear:(BOOL)animated
{
	[super viewDidDisappear:animated];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation != UIInterfaceOrientationPortraitUpsideDown);
}

# pragma mark - Facebook Log in/out

//Check fbLogIn Status, and update UI
- (BOOL)fbCheckLoginStatus
{
    BIDAppDelegate *appDelegate = (BIDAppDelegate *)[[UIApplication sharedApplication] delegate];
    if ([[appDelegate facebook] isSessionValid])
        [self.logoutBtn setTitle:@"Log Out"];
    else
        [self.logoutBtn setTitle:@"Log In"];
    return [[appDelegate facebook] isSessionValid];
}


//Log In/Out Button Action
- (IBAction)logOutBtnPressed:(id)sender
{
    BIDAppDelegate *appDelegate = (BIDAppDelegate *)[[UIApplication sharedApplication] delegate];
    if ([[appDelegate facebook] isSessionValid])
    {
        [[appDelegate facebook] logout];
    }
    else
    {
        [appDelegate fbLogIn];
    }
    [self fbCheckLoginStatus];
    
}


#pragma mark - Facebook Posting
- (void) postImageToFacebook
{
    NSLog(@"postImageToFacebook");
    BIDAppDelegate *appDelegate = (BIDAppDelegate *)[[UIApplication sharedApplication] delegate];

    //get image from temp UIImage which captured from camera
    UIImage *img = [self imageWithImage:tempImage];
    
    //set APICall flag to photos post, used in request
    currentAPICall = kAPIGraphUserPhotosPost;
    
    //set image caption
    NSString *messageString = [NSString stringWithFormat:@"(Lat, Long): (%@, %@)", latLocation, longLocation];
    
    //set GraphAPI param
    NSMutableDictionary *params = [NSMutableDictionary dictionaryWithObjectsAndKeys:img, @"picture", messageString, @"caption",nil];

    //call GraphAPI, upload image to photo album
    [appDelegate.facebook requestWithGraphPath:@"me/photos" andParams:params andHttpMethod:@"POST" andDelegate:self];
}

// Respong to GraphAPI
- (void)request:(FBRequest *)request didLoad:(id)result 
{
    if ([result isKindOfClass:[NSArray class]] && ([result count] > 0)) 
    {
        result = [result objectAtIndex:0];
    }
    switch (currentAPICall) 
    {
        // Can Implement more different action in the future    
        case kAPIGraphUserPhotosPost:
        {
            uploadFlag = NO;
            [self.statusLabel setText:@"Successful Uploaded"];
            [self.cameraBtn setEnabled:YES];
            break;
        }
    }
}

#pragma mark - Image and Camera Picker
//Start the camera
- (IBAction)cameraBtnPressed:(id)sender
{
    // Create image picker controller
    UIImagePickerController *imagePicker = [[UIImagePickerController alloc] init];
    
    // Set source to the camera
    imagePicker.sourceType =  UIImagePickerControllerSourceTypeCamera;
    imagePicker.allowsEditing = NO;
    imagePicker.delegate = self;
    
    // Show image picker
    [self presentModalViewController:imagePicker animated:YES];
    
}

- (void) imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    [self dismissModalViewControllerAnimated:YES];
    
    //save image to (UIImage)tempImage from camera roll
    tempImage = [info objectForKey:UIImagePickerControllerOriginalImage];
    NSLog(@"pick");
    //update (UIImageView *)imagePreview
    [imagePreview setImage:tempImage];
    
    [self.statusLabel setText:@"Shake to Upload Photos"];
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
    //Do Nothing
    [self dismissModalViewControllerAnimated:YES];
    [imagePreview setImage:tempImage];
}

- (double) radians:(double)degrees
{
    return degrees * M_PI/180;
}

- (UIImage*)imageWithImage:(UIImage*)sourceImage
{
    CGSize imageSize = sourceImage.size;
    CGFloat targetWidth = imageSize.width;
    CGFloat targetHeight = imageSize.height;
    
    CGImageRef imageRef = [sourceImage CGImage];
    CGBitmapInfo bitmapInfo = CGImageGetBitmapInfo(imageRef);
    CGColorSpaceRef colorSpaceInfo = CGImageGetColorSpace(imageRef);
    
    if (bitmapInfo == kCGImageAlphaNone) 
    {
        bitmapInfo = kCGImageAlphaNoneSkipLast;
    }
    
    CGContextRef bitmap;
    
    bitmap = CGBitmapContextCreate(NULL, targetWidth, targetHeight, CGImageGetBitsPerComponent(imageRef), CGImageGetBytesPerRow(imageRef), colorSpaceInfo, bitmapInfo);
    
    // Rotate the Image Based on the imageOrientation
    if (sourceImage.imageOrientation == UIImageOrientationLeft) 
    {
        CGFloat oldScaledWidth = targetWidth;
        targetWidth = targetHeight;
        targetHeight = oldScaledWidth;
        
        CGContextRotateCTM (bitmap, [self radians:90]);
        CGContextTranslateCTM (bitmap, 0, -targetHeight);
        
    } 
    else if (sourceImage.imageOrientation == UIImageOrientationRight) 
    {
        CGFloat oldScaledWidth = targetWidth;
        targetWidth = targetHeight;
        targetHeight = oldScaledWidth;
        
        CGContextRotateCTM (bitmap, [self radians:-90]);
        CGContextTranslateCTM (bitmap, -targetWidth, 0);
        
    } 
    else if (sourceImage.imageOrientation == UIImageOrientationUp) 
    {
        // NOTHING
    } 
    else if (sourceImage.imageOrientation == UIImageOrientationDown) 
    {
        CGContextTranslateCTM (bitmap, targetWidth, targetHeight);
        CGContextRotateCTM (bitmap, [self radians:-180]);
    }
    
    CGContextDrawImage(bitmap, CGRectMake(0.0, 0.0, targetWidth, targetHeight), imageRef);
    CGImageRef ref = CGBitmapContextCreateImage(bitmap);
    UIImage* newImage = [UIImage imageWithCGImage:ref];
    return newImage; 
}


#pragma mark - Location Manager
//get location data
- (void)locationManager:(CLLocationManager *)manager didUpdateToLocation:(CLLocation *)newLocation fromLocation:(CLLocation *)oldLocation
{
    double degrees = newLocation.coordinate.latitude;
    latLocation = [NSString stringWithFormat:@"%.4f", degrees];
    degrees = newLocation.coordinate.longitude;
    longLocation = [NSString stringWithFormat:@"%.4f", degrees];
}



#pragma mark - Device Interaction
// Shake motion implement
- (void)motionEnded:(UIEventSubtype)motion withEvent:(UIEvent *)event
{
    if (event.type == UIEventSubtypeMotionShake) 
    {
        // your code here
        if (tempImage == nil)
        {
            [self.statusLabel setText:@"Please Take a Picture First"];
        }
        else if(![self fbCheckLoginStatus])
        {
            [self.statusLabel setText:@"Please Log In to Facebook First"];
        }
        else if(uploadFlag)
        {
            //Do nothing
        }
        else
        {
            uploadFlag = YES;
            [NSThread detachNewThreadSelector:@selector(UIUpdateThread) toTarget:self withObject:nil];
            [self postImageToFacebook];
        }
    }
}


#pragma mark - UI Updating Thread
- (void)UIUpdateThread
{
    @autoreleasepool 
    {
        [self.statusLabel setText:@"Start Uploading..."];
        [self.cameraBtn setEnabled:NO];
    }
}

@end
