//
//  AppDelegate.m
//  NoeZeeChildApp
//
//  Created by Codaemon  on 26/03/18.
//  Copyright © 2018 Codaemon . All rights reserved.
//

#import "AppDelegate.h"
#import <CoreLocation/CoreLocation.h>

@interface AppDelegate () <CLLocationManagerDelegate>
@property (nonatomic,strong) CLLocationManager *locationManager;
@end

@implementation AppDelegate
#define SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(v)  ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] != NSOrderedAscending)
#define SYSTEM_VERSION_LESS_THAN(v) ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] == NSOrderedAscending)

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch.
    [self registerForRemoteNotifications];
    return YES;
}

- (void)registerForRemoteNotifications {
    if( SYSTEM_VERSION_LESS_THAN( @"10.0" ) ) {
        [[UIApplication sharedApplication] registerUserNotificationSettings:[UIUserNotificationSettings settingsForTypes:(UIUserNotificationTypeSound |    UIUserNotificationTypeAlert | UIUserNotificationTypeBadge) categories:nil]];
        [[UIApplication sharedApplication] registerForRemoteNotifications];
        
        //if( option != nil )
        //{
        //    NSLog( @"registerForPushWithOptions:" );
        //}
    } else {
        UNUserNotificationCenter *center = [UNUserNotificationCenter currentNotificationCenter];
        center.delegate = self;
        [center requestAuthorizationWithOptions:(UNAuthorizationOptionSound | UNAuthorizationOptionAlert | UNAuthorizationOptionBadge) completionHandler:^(BOOL granted, NSError * _Nullable error) {
            if( !error ) {
                // required to get the app to do anything at all about push notifications
                dispatch_async(dispatch_get_main_queue(), ^{
                    [[UIApplication sharedApplication] registerForRemoteNotifications];
                    NSLog( @"Push registration success." );
                });
            } else {
                NSLog( @"Push registration FAILED" );
                NSLog( @"ERROR: %@ - %@", error.localizedFailureReason, error.localizedDescription );
                NSLog( @"SUGGESTIONS: %@ - %@", error.localizedRecoveryOptions, error.localizedRecoverySuggestion );
            }
        }];
    }
}

- (void)application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken {
    NSString *deviceTokenString = [NSString stringWithFormat:@"%@", deviceToken];
    //Set Device token in session variable
    [[NSUserDefaults standardUserDefaults] setObject:deviceTokenString forKey:@"device_token"];
    [[NSUserDefaults standardUserDefaults] synchronize];
    NSLog(@"Device Token: %@", deviceTokenString);
    
}


/*- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo  {
    NSLog(@"USER Info: %@", userInfo);
    if (application.applicationState == UIApplicationStateActive) {
        // Nothing to do if applicationState is Inactive, the iOS already displayed an alert view.
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:[[[userInfo objectForKey:@"aps"] objectForKey:@"alert"] valueForKey:@"title"] message:[[[userInfo objectForKey:@"aps"] objectForKey:@"alert"] valueForKey:@"body"]delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [alertView show];
    }
    
}*/


- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
}


- (void)applicationDidEnterBackground:(UIApplication *)application {
    NSLog(@"In background...");
    UIApplication *app = [UIApplication sharedApplication];
    
    //create new uiBackgroundTask
    __block UIBackgroundTaskIdentifier bgTask = [app beginBackgroundTaskWithExpirationHandler:^{
        [app endBackgroundTask:bgTask];
        bgTask = UIBackgroundTaskInvalid;
    }];
    
    //and create new timer with async call:
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        //run function methodRunAfterBackground
        [self methodRepeat];
        NSTimer* t = [NSTimer scheduledTimerWithTimeInterval:10 target:self selector:@selector(methodRepeat) userInfo:nil repeats:YES];
        [[NSRunLoop currentRunLoop] addTimer:t forMode:NSDefaultRunLoopMode];
        [[NSRunLoop currentRunLoop] run];
    });
}


-(void)methodRepeat {
    NSLog(@"In methodRepeat");
    /*dispatch_async(dispatch_get_main_queue(), ^{
    self.locationManager = [[CLLocationManager alloc] init];
    self.locationManager.delegate = self;
    // Check for iOS 8. Without this guard the code will crash with "unknown selector" on iOS 7.
    if ([self.locationManager respondsToSelector:@selector(requestWhenInUseAuthorization)]) {
        [self.locationManager requestWhenInUseAuthorization];
    }
    [self.locationManager startUpdatingLocation];
    });*/
}

- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations
{
    NSLog(@"In didUpdateLocations1");
    CLLocation *location = [locations lastObject];
    NSLog(@"%@", [NSString stringWithFormat:@"%f", location.coordinate.latitude]);
    NSLog(@"%@", [NSString stringWithFormat:@"%f", location.coordinate.longitude]);
}


- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
}


- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}


- (void)applicationWillTerminate:(UIApplication *)application {
    NSLog(@"Application is terminated.");
}


@end
