//
//  AnnotationPoint.m
//  Tapastreet
//
//  Created by Paulo Cristo on 12/12/12.
//  Copyright (c) 2012 Paulo Cristo. All rights reserved.
//

#import "MapViewAnnotationPoint.h"

@implementation MapViewAnnotationPoint

@synthesize coordinate,title,subtitle,assetURL,image,dataModel,albumPhotos,imageFullScreen;

//TODO update this
- (id) initWithCoordinate: (CLLocationCoordinate2D) cord title: (NSString*) title
{
    self = [super init];
    if(self)
    {
        //NSLog(@"title is %@",t);
        coordinate = cord;
        self.title = title;
        albumPhotos = [[NSMutableArray alloc] init];
    
    }
    return self;
}
- (id) initWithCoordinate: (CLLocationCoordinate2D) cord title: (NSString*) title assetURL: (NSURL *) url {
    self = [self initWithCoordinate:cord title:title];
    if(self)
    {
        self.assetURL = url;
        self.image = nil;
        albumPhotos = [[NSMutableArray alloc] init];
    }
    return self;
}

- (id) initWithCoordinate: (CLLocationCoordinate2D) cord title: (NSString*) title image: (UIImage *) image {
    self = [self initWithCoordinate:cord title:title];
    if(self)
    {
        self.assetURL = nil;
        self.image = image;
        albumPhotos = [[NSMutableArray alloc] init];
    }
    return self;
}

- (NSString *) description
{
    return title;
}

- (BOOL)isEqual:(id)anObject
{
    
    //if([anObject isKindOfClass: self.class]) {
    //    MapViewAnnotationPoint *other = (MapViewAnnotationPoint *) anObject;
    //    return [data.id isEqualToString:other.data.id];
    //}
    return NO;
   
}

//- (NSUInteger)hash {
  //  return [[data.id]integerValue];
//}

@end
