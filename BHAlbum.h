//
//  BHAlbum.h
//  CollectionViewTutorial
//
//  Created by Bryan Hansen on 11/3/12.
//  Copyright (c) 2012 Bryan Hansen. All rights reserved.
//

#import <Foundation/Foundation.h>

@class BHPhoto;

#define ALBUM_TYPE_SMART @"smart"
#define ALBUM_TYPE_USER @"user"
#define ALBUM_TYPE_FAKE @"fake"

@interface BHAlbum : NSObject

@property (copy, nonatomic) NSString *name;
@property (copy, nonatomic) NSString *type; //smart/user/fake
@property (nonatomic, strong) NSMutableArray *photos;

@property(strong,nonatomic) NSMutableArray *photosURLs;

@property (copy, nonatomic) NSString *assetURL;//if nil is a fake album

- (void)addPhoto:(BHPhoto *)photo;
- (BOOL)removePhoto:(BHPhoto *)photo;
- (BOOL)isFakeAlbum;

@property NSInteger photosCount;

@end
