//
//  PhotosMapViewController.m
//  CollectionViewTutorial
//
//  Created by Paulo Cristo on 6/7/13.
//  Copyright (c) 2013 Bryan Hansen. All rights reserved.
//

#import "PhotosMapViewController.h"

@interface PhotosMapViewController ()

@end

@implementation PhotosMapViewController

@synthesize mapView;
@synthesize annotationsArray;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        self.tabBarItem.title = @"Your Photos Map";
        self.title = @"Your Photos Map";
        annotationsArray = [[NSMutableArray alloc]init];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    //this always places the map on the user location
    [self.mapView setShowsUserLocation:YES];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

//clear stuff
- (void) removeAnnotations {
    [annotationsArray removeAllObjects];
}

- (void) addLocation:(CLLocation*) imageLocation withImage: (UIImage*) image andTitle: (NSString *)title {
    
    CLLocationCoordinate2D coordinate = imageLocation.coordinate;
    MapViewAnnotationPoint *annotation = [[MapViewAnnotationPoint alloc] initWithCoordinate: coordinate title: title image: image] ;
    annotation.subtitle = @"";
    //don´t plot them until they are on the array
    [annotationsArray addObject:annotation];
    
   // NSArray *mkannotationArray = [[NSArray alloc]initWithArray:self.annotationsArray];
    [self mutateCoordinatesOfClashingAnnotations:annotationsArray];
 
    //[self.mapView addAnnotations:mkannotationArray];
    
    
    [self plotMapAnnotationsInsideView];
    
}

//to handle annotation touch
- (void)mapView:(MKMapView *)mapView didSelectAnnotationView:(MKAnnotationView *)view
{
    NSLog(@"I CLICKED ON THE ANNOTATION");
}
//sets view region and zoom level
- (void) adjustViewRegion: (CLLocationCoordinate2D) zoomLocation {
    
    mapView.centerCoordinate = zoomLocation;
    
    MKCoordinateRegion viewRegion = MKCoordinateRegionMakeWithDistance(zoomLocation, 600*METERS_PER_MILE, 600*METERS_PER_MILE);//was0.5
    //previousZoomLevel = viewRegion.span.longitudeDelta;
    // 3
    MKCoordinateRegion adjustedRegion = [mapView regionThatFits:viewRegion];
    // 4
    [mapView setRegion:adjustedRegion animated:YES];
}

//sets view region and zoom level, quanto maior mais mapa se vê (zoom in > valor menor, zoom out > valor maior
- (void) adjustViewRegion: (CLLocationCoordinate2D) zoomLocation multiplier: (long) value {
    
    mapView.centerCoordinate = zoomLocation;
    
    MKCoordinateRegion viewRegion = MKCoordinateRegionMakeWithDistance(zoomLocation, value*METERS_PER_MILE, value*METERS_PER_MILE);//was0.5
    //previousZoomLevel = viewRegion.span.longitudeDelta;
    // 3
    MKCoordinateRegion adjustedRegion = [mapView regionThatFits:viewRegion];
    // 4
    [mapView setRegion:adjustedRegion animated:YES];
}

//will plot an array of "in view" annotations
- (void)plotMapAnnotationsInsideView{
    
    //check the ones to plot on map
    for(id <MKAnnotation> annotation in annotationsArray) {
        MapViewAnnotationPoint *myAnnotation = (MapViewAnnotationPoint *)annotation;
        
        if([self isCoordinateInMapView:myAnnotation.coordinate]) {
            //is coordinate inside current map rect?
            if(![[mapView annotations] containsObject:myAnnotation]) {
                //only add if not present already
                [mapView addAnnotation:myAnnotation];
            }
            
            
        }
        
    }
}

//check if the given coordinate is in the map view
- (BOOL) isCoordinateInMapView: (CLLocationCoordinate2D) coordinate
{
    CGPoint point;
    
    /* Determine if point is in view. Is there a better way then this? */
    point = [mapView convertCoordinate:coordinate toPointToView:nil];
    if( (point.x > 0) && (point.y>0) ) {
        /* Add coordinate to array that is later added to mapView */
        return YES;
    }
    return NO;
}

//remove the maps annotations
-(void)removeMapAnnotations{
    
    if(annotationsArray!=nil) {
        [annotationsArray removeAllObjects];
    }
    for (id<MKAnnotation> annotation in mapView.annotations) {
        [mapView removeAnnotation:annotation];
    }
}

//This is used to detect zoom in / out operations, since we need to swap the annotation images
- (void)mapView:(MKMapView *)viewMap regionDidChangeAnimated:(BOOL)animated{
    
    //will plot the annotations that are currently inside the view rect
    [self plotMapAnnotationsInsideView];
    

}

#pragma mutate coordinates on same location
- (void)mutateCoordinatesOfClashingAnnotations:(NSArray *)annotations {
    
    NSDictionary *coordinateValuesToAnnotations = [self groupAnnotationsByLocationValue:annotations];
    
    for (NSValue *coordinateValue in coordinateValuesToAnnotations.allKeys) {
        NSMutableArray *outletsAtLocation = coordinateValuesToAnnotations[coordinateValue];
        if (outletsAtLocation.count > 1) { //more than one in the same place
            CLLocationCoordinate2D coordinate;
            [coordinateValue getValue:&coordinate];
            [self repositionAnnotations:outletsAtLocation toAvoidClashAtCoordination:coordinate];
        }
    }
}

