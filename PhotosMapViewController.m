//
//  PhotosMapViewController.m
//  CollectionViewTutorial
//
//  Created by Paulo Cristo on 6/7/13.
//  Copyright (c) 2013 Bryan Hansen. All rights reserved.
//

#import "PhotosMapViewController.h"
#import "AnnotationCalloutViewController.h"
#import "FPPopoverController.h"
#import <AssetsLibrary/AssetsLibrary.h>
#import <Photos/PHPhotoLibrary.h>
#import <Photos/PHAssetCollectionChangeRequest.h>
#import <Photos/Photos.h>

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
        self.title = @"Your Photos Map";
        annotationsArray = [[NSMutableArray alloc]init];
        self.tabBarItem.image = [UIImage imageNamed:@"map.png"];
   
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

//change the map
-(IBAction)terrainClicked:(id)sender {
    mapView.mapType = MKMapTypeStandard;
}

- (IBAction)satelliteClicked:(id)sender {
    mapView.mapType = MKMapTypeSatellite;
}

- (IBAction)hybridClicked:(id)sender {
    mapView.mapType = MKMapTypeHybrid;
}



//clear stuff
- (void) removeAnnotations {
    [annotationsArray removeAllObjects];
}


- (void) addLocation:(CLLocation*) imageLocation withImage: (UIImage*) image andTitle: (NSString *)title forModel: (LocationDataModel *)model containingURLS: (NSMutableArray *)photosURLS; {
    
    //NSLog(@"Add location.....");
    CLLocationCoordinate2D coordinate = imageLocation.coordinate;
    MapViewAnnotationPoint *annotation = [[MapViewAnnotationPoint alloc] initWithCoordinate: coordinate title: title image: image] ;
    //TODO NEXT (use different??)
    annotation.subtitle = title;
    annotation.title = title;
    
    //we save the data mode to know if dealing with a single album or a photo
    annotation.dataModel = model;
    //TODO check
    if(model!=nil && model.assetURL!=nil && annotation.assetURL == nil) {
        annotation.assetURL = model.assetURL;
    }
    //NOTE if model is nil then probably the location is just from EXIF
    
    if(photosURLS!=nil && photosURLS.count>0) {
        //NSLog(@"#1 this annotation is for an album with %lu pictures",(unsigned long)photosURLS.count);
        [annotation.albumPhotos addObjectsFromArray:photosURLS];
    }
    
    
    //don´t plot them until they are on the array
    [annotationsArray addObject:annotation];
    
    //NSLog(@"map annotations size: %ld",(long)annotationsArray.count);
    
    //plot them inside the visible view
    [self plotMapAnnotationsInsideView];
    
}

//TODO CHECK THIS ONE
/*
- (void) addLocation:(CLLocation*) imageLocation withThumbnail: (UIImage*) thumb withImage: (UIImage*) image andTitle: (NSString *)title forModel: (LocationDataModel *)model containingURLS: (NSMutableArray *)photosURLS {
    
    CLLocationCoordinate2D coordinate = imageLocation.coordinate;
    MapViewAnnotationPoint *annotation = [[MapViewAnnotationPoint alloc] initWithCoordinate: coordinate title: title image: image] ;
    annotation.subtitle = title;
    
    
    //we save the data mode to know if dealing with a single album or a photo
    annotation.dataModel = model;
    //NOTE if model is nil then probably the location is just from EXIF
    //TODO check
    if(model!=nil && model.assetURL!=nil && annotation.assetURL == nil) {
        annotation.assetURL = model.assetURL;
    }
    
    if(photosURLS!=nil && photosURLS.count>0) {
        NSLog(@"#2 this annotation is for an album with %lu pictures",(unsigned long)photosURLS.count);
        [annotation.albumPhotos addObjectsFromArray:photosURLS];
    } 
    
    
    //don´t plot them until they are on the array
    [annotationsArray addObject:annotation];
    
    //plot them inside the visible view
    [self plotMapAnnotationsInsideView];
}*/

