//
//  LocationEntity.m
//  CollectionViewTutorial
//
//  Created by Paulo Cristo on 6/12/13.
//  Copyright (c) 2013 Bryan Hansen. All rights reserved.
//

#import "LocationDataModel.h"


@implementation LocationDataModel

@dynamic latitude;
@dynamic name;
@dynamic longitude;
@dynamic assetURL;
@dynamic type;
@dynamic timestamp;
@dynamic thumbnailURL;
@dynamic desc;

/*
 - (id)copyWithZone:(NSZone *)zone
 {
     id copy = [[[self class] alloc] init];

     if (copy)
     {
         // Copy NSObject subclasses
         if(self.latitude) {
            [copy setLatitude:[self.latitude copyWithZone:zone]];
         }
         if(self.name) {
           [copy setName:[self.name copyWithZone:zone]];
         }
         
         if(self.longitude) {
            [copy setLongitude:[self.longitude copyWithZone:zone]];
         }
         
         if(self.assetURL) {
            [copy setAssetURL:[self.assetURL copyWithZone:zone]];
         }
         
         if(self.type) {
             [copy setType:[self.type copyWithZone:zone]];
         }
         
         if(self.thumbnailURL) {
             [copy setThumbnailURL:[self.thumbnailURL copyWithZone:zone]];
         }
        
         if(self.desc) {
             [copy setDesc:[self.desc copyWithZone:zone]];
         }
         
         if(self.timestamp) {
             [copy setTimestamp:[self.timestamp copyWithZone:zone]];
         }

     }

     return copy;
 }*/
 
@end
