//
//  PictureLocationViewController.h
//  1-GeoPhotoApp
//
//  Created by Blayne Chong on 2015-10-19.
//  Copyright © 2015 blayncecameron. All rights reserved.
//

#import <MapKit/MapKit.h>
#import <CoreLocation/CoreLocation.h>
#import <Photos/Photos.h>
#import "ViewController.h"

@interface PictureLocationViewController : ViewController <UIImagePickerControllerDelegate, UINavigationControllerDelegate, MKMapViewDelegate, CLLocationManagerDelegate>

@property (nonatomic) float latitude;
@property (nonatomic) float longitude;
@property (strong, nonatomic) NSString *streetAddress;


@property (weak, nonatomic) IBOutlet UIImageView *pictureTaken;
@property (weak, nonatomic) IBOutlet MKMapView *locationPictureTaken;

- (IBAction)takePhoto:(id)sender;

@end