//TODO do this when we add the annotation
/*
-(void) getFullScreenImage:(MapViewAnnotationPoint *) annotation {
    
    ALAssetsLibraryAssetForURLResultBlock resultblock = ^(ALAsset *asset){
        
        __block UIImage *image = [self imageFromAsset:asset];
        if(image!=nil) {
           annotation.imageFullScreen = image;
        }
        
        
    };
    
    ALAssetsLibraryAccessFailureBlock failureblock  = ^(NSError *myerror){
        NSLog(@"Failed to get image for assetURL %@: ",annotation.dataModel.assetURL);
        //failed to get image.
    };
    
    ALAssetsLibrary* assetslibrary = [[ALAssetsLibrary alloc] init];
    [assetslibrary assetForURL: [NSURL URLWithString: annotation.dataModel.assetURL ] resultBlock:resultblock failureBlock:failureblock];
}



//get the full screen image representation
-(UIImage *)imageFromAsset:(ALAsset *)asset
{
    ALAssetRepresentation *representation = [asset defaultRepresentation];
    return [UIImage imageWithCGImage:representation.fullResolutionImage
                               scale:[representation scale]
                         orientation:(UIImageOrientation)[representation orientation]];
}*/


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

#pragma table stuff

//to handle annotation touch
- (void)mapView:(MKMapView *)mapView didSelectAnnotationView:(MKAnnotationView *)view
{
    NSLog(@"I CLICKED ON THE ANNOTATION");
}

//This is where i set the image for the anottation passed by parameter

