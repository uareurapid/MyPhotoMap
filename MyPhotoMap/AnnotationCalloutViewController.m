//
//  AnnotationCalloutViewController.m
//  MyPhotoMap
//
//  Created by Paulo Cristo on 6/14/13.
//  Copyright (c) 2013 Paulo Cristo. All rights reserved.
//

#import "AnnotationCalloutViewController.h"
#import "CallOutViewCell.h"
#import <Photos/PHPhotoLibrary.h>
#import <Photos/Photos.h>
#import "PCImageUtils.h"

@interface AnnotationCalloutViewController ()

@end

@implementation AnnotationCalloutViewController

@synthesize calloutAnnotations,imageView, previousAssetURL, photoCellView, imgTitle;

- (id)initWithNibName:(NSString *)nibName bundle:(NSBundle *)nibBundle  {
    self = [super initWithNibName:nibName bundle:nibBundle];
    if (self) {
        // Custom initialization
        calloutAnnotations = [[NSMutableArray alloc] init];
    }
    return self;
}

- (id)initWithNibName:(NSString *)nibName bundle:(NSBundle *)nibBundle annotations:(NSMutableArray*) annots {
    self = [super initWithNibName:nibName bundle:nibBundle];
    if (self) {
        // Custom initialization
        calloutAnnotations = [[NSMutableArray alloc] init];
        [calloutAnnotations addObjectsFromArray:annots];
        
        
        
        //[self.tableView registerClass:[CallOutViewCell class] forCellReuseIdentifier:@"myCalloutCell"];
        
        //UINib *cellNib = [UINib nibWithNibName:@"CallOutViewCell" bundle:nil];
        //[self.tableView registerNib:cellNib forCellReuseIdentifier:@"myCalloutCell"];
    }
    return self;
}

/*
- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}*/

