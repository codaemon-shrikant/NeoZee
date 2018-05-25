//
//  LoginViewController.m
//  NoeZeeChildApp
//
//  Created by Codaemon  on 02/04/18.
//  Copyright © 2018 Codaemon . All rights reserved.
//

#import "LoginViewController.h"
#import <CoreLocation/CoreLocation.h>

@interface LoginViewController () <CLLocationManagerDelegate>
@property (strong, nonatomic) IBOutlet UITextField *emailTextField;
@property (strong, nonatomic) IBOutlet UITextField *passwordTextField;
@property (nonatomic,strong) CLLocationManager *locationManager;
@end

@implementation LoginViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    NSLog(@"In viewDidLoad");
    [super viewDidLoad];
    
    self.locationManager = [[CLLocationManager alloc] init];
    
    // Setup location tracker accuracy
    self.locationManager.desiredAccuracy = kCLLocationAccuracyBestForNavigation;
    
    // Distance filter
    self.locationManager.distanceFilter = 0.f;
    
    // Assign location tracker delegate
    self.locationManager.delegate = self;
    
    // This setup pauses location manager if location wasn't changed
    [self.locationManager setPausesLocationUpdatesAutomatically:YES];
    
    [self.locationManager requestAlwaysAuthorization];
    
    // For iOS9 we have to call this method if we want to receive location updates in background mode
    if([self.locationManager respondsToSelector:@selector(allowsBackgroundLocationUpdates)]){
        [self.locationManager setAllowsBackgroundLocationUpdates:YES];
    }
    
    [self.locationManager startUpdatingLocation];
    UIGraphicsBeginImageContext(self.view.frame.size);
    [[UIImage imageNamed:@"background.jpg"] drawInRect:self.view.bounds];
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    self.view.backgroundColor = [UIColor colorWithPatternImage:image];
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(dismissKeyboard)];
    [self.navigationController setNavigationBarHidden:YES animated:YES];
    // Email Bottom border
    CALayer *emailBottomBorder = [CALayer layer];
    emailBottomBorder.frame = CGRectMake(0.0f, _emailTextField.frame.size.height - 1, _emailTextField.frame.size.width, 1.0f);
    emailBottomBorder.backgroundColor = [UIColor colorWithRed:0.16 green:0.60 blue:0.17 alpha:1.0].CGColor;
    [self.emailTextField.layer addSublayer:emailBottomBorder];
    // Create an image
    UIImage *eimage = [UIImage imageNamed:@"mailbox-128.png"];
    CGSize sacleSize = CGSizeMake(20, 20);
    UIGraphicsBeginImageContextWithOptions(sacleSize, NO, 0.0);
    [eimage drawInRect:CGRectMake(0, 0, sacleSize.width, sacleSize.height)];
    UIImage * resizedImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    // Scale the mailbox image
    UIImageView *emailImg = [[UIImageView alloc] initWithImage:resizedImage];
    emailImg.frame = CGRectMake(0.0, 0.0, emailImg.image.size.width+10.0, emailImg.image.size.height);
    emailImg.contentMode = UIViewContentModeCenter;
    
    self.emailTextField.leftView = emailImg;
    self.emailTextField.leftViewMode = UITextFieldViewModeAlways;
    CALayer *passwordBottomBorder = [CALayer layer];
    passwordBottomBorder.frame = CGRectMake(0.0f, _passwordTextField.frame.size.height - 1, _emailTextField.frame.size.width, 1.0f);
    passwordBottomBorder.backgroundColor = [UIColor colorWithRed:0.16 green:0.60 blue:0.17 alpha:1.0].CGColor;
    [self.passwordTextField.layer addSublayer:passwordBottomBorder];
    // Create an image
    UIImage *pimage = [UIImage imageNamed:@"lock-128.png"];
    CGSize pSacleSize = CGSizeMake(25, 25);
    UIGraphicsBeginImageContextWithOptions(sacleSize, NO, 0.0);
    [pimage drawInRect:CGRectMake(0, 0, pSacleSize.width, pSacleSize.height)];
    UIImage * pResizedImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    // Scale the lock image
    UIImageView *passImg = [[UIImageView alloc] initWithImage:pResizedImage];
    passImg.frame = CGRectMake(0.0, 0.0, passImg.image.size.width+10.0, passImg.image.size.height);
    passImg.contentMode = UIViewContentModeCenter;
    
    self.passwordTextField.leftView = passImg;
    self.passwordTextField.leftViewMode = UITextFieldViewModeAlways;
    [self.view addGestureRecognizer:tap];
}

- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations
{
    NSLog(@"In didUpdateLocations");
    CLLocation *location = [locations lastObject];
    NSLog(@"%@", [NSString stringWithFormat:@"%f", location.coordinate.latitude]);
    NSLog(@"%@", [NSString stringWithFormat:@"%f", location.coordinate.longitude]);
}

-(void)dismissKeyboard
{
    [self.view endEditing:YES];
}

