//
//  TSPosition.h
//  Tapastreet
//
//  Created by Paulo Cristo on 12/16/12.
//  Copyright (c) 2012 Paulo Cristo. All rights reserved.
//

#import <Foundation/Foundation.h>
#import  <CoreLocation/CoreLocation.h>

@interface MyGPSPosition : NSObject


@property (copy,nonatomic) NSString* latitude;
@property (copy,nonatomic) NSString* longitude;
@property (copy,nonatomic) NSString *location;

@property (strong,nonatomic) CLLocation *clLocation;


- (void) print;


@end
