//
//  AnnotationPoint.h
//  Tapastreet
//
//  Created by Paulo Cristo on 12/12/12.
//  Copyright (c) 2012 Paulo Cristo. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <MapKit/MapKit.h>


//this will be used for annotations
@interface MapViewAnnotationPoint : NSObject <MKAnnotation>

@property (nonatomic,readwrite) CLLocationCoordinate2D coordinate;
@property (nonatomic,copy) NSString *title;
@property (nonatomic,copy) NSString *subtitle;
@property (nonatomic,copy) NSURL *assetURL;
@property (nonatomic,copy) UIImage *image;//this is actually the thumbnail only
@property (nonatomic,copy) UIImage *imageFullScreen;
@property (nonatomic,assign) LocationDataModel *dataModel;

//in case the annotation is from an album we add here the album.photoURLS
@property (strong,nonatomic) NSMutableArray *albumPhotos;


//@property (assign,nonatomic) BOOL usingAPIMarker;//are we using the api marker or the image one??

- (id) initWithCoordinate: (CLLocationCoordinate2D) cord title: (NSString*) title assetURL: (NSURL *) url;

- (id) initWithCoordinate: (CLLocationCoordinate2D) cord title: (NSString*) title image: (UIImage *) image;

//override to return title
- (NSString *) description;

//override
- (BOOL)isEqual:(id)anObject;
//- (NSUInteger)hash;

@end
