//
//  MYAlbumViewController.m
//  CollectionViewTutorial
//
//  Created by Paulo Cristo on 6/6/13.
//  Copyright (c) 2013 Bryan Hansen. All rights reserved.
//

#import "MYAlbumViewController.h"

#import "AlbumOptionsTableViewController.h"
#import "PCAppDelegate.h"
//#import "ALAssetsLibrary+CustomPhotoAlbum.h"


#define ACTIONS_TAG 0
#define SELECT_ALL_TAG 1
#define UNSELECT_ALL_TAG 2

#define ACTION_DELETE_ALBUM 3
#define ACTION_TAKE_PHOTO 4
#define ACTION_ADD_LOCATION 5
#define ACTION_ADD_TO_ALBUM 6

#define ACTION_PERSIST_ALBUM 7

@interface MYAlbumViewController ()

@end



@implementation MYAlbumViewController


@synthesize detailViewController;
@synthesize listAlbumsAvailableController;
@synthesize albumsNames;
@synthesize selectedAlbumIndex;
@synthesize selectedAlbum,selectedPhoto,selectedAction,selectedItems;
@synthesize isFirstLoad;
@synthesize location;
@synthesize albums;
@synthesize rootViewController;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        
         albums = [NSMutableArray array];
        // Custom initialization
        //albumPhotos = [[NSMutableArray alloc] init];
        detailViewController = [[PhotoDetailViewController alloc] initWithNibName:@"PhotoDetailViewController" bundle:nil];
        
        //add the settings button
        UIBarButtonItem *addAlbumButton = [[UIBarButtonItem alloc] initWithTitle:@"Actions"
                                                                           style:UIBarButtonItemStyleDone target:self action:@selector(settingsClicked:)];
        addAlbumButton.tag = ACTIONS_TAG;//to know the function of the button
        self.navigationItem.rightBarButtonItem = addAlbumButton;
        albumsNames = [[NSMutableArray alloc] init];
        
    }
    return self;
}

- (void)viewDidLoad
{
    //[super viewDidLoad];
    
    UIImage *patternImage = [UIImage imageNamed:@"concrete_wall"];
    self.collectionView.backgroundColor = [UIColor colorWithPatternImage:patternImage];
    
    [self.collectionView registerClass:[BHAlbumPhotoCell class]
            forCellWithReuseIdentifier:PhotoCellIdentifier];
    [self.collectionView registerClass:[BHAlbumTitleReusableView class]
            forSupplementaryViewOfKind:BHPhotoAlbumLayoutAlbumTitleKind
                   withReuseIdentifier:AlbumTitleIdentifier];
    
    //self.thumbnailQueue = [[NSOperationQueue alloc] init];
    //self.thumbnailQueue.maxConcurrentOperationCount = 3;

    selectedItems = 0;
    self.isFirstLoad = true;
	// Do any additional setup after loading the view.
    
}

-(void) viewWillAppear:(BOOL)animated {
    
    NSLog(@"viewWillAppear, album");
    self.selectedAction = 0;
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    if(![defaults boolForKey:@"was_dismissed"]) {
        [self readAlbumThumbnails];
    } else {
        [defaults setBool:false forKey:@"was_dismissed"];
    }
    
    
    
}

//add the "real" existing albums" names
-(void) addAlbumsNamesFromArray: (NSMutableArray*) names {
    [albumsNames removeAllObjects];
    [albumsNames addObjectsFromArray:names];
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma add/persist existing fake to new album
//show the input new album dialog
- (IBAction)persistAlbumClicked:(id)sender{
    
    UIAlertView * alert = [[UIAlertView alloc] initWithTitle:@"New album..." message:@"Enter the album name" delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"Save",nil];
    alert.alertViewStyle = UIAlertViewStylePlainTextInput;
    [alert textFieldAtIndex:0].text = self.selectedAlbum.name;
    alert.tag = PERSIST_ALBUM_TAG;
    [alert show];
}

-(void) persistAlsoImagesInsideAlbum: (PHAssetCollection *) assetCollection {
    
       //first we get the assets on the fake album and we move them to the new persisted one
       PHFetchResult *results = [PHAsset fetchAssetsWithLocalIdentifiers: self.selectedAlbum.photosURLs options:nil];
            
        if(results!=nil && results.count > 0) {
        
            NSMutableArray *assetsArray = [[NSMutableArray alloc] initWithCapacity:results.count];
            
            for(PHAsset *asset in results) {
                
                [assetsArray addObject:(PHAsset *)asset];
            }
            
                [[PHPhotoLibrary sharedPhotoLibrary] performChanges:^{
                        //PHAssetChangeRequest *assetChangeRequest = [PHAssetChangeRequest cr:asset];
                    PHAssetCollectionChangeRequest *assetCollectionChangeRequest = [PHAssetCollectionChangeRequest changeRequestForAssetCollection:assetCollection];
                        [assetCollectionChangeRequest addAssets:assetsArray];

                } completionHandler:^(BOOL success, NSError *error) {
                        if (!success) {
                            NSLog(@"Error persistsing asset: %@", error);
                        } else {
                            NSLog(@"Persisted assets on new album");
                        }
                }];
                
        }
            
    
}
//the delegate for the new Album
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    
    
    if(alertView.tag == PERSIST_ALBUM_TAG) {
        if(buttonIndex==1) { //0 - cancel, 1 - save
            NSString *albumName = [alertView textFieldAtIndex:0].text;
            
            
            //https://developer.apple.com/documentation/photokit/browsing_and_modifying_photo_albums?language=objc
            
           
            
            PHFetchOptions *fetchOptions = [[PHFetchOptions alloc] init];
            
            fetchOptions.predicate = [NSPredicate predicateWithFormat:@"localizedTitle = %@", albumName];
             PHFetchResult *fetchResult = [PHAssetCollection fetchAssetCollectionsWithType:PHAssetCollectionTypeAlbum subtype:PHAssetCollectionSubtypeAny options:fetchOptions];
            //first check if already exists, only add if not
            if (fetchResult.count ==0) {
                    __block PHObjectPlaceholder *albumPlaceholder;
                    [[PHPhotoLibrary sharedPhotoLibrary] performChanges:^{
                        PHAssetCollectionChangeRequest *changeRequest = [PHAssetCollectionChangeRequest creationRequestForAssetCollectionWithTitle:albumName];
                        albumPlaceholder = changeRequest.placeholderForCreatedAssetCollection;

                    } completionHandler:^(BOOL success, NSError *error) {
                        if (success) {
                            PHFetchResult *fetchResultCreated = [PHAssetCollection fetchAssetCollectionsWithType:PHAssetCollectionTypeAlbum subtype:PHAssetCollectionSubtypeAny options:fetchOptions];
                            
                             NSLog(@"OK CREATED ALBUM NAMED %@", albumName);
                            
                            if (fetchResultCreated.count > 0 && self.selectedAlbum!=nil && self.selectedAlbum.photosURLs.count > 0) {
                                [self persistAlsoImagesInsideAlbum:fetchResultCreated.firstObject];
                            }
                        } else {
                            NSLog(@"Error creating album: %@", error);
                        }
                    }];
            } else if(fetchResult.count == 1) {
                //TODO don´t think this is happening cause we are persisting a FAKE ONE
                
                //first we need to delete the other one
                [[PHPhotoLibrary sharedPhotoLibrary] performChanges:^{
                    NSArray *toDelete = [[NSArray alloc] initWithObjects:fetchResult.firstObject, nil];
                    [PHAssetCollectionChangeRequest deleteAssetCollections:toDelete];

                } completionHandler:^(BOOL success, NSError *error) {
                    if (!success) {
                        NSLog(@"Error deleting album: %@", error);
                    } else {
                        // DELETE OK
                        NSLog(@"Deleted album %@ ",self.selectedAlbum.name);
                        //TODO remove from the list of albums and reload webview
                        
                        //AND CREATE (same code as above)
                        __block PHObjectPlaceholder *albumPlaceholder;
                        [[PHPhotoLibrary sharedPhotoLibrary] performChanges:^{
                            PHAssetCollectionChangeRequest *changeRequest = [PHAssetCollectionChangeRequest creationRequestForAssetCollectionWithTitle:albumName];
                            albumPlaceholder = changeRequest.placeholderForCreatedAssetCollection;

                        } completionHandler:^(BOOL success, NSError *error) {
                            if (success) {
                                PHFetchResult *fetchResultCreated = [PHAssetCollection fetchAssetCollectionsWithType:PHAssetCollectionTypeAlbum subtype:PHAssetCollectionSubtypeAny options:fetchOptions];
                                
                                 NSLog(@"OK CREATED ALBUM NAMED %@", albumName);
                                
                                if (fetchResultCreated.count > 0 && self.selectedAlbum!=nil && self.selectedAlbum.photosURLs.count > 0) {
                                    [self persistAlsoImagesInsideAlbum:fetchResultCreated.firstObject];
                                }
                            } else {
                                NSLog(@"Error creating album: %@", error);
                            }
                        }];
                        
        
                    }
                }];//end delete completion handler
            }
           
        }
    }
    
    
    
}

