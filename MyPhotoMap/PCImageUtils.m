//
//  PCImageUtils.m
//  MyPhotoMap
//
//  Created by PC Dreams on 22/10/2019.
//  Copyright © 2019 Paulo Cristo. All rights reserved.
//

#import "PCImageUtils.h"

@implementation PCImageUtils

+(UIAlertView *)showActivityIndicator :(NSString *)message
{

   // UIAlertController *controller = [[UIAlertController alloc] init];
    
    UIAlertView *alertViewProgress = [[UIAlertView alloc] initWithTitle:message message:@"" delegate:nil cancelButtonTitle:nil otherButtonTitles:nil];
    UIActivityIndicatorView *activity =[[UIActivityIndicatorView alloc] initWithFrame:CGRectMake(120,50,37,37)];
    activity.activityIndicatorViewStyle = UIActivityIndicatorViewStyleWhiteLarge;
    [activity startAnimating];
    [alertViewProgress addSubview:activity];
    return alertViewProgress;
}

+(void) getImageFromPHAsset: (PHAsset *) asset withTargetSize:(CGSize) size  completion:(void (^)(UIImage *))completionBlock {
    
    
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
                           targetSize:size
                          contentMode:PHImageContentModeDefault
                              options:requestOptions
                        resultHandler:^void(UIImage *image, NSDictionary *info) {
                            if(image!=nil) {
                                theImage = image;
                                NSLog(@"HERE WAS OK ");
                                completionBlock(theImage);
                           
                            } else {
                                completionBlock(nil);
                            }
                            
                        }];
        
    });
}
@end
