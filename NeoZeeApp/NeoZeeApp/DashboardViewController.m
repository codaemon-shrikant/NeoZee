//
//  DashboardViewController.m
//  NeoZeeApp
//
//  Created by Codaemon  on 21/12/17.
//  Copyright © 2017 Codaemon . All rights reserved.
//

#import "DashboardViewController.h"
#import "ParentViewCell.h"
#import <MediaPlayer/MediaPlayer.h>
#import <QuartzCore/QuartzCore.h>
#import "ImageViewController.h"
#import <AVFoundation/AVFoundation.h>

@interface DashboardViewController () {
    UIImageView *imgView;
    UIImageView *closeimgView;
}

@end

@implementation DashboardViewController
UIRefreshControl *refreshControl;
static NSString * const reuseIdentifier = @"Cell";

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"Media";
    self.navigationItem.hidesBackButton = YES;
    //Create custom logout button on navigation bar
    UIBarButtonItem *logoutButton = [[UIBarButtonItem alloc]
                                     initWithTitle:@"Logout"
                                     style:UIBarButtonItemStylePlain
                                     target:self
                                     action:@selector(logout)];
    self.navigationItem.rightBarButtonItem = logoutButton;
    
    //Get the session variable value for user id
    NSString *user_id = [[NSUserDefaults standardUserDefaults] valueForKey:@"UserId"];
    NSString *urlString = [NSString stringWithFormat:@"http://54.145.124.70/neozee/api/v1/media?user_id=%@",user_id];
    
    NSURL *url = [NSURL URLWithString:urlString];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
    [request setHTTPMethod:@"GET"];
    [request setValue:@"neo-32696d98-a84a2f0f-2a254259-ea5de6aa" forHTTPHeaderField:@"neo-x-api-key"];
    [request setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    [request setValue:@"application/json" forHTTPHeaderField:@"Accept"];
    NSError *error;
    NSHTTPURLResponse *responseCode;
    
    NSData *oResponseData = [NSURLConnection sendSynchronousRequest:request returningResponse:&responseCode error:nil];
    NSDictionary *json = [NSJSONSerialization JSONObjectWithData:oResponseData
                                                         options:NSJSONReadingMutableContainers
                                                           error:nil];
    child_data = [[NSMutableArray alloc]init];
    child_data = [[json objectForKey:@"data"] mutableCopy];
    NSLog(@"Count: %lu",(unsigned long)child_data.count);
    NSLog(@"Response :%@",child_data);
    if([responseCode statusCode] != 200){
        NSLog(@"Error getting HTTP status code %li", (long)[responseCode statusCode]);
        UIAlertView *ErrorAlert = [[UIAlertView alloc]initWithTitle:@""
                                                            message:[json objectForKey:@"message"] delegate:nil
                                                  cancelButtonTitle:@"OK"
                                                  otherButtonTitles:nil, nil];
        
        [ErrorAlert show];
    }
    else {
        NSLog(@"Sucessfully Login...");
        if((unsigned long)child_data.count == 0) {
            UIAlertView *ErrorAlert = [[UIAlertView alloc]initWithTitle:@""
                                                                message:@"No media found." delegate:nil
                                                      cancelButtonTitle:@"OK"
                                                      otherButtonTitles:nil, nil];
            
            [ErrorAlert show];
        }
        
    }
    //[_myCollectionView reloadData];
}

-(void)viewWillAppear:(BOOL)animated {
    NSLog(@"In viewWillAppear");
}

- (IBAction)playButton:(UIButton *)sender {
    // pick a video from the documents directory
    NSURL *video = [NSURL URLWithString:@"http://www.sample-videos.com/video/mp4/240/big_buck_bunny_240p_30mb.mp4"];
    
    // create a movie player view controller
    MPMoviePlayerViewController * controller = [[MPMoviePlayerViewController alloc]initWithContentURL:video];
    [controller.moviePlayer prepareToPlay];
    [controller.moviePlayer play];
    
    // and present it
    [self presentMoviePlayerViewControllerAnimated:controller];
}

- (void)logout
{
    NSLog(@"Logout Sucessfully...");
    [[NSUserDefaults standardUserDefaults] setObject:@"" forKey:@"UserId"];
    [[NSUserDefaults standardUserDefaults] setObject:@"" forKey:@"DeviceId"];
    [[NSUserDefaults standardUserDefaults] synchronize];
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    DashboardViewController *dashboardController = [storyboard instantiateViewControllerWithIdentifier:@"welcomeViewController"];
    [self.navigationController pushViewController:dashboardController animated:YES];
    [self dismissViewControllerAnimated:YES completion:nil];
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

#pragma mark <UICollectionViewDataSource>

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 1;
}


- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return child_data.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    ParentViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"ParentCell" forIndexPath:indexPath];
    // Configure the cell...
    cell.layer.shouldRasterize = YES;
    cell.layer.rasterizationScale = [UIScreen mainScreen].scale;
    cell.parentImageView.image=nil;
    UIActivityIndicatorView *activityIndicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    
    //Show loading indicator before loading images
    [activityIndicator setCenter: cell.parentImageView.center];
    [activityIndicator startAnimating];
    [cell.contentView addSubview:activityIndicator];
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
        NSArray *images = [child_data objectAtIndex:indexPath.row];
        NSLog(@"images: %@", images);
        NSString *ImageType = [images valueForKey:@"type"];
        NSURL *url;
        if([ImageType  isEqual: @"video"]) {
            url = [NSURL URLWithString:[images valueForKey:@"thumbnailUrl"]];
            NSLog(@"Thumbnail Url: %@",url);
        }
        else {
            url = [NSURL URLWithString:[images valueForKey:@"url"]];
            NSLog(@"URL: %@",url);
        }
        NSData *data = [NSData dataWithContentsOfURL:url];
        UIImage *theImage=[UIImage imageWithData:data];
        cell.parentImageView.layer.shadowOffset = CGSizeMake(0, 3);
        cell.parentImageView.layer.shadowRadius = 2.0;
        cell.parentImageView.layer.shadowOpacity = 0.6;
        cell.parentImageView.layer.masksToBounds = NO;
        
        dispatch_async(dispatch_get_main_queue(), ^{
            cell.parentImageView.image=theImage;
            
            //Hide loading indicator once image is set
            [activityIndicator removeFromSuperview];
       });
    });
    
    return cell;
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    return CGSizeMake(150, 180);
}

-(UIEdgeInsets) collectionView:(UICollectionView *)collectionView layout:(UICollectionViewFlowLayout *)collectionViewLayout insetForSectionAtIndex:(NSInteger)section
{
    return UIEdgeInsetsMake(5, 5, 5, 5);
}

//Method used to save browser history data when click on any media
-(void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath  {
    NSDictionary *rowItem = [child_data objectAtIndex:indexPath.row];
    NSString *ImageURL = [rowItem objectForKey:@"url"];
    NSString *ImageType = [rowItem objectForKey:@"type"];
    if([ImageType  isEqual: @"image"]) {
        NSLog(@"In Image.");
        UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
        DashboardViewController *dashboardController = [storyboard instantiateViewControllerWithIdentifier:@"imageViewController"];
        dashboardController.strURL = ImageURL;
        [self.navigationController pushViewController:dashboardController animated:YES];
    }
    else {
        NSLog(@"In Video.");
        // pick a video from the documents directory
        NSURL *video = [NSURL URLWithString:ImageURL];
        
        // create a movie player view controller
        MPMoviePlayerViewController * controller = [[MPMoviePlayerViewController alloc]initWithContentURL:video];
        [controller.moviePlayer prepareToPlay];
        [controller.moviePlayer play];
        
        // and present it
        [self presentMoviePlayerViewControllerAnimated:controller];
    }
    
}

- (void)closeivTapped:(id)sender
{
    [imgView removeFromSuperview];
    [closeimgView removeFromSuperview];
}

#pragma mark <UICollectionViewDelegate>

/*
// Uncomment this method to specify if the specified item should be highlighted during tracking
- (BOOL)collectionView:(UICollectionView *)collectionView shouldHighlightItemAtIndexPath:(NSIndexPath *)indexPath {
	return YES;
}
*/

/*
// Uncomment this method to specify if the specified item should be selected
- (BOOL)collectionView:(UICollectionView *)collectionView shouldSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    return YES;
}
*/

/*
// Uncomment these methods to specify if an action menu should be displayed for the specified item, and react to actions performed on the item
- (BOOL)collectionView:(UICollectionView *)collectionView shouldShowMenuForItemAtIndexPath:(NSIndexPath *)indexPath {
	return NO;
}

- (BOOL)collectionView:(UICollectionView *)collectionView canPerformAction:(SEL)action forItemAtIndexPath:(NSIndexPath *)indexPath withSender:(id)sender {
	return NO;
}

- (void)collectionView:(UICollectionView *)collectionView performAction:(SEL)action forItemAtIndexPath:(NSIndexPath *)indexPath withSender:(id)sender {
	
}
*/

@end