- (id)initWithAnnotations:(NSMutableArray *)annotations
{
    self = [super init];
    if (self) {
        // Custom initialization
        calloutAnnotations = [[NSMutableArray alloc] init];
        [calloutAnnotations addObjectsFromArray:annotations];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.currentIndex = 0;//-1;
    self.currentSecondaryIndex = 0;
    
    NSLog(@"Annotations size is %lu",(unsigned long)calloutAnnotations.count);
    
    
    CGRect rect = CGRectMake(self.view.bounds.origin.x+20, self.view.bounds.origin.y+40, self.view.bounds.size.width-40, self.view.bounds.size.height-120);
    photoCellView = [[BHPhotoAlbumView alloc ] initWithFrame: rect];
    photoCellView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    photoCellView.imageView.userInteractionEnabled = YES;
    
    //initWithFrame:CGRectMake(-10, 70, 320, 480)];
    
    [self.view addSubview:photoCellView];
    
    [self.view bringSubviewToFront:photoCellView];
    
    //UITapGestureRecognizer *tapGesture =[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(didTapImageThumbnailWithGesture:)];
    //[photoCellView.imageView addGestureRecognizer:tapGesture];
    
    // Do any additional setup after loading the view from its nib.
    UISwipeGestureRecognizer *swipeLeft = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(handleSwipe:)];
    UISwipeGestureRecognizer *swipeRight = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(handleSwipe:)];
    
    [photoCellView.imageView setUserInteractionEnabled:true];
    // Setting the swipe direction.
    [swipeLeft setDirection:UISwipeGestureRecognizerDirectionLeft];
    [swipeRight setDirection:UISwipeGestureRecognizerDirectionRight];
    
    [photoCellView.imageView addGestureRecognizer:swipeLeft];
    [photoCellView.imageView addGestureRecognizer:swipeRight];
    
    
    if(self.calloutAnnotations.count>0) {
      
     
      MapViewAnnotationPoint *myAnnotation = [calloutAnnotations objectAtIndex:self.currentIndex];
      
       //TODO check if a album or photo, if an album show all the other images on the same location
        
      //this is the thumbnail image i think
        UIImage *image = myAnnotation.image; //TODO WAS OK
        NSLog(@"IMAGE SIZE %fl %fl", image.size.width,image.size.height);
        
        BOOL hasModel = (myAnnotation.dataModel != nil && myAnnotation.dataModel.assetURL!=nil);
        
        
        self.imgTitle.text = (myAnnotation.title!=nil ? myAnnotation.title: @"");
        
        //this is the thumbnail image
        if(myAnnotation.image!=nil) {
            
            NSString *url = nil;
            NSArray *urls = nil;
            if(hasModel) {
                url = myAnnotation.dataModel.assetURL;
                urls = [[NSArray alloc] initWithObjects: url , nil];
            }
            else if(myAnnotation.albumPhotos.count == 1) {
                url = (NSString *) [myAnnotation.albumPhotos objectAtIndex:0];
                urls = [[NSArray alloc] initWithObjects: url , nil];
            }
            else if(myAnnotation.albumPhotos.count > 0 && (self.currentSecondaryIndex >-1 && self.currentSecondaryIndex < myAnnotation.albumPhotos.count) ) {
                
                url = [myAnnotation.albumPhotos objectAtIndex: self.currentSecondaryIndex]; //convert NSString to NSURL
                urls = [[NSArray alloc] initWithObjects: url , nil];
            }
            
            //only if i have some asset url to convert back to image
            if(urls.count > 0) {
                
                PHFetchResult *results = [PHAsset fetchAssetsWithLocalIdentifiers: urls options:nil];
                if(results!=nil && results.count > 0) {
                    PHAsset *asset = (PHAsset *)results.firstObject;
                    
                    //this is the bigger image, after clicking the annotation (i) disclosure button
                    //where we can move to next/previous pic on the same location (if any)
                    //CGSize newSize = CGSizeMake(cell.cellImageView.frame.size.width, cell.cellImageView.frame.size.height);
                    
                    NSLog(@"FETCH IMAGE FULLSCREEN SIZE");
                    
                    dispatch_async(dispatch_get_main_queue(), ^{
                        
                        //this is the full screen image, maybe it should be restricted?
                        NSLog(@" CONTAINER WIDTH %lf HEIGHT %lf", self.photoCellView.imageView.frame.size.width, self.photoCellView.imageView.frame.size.height);
                        [PCImageUtils getImageFromPHAsset:asset
                                           withTargetSize: CGSizeMake(self.photoCellView.imageView.frame.size.width, self.photoCellView.imageView.frame.size.height)
                                               completion:^(UIImage *image) {
                            
                            if(image!=nil) {
                                NSLog(@"SUCCESS GOT FULL SIZE IMAGE OK 1 WIDTH: %lf %lf", image.size.width, image.size.height);
                                
                                    // Update the UI
                                    //but i also have the asset URL here, so maybe i´ll use that
                                    //self.imageView.contentMode = UIViewContentModeScaleAspectFit;
                                    self.photoCellView.imageView.image = image;
                                    self.previousAssetURL = asset.localIdentifier;
                            }
                            else {
                                NSLog(@"IT FAILED");
                                self.previousAssetURL = nil;
                            }
                            
                                
                          
                        }];
                        
                  });
                    
                }
                
            }
    
        }
        
        
    } else {
        
        self.imgTitle.text = @"";
    }
    
    
    //SWIP BETWEEN IMAGES IN ANOTTATIONS
    /*[imageView setUserInteractionEnabled:YES];
    // Do any additional setup after loading the view from its nib.
    UISwipeGestureRecognizer *swipeLeft = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(handleSwipe:)];
    UISwipeGestureRecognizer *swipeRight = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(handleSwipe:)];
    
    // Setting the swipe direction.
    [swipeLeft setDirection:UISwipeGestureRecognizerDirectionLeft];
    [swipeRight setDirection:UISwipeGestureRecognizerDirectionRight];
    
    // Adding the swipe gesture on image view
    [imageView addGestureRecognizer:swipeLeft];
    [imageView addGestureRecognizer:swipeRight];*/
}

-(IBAction)create: (id)sender {
    NSLog(@"CREATE");
}