-(IBAction)settingsClicked:(id) sender{
    
    NSInteger tag = self.navigationItem.rightBarButtonItem.tag;
    if(tag == ACTIONS_TAG) {
        //will show a lit with two options
        //edit location and take photo
        
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Album actions"
                                                                       message:@"Select one option:"
                                                                preferredStyle:UIAlertControllerStyleActionSheet];
      
        
        UIAlertAction *editAlbumAction = [UIAlertAction actionWithTitle:@"Edit album location" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            // this block runs when the driving option is selected
            self.selectedAction = ACTION_ADD_LOCATION;
            [self addLocation:nil];
        }];
        UIAlertAction *takePhotoAction = [UIAlertAction actionWithTitle:@"Take photo" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            // this block runs when the walking option is selected
            self.selectedAction = ACTION_TAKE_PHOTO;
            [self takePhoto:nil];
        }];
        UIAlertAction *deleteAlbumAction = [UIAlertAction actionWithTitle:@"Delete album" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            self.selectedAction = ACTION_DELETE_ALBUM;
            [self deleteAlbum:nil];
        }];
        
        UIAlertAction *addPhotosAction = [UIAlertAction actionWithTitle:@"Add photos to album" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            self.selectedAction = ACTION_ADD_TO_ALBUM;
            [self addPhotosToCurrentAlbum:nil];
        }];
        
        UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:nil];
        
        [alert addAction:editAlbumAction];
        [alert addAction:takePhotoAction];
        [alert addAction:deleteAlbumAction];
        [alert addAction:addPhotosAction];
        [alert addAction:cancelAction];
        if(self.selectedAlbum!=nil && [self.selectedAlbum isFakeAlbum]) {
           //add option to persist on cameral rool, will use the same code of create album + will add all the assets currently inside this fake container
            UIAlertAction *persistAlbumAction = [UIAlertAction actionWithTitle:@"Persist album" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                // this block runs when the driving option is selected
                self.selectedAction = ACTION_PERSIST_ALBUM;
                [self persistAlbumClicked: nil];
                
            }];
            
            [alert addAction:persistAlbumAction];
        }
        
        alert.popoverPresentationController.barButtonItem = self.navigationItem.rightBarButtonItem;
        [self presentViewController:alert animated:YES completion:nil];
        
        /*AlbumOptionsTableViewController *optionsController = [[AlbumOptionsTableViewController alloc] initWithNibName:@"AlbumOptionsTableViewController" bundle:nil controller:self];
        [self.navigationController pushViewController:optionsController animated:YES];*/
    }
    else if(tag == SELECT_ALL_TAG) {
        [self selectAllAlbumThumbnails: true];
        self.navigationItem.rightBarButtonItem.tag = UNSELECT_ALL_TAG;
        self.navigationItem.rightBarButtonItem.title = @"UnSelect All";
    }
    else if(tag == ACTION_ADD_TO_ALBUM && selectedPhoto!=nil && selectedItems>0) {
        [self addPhotosToCurrentAlbum:nil];
        [self selectAllAlbumThumbnails:false];
    }
    else {
        //unselect all
        [self selectAllAlbumThumbnails: false];
        self.navigationItem.rightBarButtonItem.tag = ACTIONS_TAG;
        self.navigationItem.rightBarButtonItem.title = @"Actions";
    }
    
  
}

-(IBAction)addPhotosToCurrentAlbum:(id)sender {
    //TODO actual theyr are already in this album, so need to ask for other or create a new one!!!
    NSLog(@"start selecting photos");
    //TODO disable the button or change it´s label to select
    //add another one to select all
    
    //self.navigationItem.rightBarButtonItem.tag = SELECT_ALL_TAG;
    //self.navigationItem.rightBarButtonItem.title = @"Select All";
    
    if(self.selectedAlbum!=nil) {
        QBImagePickerController *imagePickerController = [QBImagePickerController new];
        imagePickerController.delegate = self;
        imagePickerController.allowsMultipleSelection = YES;
        imagePickerController.maximumNumberOfSelection = 50;
        imagePickerController.showsNumberOfSelectedAssets = YES;

        [self presentViewController:imagePickerController animated:YES completion:NULL];
    }
    
    
    //TODO https://www.ecanarys.com/Blogs/ArticleID/94/How-to-Save-Photos-to-Custom-Album-in-iPhone-iPad-Photo-Library
    //TODO #import <Photos/Photos.h>
}



