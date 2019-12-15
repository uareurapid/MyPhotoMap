//
//  PCImageUtils.h
//  MyPhotoMap
//
//  Created by PC Dreams on 22/10/2019.
//  Copyright © 2019 Paulo Cristo. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Photos/PHPhotoLibrary.h>
#import <Photos/Photos.h>

NS_ASSUME_NONNULL_BEGIN

@interface PCImageUtils : NSObject

//get imageFromPHAssets
+(void) getImageFromPHAsset: (PHAsset *) asset withTargetSize:(CGSize) size  completion:(void (^)(UIImage *))completionBlock;
+(UIAlertView *)showActivityIndicator :(NSString *)message;
@end

NS_ASSUME_NONNULL_END
