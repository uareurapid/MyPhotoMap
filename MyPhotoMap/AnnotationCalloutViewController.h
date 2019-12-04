//
//  AnnotationCalloutViewController.h
//  MyPhotoMap
//
//  Created by Paulo Cristo on 6/14/13.
//  Copyright (c) 2013 Paulo Cristo. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MapViewAnnotationPoint.h"
#import "FPPopoverController.h"
#import "BHPhotoAlbumView.h"

@interface AnnotationCalloutViewController : UIViewController /*<UIPopoverPresentationControllerDelegate> */ <FPPopoverControllerDelegate>
- (IBAction)closeClicked:(id)sender;
@property (weak, nonatomic) IBOutlet UILabel *imgTitle;

//it appears as a list of 1-n images
@property (strong,nonatomic) NSMutableArray *calloutAnnotations;
@property (copy, nonatomic) NSString *previousAssetURL;

@property (weak, nonatomic) IBOutlet UIImageView *imageView;

@property (assign, nonatomic) NSInteger currentIndex;
@property (assign, nonatomic) NSInteger currentSecondaryIndex; //used when we have multiple photos urls in 1 annotation (an album?)

@property (retain, nonatomic) IBOutlet BHPhotoAlbumView *photoCellView;
- (id)initWithNibName:(NSString *)nibName bundle:(NSBundle *)nibBundle annotations:(NSMutableArray*) annots;
@end
