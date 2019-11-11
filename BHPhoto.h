//
//  BHPhoto.h
//  CollectionViewTutorial
//
//  Created by Bryan Hansen on 11/3/12.
//  Copyright (c) 2012 Bryan Hansen. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AssetsLibrary/AssetsLibrary.h>

@interface BHPhoto : NSObject

@property (nonatomic, strong) NSString *imageURL;
@property (nonatomic, strong) UIImage *image;
@property (nonatomic, assign) BOOL isSelected;

@property (nonatomic, strong) ALAssetRepresentation* rawImage;

+ (BHPhoto *)photoWithImageURL:(NSString *)imageURL;

+ (BHPhoto *)photoWithImageData:(UIImage *)imageData;


- (id)initWithImageData:(UIImage *)imageData;
- (id)initWithImageURL:(NSString *)imageURL;
//ALAssetRepresentation* rawImage = [asset defaultRepresentation];

@end
