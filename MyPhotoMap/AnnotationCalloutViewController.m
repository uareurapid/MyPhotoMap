//
//  AnnotationCalloutViewController.m
//  MyPhotoMap
//
//  Created by Paulo Cristo on 6/14/13.
//  Copyright (c) 2013 Paulo Cristo. All rights reserved.
//

#import "AnnotationCalloutViewController.h"
#import "CallOutViewCell.h"

@interface AnnotationCalloutViewController ()

@end

@implementation AnnotationCalloutViewController

@synthesize calloutAnnotations,imageView,nextPictureButton,previousPicButton;

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
    
    
    NSLog(@"Annotations size %lu",(unsigned long)calloutAnnotations.count);
    
    if(calloutAnnotations.count>0) {
      
      previousPicButton.hidden = nextPictureButton.hidden = (calloutAnnotations.count == 1);
        
      MapViewAnnotationPoint *myAnnotation = [calloutAnnotations objectAtIndex:0];
      
       //TODO check if a album or photo, if an album show all the other images on the same location
      //from the asset url 
      LocationDataModel *theModel = myAnnotation.dataModel;
        
      //this is the thumbnail image i think
      UIImage *image = myAnnotation.image; //TODO WAS OK
        
      //  UIImage *image = myAnnotation.imageFullScreen;
        //cell.imageName.text = myAnnotation.subtitle;
        
        
        
        dispatch_async(dispatch_get_main_queue(), ^{
            // Update the UI
            //but i also have the asset URL here, so maybe i´ll use that
            imageView.image = image;
            
        });
    }
    else {
        previousPicButton.hidden = true;
        nextPictureButton.hidden = true;
    }
    
    //SWIP BETWEEN IMAGES IN ANOTTATIONS
    [imageView setUserInteractionEnabled:YES];
    // Do any additional setup after loading the view from its nib.
    UISwipeGestureRecognizer *swipeLeft = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(handleSwipe:)];
    UISwipeGestureRecognizer *swipeRight = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(handleSwipe:)];
    
    // Setting the swipe direction.
    [swipeLeft setDirection:UISwipeGestureRecognizerDirectionLeft];
    [swipeRight setDirection:UISwipeGestureRecognizerDirectionRight];
    
    // Adding the swipe gesture on image view
    [imageView addGestureRecognizer:swipeLeft];
    [imageView addGestureRecognizer:swipeRight];
    
    
    
    //cell.accessoryType = UITableViewCellAccessoryDetailDisclosureButton;
}

- (void)handleSwipe:(UISwipeGestureRecognizer *)swipe {
    
    //NSInteger albumSize = enclosingAlbum.photosURLs.count;
    //enclosingAlbum.photosURLs objectAtIndex:0];
    if (swipe.direction == UISwipeGestureRecognizerDirectionLeft) {
        NSLog(@"Left Swipe");
        
    }
    else if (swipe.direction == UISwipeGestureRecognizerDirectionRight) {
        NSLog(@"swipe right....");
    }
}

- (void)viewWillAppear:(BOOL)animated
{
    //[self.tableView reloadData];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
#warning Potentially incomplete method implementation.
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
#warning Incomplete method implementation.
    // Return the number of rows in the section.
    return calloutAnnotations.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"myCalloutCell";
    CallOutViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[CallOutViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
        //NSArray *nib = [[NSBundle mainBundle] loadNibNamed:@"CallOutViewCell" owner:self options:nil];
        //cell = [nib objectAtIndex:0];
        NSLog(@"cell class %@",[cell class]);
    }
    
     // Configure the cell...
    NSInteger row = indexPath.row;
    if(row < calloutAnnotations.count) {
   
        MapViewAnnotationPoint *myAnnotation = [calloutAnnotations objectAtIndex:row];
        
        //this is the thumbnail image i think
        UIImage *image = myAnnotation.image;
        cell.imageName.text = myAnnotation.subtitle;
        
        //TODO, this operation must be done somewhere else
        //cell = [self getFullScreenImage: myAnnotation.dataModel forCell:cell];

         dispatch_async(dispatch_get_main_queue(), ^{
                // Update the UI
                //but i also have the asset URL here, so maybe i´ll use that
             cell.cellImageView.image = image; // [self getResizedImage:image];
                
         });
        //cell.accessoryType = UITableViewCellAccessoryDetailDisclosureButton;
    }
    
    return cell;
}

//returns squared image

- (UIImage *) getResizedImage:(UIImage *) original {
    CGSize newSize = newSize = CGSizeMake(67, 66);
    
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
@end