/*
 - (void)insertImage:(UIImage *)image intoAlbumNamed:(NSString *)albumName {
 //Fetch a collection in the photos library that has the title "albumNmame"
 PHAssetCollection *collection = [self fetchAssetCollectionWithAlbumName: albumName];
 
 if (collection == nil) {
 //If we were unable to find a collection named "albumName" we'll create it before inserting the image
 [[PHPhotoLibrary sharedPhotoLibrary] performChanges:^{
 [PHAssetCollectionChangeRequest creationRequestForAssetCollectionWithTitle: albumName];
 } completionHandler:^(BOOL success, NSError * _Nullable error) {
 if (error != nil) {
 NSLog(@"Error inserting image into album: %@", error.localizedDescription);
 }
 
 if (success) {
 //Fetch the newly created collection (which we *assume* exists here)
 PHAssetCollection *newCollection = [self fetchAssetCollectionWithAlbumName:albumName];
 [self insertImage:image intoAssetCollection: newCollection];
 }
 }];
 } else {
 //If we found the existing AssetCollection with the title "albumName", insert into it
 [self insertImage:image intoAssetCollection: collection];
 }
 }
 
 - (PHAssetCollection *)fetchAssetCollectionWithAlbumName:(NSString *)albumName {
 PHFetchOptions *fetchOptions = [PHFetchOptions new];
 //Provide the predicate to match the title of the album.
 fetchOptions.predicate = [NSPredicate predicateWithFormat:[NSString stringWithFormat:@"title == '%@'", albumName]];
 
 //Fetch the album using the fetch option
 PHFetchResult *fetchResult = [PHAssetCollection fetchAssetCollectionsWithType:PHAssetCollectionTypeAlbum subtype:PHAssetCollectionSubtypeAlbumRegular options:fetchOptions];
 
 //Assuming the album exists and no album shares it's name, it should be the only result fetched
 return fetchResult.firstObject;
 }
 
 - (void)insertImage:(UIImage *)image intoAssetCollection:(PHAssetCollection *)collection {
 [[PHPhotoLibrary sharedPhotoLibrary] performChanges:^{
 
 //This will request a PHAsset be created for the UIImage
 PHAssetCreationRequest *creationRequest = [PHAssetCreationRequest creationRequestForAssetFromImage:image];
 
 //Create a change request to insert the new PHAsset in the collection
 PHAssetCollectionChangeRequest *request = [PHAssetCollectionChangeRequest changeRequestForAssetCollection:collection];
 
 //Add the PHAsset placeholder into the creation request.
 //The placeholder is used because the actual PHAsset hasn't been created yet
 if (request != nil && creationRequest.placeholderForCreatedAsset != nil) {
 [request addAssets: @[creationRequest.placeholderForCreatedAsset]];
 }
 } completionHandler:^(BOOL success, NSError * _Nullable error) {
 if (error != nil) {
 NSLog(@"Error inserting image into asset collection: %@", error.localizedDescription);
 }
 }];
 }
 */
/*
 - (IBAction)addAlbumClicked:(id)sender{
 
 UIAlertView * alert = [[UIAlertView alloc] initWithTitle:@"New album..." message:@"Enter the album name" delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"Save",nil];
 alert.alertViewStyle = UIAlertViewStylePlainTextInput;
 [alert show];
 }
 
 - (IBAction)settingsClicked:(id)sender{
 
 UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil
 message:@"Will show a listview here"
 delegate:nil
 cancelButtonTitle:@"OK"
 otherButtonTitles:nil];
 [alert show];
 
 }
 
 //the delegate for the new Album
 - (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
 
 if(buttonIndex==1) { //0 - cancel, 1 - save
 NSString *albumName = [alertView textFieldAtIndex:0].text;
 [self createNewAlbum:albumName];
 }
 
 }

*/

#pragma take photo selector
- (IBAction)takePhoto:(id)sender {
    UIImagePickerController *imagePickerController = [[UIImagePickerController alloc] init];
    imagePickerController.sourceType = UIImagePickerControllerSourceTypeCamera;
	imagePickerController.editing = YES;
    imagePickerController.delegate = (id)self;
    
    [self presentModalViewController:imagePickerController animated:YES];
}

-(IBAction)addLocation:(id)sender {
    
    
    
    NSLog(@"selected album index: %lu %lu",(unsigned long)selectedAlbumIndex, (unsigned long)selectedAlbum.photosCount);
    
    if(self.selectedAlbum!=nil) {
        
        SearchLocationViewController *searchView = [(PCAppDelegate *)[[UIApplication sharedApplication] delegate] searchController];
        
        searchView.navigationItem.rightBarButtonItem = nil;
        searchView.navigationItem.leftBarButtonItem = nil;
        
        //OK I HAVE THE SELECTED ALBUM
        //BHAlbum *theSelectedAlbum = self.selectedAlbum;// [self.albums objectAtIndex:selectedAlbumIndex];
        searchView.selectedAlbum = self.selectedAlbum;
        searchView.assetURL = self.selectedAlbum.assetURL; //set the asset url (nil if a yealy album)
        //searchView.selectedAlbum.photosURLs = [[NSMutableArray alloc] initWithCapacity:selectedAlbum.photosCount];
        //[searchView.selectedAlbum.photosURLs addObjectsFromArray:[selectedAlbum photosURLs]];
        
        NSLog(@"ASSET URL HERE %@ %@",self.selectedAlbum.assetURL,searchView.assetURL);
        
        //assign the correct photo
        if(searchView.selectedAlbum.photosURLs.count>0) {
            //TODO this photos is not being added
            BHPhoto *photo = [searchView.selectedAlbum.photos objectAtIndex:0];
            searchView.image = photo.image;
            //we save the thumbnail URL on the LocationDataModel
            searchView.thumbnailURL = photo.imageURL;
        }
        else {
            searchView.image = [UIImage imageNamed:@"concrete"];
            searchView.thumbnailURL = nil;
        }
        
        searchView.mapView = [(PCAppDelegate *)[[UIApplication sharedApplication] delegate] mapViewController];
        
        
        [self.navigationController pushViewController:searchView animated:NO];
    } else {
        NSLog(@"OOPS!!!");
    }
    
    
}

