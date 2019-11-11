//
//  BHAlbum.m
//  CollectionViewTutorial
//
//  Created by Bryan Hansen on 11/3/12.
//  Copyright (c) 2012 Bryan Hansen. All rights reserved.
//

#import "BHAlbum.h"
#import "BHPhoto.h"

@interface BHAlbum ()

//@property (nonatomic, strong) NSMutableArray *mutablePhotos;

@end

@implementation BHAlbum


@synthesize photos;
@synthesize photosURLs;
@synthesize assetURL;
@synthesize type;


#pragma mark - Properties



#pragma mark - Lifecycle

- (id)init
{
    self = [super init];
    if (self) {
        self.photos = [[NSMutableArray alloc] init];
    }
    return self;
}

#pragma mark - Photos

- (void)addPhoto:(BHPhoto *)photo
{
    [self.photos addObject:photo];

}

- (BOOL)removePhoto:(BHPhoto *)photo
{
    if ([self.photos indexOfObject:photo] == NSNotFound) {
        return NO;
    }
    
    [self.photos removeObject:photo];
    
    return YES;
}

- (BOOL)isFakeAlbum {
    return self.assetURL==nil || self.assetURL==NULL;
}

@end
