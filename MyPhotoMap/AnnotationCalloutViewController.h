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

@interface AnnotationCalloutViewController : UITableViewController <FPPopoverControllerDelegate>

//it appears as a list of 1-n images
@property (strong,nonatomic) NSMutableArray *calloutAnnotations;


- (id)initWithNibName:(NSString *)nibName bundle:(NSBundle *)nibBundle annotations:(NSMutableArray*) annots;
@end