- (IBAction)deleteAlbum:(id)sender {
    
    if(selectedAlbum!=nil) {
        NSLog(@"DELETE ALBUM %@",selectedAlbum.name);
        
        
        if([selectedAlbum isFakeAlbum]) {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil
                                                            message:@"This is a fake album (only exists inside the app), and cannot be deleted!"
                                                           delegate:nil
                                                  cancelButtonTitle:@"OK"
                                                  otherButtonTitles:nil];
            alert.tag = DELETE_ABUM_TAG;
            alert.delegate = self;
            [alert show];
            
        }else {
            //otherwise continue
            PHFetchOptions *fetchOptions = [[PHFetchOptions alloc] init];
            
            fetchOptions.predicate = [NSPredicate predicateWithFormat:@"localizedTitle = %@", selectedAlbum.name];
             PHFetchResult *fetchResult = [PHAssetCollection fetchAssetCollectionsWithType:PHAssetCollectionTypeAlbum subtype:PHAssetCollectionSubtypeAny options:fetchOptions];
            if(fetchResult.count == 1) {
                
                [[PHPhotoLibrary sharedPhotoLibrary] performChanges:^{
                    NSArray *toDelete = [[NSArray alloc] initWithObjects:fetchResult.firstObject, nil];
                    [PHAssetCollectionChangeRequest deleteAssetCollections:toDelete];
                 
                    //[assetCollectionChangeRequest addAssets:@[[assetChangeRequest placeholderForCreatedAsset]]];

                } completionHandler:^(BOOL success, NSError *error) {
                    if (!success) {
                        NSLog(@"Error deleting album: %@", error);
                    } else {
                        NSLog(@"Deleted album %@ ",self.selectedAlbum.name);
                        
                        //TODO remove from the list of albums and reload webview
                        [self.albumsNames removeObject:self.selectedAlbum.name];
                        //
                        if(self.rootViewController!=nil) {
                            [self.rootViewController deleteAlbum:self.selectedAlbum completion:^(BOOL deleted) {
                                [self.navigationController popToRootViewControllerAnimated:YES];
                                //TODO remove them from the root view controller too!!!!
                            }];
                        } else {
                            //BAD THINGS HAPPENED!!!
                            [self.navigationController popToRootViewControllerAnimated:YES];
                        }
                        
                    }
                }];
            }
        }
    }
}


#pragma mark Image picker delegate methdos
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingImage:(UIImage *)image editingInfo:(NSDictionary *)editingInfo

{
    
    [picker dismissViewControllerAnimated:NO
                               completion: ^{[self showAlbumsList: image editingInfo:editingInfo];}];
}

- (void) showAlbumsList:(UIImage *)image editingInfo:(NSDictionary *)editingInfo {
    
    
    
    NSMutableArray *albumsAvailable = [[NSMutableArray alloc]init];
    for(NSString *albumName in albumsNames) {
        [albumsAvailable addObject:albumName];
    }

    listAlbumsAvailableController =
    [[AlbumsListViewController alloc] initWithNibName:@"AlbumsListViewController"
                                               bundle:nil predefined:selectedAlbum.name available:albumsAvailable];
    //pass the necessary info
    listAlbumsAvailableController.imageToSave = image;
    listAlbumsAvailableController.imageInfo = editingInfo;
    listAlbumsAvailableController.photoLocation = self.location;
    
    [self.navigationController pushViewController:listAlbumsAvailableController animated:NO];
}


//save the image along with their metadata info
- (void) saveImage:(UIImage *)imageToSave withInfo:(NSDictionary *)info
{
    ALAssetsLibrary *library = [[ALAssetsLibrary alloc] init];
    // Get the image metadata (EXIF & TIFF)
    NSMutableDictionary * imageMetadata = [[info objectForKey:UIImagePickerControllerMediaMetadata] mutableCopy];
    
    if(imageMetadata==nil){
        //NSLog(@"this one is nil");
        imageMetadata = [[NSMutableDictionary alloc]init];
    }
    // add GPS data
    // need a location here
    if ( self.location!=nil ) {
        NSDictionary *locationInfo = [self getGPSDictionaryForLocation:self.location];
        NSLog(@"Location dictionary is: %@",locationInfo);
        [imageMetadata setObject:locationInfo forKey:(NSString*)kCGImagePropertyGPSDictionary];
    }
    // Get the assets library
    ALAssetsLibraryWriteImageCompletionBlock imageWriteCompletionBlock =
    ^(NSURL *newURL, NSError *error) {
        if (error) {
            NSLog( @"Error writing image with metadata to Photo Library: %@", error );
        } else {
            NSLog( @"Wrote image %@ with metadata %@ to Photo Library",newURL,imageMetadata);
        }
    };
    // Save the new image to the Camera Roll
    [library writeImageToSavedPhotosAlbum:[imageToSave CGImage]
                                 metadata:imageMetadata
                          completionBlock:imageWriteCompletionBlock];
    //[imageMetadata release];
    //[library release];
}



- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
    [picker dismissModalViewControllerAnimated:NO];
}

//read all the photo thumbnaisl of the passed/selected album
- (void)readAlbumThumbnails {
    
    NSInteger __block processed = 0;
    NSInteger count = selectedAlbum.photosURLs.count;
    
    NSLog(@"IMAGES COUNT %ld", (long)count);
    //only if not the same
    
    [self.albums removeAllObjects];
    

    
    if(count > 0) {
        PHImageManager *imageManager = [PHImageManager defaultManager];
        PHFetchOptions *options = [PHFetchOptions new];
        options.predicate = [NSPredicate predicateWithFormat:@"mediaType == %ld", PHAssetMediaTypeImage];
        
        PHFetchResult<PHAsset *> *assets = [PHAsset fetchAssetsWithLocalIdentifiers:self.selectedAlbum.photosURLs options:options];
        if(assets!=nil && assets.count > 0) {
            
            for(PHAsset *asset in assets){
                if(asset!=nil){
                   PHImageRequestOptions *requestOptions = [[PHImageRequestOptions alloc] init];
                   requestOptions.resizeMode   = PHImageRequestOptionsResizeModeExact;
                   requestOptions.networkAccessAllowed = true;
                   requestOptions.deliveryMode = PHImageRequestOptionsDeliveryModeHighQualityFormat;
                   requestOptions.synchronous = true;
                   
                   [imageManager requestImageForAsset:asset
                                          targetSize:CGSizeMake(125.0f, 125.0f)
                                         contentMode:PHImageContentModeDefault
                                             options:requestOptions
                                       resultHandler:^void(UIImage *thumbnail, NSDictionary *info) {
                                           if(thumbnail!=nil) {
                                               
                                               NSLog(@"loaded thumbnail %ld", processed +1);
                                               BHAlbum *albumSingle = [[BHAlbum alloc] init];
                                               albumSingle.photosURLs = [[NSMutableArray alloc] init];
                                                
                                                //if the record exists on DB, try get the title name from the album/pic description
                                                NSString *theURL = asset.localIdentifier;
                                                if(theURL!=nil) {
                                                    NSMutableArray *records = [CoreDataUtils fetchLocationRecordsFromDatabaseWithAssetURL:theURL];
                                                    if(records!=nil && records.count==1) {
                                                        LocationDataModel *model = [records objectAtIndex:0];
                                                        if(![model.desc isEqualToString:@"NA"]) {
                                                            albumSingle.name = model.desc;
                                                        }
                                                        else {
                                                            //DEFAULT
                                                            albumSingle.name = [NSString stringWithFormat:@"%lu",(unsigned long)self.albums.count ];
                                                        }
                                                    }
                                                    
                                                }
                                                else {
                                                     //DEFAULT
                                                     albumSingle.name = [NSString stringWithFormat:@"%lu",(unsigned long)self.albums.count ];
                                                }
                                                
                                        
                                               
                                                processed++;
                                                

                                                BHPhoto *photo = [BHPhoto photoWithImageData: thumbnail];
                                                photo.imageURL = theURL;
                                                [albumSingle addPhoto:photo];
                                               
                                               //save the URL of the asset Photo
                                               [albumSingle.photosURLs addObject: asset.localIdentifier];
                                               //add to the list of albums (each of these albums has just one image)
                                               [self.albums addObject:albumSingle];
                                               
                                               
                                                //TODO check is only refreshing the view after all images have been processed, might want to do it every one or every 2 or 3 for instance
                                                if(processed == count) {
                                                    NSLog(@"PROCESSED %ld albums count: %ld", (long)processed , self.albums.count);
                                                    //NOTE the selected album only has 3 photos processed, so when reading the cell content we should get the pic from self.albums[section].photos[0]
                                                    self.selectedAlbum.photosCount = processed;
                                                    
                                                    [self refreshCollection];
                                                }
                                               
                                           }
                       }];
                }
            }
        }
        
       // [self refreshCollection]; //maybe invalidate layout too?
        
    }
   
    

    
    
    
    
}

