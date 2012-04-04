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
@synthesize loginFlag;
@synthesize statusLabel;
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - View lifecycle


- (void)viewDidLoad
{
    [super viewDidLoad];
    self.locationManager = [[CLLocationManager alloc] init];
    self.locationManager.delegate = self;
    self.locationManager.distanceFilter = kCLDistanceFilterNone; // whenever we move
    self.locationManager.desiredAccuracy = kCLLocationAccuracyHundredMeters; // 100 m
    self.loginFlag = YES;
    [self.locationManager startUpdatingLocation];
	// Do any additional setup after loading the view, typically from a nib.
}

- (void)viewDidUnload
{
    [self setImagePreview:nil];
    [self setLogoutBtn:nil];
    [self setStatusLabel:nil];
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

- (IBAction)logOutBtnPressed:(id)sender
{
    NSLog(@"pressed");
    BIDAppDelegate *appDelegate = (BIDAppDelegate *)[[UIApplication sharedApplication] delegate];
    if (loginFlag == YES)
    {
        [[appDelegate facebook] logout];
        loginFlag = NO;
        [logoutBtn setTitle:@"Log In"];
    }
    else
    {
        NSArray *permissions = [[NSArray alloc] initWithObjects: 
                                @"publish_stream",
                                nil];

        if (![[appDelegate facebook] isSessionValid]) 
        {
            [[appDelegate facebook] authorize:permissions];
        } 
        loginFlag = YES;
        [logoutBtn setTitle:@"Log Out"];
    }
}

- (void) postImageToFacebook
{
    BIDAppDelegate *appDelegate = (BIDAppDelegate *)[[UIApplication sharedApplication] delegate];
    //NSString *path = @"http://www.facebook.com/images/devsite/iphone_connect_btn.jpg";
    //NSURL *url = [NSURL URLWithString:path];
    //NSData *data = [NSData dataWithContentsOfURL:url];
    UIImage *img = [self imageWithImage:tempImage];
    //NSLog(@"orientation: %@", imagePreview.image.imageOrientation);

    currentAPICall = kAPIGraphUserPhotosPost;
    NSString *messageString = [NSString stringWithFormat:@"Lat: %@, Long: %@", latLocation, longLocation];

    NSMutableDictionary *params = [NSMutableDictionary dictionaryWithObjectsAndKeys:img, @"picture", messageString, @"caption",nil];
    [appDelegate.facebook requestWithGraphPath:@"me/photos"
                           andParams:params
                       andHttpMethod:@"POST"
                         andDelegate:self];
}

- (void)request:(FBRequest *)request didLoad:(id)result {
    NSLog(@"in request");
    if ([result isKindOfClass:[NSArray class]] && ([result count] > 0)) {
        result = [result objectAtIndex:0];
    }
    //BIDAppDelegate *appDelegate = (BIDAppDelegate *)[[UIApplication sharedApplication] delegate];
    switch (currentAPICall) 
    {
            
        case kAPIGraphUserPhotosPost: // step 2
        {
            
            [self.statusLabel setText:@"Successful Uploaded"];
            //NSString *imageLink = [NSString stringWithFormat:[result objectForKey:@"link"]];            
            //NSString *thumbLink = [NSString stringWithFormat:[result objectForKey:@"src"]];
            /*NSString *urlString = [NSString stringWithFormat:
                                   @"https://graph.facebook.com/%@?access_token=%@", imageLink, 
                                   [appDelegate.facebook.accessToken stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];*/
           /* NSString *messageString = [NSString stringWithFormat:@"Lat: %@, Long: %@", latLocation, longLocation];
            NSLog(@"id of uploaded screen image %@:", result);

            currentAPICall = kAPIGraphPhotoData;
            
          //BIDAppDelegate *appDelegate = (BIDAppDelegate *)[[UIApplication sharedApplication] delegate];  
          NSMutableDictionary* dialogParams = [NSMutableDictionary dictionaryWithObjectsAndKeys:imageLink, @"link", messageString, @"name",nil];
            [appDelegate.facebook dialog:@"feed" 
                             andParams:dialogParams
                           andDelegate:self];*/
            break;
        }
    }
}

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
    tempImage = [info objectForKey:UIImagePickerControllerOriginalImage];
    if (tempImage == nil)
        NSLog(@"noimage");
    [imagePreview setImage:tempImage];
    
}

