//
//  PCImageUtils.m
//  MyPhotoMap
//
//  Created by PC Dreams on 22/10/2019.
//  Copyright © 2019 Paulo Cristo. All rights reserved.
//

#import "PCImageUtils.h"

@implementation PCImageUtils

+(void) getImageFromPHAsset: (PHAsset *) asset  completion:(void (^)(UIImage *))completionBlock {
    
    /**
     if(image!=nil && model != nil && model.assetURL!=nil) {
         
         NSURL *url = [[NSURL alloc] initWithString: model.assetURL]; //convert to NSURL
         NSArray *urls = [[NSArray alloc] initWithObjects: url , nil];
         
         PHFetchResult *results = [PHAsset fetchAssetsWithALAssetURLs:urls options:nil];
         if(results!=nil && results.count > 0) {
             PHAsset *asset = (PHAsset *)results.firstObject;
             
             [self getImageFromPHAsset:asset completion:^(UIImage *image) {
                 NSLog(@"SUCCESS GOT FULL SIZE IMAGE OK 1");
                 annotation.imageFullScreen =  image;
             }];
             
         }
             
     }
     */
    
    PHImageRequestOptions *requestOptions = [[PHImageRequestOptions alloc] init];
    requestOptions.resizeMode   = PHImageRequestOptionsResizeModeExact;
    requestOptions.networkAccessAllowed = true;
    requestOptions.deliveryMode = PHImageRequestOptionsDeliveryModeHighQualityFormat;
    
    // this one is key
    requestOptions.synchronous = YES;
    
    PHImageManager *manager = [PHImageManager defaultManager];
    
    dispatch_async(dispatch_get_main_queue(), ^(){
        
        __block UIImage *theImage;
    [manager requestImageForAsset:asset
                           targetSize:PHImageManagerMaximumSize
                          contentMode:PHImageContentModeDefault
                              options:requestOptions
                        resultHandler:^void(UIImage *image, NSDictionary *info) {
                            if(image!=nil) {
                                theImage = image;
                                completionBlock(theImage);
                           
                            } else {
                                completionBlock(nil);
                            }
                            
                        }];
        
    });
}
@end