- (void)selectAllAlbumThumbnails: (BOOL) select {
    
    //set them as selected
    for(BHAlbum *album in self.albums) {
        BHPhoto *photo = [album.photos objectAtIndex:0];
        photo.isSelected = select;
    }
    selectedItems = select ? self.albums.count : 0;
    
    //make the table refresh
    //[self.collectionView.collectionViewLayout invalidateLayout];
    [self refreshCollection];
    
    
}

-(void) refreshCollection {
     
    //dispatch_async(dispatch_get_main_queue(), ^{
        [self.collectionView.collectionViewLayout invalidateLayout];
        [self.collectionView reloadData];
        [self.collectionView performBatchUpdates:^{
                
           NSArray *indexpaths = self.collectionView.indexPathsForVisibleItems;
           if(indexpaths!=nil && indexpaths.count>0) {
               
               for(NSIndexPath *path in indexpaths) {
                   NSLog(@"VISIBLE PATH ROW: %ld SECTION %ld", (long)path.row, (long)path.section);
               }
               
              [self.collectionView reloadItemsAtIndexPaths:indexpaths];
               
           }
        } completion:^(BOOL finished) {
            // Called async when all animations are finished; finished = NO if cancelled
        }];
    //});
    
    
}

-(void) reloadAlbumAssets {
    
    //TODO need to recreate the entire album strcuture
    //read photos, photos url etc..
    //and them call [self readAlbumThumbnails];
    
    //[self.selectedAlbum.photosURLs removeAllObjects];
    //[self.selectedAlbum.photos removeAllObjects];

    //add all the urls using PHAsset
    //[self readAlbumThumbnails];
    //will also reload the view
}

-(void)selectAlbumPhoto: (BOOL) select atIndex:(NSInteger) index {

    if(index < self.albums.count) {
        
        self.selectedPhoto  = [self.albums objectAtIndex:index];
        
        if(select) {
            
            BHPhoto *photo = [self.selectedPhoto.photos objectAtIndex:0];
            photo.isSelected = select;
            //TODO the button should not be called select all anymore
            self.selectedAction = ACTION_ADD_TO_ALBUM;
            self.navigationItem.rightBarButtonItem.tag = ACTION_ADD_TO_ALBUM;
            self.navigationItem.rightBarButtonItem.title = @"Add to album";
            selectedItems+=1;
        }
        else {
            BHPhoto *photo = [self.selectedPhoto.photos objectAtIndex:0];
            photo.isSelected = select;
            self.selectedPhoto = nil;
            selectedItems-=1;
            if(selectedItems < 0) {
               selectedItems = 0;
            }
        }
        
        //make the table refresh
        [self refreshCollection];
    }
    
}


#pragma mark - UICollectionViewDataSource

//each section is a photo
- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    NSLog(@"numberOfSectionsInCollectionView NUM photos in album is %lu",(unsigned long)selectedAlbum.photosURLs.count);
    return selectedAlbum.photosURLs.count > 0 ? selectedAlbum.photosURLs.count : 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    //number of images on top of the others/paging ilussion, should be always 1
    if(selectedAlbum.photosURLs.count > 0) {
       return 1;
    }
    return 0;
}

//TODO i just changed the animation on the push, and the title, don´t know why i got the ghost albums at 1st run..
//I SHOULD JUST MOVE TO NEXT PAGE(details) ON DOUBLE TAP (or button labeled GO)
//OTHERWISE IT SHOULD JUST SELECT

//TODO implement this instead of the tap gesture

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(nonnull NSIndexPath *)indexPath {
    BHAlbumPhotoCell *photoCell =
    [collectionView dequeueReusableCellWithReuseIdentifier:PhotoCellIdentifier
                                              forIndexPath:indexPath];
    
    NSInteger row = indexPath.section;
    NSInteger photoIndex = indexPath.item;
    
    if(row < self.albums.count) {
        self.selectedPhoto = self.albums[row];
    }
    [photoCell setPhotoSelected:true];
    
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView
                  cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
  
    BHAlbumPhotoCell *photoCell =
    [collectionView dequeueReusableCellWithReuseIdentifier:PhotoCellIdentifier
                                              forIndexPath:indexPath];
    //NOTE the section is the index, because the number of sections is the number of pics on th ecurrent album
    
    NSInteger row = indexPath.row;
    NSInteger photoIndex = indexPath.section;
    
    NSLog(@"ROW is %ld count %ld section/index %ld", (long)row, self.selectedAlbum.photosCount, photoIndex);
    if( (photoIndex < self.selectedAlbum.photosURLs.count && row == 0) ) {
        
        
        
        NSInteger tag = photoIndex;
        
        if(self.albums!=nil && photoIndex < self.albums.count) {
            
            BHAlbum *albumSelected = self.albums[photoIndex];
            
            BHPhoto *photo = albumSelected.photos[0];//which should only be 1indexPath.item
            BOOL isSelected = photo.isSelected;
            
            NSLog(@"WILL SET IMAGE %@ at index %ld",photo.image.description,(long) photoIndex);
            dispatch_async(dispatch_get_main_queue(), ^(){
               photoCell.imageView.image = photo.image;
            });
            
            photoCell.imageView.userInteractionEnabled = YES;
            [photoCell setPhotoSelected:isSelected];
            //TODO do i need to have this alos on the main thread?? probably just update the image no???
            photoCell.imageView.tag = tag;
            UITapGestureRecognizer *tapGesture =[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(didTapImageWithGesture:)];
            [photoCell.imageView addGestureRecognizer:tapGesture];
         
        } else {
            NSLog(@"WTF");
        }
        
    }
    
    
    
    return photoCell;
}

