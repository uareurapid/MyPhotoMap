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

CGFloat firstX;
CGFloat firstY;
CGFloat lastRotation;

#pragma mark - Lifecycle

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        //lastRotation = 0.0;
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
    
    /**
    UIPanGestureRecognizer* panRecognizer = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(move:)];
    [panRecognizer setMinimumNumberOfTouches:1];
    [panRecognizer setMaximumNumberOfTouches:1];
    [panRecognizer setDelegate:self];
    [self.imageView addGestureRecognizer:panRecognizer];
    
    UIRotationGestureRecognizer* rotationRecognizer = [[UIRotationGestureRecognizer alloc] initWithTarget:self action:@selector(rotate:)];
    [rotationRecognizer setDelegate:self];
    [self addGestureRecognizer:rotationRecognizer];*/
    
    return self;
}
/**

-(void)move:(id)sender {
    [self bringSubviewToFront:[(UIPanGestureRecognizer*)sender view]];
    CGPoint translatedPoint = [(UIPanGestureRecognizer*)sender translationInView:self];
    
    if([(UIPanGestureRecognizer*)sender state] == UIGestureRecognizerStateBegan) {
        firstX = [[sender view] center].x;
        firstY = [[sender view] center].y;
    }
    translatedPoint = CGPointMake(firstX+translatedPoint.x, firstY+translatedPoint.y);
    
    [[sender view] setCenter:translatedPoint];
    
    if([(UIPanGestureRecognizer*)sender state] == UIGestureRecognizerStateEnded) {
        
        CGFloat finalX = translatedPoint.x + (0*[(UIPanGestureRecognizer*)sender velocityInView:self.imageView].x);
        CGFloat finalY = translatedPoint.y + (0*[(UIPanGestureRecognizer*)sender velocityInView:self.imageView].y);
        
        [[sender view] setCenter:CGPointMake(finalX, finalY)];
    }
}

-(void)rotate:(id)sender {
    
    if([(UIRotationGestureRecognizer*)sender state] == UIGestureRecognizerStateEnded) {
        lastRotation = 0.0;
        return;
    }
    
    CGFloat rotation = 0.0 - (lastRotation - [(UIRotationGestureRecognizer*)sender rotation]);
    
    CGAffineTransform currentTransform = self.imageView.transform;
    CGAffineTransform newTransform = CGAffineTransformRotate(currentTransform,rotation);
    
    [self.imageView setTransform:newTransform];
    lastRotation = [(UIRotationGestureRecognizer*)sender rotation];
}*/
@end
