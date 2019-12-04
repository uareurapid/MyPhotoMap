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
#import "LocationDataModel.h"


#define METERS_PER_MILE 1609.344

@interface PhotosMapViewController : UIViewController

@property (strong, nonatomic) IBOutlet MKMapView *mapView;

//the annotations to plot
@property (strong, nonatomic) NSMutableArray *annotationsArray;


//add the image with the location to the map, to create the annotation
- (void) addLocation:(CLLocation*) imageLocation withImage: (UIImage*) image andTitle: (NSString *)title forModel: (LocationDataModel *)model containingURLS: (NSMutableArray *)photosURLS;

- (void) addLocation:(CLLocation*) imageLocation withThumbnail: (UIImage*) thumb withImage: (UIImage*) image andTitle: (NSString *)title forModel: (LocationDataModel *)model containingURLS: (NSMutableArray *)photosURLS;

- (void)mutateCoordinatesOfClashingAnnotations:(NSArray *)annotations;
- (NSDictionary *)groupAnnotationsByLocationValue:(NSArray *)annotations;
- (void)repositionAnnotations:(NSMutableArray *)annotations toAvoidClashAtCoordination:(CLLocationCoordinate2D)coordinate;
-(void) updateAnnotationTitle:(NSString *) title forModel:(LocationDataModel *)model;
- (void) removeAnnotations;
- (IBAction)terrainClicked:(id)sender;
- (IBAction)satelliteClicked:(id)sender;
- (IBAction)hybridClicked:(id)sender;


@end