- (UICollectionReusableView *)collectionView:(UICollectionView *)collectionView
           viewForSupplementaryElementOfKind:(NSString *)kind
                                 atIndexPath:(NSIndexPath *)indexPath;
{
    //NSLog(@"WHAT ABOUT HERE? indexpath: %d albumPhotos count:%d",indexPath.section,albumPhotos.count);
    
    
    BHAlbumTitleReusableView *titleView =
    [collectionView dequeueReusableSupplementaryViewOfKind:kind
                                       withReuseIdentifier:AlbumTitleIdentifier
                                              forIndexPath:indexPath];
    NSInteger row = indexPath.section;
    /*if(self.albums.count >0 && row < self.albums.count) {
        BHAlbum *albumSelected = self.albums[indexPath.section];
        titleView.titleLabel.text = albumSelected.name;
    }
    else {*/
        titleView.titleLabel.text = [NSString stringWithFormat:@"%ld",(long)row];
    //}
    
    return titleView;
}

- (void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation
                                duration:(NSTimeInterval)duration
{
    if (UIInterfaceOrientationIsLandscape(toInterfaceOrientation)) {
        self.photoAlbumLayout.numberOfColumns = 3;
        
        // handle insets for iPhone 4 or 5
        CGFloat sideInset = [UIScreen mainScreen].preferredMode.size.width == 1136.0f ?
        45.0f : 25.0f;
        
        self.photoAlbumLayout.itemInsets = UIEdgeInsetsMake(22.0f, sideInset, 13.0f, sideInset);
        
    } else {
        self.photoAlbumLayout.numberOfColumns = 2;
        self.photoAlbumLayout.itemInsets = UIEdgeInsetsMake(22.0f, 22.0f, 13.0f, 22.0f);
    }
}


//the user tapped on the image
- (void)didTapImageWithGesture:(UITapGestureRecognizer *)tapGesture{
    
    UIImageView *imageView = (UIImageView*)tapGesture.view;
    NSInteger tag = imageView.tag; // this is the index on the select album
    
    NSLog(@"selected image/album is %ld",(long)tag);
    
    
    if(tag < self.albums.count) {
       
        //represents here an album with just one image
        BHAlbum *albumTap = [self.albums objectAtIndex:tag];
        
        //these "albums" are made of only 1 image
        BHPhoto *photo = [albumTap.photos objectAtIndex:0];
        
        //nothing selected yet, select it now
        if(self.selectedAction==ACTION_ADD_TO_ALBUM) {
            
            
            if(!photo.isSelected) {
                
                [self selectAlbumPhoto:YES atIndex:tag];
                NSLog(@"select now at position %ld",(long)tag);
            }
            else {
                [self selectAlbumPhoto:NO atIndex:tag];
                NSLog(@"Unselect now at position %ld",(long)tag);
            }
            

        }
        else {
            //JUST SHOW DETAIL
            detailViewController.title = albumTap.name;
            //each of these albums only has one image
            NSLog(@"SHOW DETAIL: The url here is : %@, just to make sure num photos is : %ld",[albumTap.photosURLs objectAtIndex:0],(long)albumTap.photosURLs.count);
            NSLog(@"ALBUMS COUNT:  %ld",(long) self.albums.count);
            detailViewController.enclosingAlbum = selectedAlbum;
            detailViewController.selectedIndex = tag;
            /************************************************************/
            //here the single "albums"
            //WAS OK detailViewController.singleAlbums = [[NSMutableArray alloc] initWithArray:self.albums];
            
            [detailViewController resetAlbumsListFromList: self.albums];
            
            //pass the map too
            detailViewController.mapViewController = self.mapViewController;
            
            NSLog(@"2nd ALBUMS COUNT:  %ld",(long) detailViewController.singleAlbums.count);
            //**********************************
            //the albumTap has just one image
            detailViewController.assetURL = [albumTap.photosURLs objectAtIndex:0];
            NSLog(@"pushing now: with assetURL %@ index > %ld",detailViewController.assetURL,tag);
            [self.navigationController pushViewController:detailViewController animated:NO];
        }
        
    }
    
      
    
}

//NSDictionary *metadata = asset.defaultRepresentation.metadata;
- (NSDictionary *)getGPSDictionaryForLocation:(CLLocation *)location {
    NSMutableDictionary *gps = [NSMutableDictionary dictionary];
    
    // GPS tag version
    [gps setObject:@"2.2.0.0" forKey:(NSString *)kCGImagePropertyGPSVersion];
    
    // Time and date must be provided as strings, not as an NSDate object
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"HH:mm:ss.SSSSSS"];
    [formatter setTimeZone:[NSTimeZone timeZoneWithAbbreviation:@"UTC"]];
    [gps setObject:[formatter stringFromDate:location.timestamp] forKey:(NSString *)kCGImagePropertyGPSTimeStamp];
    [formatter setDateFormat:@"yyyy:MM:dd"];
    [gps setObject:[formatter stringFromDate:location.timestamp] forKey:(NSString *)kCGImagePropertyGPSDateStamp];
    //[formatter release];
    
    // Latitude
    CGFloat latitude = location.coordinate.latitude;
    if (latitude < 0) {
        latitude = -latitude;
        [gps setObject:@"S" forKey:(NSString *)kCGImagePropertyGPSLatitudeRef];
    } else {
        [gps setObject:@"N" forKey:(NSString *)kCGImagePropertyGPSLatitudeRef];
    }
    [gps setObject:[NSNumber numberWithFloat:latitude] forKey:(NSString *)kCGImagePropertyGPSLatitude];
    
    // Longitude
    CGFloat longitude = location.coordinate.longitude;
    if (longitude < 0) {
        longitude = -longitude;
        [gps setObject:@"W" forKey:(NSString *)kCGImagePropertyGPSLongitudeRef];
    } else {
        [gps setObject:@"E" forKey:(NSString *)kCGImagePropertyGPSLongitudeRef];
    }
    [gps setObject:[NSNumber numberWithFloat:longitude] forKey:(NSString *)kCGImagePropertyGPSLongitude];
    
    // Altitude
    CGFloat altitude = location.altitude;
    if (!isnan(altitude)){
        if (altitude < 0) {
            altitude = -altitude;
            [gps setObject:@"1" forKey:(NSString *)kCGImagePropertyGPSAltitudeRef];
        } else {
            [gps setObject:@"0" forKey:(NSString *)kCGImagePropertyGPSAltitudeRef];
        }
        [gps setObject:[NSNumber numberWithFloat:altitude] forKey:(NSString *)kCGImagePropertyGPSAltitude];
    }
    
    // Speed, must be converted from m/s to km/h
    if (location.speed >= 0){
        [gps setObject:@"K" forKey:(NSString *)kCGImagePropertyGPSSpeedRef];
        [gps setObject:[NSNumber numberWithFloat:location.speed*3.6] forKey:(NSString *)kCGImagePropertyGPSSpeed];
    }
    
    // Heading
    if (location.course >= 0){
        [gps setObject:@"T" forKey:(NSString *)kCGImagePropertyGPSTrackRef];
        [gps setObject:[NSNumber numberWithFloat:location.course] forKey:(NSString *)kCGImagePropertyGPSTrack];
    }
    
    return gps;
}


