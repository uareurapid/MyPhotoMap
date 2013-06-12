//
//  AlbumsListViewController.h
//  CollectionViewTutorial
//
//  Created by Paulo Cristo on 6/8/13.
//  Copyright (c) 2013 Bryan Hansen. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AssetsLibrary/AssetsLibrary.h>

typedef void(^SaveImageCompletion)(NSError* error);

@interface AlbumsListViewController : UITableViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil;
-(void)saveImage:(UIImage*)image toAlbum:(NSString*)albumName withCompletionBlock:(SaveImageCompletion)completionBlock;
-(void)addAssetURL:(NSURL*)assetURL toAlbum:(NSString*)albumName withCompletionBlock:(SaveImageCompletion)completionBlock;
- (void)saveOnAlbum: (UIImage*)image;

@property (strong,nonatomic) NSArray *albumsNames;
@property (strong, atomic) ALAssetsLibrary* library;
@end
