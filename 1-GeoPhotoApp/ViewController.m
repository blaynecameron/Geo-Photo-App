//
//  ViewController.m
//  1-GeoPhotoApp
//
//  Created by Blayne Chong on 2015-10-19.
//  Copyright © 2015 blayncecameron. All rights reserved.
//

#import "ViewController.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
}

- (IBAction)segueButton:(id)sender {
    [self performSegueWithIdentifier:@"pictureLocationSegue" sender:self];
}

@end