#pragma NEW STUFF
#pragma mark - Public Method

- (void)saveImage:(UIImage *)image
          toAlbum:(NSString *)albumName
       completion:(ALAssetsLibraryWriteImageCompletionBlock)completion
          failure:(ALAssetsLibraryAccessFailureBlock)failure
{
    if(self.assetslibrary==nil) {
        self.assetslibrary = [[ALAssetsLibrary alloc] init];
    }
    
  [self.assetslibrary writeImageToSavedPhotosAlbum:image.CGImage
                         orientation:(ALAssetOrientation)image.imageOrientation
                     completionBlock:[self _resultBlockOfAddingToAlbum:albumName
                                                            completion:completion
                                                               failure:failure]];
}

- (void)saveVideo:(NSURL *)videoUrl
          toAlbum:(NSString *)albumName
       completion:(ALAssetsLibraryWriteImageCompletionBlock)completion
          failure:(ALAssetsLibraryAccessFailureBlock)failure
{
    if(self.assetslibrary==nil) {
        self.assetslibrary = [[ALAssetsLibrary alloc] init];
    }
    
    [self.assetslibrary writeVideoAtPathToSavedPhotosAlbum: videoUrl
                             completionBlock:[self _resultBlockOfAddingToAlbum:albumName
                                                                    completion:completion
                                                                       failure:failure]];
}

- (void)saveImageData:(NSData *)imageData
              toAlbum:(NSString *)albumName
             metadata:(NSDictionary *)metadata
           completion:(ALAssetsLibraryWriteImageCompletionBlock)completion
              failure:(ALAssetsLibraryAccessFailureBlock)failure
{
  
    if(self.assetslibrary==nil) {
        self.assetslibrary = [[ALAssetsLibrary alloc] init];
    }
    
    [self.assetslibrary writeImageDataToSavedPhotosAlbum:imageData
                                metadata:metadata
                         completionBlock:[self _resultBlockOfAddingToAlbum:albumName
                                                                completion:completion
                                                                   failure:failure]];
  
}

#pragma mark - Private Method

-(void)_addAssetURL:(NSURL *)assetURL
            toAlbum:(NSString *)albumName
            failure:(ALAssetsLibraryAccessFailureBlock)failure
{
  __block BOOL albumWasFound = NO;
  
  ALAssetsLibraryGroupsEnumerationResultsBlock enumerationBlock;
  enumerationBlock = ^(ALAssetsGroup *group, BOOL *stop) {
    // compare the names of the albums
    if ([albumName compare:[group valueForProperty:ALAssetsGroupPropertyName]] == NSOrderedSame) {
      // target album is found
      albumWasFound = YES;
      
    if(self.assetslibrary==nil) {
        self.assetslibrary = [[ALAssetsLibrary alloc] init];
    }
      
      // get a hold of the photo's asset instance
      [self.assetslibrary assetForURL:assetURL
            resultBlock:^(ALAsset *asset) {
              // add photo to the target album
              [group addAsset:asset];
            }
           failureBlock:failure];
      
      // album was found, bail out of the method
      return;
    }
    
    if (group == nil && albumWasFound == NO) {
      // photo albums are over, target album does not exist, thus create it
      
      // Since you use the assets library inside the block,
      //   ARC will complain on compile time that there’s a retain cycle.
      //   When you have this – you just make a weak copy of your object.
      //
      //   __weak ALAssetsLibrary * weakSelf = self;
      //
      // by @Marin.
      //
      // I don't use ARC right now, and it leads a warning.
      // by @Kjuly
      ALAssetsLibrary * weakSelf = self;
      
      // if iOS version is lower than 5.0, throw a warning message
      if (! [self respondsToSelector:@selector(addAssetsGroupAlbumWithName:resultBlock:failureBlock:)])
        NSLog(@"![WARNING][LIB:ALAssetsLibrary+CustomPhotoAlbum]: \
              |-addAssetsGroupAlbumWithName:resultBlock:failureBlock:| \
              only available on iOS 5.0 or later. \
              ASSET cannot be saved to album!");
        
        if(self.assetslibrary==nil) {
            self.assetslibrary = [[ALAssetsLibrary alloc] init];
        }
      // create new assets album
      else [self.assetslibrary addAssetsGroupAlbumWithName:albumName
                                 resultBlock:^(ALAssetsGroup *group) {
                                   // get the photo's instance
                                   [weakSelf assetForURL:assetURL
                                             resultBlock:^(ALAsset *asset) {
                                               // add photo to the newly created album
                                               [group addAsset:asset];
                                             }
                                            failureBlock:failure];
                                 }
                                failureBlock:failure];
      
      // should be the last iteration anyway, but just in case
      return;
    }
  };
  
    if(self.assetslibrary==nil) {
        self.assetslibrary = [[ALAssetsLibrary alloc] init];
    }
  // search all photo albums in the library
  [self.assetslibrary enumerateGroupsWithTypes:ALAssetsGroupAlbum
                      usingBlock:enumerationBlock
                    failureBlock:failure];
}

