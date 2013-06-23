//
//  LocationEntity.h
//  CollectionViewTutorial
//
//  Created by Paulo Cristo on 6/12/13.
//  Copyright (c) 2013 Bryan Hansen. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

#define TYPE_ALBUM @"AL"
#define TYPE_PHOTO @"PH"
#define TYPE_VIDEO @"VI"

@interface LocationDataModel : NSManagedObject

@property (nonatomic, retain) NSString * latitude;
@property (nonatomic, retain) NSString * name; //name of album which belongs too or NIL
@property (nonatomic, retain) NSString * description; //description of pic or album
@property (nonatomic, retain) NSString * longitude;
@property (nonatomic, retain) NSString * assetURL; //if asset URL is nil than is a "fake" album
@property (nonatomic, retain) NSString * type; //TYPE_ALBUM, etc..
@property (nonatomic, retain) NSDate * timestamp;

@end
