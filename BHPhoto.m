//
//  BHPhoto.m
//  CollectionViewTutorial
//
//  Created by Bryan Hansen on 11/3/12.
//  Copyright (c) 2012 Bryan Hansen. All rights reserved.
//

#import "BHPhoto.h"

@interface BHPhoto ()


@end

@implementation BHPhoto

@synthesize image,rawImage,isSelected;

#pragma mark - Properties

//- (UIImage *)image
//{
    /*if (!_image && self.imageURL) {
        NSData *imageData = [NSData dataWithContentsOfURL:self.imageURL];
        UIImage *image = [UIImage imageWithData:imageData scale:[UIScreen mainScreen].scale];
        
        _image = image;
    }*/
    
//    return image;
//}

#pragma mark - Lifecycle

+ (BHPhoto *)photoWithImageURL:(NSString *)imageURL
{
    return [[self alloc] initWithImageURL:imageURL];
}

+ (BHPhoto *)photoWithImageData:(UIImage *)imageData {
    return [[self alloc] initWithImageData:imageData];
}
- (id)initWithImageData:(UIImage *)imageData
{
    self = [super init];
    if (self) {
        self.image = imageData;
        self.isSelected = false;
    }
    return self;
}

- (id)initWithImageURL:(NSString *)imageURL
{
    self = [super init];
    if (self) {
        self.imageURL = imageURL;
        self.isSelected = false;
    }
    return self;
}

@end