- (IBAction)loginButton:(id)sender {
    NSString *password = [_passwordTextField text];
    NSString *email = [_emailTextField text];
    NSString *appVersion = [[[NSBundle mainBundle] infoDictionary] objectForKey:(NSString *)kCFBundleVersionKey];
    NSString *osVersion = [[UIDevice currentDevice] systemVersion];
    //Get the device token
    NSString *device_id = [[[UIDevice currentDevice] identifierForVendor] UUIDString];
    NSLog(@"Device Token: %@", device_id);
    NSDictionary *parameters = [[NSMutableDictionary alloc] init];
    parameters = @{
                   @"email": email,
                   @"user_password": password,
                   @"appVersion": appVersion,
                   @"osVersion": osVersion,
                   @"deviceToken": device_id
                   };
    
    NSString *urlString = [NSString stringWithFormat:@"http://54.145.124.70/neozee/api/v1/user/login"];
    
    NSURL *url = [NSURL URLWithString:urlString];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:parameters options:0 error:nil];
    NSString *jsonString = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
    
    NSData *requestData = [NSData dataWithBytes:[jsonString UTF8String] length:[jsonString lengthOfBytesUsingEncoding:NSUTF8StringEncoding]];
    [request setHTTPMethod:@"POST"];
    [request setValue:@"neo-32696d98-a84a2f0f-2a254259-ea5de6aa" forHTTPHeaderField:@"neo-x-api-key"];
    [request setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    [request setValue:@"application/json" forHTTPHeaderField:@"Accept"];
    [request setValue:[NSString stringWithFormat:@"%d", [requestData length]] forHTTPHeaderField:@"Content-Length"];
    [request setHTTPBody: requestData];
    NSHTTPURLResponse *responseCode = nil;
    NSData *oResponseData = [NSURLConnection sendSynchronousRequest:request returningResponse:&responseCode error:nil];
    NSDictionary *json = [NSJSONSerialization JSONObjectWithData:oResponseData
                                                         options:NSJSONReadingMutableContainers
                                                           error:nil];
    NSLog(@"Response :%@",json);
    if([responseCode statusCode] != 200){
        NSLog(@"Error getting HTTP status code %li", (long)[responseCode statusCode]);
        UIAlertController * alert = [UIAlertController
                                     alertControllerWithTitle:@""
                                     message:[json objectForKey:@"message"]
                                     preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction* OkButton = [UIAlertAction
                                   actionWithTitle:@"OK"
                                   style:UIAlertActionStyleDefault
                                   handler:^(UIAlertAction * action) {
                                       //Handle your yes please button action here
                                   }];
        [alert addAction:OkButton];
        [self presentViewController:alert animated:YES completion:nil];
    }
    else {
        NSLog(@"Sucessfully Login...");
        NSMutableDictionary *user = [json valueForKey:@"data"];
        NSString *id = [user valueForKey:@"user_id"];
        //Set Logged In user Id in session variable
        [[NSUserDefaults standardUserDefaults] setObject:id forKey:@"UserId"];
        [[NSUserDefaults standardUserDefaults] synchronize];
        /*UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
        LoginViewController *loginController = [storyboard instantiateViewControllerWithIdentifier:@"mainViewController"];
        [self.navigationController pushViewController:loginController animated:YES];*/
        [self setDeviceAsChild];
    }
}

- (void)setDeviceAsChild {
    //Get the session variable value for user id
    NSString *user_id = [[NSUserDefaults standardUserDefaults] valueForKey:@"UserId"];
    NSLog(@"User Id: %@", user_id);
    //Get the session variable value for device token
    NSString *device_id = [[[UIDevice currentDevice] identifierForVendor] UUIDString];
    NSLog(@"Device Id: %@", device_id);
    NSString *device_name = [[UIDevice currentDevice] name];
    NSLog(@"Device name: %@", device_name);
    //NSString *osVersion = [[UIDevice currentDevice] systemVersion];
    [[NSUserDefaults standardUserDefaults] setObject:device_id forKey:@"DeviceId"];
    [[NSUserDefaults standardUserDefaults] synchronize];
    NSString *device_token = [[NSUserDefaults standardUserDefaults] valueForKey:@"device_token"];
    NSCharacterSet *doNotWant = [NSCharacterSet characterSetWithCharactersInString:@"<> "];
    device_token = [[device_token componentsSeparatedByCharactersInSet: doNotWant] componentsJoinedByString: @""];
    NSLog(@"Device Token: %@", device_token);
    //Create JSON data parameter which needs to send with POST request
    NSDictionary *parameters = [[NSMutableDictionary alloc] init];
    parameters = @{
                   @"user_type": @"c",
                   @"user_id": user_id,
                   @"device_id": device_id,
                   @"device_name": device_name,
                   @"device_token": device_token,
                   @"device_os": @"ios"
                   };
    
    NSString *urlString = [NSString stringWithFormat:@"http://54.145.124.70/neozee/api/v1/user/setdevice"];
    
    NSURL *url = [NSURL URLWithString:urlString];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:parameters options:0 error:nil];
    NSString *jsonString = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
    
    NSData *requestData = [NSData dataWithBytes:[jsonString UTF8String] length:[jsonString lengthOfBytesUsingEncoding:NSUTF8StringEncoding]];
    [request setHTTPMethod:@"POST"];
    [request setValue:@"neo-32696d98-a84a2f0f-2a254259-ea5de6aa" forHTTPHeaderField:@"neo-x-api-key"];
    [request setValue:@"application/json" forHTTPHeaderField:@"Accept"];
    [request setValue:@"application/json; charset=UTF-8" forHTTPHeaderField:@"Content-Type"];
    [request setValue:[NSString stringWithFormat:@"%lu", (unsigned long)[requestData length]] forHTTPHeaderField:@"Content-Length"];
    [request setHTTPBody: requestData];
    NSHTTPURLResponse *responseCode = nil;
    NSData *oResponseData = [NSURLConnection sendSynchronousRequest:request returningResponse:&responseCode error:nil];
    NSDictionary *json = [NSJSONSerialization JSONObjectWithData:oResponseData
                                                         options:NSJSONReadingMutableContainers
                                                           error:nil];
    NSLog(@"Response :%@",json);
    if([responseCode statusCode] != 201){
        NSLog(@"Error getting HTTP status code %li", (long)[responseCode statusCode]);
    }
    else {
        NSLog(@"Sucessfully set device as child...");
        UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
        LoginViewController *loginController = [storyboard instantiateViewControllerWithIdentifier:@"mainViewController"];
        [self.navigationController pushViewController:loginController animated:YES];
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
