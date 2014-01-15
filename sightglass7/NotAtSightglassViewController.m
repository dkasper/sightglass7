//
//  NotAtSightglassViewController.m
//  sightglass7
//
//  Created by David Kasper on 1/14/14.
//  Copyright (c) 2014 David Kasper. All rights reserved.
//

#import "NotAtSightglassViewController.h"
@import CoreLocation;
@import MapKit;

@interface NotAtSightglassViewController ()

@end

@implementation NotAtSightglassViewController

-(IBAction)findSightglass:(id)sender {
    CLLocationCoordinate2D sightglassCoordinate = CLLocationCoordinate2DMake(37.777143, -122.408427);
    
    MKPlacemark *placemark = [[MKPlacemark alloc] initWithCoordinate:sightglassCoordinate
                                                   addressDictionary:nil];
    MKMapItem *mapItem = [[MKMapItem alloc] initWithPlacemark:placemark];
    [mapItem setName:@"Sightglass"];
    
    // Set the directions mode to "Walking"
    // Can use MKLaunchOptionsDirectionsModeDriving instead
    NSDictionary *launchOptions = @{MKLaunchOptionsDirectionsModeKey : MKLaunchOptionsDirectionsModeWalking};
    // Get the "Current User Location" MKMapItem
    MKMapItem *currentLocationMapItem = [MKMapItem mapItemForCurrentLocation];
    // Pass the current location and destination map items to the Maps app
    // Set the direction mode in the launchOptions dictionary
    [MKMapItem openMapsWithItems:@[currentLocationMapItem, mapItem]
                   launchOptions:launchOptions];
}

@end
