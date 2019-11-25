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
    
    
    PHImageRequestOptions *requestOptions = [[PHImageRequestOptions alloc] init];
    requestOptions.resizeMode   = PHImageRequestOptionsResizeModeExact;
    requestOptions.networkAccessAllowed = true;
    requestOptions.deliveryMode = PHImageRequestOptionsDeliveryModeFastFormat;
    
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
