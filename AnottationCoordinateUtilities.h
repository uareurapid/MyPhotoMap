//
//  AnottationCoordinateUtilities.h
//  CollectionViewTutorial
//
//  Created by Paulo Cristo on 6/12/13.
//  Copyright (c) 2013 Bryan Hansen. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>
#import <MapKit/MapKit.h>


@interface AnottationCoordinateUtilities : NSObject

+ (void)mutateCoordinatesOfClashingAnnotations:(NSArray *)annotations;
+ (NSDictionary *)groupAnnotationsByLocationValue:(NSArray *)annotations;
+ (void)repositionAnnotations:(NSMutableArray *)annotations toAvoidClashAtCoordination:(CLLocationCoordinate2D)coordinate;
@end
