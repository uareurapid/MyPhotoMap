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

@interface LocationDataModel : NSManagedObject// <NSCopying>

@property (copy, nonatomic) NSString * latitude;
@property (copy, nonatomic) NSString * name; //name of album which belongs too or NIL (actually is the same of the asset URL right now)
@property (copy, nonatomic) NSString * desc; //description of pic or album (the one we can edit)
@property (copy, nonatomic) NSString * longitude;
@property (copy, nonatomic) NSString * assetURL; //if asset URL is nil than is a "fake" album
@property (copy, nonatomic) NSString * thumbnailURL; //either an url to an image or NIL (use default concrete image)
@property (copy, nonatomic) NSString * type; //TYPE_ALBUM, etc..
@property (copy, nonatomic) NSDate * timestamp;

@end
