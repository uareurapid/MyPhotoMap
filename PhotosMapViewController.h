//
//  PhotosMapViewController.h
//  CollectionViewTutorial
//
//  Created by Paulo Cristo on 6/7/13.
//  Copyright (c) 2013 Bryan Hansen. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>
#import "MapViewAnnotationPoint.h"


#define METERS_PER_MILE 1609.344

@interface PhotosMapViewController : UIViewController

@property (strong, nonatomic) IBOutlet MKMapView *mapView;

//the annotations to plot
@property (strong, nonatomic) NSMutableArray *annotationsArray;

@property (strong, nonatomic) UIPopoverController *annotationsPopoverControl;

//add the image with the location to the map, to create the annotation
- (void) addLocation:(CLLocation*) imageLocation withImage: (UIImage*) image andTitle: (NSString *)title;

- (void)mutateCoordinatesOfClashingAnnotations:(NSArray *)annotations;
- (NSDictionary *)groupAnnotationsByLocationValue:(NSArray *)annotations;
- (void)repositionAnnotations:(NSMutableArray *)annotations toAvoidClashAtCoordination:(CLLocationCoordinate2D)coordinate;

- (void) removeAnnotations;
- (IBAction)terrainClicked:(id)sender;
- (IBAction)satelliteClicked:(id)sender;
- (IBAction)hybridClicked:(id)sender;


@end
