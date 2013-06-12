/*
     File: ViewController.m
 Abstract: The primary view controller for this app.
 
  Version: 1.0
 
 Disclaimer: IMPORTANT:  This Apple software is supplied to you by Apple
 Inc. ("Apple") in consideration of your agreement to the following
 terms, and your use, installation, modification or redistribution of
 this Apple software constitutes acceptance of these terms.  If you do
 not agree with these terms, please do not use, install, modify or
 redistribute this Apple software.
 
 In consideration of your agreement to abide by the following terms, and
 subject to these terms, Apple grants you a personal, non-exclusive
 license, under Apple's copyrights in this original Apple software (the
 "Apple Software"), to use, reproduce, modify and redistribute the Apple
 Software, with or without modifications, in source and/or binary forms;
 provided that if you redistribute the Apple Software in its entirety and
 without modifications, you must retain this notice and the following
 text and disclaimers in all such redistributions of the Apple Software.
 Neither the name, trademarks, service marks or logos of Apple Inc. may
 be used to endorse or promote products derived from the Apple Software
 without specific prior written permission from Apple.  Except as
 expressly stated in this notice, no other rights or licenses, express or
 implied, are granted by Apple herein, including but not limited to any
 patent rights that may be infringed by your derivative works or by other
 works in which the Apple Software may be incorporated.
 
 The Apple Software is provided by Apple on an "AS IS" basis.  APPLE
 MAKES NO WARRANTIES, EXPRESS OR IMPLIED, INCLUDING WITHOUT LIMITATION
 THE IMPLIED WARRANTIES OF NON-INFRINGEMENT, MERCHANTABILITY AND FITNESS
 FOR A PARTICULAR PURPOSE, REGARDING THE APPLE SOFTWARE OR ITS USE AND
 OPERATION ALONE OR IN COMBINATION WITH YOUR PRODUCTS.
 
 IN NO EVENT SHALL APPLE BE LIABLE FOR ANY SPECIAL, INDIRECT, INCIDENTAL
 OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF
 SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS
 INTERRUPTION) ARISING IN ANY WAY OUT OF THE USE, REPRODUCTION,
 MODIFICATION AND/OR DISTRIBUTION OF THE APPLE SOFTWARE, HOWEVER CAUSED
 AND WHETHER UNDER THEORY OF CONTRACT, TORT (INCLUDING NEGLIGENCE),
 STRICT LIABILITY OR OTHERWISE, EVEN IF APPLE HAS BEEN ADVISED OF THE
 POSSIBILITY OF SUCH DAMAGE.
 
 Copyright (C) 2012 Apple Inc. All Rights Reserved.
 
 */

#import "AlbumViewController.h"
#import "DetailViewController.h"
#import "Cell.h"

NSString *kDetailedViewControllerID = @"DetailView";    // view controller storyboard id
NSString *kCellID = @"cellID";                          // UICollectionViewCell storyboard id

@implementation AlbumViewController

@synthesize album;


-(id) initWithCollectionViewLayout:(UICollectionViewLayout *)layt {
    
    self = [super initWithCollectionViewLayout:layt];
    if(self) {
        [self.collectionView registerClass:[Cell class]
                forCellWithReuseIdentifier:kCellID];
        [self.collectionView registerClass:[DetailViewController class]
                forCellWithReuseIdentifier:kDetailedViewControllerID];
    }
    
    return self;
}


- (NSInteger)collectionView:(UICollectionView *)view numberOfItemsInSection:(NSInteger)section;
{
    NSLog(@"returning %d on album view %d",album.photosURLs.count);
    return album.photosURLs.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)cv cellForItemAtIndexPath:(NSIndexPath *)indexPath;
{
    // we're going to use a custom UICollectionViewCell, which will hold an image and its label
    //
    Cell *cell = [cv dequeueReusableCellWithReuseIdentifier:kCellID forIndexPath:indexPath];
    
    NSInteger row = indexPath.row;
    
    NSLog(@"Album name: %@ with %d photos on row %d",album.name, album.photosURLs.count,row);
    if(row<album.photosURLs.count) {
        
        // make the cell's title the actual NSIndexPath value
        cell.label.text = [NSString stringWithFormat:@"{%ld,%ld}", (long)indexPath.row, (long)indexPath.section];
        
        //do the assets enumeration
        ALAssetsLibraryAssetForURLResultBlock resultblock = ^(ALAsset *myasset){
            
            //ALAssetRepresentation *rep = [myasset defaultRepresentation];
            CGImageRef iref = [myasset thumbnail ];//fullResolutionImage
            
            if (iref){
                
                //dispatch_async(dispatch_get_main_queue(), ^{
                    __block UIImage *myImage = [UIImage imageWithCGImage:iref];//FOR FULL SCREEN iref scale:[rep scale] orientation:(UIImageOrientation)[rep orientation]
                    cell.image.image = myImage;
                    //[fileImage addObject:myImage];
                    //binding ur UI elements in main queue for fast execution
                    //self.imageView.image = myImage;
                //});
                
                
            }
        };
        
        ALAssetsLibraryAccessFailureBlock failureblock  = ^(NSError *myerror){
            
            //failed to get image.
        };
        
        ALAssetsLibrary* assetslibrary = [[ALAssetsLibrary alloc] init];
        NSLog(@"Checking URL: %@",[album.photosURLs objectAtIndex:row]);
        [assetslibrary assetForURL:[album.photosURLs objectAtIndex:row] resultBlock:resultblock failureBlock:failureblock];
        
        
        
        
        
    }
    
    
    return cell;
}

