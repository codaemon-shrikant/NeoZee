//
//  RegisterViewController.m
//  NeoZeeApp
//
//  Created by Codaemon  on 19/12/17.
//  Copyright © 2017 Codaemon . All rights reserved.
//

#import "RegisterViewController.h"

@interface RegisterViewController ()
@property (strong, nonatomic) IBOutlet UITextField *emailTextField;
@property (strong, nonatomic) IBOutlet UITextField *passwordTextField;

@end

@implementation RegisterViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [_emailTextField setDelegate:self];
    /*UIBarButtonItem *backButton = [[UIBarButtonItem alloc]
                                   initWithTitle:@"Back"
                                   style:UIBarButtonItemStylePlain
                                   target:self
                                   action:@selector(goBack)];
    self.navigationItem.leftBarButtonItem = backButton;*/
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(dismissKeyboard)];
    
    [self.view addGestureRecognizer:tap];
    // Do any additional setup after loading the view.
}

-(void)goBack
{
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    RegisterViewController *registerController = [storyboard instantiateViewControllerWithIdentifier:@"welcomeViewController"];
    [self.navigationController pushViewController:registerController animated:YES];
}

- (IBAction)registerButtonClick:(UIButton *)sender {
    NSString *email = [_emailTextField text];
    NSString *password = [_passwordTextField text];
    NSDictionary *parameters = [[NSMutableDictionary alloc] init];
    parameters = @{
                   @"email": email,
                   @"user_password": password
                   };
    
    NSString *urlString = [NSString stringWithFormat:@"http://54.145.124.70/neozee/api/v1/user"];
    
    NSURL *url = [NSURL URLWithString:urlString];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:parameters options:0 error:nil];
    NSString *jsonString = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
    
    NSData *requestData = [NSData dataWithBytes:[jsonString UTF8String] length:[jsonString lengthOfBytesUsingEncoding:NSUTF8StringEncoding]];
    [request setHTTPMethod:@"POST"];
    [request setValue:@"neo-32696d98-a84a2f0f-2a254259-ea5de6aa" forHTTPHeaderField:@"neo-x-api-key"];
    [request setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    [request setValue:[NSString stringWithFormat:@"%d", [requestData length]] forHTTPHeaderField:@"Content-Length"];
    [request setHTTPBody: requestData];
    NSHTTPURLResponse *responseCode = nil;
    NSData *oResponseData = [NSURLConnection sendSynchronousRequest:request returningResponse:&responseCode error:nil];
    NSDictionary *json = [NSJSONSerialization JSONObjectWithData:oResponseData
                                                         options:NSJSONReadingMutableContainers
                                                           error:nil];
    NSLog(@"Response :%@",json);
    if([responseCode statusCode] != 201){
        NSLog(@"Error getting HTTP status code %li", (long)[responseCode statusCode]);
        UIAlertView *ErrorAlert = [[UIAlertView alloc]initWithTitle:@""
                                                            message:[json objectForKey:@"message"] delegate:nil
                                                  cancelButtonTitle:@"OK"
                                                  otherButtonTitles:nil, nil];
        
        [ErrorAlert show];
    }
    else {
        NSLog(@"Sucessfully registered...");
        NSMutableDictionary *user = [[[json valueForKey:@"data"] objectAtIndex:0]mutableCopy];
        NSString *id = [user valueForKey:@"id"];
        //Set Logged In user Id in session variable
        [[NSUserDefaults standardUserDefaults] setObject:id forKey:@"UserId"];
        [[NSUserDefaults standardUserDefaults] synchronize];
        [self registerDeviceToken];
        
    }

}

-(void)registerDeviceToken {
    //Get the session variable value for user id
    NSString *user_id = [[NSUserDefaults standardUserDefaults] valueForKey:@"UserId"];
    NSLog(@"user_id: %@",user_id);
    //Get the session variable value for device token
    NSString *device_id = [[[UIDevice currentDevice] identifierForVendor] UUIDString];
    NSLog(@"Device Id: %@", device_id);
    [[NSUserDefaults standardUserDefaults] setObject:device_id forKey:@"DeviceId"];
    [[NSUserDefaults standardUserDefaults] synchronize];
    //Create JSON data parameter which needs to send with POST request
    NSDictionary *parameters = [[NSMutableDictionary alloc] init];
    parameters = @{
                   @"user_type": @"p",
                   @"user_id": user_id,
                   @"device_id": device_id
                  };
    
    NSString *urlString = [NSString stringWithFormat:@"http://54.145.124.70/neozee/api/v1/user/device"];
    NSLog(@"url string: %@",urlString);
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
        NSLog(@"Sucessfully saved device details...");
        UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
        RegisterViewController *registerController = [storyboard instantiateViewControllerWithIdentifier:@"dashboardViewController"];
        [self.navigationController pushViewController:registerController animated:YES];
    }
    
    
}

-(BOOL) textFieldShouldReturn:(UITextField *)textField{
    
    [textField resignFirstResponder];
    return YES;
}

-(void)dismissKeyboard
{
    [self.view endEditing:YES];
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
