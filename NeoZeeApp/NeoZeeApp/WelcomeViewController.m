//
//  WelcomeViewController.m
//  NeoZeeApp
//
//  Created by Codaemon  on 19/12/17.
//  Copyright © 2017 Codaemon . All rights reserved.
//

#import "WelcomeViewController.h"

@interface WelcomeViewController ()

@end

@implementation WelcomeViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationItem.backBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"" style:UIBarButtonItemStylePlain target:nil action:nil];
    self.navigationItem.hidesBackButton= true;
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (IBAction)createAccountButtonClick:(UIButton *)sender {
    //[self performSegueWithIdentifier:@"register" sender:self];
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    WelcomeViewController *registerController = [storyboard instantiateViewControllerWithIdentifier:@"registerViewController"];
    [self.navigationController pushViewController:registerController animated:YES];
}
- (IBAction)signInButtonClick:(UIButton *)sender {
    //[self performSegueWithIdentifier:@"login" sender:self];
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    WelcomeViewController *loginController = [storyboard instantiateViewControllerWithIdentifier:@"loginViewController"];
    [self.navigationController pushViewController:loginController animated:YES];
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