- (NSDictionary *)groupAnnotationsByLocationValue:(NSArray *)annotations {
    
    NSMutableDictionary *result = [NSMutableDictionary dictionary];
    
    for (id<MKAnnotation> pin in annotations) {
        
        CLLocationCoordinate2D coordinate = pin.coordinate;
        NSValue *coordinateValue = [NSValue valueWithBytes:&coordinate objCType:@encode(CLLocationCoordinate2D)];
        
        NSMutableArray *annotationsAtLocation = result[coordinateValue];
        if (!annotationsAtLocation) {
            annotationsAtLocation = [NSMutableArray array];
            result[coordinateValue] = annotationsAtLocation;
        }
        
        [annotationsAtLocation addObject:pin];
    }
    return result;
}

- (void)repositionAnnotations:(NSMutableArray *)annotations toAvoidClashAtCoordination:(CLLocationCoordinate2D)coordinate {
    
    double distance = 60 * annotations.count / 2.0;
    double radiansBetweenAnnotations = (M_PI * 20) / annotations.count;
    NSLog(@"COUNT IS : %d",annotations.count);
    for (int i = 0; i < annotations.count; i++) {
        
        double heading = radiansBetweenAnnotations * i;
        CLLocationCoordinate2D newCoordinate = [self calculateCoordinateFrom:coordinate onBearing:heading atDistance:distance];
        
        id <MKAnnotation> annotation = annotations[i];
        annotation.coordinate = newCoordinate;
    }
}

- (CLLocationCoordinate2D)calculateCoordinateFrom:(CLLocationCoordinate2D)coordinate  onBearing:(double)bearingInRadians atDistance:(double)distanceInMetres {
    
    double coordinateLatitudeInRadians = coordinate.latitude * M_PI / 180;
    double coordinateLongitudeInRadians = coordinate.longitude * M_PI / 180;
    
    double distanceComparedToEarth = distanceInMetres / 6378100;
    
    double resultLatitudeInRadians = asin(sin(coordinateLatitudeInRadians) * cos(distanceComparedToEarth) + cos(coordinateLatitudeInRadians) * sin(distanceComparedToEarth) * cos(bearingInRadians));
    double resultLongitudeInRadians = coordinateLongitudeInRadians + atan2(sin(bearingInRadians) * sin(distanceComparedToEarth) * cos(coordinateLatitudeInRadians), cos(distanceComparedToEarth) - sin(coordinateLatitudeInRadians) * sin(resultLatitudeInRadians));
    
    CLLocationCoordinate2D result;
    result.latitude = resultLatitudeInRadians * 180 / M_PI;
    result.longitude = resultLongitudeInRadians * 180 / M_PI;
    return result;
}

#pragma images stuff


//This is where i set the image for the anottation passed by parameter
- (MKAnnotationView *)mapView:(MKMapView *)theMapView viewForAnnotation:(id )annotation {
    
    // NSLog(@"View for annotation called");
    //MKAnnotationView *aView = [mapView dequeueReusableAnnotationViewWithIdentifier:@"MapVC"]; if(nil) create it
    MKAnnotationView *annotationView = [[MKAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:nil];
    
    //need to do a cast to my custom annotation type
    if([annotation isKindOfClass: [MapViewAnnotationPoint class]])
    {
        MapViewAnnotationPoint *myAnnotation = (MapViewAnnotationPoint *)annotation;

                UIImage *backImage = [self getBackgroundImage:nil];
                
                //GET THE IMAGE IN ANOTHER THREAD
                //dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
                    
                    
                    dispatch_async(dispatch_get_main_queue(), ^{
                        // Update the UI
                        UIImage *image = myAnnotation.image;
                        if(image.size.width!=image.size.height) {
                            //make it round square
                            image = [self getResizedImage:image];
                        }

                        UIImage *overlayedImage = [self getOverlayMarkerImage:backImage overlay:image];
                        annotationView.image = overlayedImage;
                    });
               // });
        
        
    }
    
    
    return annotationView;
}

//returns squared image
- (UIImage *) getResizedImage:(UIImage *) original {
    CGSize newSize;
    if(original.size.width>original.size.height) {
        newSize = CGSizeMake(original.size.width, original.size.width);
    }
    else {
        newSize = CGSizeMake(original.size.height, original.size.height);;
    }
    
    UIGraphicsBeginImageContext(newSize);
    CGContextSetInterpolationQuality(UIGraphicsGetCurrentContext(), kCGInterpolationDefault);
    [original drawInRect:CGRectMake(0,0,newSize.width,newSize.height)];
    UIImage *resizedImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return resizedImage;
}


//will build the overlayed image
- (UIImage *) getOverlayMarkerImage: (UIImage *)backImage overlay: (UIImage *) topImage {
    
    CGSize finalSize = [backImage size];
    UIGraphicsBeginImageContext(finalSize);
    [backImage drawInRect:CGRectMake(0,0,finalSize.width,finalSize.height)];
    [topImage drawInRect:CGRectMake(5,5,67,66)];//x,y position
    UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return newImage;
    
}

//will get the background image
- (UIImage *) getBackgroundImage: (NSString *) searchAPI
{
    
    UIImage * image = [UIImage imageNamed:@"shadow_instagram"];
    return image;
}

@end
