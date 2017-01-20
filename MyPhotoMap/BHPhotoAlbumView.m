//
//  BHPhotoAlbumView.m
//  MyPhotoMap
//
//  Created by PC Dreams on 16/01/2017.
//  Copyright © 2017 Paulo Cristo. All rights reserved.
//

#import "BHPhotoAlbumView.h"

@interface BHPhotoAlbumView ()


@end

@implementation BHPhotoAlbumView

#pragma mark - Lifecycle

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor colorWithWhite:0.85f alpha:1.0f];
        self.superview.backgroundColor = (__bridge UIColor * _Nullable)([UIColor blackColor].CGColor);
        
        self.layer.borderColor = [UIColor whiteColor].CGColor;
        self.layer.borderWidth = 3.0f;
        self.layer.shadowColor = [UIColor blackColor].CGColor;
        self.layer.shadowRadius = 3.0f;
        self.layer.shadowOffset = CGSizeMake(0.0f, 2.0f);
        self.layer.shadowOpacity = 0.5f;
        // make sure we rasterize nicely for retina
        self.layer.rasterizationScale = [UIScreen mainScreen].scale;
        self.layer.shouldRasterize = YES;
        
        CGRect rect = CGRectMake(frame.origin.x-20, frame.origin.y-20, frame.size.width, frame.size.height-20);
        
        self.imageView = [[UIImageView alloc] initWithFrame: rect];
        self.imageView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        self.imageView.contentMode = UIViewContentModeScaleAspectFill;
        self.imageView.clipsToBounds = YES;
        
        [self addSubview:self.imageView];
    }
    
    return self;
}

@end
