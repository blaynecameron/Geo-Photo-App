//
//  PictureLocationViewController.m
//  1-GeoPhotoApp
//
//  Created by Blayne Chong on 2015-10-19.
//  Copyright © 2015 blayncecameron. All rights reserved.
//

#import "PictureLocationViewController.h"

@interface PictureLocationViewController ()

@property CLLocationManager *locationManager;

@end

@implementation PictureLocationViewController

CLPlacemark *placemark;
CLGeocoder *geocoder;
CLLocation *currentLocation;
PHAssetChangeRequest *changeRequest;
PHFetchOptions *fetchOptions;
PHAsset *lastImage;

#pragma mark - viewDidLoad
- (void)viewDidLoad {
    [super viewDidLoad];
    self.locationManager = [[CLLocationManager alloc] init];
    geocoder = [[CLGeocoder alloc] init];
}

#pragma mark - Button
- (IBAction)takePhoto:(id)sender {
    [self openCamera];
}


#pragma mark - Delegate Methods
-(void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary<NSString *,id> *)info {
    UIImage *photo = info[UIImagePickerControllerEditedImage];
    self.pictureTaken.image = photo;
    [picker dismissViewControllerAnimated:YES completion:NULL];
    
    [self getUserPictureLocation];
    
    //    PHPhotoLibrary saves our image to the devices photo library
    [[PHPhotoLibrary sharedPhotoLibrary] performChanges:^{
        
        changeRequest = [PHAssetChangeRequest creationRequestForAssetFromImage:[info valueForKey:UIImagePickerControllerOriginalImage]];
        
    }completionHandler:^(BOOL success, NSError * _Nullable error) {
        if (error) {
            NSLog(@"%@", error);
        } else {
            
            // get last image taken (note, location is saved after all these blocks run) - so NSLog will show a null that location was not saved when in fact it was....
            PHFetchOptions *fetchOptions = [[PHFetchOptions alloc] init];
            fetchOptions.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"creationDate" ascending:YES]];
            
            [[PHPhotoLibrary sharedPhotoLibrary] performChanges:^{
                PHFetchResult *fetchResult = [PHAsset fetchAssetsWithMediaType:PHAssetMediaTypeImage options:fetchOptions];
                lastImage = [fetchResult lastObject];
                
                if ([lastImage canPerformEditOperation:PHAssetEditOperationProperties]) {
                    PHAssetChangeRequest *locationChangeRequest = [PHAssetChangeRequest changeRequestForAsset:lastImage];
                    CLLocation *location = [[CLLocation alloc] initWithLatitude:self.latitude longitude:self.longitude];
                    locationChangeRequest.location = location;
                    NSLog(@"%@", location);
                }
            } completionHandler:^(BOOL success, NSError * _Nullable error) {
                if (error) {
                    NSLog(@"%@", error);
                }
            }];
        }
    }];
}

-(void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error {
    NSLog(@"Did Fail With Error: %@", error);
}

- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray<CLLocation *> *)locations {
    // get lat and long of currrent location
    currentLocation = [locations lastObject];
    self.latitude = currentLocation.coordinate.latitude;
    self.longitude = currentLocation.coordinate.longitude;
    [self.locationManager stopUpdatingLocation];
    
    // set zoom in area of the map
    CLLocationCoordinate2D userLocation = {.latitude = self.latitude, .longitude = self.longitude};
    MKCoordinateRegion region = MKCoordinateRegionMakeWithDistance(userLocation, 1500, 1000);
    [self.locationPictureTaken setRegion:region animated:YES];
    
    // reverse geocode to ge the address from lat and long
    [geocoder reverseGeocodeLocation:currentLocation completionHandler:^(NSArray<CLPlacemark *> * _Nullable placemarks, NSError * _Nullable error) {
        if (error) {
            NSLog(@"%@", error);
        } else {
            placemark = [placemarks lastObject];
            self.streetAddress = [NSString stringWithFormat:@"%@ %@", placemark.subThoroughfare, placemark.thoroughfare];
            
            [self setMapPin:userLocation pin:self.streetAddress];
        }
    }];
}

#pragma mark - Custom Methods
// opens the camera app
-(void)openCamera {
    UIImagePickerController *picker = [[UIImagePickerController alloc] init];
    picker.delegate = self;
    picker.allowsEditing = YES;
    picker.sourceType = UIImagePickerControllerSourceTypeCamera;
    [self presentViewController:picker animated:YES completion:NULL];
}

-(void)getUserPictureLocation {
    //    self.locationPictureTaken.showsUserLocation = YES;
    self.locationManager.desiredAccuracy = kCLLocationAccuracyBest;
    self.locationManager.delegate = self;
    [self.locationManager requestAlwaysAuthorization];
    [self.locationManager startUpdatingLocation];
    
    self.locationPictureTaken.delegate = self;
}

// sets pin
-(void)setMapPin: (CLLocationCoordinate2D)coordinates pin:(NSString *)address {
    MKPointAnnotation *pin = [[MKPointAnnotation alloc] init];
    pin.coordinate = coordinates;
    pin.title = address;
    [self.locationPictureTaken addAnnotation:pin];
    [self.locationPictureTaken selectAnnotation:pin animated:YES];
}


@end