- (MKAnnotationView *)mapView:(MKMapView *)theMapView viewForAnnotation:(id )annotation {
    
   
    MKAnnotationView *annotationView = [[MKAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:nil];
    //need to do a cast to my custom annotation type
    if([annotation isKindOfClass: [MapViewAnnotationPoint class]])
    {
        MapViewAnnotationPoint *myAnnotation = (MapViewAnnotationPoint *)annotation;
        if(myAnnotation!=nil && [self isCoordinateInMapView:myAnnotation.coordinate] ) {
            
            NSMutableArray *samePointAnnotations = [self getAnnotationsOnSameLocation:myAnnotation];
            NSUInteger count = samePointAnnotations.count;
            
            //discard albums
            for(MapViewAnnotationPoint *other in samePointAnnotations) {
                if(other!=nil) {
                    LocationDataModel *data = (LocationDataModel*)other.dataModel;
                    //if(data!=nil && data.type == nil) {
                    //    NSLog(@"WATATFUCKK");
                    //}
                    if(data!=nil && [data.type isEqualToString: TYPE_ALBUM]) {
                        count--;
                    }
                }
                
            }
            if(count > 1) {
                //because it contains this
                if(myAnnotation.title!=nil) {
                    NSMutableString *str = [[NSMutableString alloc] initWithString:myAnnotation.title];
                    [str appendString: [NSString stringWithFormat:@" and %ld more",(long)count - 1]];
                    myAnnotation.title = str;
                }
               
                
            }
            
            
            UIImage *backImage = [self getBackgroundImage:nil];
            
                // Update the UI
                
                __block UIImage *image = myAnnotation.image;
            
                if(image == nil && myAnnotation.assetURL!=nil ) {
                 
                    PHImageManager *imageManager = [PHImageManager defaultManager];
                    
                    PHFetchOptions *options = [PHFetchOptions new];
                    options.predicate = [NSPredicate predicateWithFormat:@"mediaType == %ld", PHAssetMediaTypeImage];
                    
                    PHFetchResult<PHAsset *> *assets = [PHAsset fetchAssetsWithLocalIdentifiers:[[NSMutableArray alloc] initWithObjects: myAnnotation.assetURL,nil] options:options];
                    
                    if(assets!=nil && assets.count > 0) {
                        PHAsset *asset = [assets firstObject];
                        
                        NSMutableArray *processedURLS = [[NSMutableArray alloc] initWithCapacity:1];

                          PHImageRequestOptions *requestOptions = [[PHImageRequestOptions alloc] init];
                          requestOptions.resizeMode   = PHImageRequestOptionsResizeModeExact;
                          requestOptions.networkAccessAllowed = true;
                          requestOptions.deliveryMode = PHImageRequestOptionsDeliveryModeHighQualityFormat;
                          requestOptions.synchronous = false;
                            
                          //---------------- PARSE THUMBNAIL
                          [imageManager requestImageForAsset:asset
                                                   targetSize:CGSizeMake(125.0f, 125.0f)
                                                  contentMode:PHImageContentModeDefault
                                                      options:requestOptions
                                                resultHandler:^void(UIImage *thumbnail, NSDictionary *info) {
                                                    if(thumbnail!=nil && ![processedURLS containsObject:asset.localIdentifier]) {
                                      
                                                       [processedURLS addObject:asset.localIdentifier];
                                                       image = thumbnail;
                                                       myAnnotation.image = thumbnail;
                                                        
                                                       dispatch_async(dispatch_get_main_queue(), ^{
                                                       
                                                           if(thumbnail.size.width!=thumbnail.size.height) {
                                                               //make it round square
                                                               image = [self getResizedImage:thumbnail];
                                                           }
                                                           
                                                           UIImage *overlayedImage = [self getOverlayMarkerImage:backImage overlay:image countSameLocation: count];
                                                           annotationView.image = overlayedImage;
                                                       });
                                                    }
                        }];
                    }
                    
                        
                } else {
                      
                    //already have the image
                    dispatch_async(dispatch_get_main_queue(), ^{
                    
                        if(image.size.width!=image.size.height) {
                            //make it round square
                            image = [self getResizedImage:image];
                        }
                        
                        UIImage *overlayedImage = [self getOverlayMarkerImage:backImage overlay:image countSameLocation: count];
                        annotationView.image = overlayedImage;
                    });
                }
                
            
            //set the callout button
            UIButton *disclosure = [UIButton buttonWithType:UIButtonTypeDetailDisclosure];
            [disclosure setTitle:@"+" forState:UIControlStateNormal];
            [annotationView setRightCalloutAccessoryView:disclosure];
            
            annotationView.canShowCallout = YES;
        }
         
    }

        

    return annotationView;
}


//the callout popup, find annotations within the same location of the tapped one
- (void)mapView:(MKMapView *)mapView annotationView:(MKAnnotationView *)view calloutAccessoryControlTapped:(UIControl *)control
{
    [self.mapView deselectAnnotation:view.annotation animated:YES];
    
    
    MapViewAnnotationPoint *myAnnotation = (MapViewAnnotationPoint *)view.annotation;
    if(myAnnotation!=nil) {
        //immediatelly start the array with this one;
        NSMutableArray *annotsOnSameLocation = [self getAnnotationsOnSameLocation:myAnnotation];
        
        //the view controller you want to present as popover
        AnnotationCalloutViewController *calloutController = [[AnnotationCalloutViewController alloc]
          initWithNibName:@"AnnotationCalloutViewController" bundle:nil annotations:annotsOnSameLocation];
        
        //[self.navigationController pushViewController:calloutController animated:true];
     
        
        [self presentViewController:calloutController animated:true completion:nil];
        //our popover
        //   FPPopoverController *popover = [[FPPopoverController alloc] initWithViewController:calloutController];
        //   popover.delegate = calloutController;
           
        //   popover.contentSize = CGSizeMake(300,400);
           
           //the popover will be presented from the ok Button view
        //   [popover presentPopoverFromView:view];
        
    }
    
    
    //initiate the controller (list)
   //NSLog(@"creating custom callout view for %d annotations",annotsOnSameLocation.count);
    
    
    
    

    /*calloutController.modalPresentationStyle = UIModalPresentationPopover; // 13
    UIPopoverPresentationController *popPC = calloutController.popoverPresentationController; // 14
    calloutController.popoverPresentationController.sourceRect = self.view.frame; // 15
    calloutController.popoverPresentationController.sourceView = view; // 16
    popPC.permittedArrowDirections = UIPopoverArrowDirectionAny; // 17
    popPC.delegate = self; //18
    [self presentViewController:calloutController animated:YES completion:nil]; // 19
     
    // https://www.invasivecode.com/weblog/uipopoverpresentationcontroller-uisearchcontroller
    
*/
 
    
   
    

                                       
                                     
}

- (UIModalPresentationStyle)adaptivePresentationStyleForPresentationController:(UIPresentationController *)controller traitCollection:(UITraitCollection *)traitCollection {
    return UIModalPresentationPopover; // 20
}

- (UIViewController *)presentationController:(UIPresentationController *)controller viewControllerForAdaptivePresentationStyle:(UIModalPresentationStyle)style {
    UINavigationController *navController = [[UINavigationController alloc] initWithRootViewController:controller.presentedViewController];
    return navController; // 21
}

//get all the annotations that are in the same place
-(NSMutableArray *) getAnnotationsOnSameLocation: (MapViewAnnotationPoint*) myAnnotation {
    
    NSMutableArray *annotsOnSameLocation = [[NSMutableArray alloc] initWithObjects:myAnnotation, nil];
  /*
    CLGeocoder *geocoder = [[CLGeocoder alloc] init];
    
  
    
    [geocoder reverseGeocodeLocation:myAnnotation.co completionHandler:^(NSArray *placemarks, NSError *error)
    {
        if (!placemarks) {
            // handle error
        }

        if(placemarks && placemarks.count > 0)
        {
            CLPlacemark *placemark= [placemarks objectAtIndex:0];
            NSString *address = [NSString stringWithFormat:@"%@ %@,%@ %@", [placemark subThoroughfare],[placemark thoroughfare],[placemark locality], [placemark administrativeArea]];

            // you have the address.
            // do something with it.
            [[NSNotificationCenter defaultCenter] postNotificationName:@"MBDidReceiveAddressNotification"
                 object:self
               userInfo:@{ @"address" : address }];
        }
    }];*/
    
    
    
    for (MapViewAnnotationPoint *annotation in annotationsArray) {
        if( (annotation.coordinate.latitude == myAnnotation.coordinate.latitude) &&
            (annotation.coordinate.longitude == myAnnotation.coordinate.longitude) &&
           ![self isSameAnnotationModel:annotation andSecondAnnotation:myAnnotation]) {
           // NSLog(@"Found another annotation on the same place:");
           // NSLog(@"First assetURL: %@ second assetURL: %@",annotation.assetURL, myAnnotation.assetURL);
            [annotsOnSameLocation addObject:annotation];
        }
    }
    return annotsOnSameLocation;
}

//check if they represent the same object or not
-(BOOL) isSameAnnotationModel:(MapViewAnnotationPoint*) anotOne andSecondAnnotation: (MapViewAnnotationPoint*) anotTwo {
    
    if(anotOne == nil || anotTwo == nil) {
        return false;
    }
    else if(anotOne.assetURL !=nil && anotTwo.assetURL!=nil && [anotOne.assetURL isEqualToString:anotTwo.assetURL]) {
        return true;
    }
    else if(anotOne.dataModel!=nil && anotTwo.dataModel!=nil && anotOne.dataModel.assetURL!=nil && anotTwo.dataModel.assetURL!=nil) {
        return [anotOne.dataModel.assetURL isEqualToString:anotTwo.dataModel.assetURL];
    }
    
    return false;
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
- (UIImage *) getOverlayMarkerImage: (UIImage *)backImage overlay: (UIImage *) topImage countSameLocation: (NSUInteger) count {
    
    CGSize finalSize = [backImage size];
    UIGraphicsBeginImageContext(finalSize);
    [backImage drawInRect:CGRectMake(0,0,finalSize.width,finalSize.height)];
    [topImage drawInRect:CGRectMake(5,5,67,66)];//x,y position
    

    if(count == 0 ) {
        count = 1;
    }
    UIImage * circle = [UIImage imageNamed:@"circle"];
    //circle is top too
    [circle drawInRect:CGRectMake(finalSize.width-25,0,24,24)]; //image is 24px
        
    NSDictionary *attrDict = @{
           NSFontAttributeName : [UIFont fontWithName:@"Helvetica-Bold" size:12.0],
           NSForegroundColorAttributeName : [UIColor whiteColor]
    };
        
    NSString *text = @"";
    if(count > 99) {
       text = @"99+";
    } else {
       text = [NSString stringWithFormat:@"%lu", (unsigned long)count];
    }
    
    NSMutableAttributedString *stringText = [[NSMutableAttributedString alloc] initWithString:text attributes:attrDict];
        
    //label
    UILabel *label = [[UILabel alloc] init];
    label.textAlignment = NSTextAlignmentCenter;
    label.textColor = [UIColor whiteColor];
    label.attributedText = stringText;
    [label drawTextInRect:CGRectMake(finalSize.width-25,2,24,20)];//x,y position
    
    //the final image
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
//updates photo title
- (void) updateAnnotationTitle:(NSString *) title forModel:(LocationDataModel *)model{
  for (MapViewAnnotationPoint *annotation in annotationsArray) {
      if(annotation.dataModel != nil && annotation.dataModel.assetURL!=nil && model.assetURL!=nil ){
          if([annotation.dataModel.assetURL isEqualToString:model.assetURL]){
              //TODO NEXT (use different things?)
              annotation.title = title;
              annotation.subtitle = title;
              return;
          }
      }
  }
}


@end
