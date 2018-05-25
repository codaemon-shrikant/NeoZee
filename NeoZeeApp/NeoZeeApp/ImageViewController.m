//
//  ImageViewController.m
//  NeoZeeApp
//
//  Created by Codaemon  on 22/12/17.
//  Copyright © 2017 Codaemon . All rights reserved.
//

#import "ImageViewController.h"

@interface ImageViewController ()

@end

@implementation ImageViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    NSLog(@"In Viewdidload");
    NSString *ImageURL = _strURL;
    NSLog(@"URL: %@", ImageURL);
    NSData *imageData = [NSData dataWithContentsOfURL:[NSURL URLWithString:ImageURL]];
    //_imageView = [[UIImageView alloc] initWithFrame:CGRectMake(30, 120, 320, 460)];
    _imageView.image = [UIImage imageWithData:imageData];
    [self.view addSubview:_imageView];
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