- (ALAssetsLibraryWriteImageCompletionBlock)_resultBlockOfAddingToAlbum:(NSString *)albumName
                                                             completion:(ALAssetsLibraryWriteImageCompletionBlock)completion
                                                                failure:(ALAssetsLibraryAccessFailureBlock)failure
{
  ALAssetsLibraryWriteImageCompletionBlock result = ^(NSURL *assetURL, NSError *error) {
    // run the completion block for writing image to saved
    //   photos album
    if (completion) completion(assetURL, error);
    
    // if an error occured, do not try to add the asset to
    //   the custom photo album
    if (error != nil)
      return;
    
    // add the asset to the custom photo album
    [self _addAssetURL:assetURL
               toAlbum:albumName
               failure:failure];
  };
  return [result copy];
}

#pragma image picker delegate methods
- (void)qb_imagePickerController:(QBImagePickerController *)imagePickerController didFinishPickingAssets:(NSArray *)assets {
    //first get the album
    PHAssetCollection *assetCollection = [self findAlbumByName:self.selectedAlbum.name];
    if(assetCollection!=nil) {
        
        //PHImageRequestOptions *requestOptions = [[PHImageRequestOptions alloc] init];
        //requestOptions.resizeMode   = PHImageRequestOptionsResizeModeExact;
        //requestOptions.networkAccessAllowed = true;
        //requestOptions.deliveryMode = PHImageRequestOptionsDeliveryModeHighQualityFormat;
        
        // this one is key
        //requestOptions.synchronous = YES;
        
        NSMutableArray *assetsArray = [NSMutableArray arrayWithArray:assets];
        //PHImageManager *manager = [PHImageManager defaultManager];
      
        //save them on group
        [[PHPhotoLibrary sharedPhotoLibrary] performChanges:^{
                //PHAssetChangeRequest *assetChangeRequest = [PHAssetChangeRequest cr:asset];
            PHAssetCollectionChangeRequest *assetCollectionChangeRequest = [PHAssetCollectionChangeRequest changeRequestForAssetCollection:assetCollection];
                [assetCollectionChangeRequest addAssets:assetsArray];

        } completionHandler:^(BOOL success, NSError *error) {
                if (!success) {
                    NSLog(@"Error persistsing asset: %@", error);
                } else {
                    NSLog(@"Persisted assets on new album");
                    [self getAllPHAssetsFromAlbum:assetCollection];
                }
            [self dismissViewControllerAnimated:YES completion:NULL];
        }];
    } else {
       [self dismissViewControllerAnimated:YES completion:NULL];
    }
    
    
    

    
}

- (void)qb_imagePickerControllerDidCancel:(QBImagePickerController *)imagePickerController {
    [self dismissViewControllerAnimated:YES completion:NULL];
}

- (PHAssetCollection *) findAlbumByName: (NSString *) albumName {
    
    PHFetchOptions *fetchOptions = [[PHFetchOptions alloc] init];
    
    fetchOptions.predicate = [NSPredicate predicateWithFormat:@"localizedTitle = %@", albumName];
     PHFetchResult *fetchResult = [PHAssetCollection fetchAssetCollectionsWithType:PHAssetCollectionTypeAlbum subtype:PHAssetCollectionSubtypeAny options:fetchOptions];
    //first check if already exists, only add if not
    if (fetchResult.count >= 1) {
        return (PHAssetCollection *)fetchResult.firstObject;
    }
    
    return nil;
}
/*
-(void)newReloadAlbumAssets: (NSMutableArray * )imagesArray {
    
    PHImageRequestOptions *requestOptions = [[PHImageRequestOptions alloc] init];
    requestOptions.resizeMode   = PHImageRequestOptionsResizeModeExact;
    requestOptions.networkAccessAllowed = true;
    requestOptions.deliveryMode = PHImageRequestOptionsDeliveryModeHighQualityFormat;
    
    // this one is key
    requestOptions.synchronous = YES;
    
    PHImageManager *manager = [PHImageManager defaultManager];
    
    dispatch_async(dispatch_get_main_queue(), ^(){
        
       
    for (PHAsset *asset in imagesArray) {
        // Do something with the asset
        
        [manager requestImageForAsset:asset
                           targetSize:PHImageManagerMaximumSize
                          contentMode:PHImageContentModeDefault
                              options:requestOptions
                        resultHandler:^void(UIImage *image, NSDictionary *info) {
                            if(image!=nil) {
                               // [self.attachments addObject:image];
                                //PHImageFileURLKey could be nil if the key is not present, so we add dummy string instead
                                NSURL *url = [info objectForKey: @"PHImageFileURLKey"];
                                if(url==nil) {
                                    url = [NSURL URLWithString:@"file:///var/mobile/media/dcim/100apple/pic.png"];
                                }
                                NSArray *data = [[NSArray alloc] initWithObjects:image, url.absoluteString, nil];
                               // [self.attachments addObject:data];
                           
                            }
                            
                        }];
        
        
    }
        
    });
}*/

//TODO REFACTOR NO ALA ASSETS STUFF
-(void) getAllPHAssetsFromAlbum: (PHAssetCollection *) albumCollection {
    
        
    PHFetchResult *results = [PHAsset fetchAssetsInAssetCollection:albumCollection options:nil];
    if(results!=nil && results.count > 0) {
    
        NSMutableArray *assetsArray = [[NSMutableArray alloc] initWithCapacity:results.count];
        
        [self.selectedAlbum.photos removeAllObjects];
        [self.selectedAlbum.photosURLs removeAllObjects];
        
        for(PHAsset *asset in results) {
            
            NSLog(@"LOCAL IDENTIFIER IS %@", asset.localIdentifier);
            [self.selectedAlbum.photosURLs addObject: asset.localIdentifier];
            
            NSLog(@"TYPE IS %@",[asset valueForKey:@"uniformTypeIdentifier"]);
            
            [assetsArray addObject:asset];
        }
        if(assetsArray.count > 0) {
            [self readAlbumThumbnails];
        }
        
        NSLog(@"GOT %lu Assets from album %@", (unsigned long)assetsArray.count, self.selectedAlbum.name);
        //TODO reload the collection view
        //READ https://stackoverflow.com/questions/28887638/how-to-get-an-alasset-url-from-a-phasset
    }
    /**
     
        Create the assetURL by leveraging the localidentifier of the PHAsset. Example: PHAsset.localidentifier returns 91B1C271-C617-49CE-A074-E391BA7F843F/L0/001

        Now take the 32 first characters to build the assetURL, like:

        assets-library://asset/asset.JPG?id=91B1C271-C617-49CE-A074-E391BA7F843F&ext=JPG

        You might change the extension JPG depending on the UTI of the asset (requestImageDataForAsset returns the UTI), but in my testing the extensions of the assetURL seems to be ignored anyhow.
     */
    /*/PHAsset* legacyAsset = [PHAsset fetchAssetsWithALAssetUrls:@[assetUrl] options:nil].firstObject;
    NSString* convertedIdentifier = legacyAsset.localIdentifier;*/
}

@end