- (void)locationManager:(CLLocationManager *)manager
    didUpdateToLocation:(CLLocation *)newLocation
           fromLocation:(CLLocation *)oldLocation
{
    int degrees = newLocation.coordinate.latitude;
    double decimal = fabs(newLocation.coordinate.latitude - degrees);
    int minutes = decimal * 60;
    double seconds = decimal * 3600 - minutes * 60;
    latLocation = [NSString stringWithFormat:@"%d° %d' %1.4f\"", 
                     degrees, minutes, seconds];
    degrees = newLocation.coordinate.longitude;
    decimal = fabs(newLocation.coordinate.longitude - degrees);
    minutes = decimal * 60;
    seconds = decimal * 3600 - minutes * 60;
    longLocation = [NSString stringWithFormat:@"%d° %d' %1.4f\"", 
                       degrees, minutes, seconds];
    
    //NSLog(@"lat: %@, long: %@", latLocation, longLocation);
}

// Shake motion implement
- (void)motionEnded:(UIEventSubtype)motion withEvent:(UIEvent *)event
{
    NSLog(@"shake motion");
    if (event.type == UIEventSubtypeMotionShake) 
    {
        // your code here
        [self.statusLabel setText:@"Uploading..."];
        [self postImageToFacebook];
    }
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
    
    if (bitmapInfo == kCGImageAlphaNone) {
        bitmapInfo = kCGImageAlphaNoneSkipLast;
    }
    
    CGContextRef bitmap;
    
    bitmap = CGBitmapContextCreate(NULL, targetWidth, targetHeight, CGImageGetBitsPerComponent(imageRef), CGImageGetBytesPerRow(imageRef), colorSpaceInfo, bitmapInfo);
    
    // In the right or left cases, we need to switch scaledWidth and scaledHeight,
    // and also the thumbnail point
    if (sourceImage.imageOrientation == UIImageOrientationLeft) {
        NSLog(@"left");
        CGFloat oldScaledWidth = targetWidth;
        targetWidth = targetHeight;
        targetHeight = oldScaledWidth;
        
        CGContextRotateCTM (bitmap, [self radians:90]);
        CGContextTranslateCTM (bitmap, 0, -targetHeight);
        
    } else if (sourceImage.imageOrientation == UIImageOrientationRight) {
        NSLog(@"right");
        CGFloat oldScaledWidth = targetWidth;
        targetWidth = targetHeight;
        targetHeight = oldScaledWidth;
        
        CGContextRotateCTM (bitmap, [self radians:-90]);
        CGContextTranslateCTM (bitmap, -targetWidth, 0);
        
    } else if (sourceImage.imageOrientation == UIImageOrientationUp) {
        // NOTHING
        NSLog(@"up");
    } else if (sourceImage.imageOrientation == UIImageOrientationDown) {
        NSLog(@"down");
        CGContextTranslateCTM (bitmap, targetWidth, targetHeight);
        CGContextRotateCTM (bitmap, [self radians:-180]);
    }
    
    CGContextDrawImage(bitmap, CGRectMake(0.0, 0.0, targetWidth, targetHeight), imageRef);
    CGImageRef ref = CGBitmapContextCreateImage(bitmap);
    UIImage* newImage = [UIImage imageWithCGImage:ref];
    
    //CGContextRelease(bitmap);
    //CGImageRelease(ref);
    NSLog(@"sourceImage:%i",sourceImage.imageOrientation);
    NSLog(@"newImage:%i",newImage.imageOrientation);
    
    
    
    
    return newImage; 
}



@end