- (void)handleSwipe:(UISwipeGestureRecognizer *)swipe {
    
    BOOL swipeLeft = YES;
    
    if (swipe.direction == UISwipeGestureRecognizerDirectionLeft) {
        self.currentIndex-=1;
        self.currentSecondaryIndex-=1;
        
        if(self.currentIndex < 0) {
            self.currentIndex = self.calloutAnnotations.count -1;
            NSLog(@"set index to %ld", (long)self.currentIndex);
        }
        
    }
    else if (swipe.direction == UISwipeGestureRecognizerDirectionRight) {
        self.currentIndex+=1;
        swipeLeft = NO;
        self.currentSecondaryIndex+=1;
        
        if(self.currentIndex >= self.calloutAnnotations.count ) {
            self.currentIndex = 0;
            NSLog(@"set index to %ld", (long)self.currentIndex);
        }
    }
    
    if(self.currentIndex >=0 && self.currentIndex < self.calloutAnnotations.count ) {
        NSLog(@"CHANGE IMAGE SWIPE, Annotations size is %lu, index: %ld",(unsigned long)calloutAnnotations.count, (long)self.currentIndex);
        
        MapViewAnnotationPoint *myAnnotation = [calloutAnnotations objectAtIndex:self.currentIndex];
        
        self.imgTitle.text = (myAnnotation.title!=nil ? myAnnotation.title: @"");
        
        BOOL hasModel = (myAnnotation.dataModel != nil && myAnnotation.dataModel.assetURL!=nil);
            
            //this is the thumbnail image
            if(myAnnotation.image!=nil) {
                NSLog(@"Has model %d url %@", hasModel, myAnnotation.dataModel.assetURL);
                NSString *url = nil;
                NSArray *urls = nil;
                if(hasModel) {
                    url = myAnnotation.dataModel.assetURL;
                    urls = [[NSArray alloc] initWithObjects: url , nil];
                }
                else if(myAnnotation.albumPhotos.count == 1) {
                    url = (NSString *) [myAnnotation.albumPhotos objectAtIndex:0];
                    urls = [[NSArray alloc] initWithObjects: url , nil];
                }
                else if(myAnnotation.albumPhotos.count > 0 && (self.currentSecondaryIndex >-1 && self.currentSecondaryIndex < myAnnotation.albumPhotos.count) ) {
                    NSLog(@"SEVERAL IMAGES IN ONE %lu LEFT-> %d",(unsigned long)myAnnotation.albumPhotos.count, swipeLeft);
                    
                    if(swipeLeft) {
                        self.currentSecondaryIndex-=1;
                        if(self.currentSecondaryIndex < 0 ){
                            self.currentSecondaryIndex = myAnnotation.albumPhotos.count -1;
                        }
                    }else {
                        self.currentSecondaryIndex+=1;
                        if(self.currentSecondaryIndex >= myAnnotation.albumPhotos.count){
                           self.currentSecondaryIndex = 0;
                        }
                    }
                    //ALWAYS CAST TO STRING
                    url = [myAnnotation.albumPhotos objectAtIndex: self.currentSecondaryIndex];
                    urls = [[NSArray alloc] initWithObjects: url , nil];
                }
                
                //only if i have some asset url to convert back to image
                if(urls.count > 0) {
                    
                    PHFetchResult *results = [PHAsset fetchAssetsWithLocalIdentifiers:urls options:nil];
                    if(results!=nil && results.count > 0) {
                        PHAsset *asset = (PHAsset *)results.firstObject;
                        
                        //this is the bigger image, after clicking the annotation (i) disclosure button
                        //where we can move to next/previous pic on the same location (if any)
                        //CGSize newSize = CGSizeMake(cell.cellImageView.frame.size.width, cell.cellImageView.frame.size.height);
                        
                        
                        
                        if(self.previousAssetURL == nil || ( self.previousAssetURL!=nil && ![self.previousAssetURL isEqualToString:asset.localIdentifier]) ) {
                            
                            [UIView beginAnimations:nil context:NULL];
                            [UIView setAnimationTransition:UIViewAnimationTransitionCurlUp forView:self.photoCellView.imageView cache:YES];
                            [UIView setAnimationDuration:1.5];
                            /// ----> [YourView CodeTo Be Done];
                            [UIView commitAnimations];
                            
                            NSLog(@"FETCH IMAGE FULLSCREEN SIZE, because it is different");
                            dispatch_async(dispatch_get_main_queue(), ^{
                                  
                                  //this is the full screen image, maybe it should be restricted?
                                  NSLog(@" CONTAINER WIDTH %lf HEIGHT %lf", self.photoCellView.imageView.frame.size.width, self.imageView.frame.size.height);
                                  [PCImageUtils getImageFromPHAsset:asset
                                                     withTargetSize:CGSizeMake(self.photoCellView.imageView.frame.size.width, self.photoCellView.imageView.frame.size.height)
                                                         completion:^(UIImage *image) {
                                      
                                      if(image!=nil) {
                                          NSLog(@"SUCCESS GOT FULL SIZE IMAGE OK 1 WIDTH: %lf %lf", image.size.width, image.size.height);
                                          
                                              // Update the UI
                                              //but i also have the asset URL here, so maybe i´ll use that
                                              //self.imageView.contentMode = UIViewContentModeScaleAspectFit;
                                              self.photoCellView.imageView.image = image;
                                              self.previousAssetURL = asset.localIdentifier;
                                      }
                                      else {
                                          NSLog(@"IT FAILED");
                                          self.previousAssetURL = nil;
                                      }
                                      
                                          
                                    
                                  }];
                                  
                            });//end dispatch
                        }//end get image
                        
                        
                        
                    }//end results
                    
                }//end urls count
        
            }
       
    }
    
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}