// the user tapped a collection item, load and set the image on the detail view controller
//
/*
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([[segue identifier] isEqualToString:@"showDetail"])
    {
        NSIndexPath *selectedIndexPath = [[self.collectionView indexPathsForSelectedItems] objectAtIndex:0];
        
        // load the image, to prevent it from being cached we use 'initWithContentsOfFile'
        NSString *imageNameToLoad = [NSString stringWithFormat:@"%d_full", selectedIndexPath.row];
        NSString *pathToImage = [[NSBundle mainBundle] pathForResource:imageNameToLoad ofType:@"JPG"];
        UIImage *image = [[UIImage alloc] initWithContentsOfFile:pathToImage];
        
        DetailViewController *detailViewController = [segue destinationViewController];
        detailViewController.image = image;
    }
}*/

-(void)viewWillAppear:(BOOL)animated {
    if(album!=nil && album.photosURLs.count>0) {
       // [self readAlbumThumbnails];
        NSLog(@"The album ihas size: %d",album.photosURLs.count);
    }
    else {
        
        NSLog(@"The album is empty!!!!");
    }
}

- (void) readAlbumThumbnails{
    
    
    
    
    
    
    
    /*
    
    
    
    //UIImage* __block image = [[UIImage alloc] init];
    ALAssetsLibrary *assetsLib = [[ALAssetsLibrary alloc] init];
    NSMutableArray *assets = [[NSMutableArray alloc] init];
    
    ////search all photo albums in the library
    //    [assetsLibrary enumerateGroupsWithTypes:ALAssetsGroupAlbum
    //search all photo albums in the library
    //[assetsLibrary enumerateGroupsWithTypes:ALassetP
    // [self.albums removeAllObjects];
    [assetsLib enumerateGroupsWithTypes:<#(ALAssetsGroupType)#> usingBlock:<#^(ALAssetsGroup *group, BOOL *stop)enumerationBlock#> failureBlock:<#^(NSError *error)failureBlock#>:ALAssetsGroupAll
     
                             usingBlock:^(ALAssetsGroup *group, BOOL *stop)
     {
         // NSLog(@"Group is : %@",group);
         
         NSString *name = [group valueForProperty:ALAssetsGroupPropertyName];
         if(name!=nil && [name isEqualToString:albumName]) {
             
             
             
             NSLog(@"checking album : %@",name);
             
             //UIImage *image = [UIImage imageNamed:@"concrete_wall"];
             
             
             //get only the first image to display
             
             //NSLog
             NSInteger numOfAssets = [group numberOfAssets];
             
             NSLog(@"num of photos on album %@ is %d",name, numOfAssets);
             for(int i = 0; i < numOfAssets ; i++) {//just grab the first image
                 
                 
                 
                 [group enumerateAssetsAtIndexes:[NSIndexSet indexSetWithIndex:i] options:0 usingBlock:^(ALAsset *result, NSUInteger index, BOOL *stop)
                  {
                      if (result != nil) {
                          
                          NSString *type = [result valueForProperty:ALAssetPropertyType];//only images for now
                          if([type isEqualToString:ALAssetTypePhoto]) {
                              NSLog(@"add second time");
                              UIImage *thumbnail = [UIImage imageWithCGImage:[result thumbnail]];
                              //UIImage *image = [UIImage imageWithCGImage:[rawImage fullScreenImage]];
                              //photo.rawImage = rawImage;
                              BHPhoto *photo = [BHPhoto photoWithImageData: thumbnail];
                              photo.image = thumbnail;
                              [selectedAlbum addPhoto:photo];
                              
                          }
                          
                          
                      }
                  }];
                 
             }
             
             
             
         }
         
         
         
         
     }
     
                           failureBlock:^(NSError *error)
     {
         NSLog(@"GOT ERER");
         // User did not allow access to library
         // .. handle error
     }
     ] ;
    
    */
    
}

@end
