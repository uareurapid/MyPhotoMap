//
//  TSPosition.m
//  Tapastreet
//
//  Created by Paulo Cristo on 12/16/12.
//  Copyright (c) 2012 Paulo Cristo. All rights reserved.
//

#import "MyGPSPosition.h"

@implementation MyGPSPosition

@synthesize location,latitude,longitude,clLocation;



- (void) print
{
    NSLog(@"TSPosition: location: %@, latitude: %@, longitude: %@", location,latitude,longitude);
}

- (NSString *) description
{
   NSString *desc = [[NSString alloc] initWithFormat:@"location: %@, latitude: %@, longitude: %@", location,latitude,longitude];
   return desc;
}

//forced to implement this
/*-(id) copyWithZone: (NSZone *) zone {
    
    MyGPSPosition *newPos = [[MyGPSPosition allocWithZone:zone] init];
    [newPos setLocation:location];
    [newPos setLongitude:longitude];
    [newPos setLatitude:latitude];
    [newPos setClLocation:clLocation];
    return(newPos);
}*/

@end