//returns squared image

- (UIImage *) getResizedImage:(UIImage *) original {
    CGSize newSize = CGSizeMake(67, 66);
    
    if(original.size.width>original.size.height) {
        newSize = CGSizeMake(original.size.width, original.size.width);
    }
    else {
        newSize = CGSizeMake(original.size.height, original.size.height);;
    }
    
    UIGraphicsBeginImageContext(newSize);
    CGContextSetInterpolationQuality(UIGraphicsGetCurrentContext(), kCGInterpolationDefault);
    [original drawInRect:CGRectMake(0,0,newSize.width,newSize.height)];
    UIImage *resizedImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return resizedImage;
}

/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    }   
    else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath
{
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Navigation logic may go here. Create and push another view controller.
    /*
     <#DetailViewController#> *detailViewController = [[<#DetailViewController#> alloc] initWithNibName:@"<#Nib name#>" bundle:nil];
     // ...
     // Pass the selected object to the new view controller.
     [self.navigationController pushViewController:detailViewController animated:YES];
     */
    MapViewAnnotationPoint *myAnnotation = [calloutAnnotations objectAtIndex:indexPath.row];
    NSLog(@"clicked %@ ",myAnnotation.subtitle);
    [self dismissViewControllerAnimated:NO completion:nil];
}

//- (void)presentedNewPopoverController:(FPPopoverController *)newPopoverController
  //        shouldDismissVisiblePopover:(FPPopoverController*)visiblePopoverController
//{
  //  [visiblePopoverController dismissPopoverAnimated:YES];
    //[self.tableView reloadData];
//}

- (IBAction)nextButton:(id)sender {
    NSLog(@"next button");
}

- (IBAction)previousButton:(id)sender {
    NSLog(@"previous button");
}

//resizes the image but still makes it sharp
- (UIImage *)resizeImage:(UIImage*)image newSize:(CGSize)newSize {
    CGRect newRect = CGRectIntegral(CGRectMake(0, 0, newSize.width, newSize.height));
    CGImageRef imageRef = image.CGImage;

    UIGraphicsBeginImageContextWithOptions(newSize, NO, 0);
    CGContextRef context = UIGraphicsGetCurrentContext();

    // Set the quality level to use when rescaling
    CGContextSetInterpolationQuality(context, kCGInterpolationHigh);
    CGAffineTransform flipVertical = CGAffineTransformMake(1, 0, 0, -1, 0, newSize.height);

    CGContextConcatCTM(context, flipVertical);
    // Draw into the context; this scales the image
    CGContextDrawImage(context, newRect, imageRef);

    // Get the resized image from the context and a UIImage
    CGImageRef newImageRef = CGBitmapContextCreateImage(context);
    UIImage *newImage = [UIImage imageWithCGImage:newImageRef];

    CGImageRelease(newImageRef);
    UIGraphicsEndImageContext();

    return newImage;
}

- (IBAction)closeClicked:(id)sender {
    [self dismissViewControllerAnimated:true completion:nil];
}
@end
