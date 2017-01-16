/**
 * Copyright (c) 2015-present, Facebook, Inc.
 * All rights reserved.
 *
 * This source code is licensed under the BSD-style license found in the
 * LICENSE file in the root directory of this source tree. An additional grant
 * of patent rights can be found in the PATENTS file in the same directory.
 */

#import "ReactNativeStorePhotosAlbum.h"

#import <CoreLocation/CoreLocation.h>
#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

#import "RCTAssetsLibraryRequestHandler.h"
#import "RCTBridge.h"
#import "RCTConvert.h"
#import "RCTImageLoader.h"
#import "RCTLog.h"
#import "RCTUtils.h"


@implementation RCTCameraRollExtendedManager

RCT_EXPORT_MODULE()

@synthesize bridge = _bridge;

NSString *const RCTRNSPAErrorUnableToLoad = @"E_UNABLE_TO_LOAD";
NSString *const RCTRNSPAErrorUnableToSave = @"E_UNABLE_TO_SAVE";

RCT_EXPORT_METHOD(saveToCameraRoll:(NSDictionary *)tag
                  type:(NSString *)type
                  resolve:(RCTPromiseResolveBlock)resolve
                  reject:(RCTPromiseRejectBlock)reject)
{
  NSURLRequest *request = [RCTConvert NSURLRequest:tag[@"uri"]];
  NSString * albumName = [RCTConvert NSString:tag[@"album"]];
  if ([type isEqualToString:@"video"]) {
    // It's unclear if writeVideoAtPathToSavedPhotosAlbum is thread-safe
    dispatch_async(dispatch_get_main_queue(), ^{
      [self->_bridge.assetsLibrary writeVideoAtPathToSavedPhotosAlbum:request.URL completionBlock:^(NSURL *assetURL, NSError *saveError) {
        if (saveError) {
          reject(RCTRNSPAErrorUnableToSave, nil, saveError);
        } else {
          resolve(assetURL.absoluteString);
        }
      }];
    });
  } else {
    [_bridge.imageLoader loadImageWithURLRequest:request
                                        callback:^(NSError *loadError, UIImage *loadedImage) {
      if (loadError) {
        reject(RCTRNSPAErrorUnableToLoad, nil, loadError);
        return;
      }
                                            
      // It's unclear if writeImageToSavedPhotosAlbum is thread-safe
      dispatch_async(dispatch_get_main_queue(), ^{
        [self->_bridge.assetsLibrary writeImageToSavedPhotosAlbum:loadedImage.CGImage metadata:nil completionBlock:^(NSURL *assetURL, NSError *saveError) {
          if (saveError) {
            RCTLogWarn(@"Error saving cropped image: %@", saveError);
            reject(RCTRNSPAErrorUnableToSave, nil, saveError);
          } else {

            NSString * url = assetURL.absoluteString;
            __block BOOL albumWasFound = NO;
            void (^completionBlock)(NSError *error);
            completionBlock = ^(NSError *error){
                if (error) {
                    RCTLogWarn(@"Error save album image: %@", error);
                    reject(RCTRNSPAErrorUnableToSave, nil, error);
                } else {
                    resolve(url);
                }
            };

              
            [self->_bridge.assetsLibrary enumerateGroupsWithTypes:ALAssetsGroupAlbum
                        usingBlock:^(ALAssetsGroup *group, BOOL *stop) {
 
                            //compare the names of the albums
                            if ([albumName compare: [group valueForProperty:ALAssetsGroupPropertyName]]==NSOrderedSame) {
                                
                                //target album is found
                                albumWasFound = YES;
                                
                                //get a hold of the photo's asset instance
                                [self->_bridge.assetsLibrary assetForURL: assetURL 
                                      resultBlock:^(ALAsset *asset) {
                                                  
                                          //add photo to the target album
                                          [group addAsset: asset];
                                          
                                          //run the completion block
                                          completionBlock(nil);
                                          
                                      } failureBlock: completionBlock];
 
                                //album was found, bail out of the method
                                return;
                            }
                            
                            if (group==nil && albumWasFound==NO) {
                                //photo albums are over, target album does not exist, thus create it
                                
                                 ALAssetsLibrary* weakSelf = self->_bridge.assetsLibrary;
 
                                //create new assets album
                                [self->_bridge.assetsLibrary addAssetsGroupAlbumWithName:albumName 
                                                      resultBlock:^(ALAssetsGroup *group) {
                                                                  
                                                          //get the photo's instance
                                                          [weakSelf assetForURL: assetURL 
                                                                        resultBlock:^(ALAsset *asset) {
 
                                                                            //add photo to the newly created album
                                                                            [group addAsset: asset];
                                                                            
                                                                            //call the completion block
                                                                            completionBlock(nil);
 
                                                                        } failureBlock: completionBlock];
                                                          
                                                      } failureBlock: completionBlock];
 
                                //should be the last iteration anyway, but just in case
                                return;
                            }
                            
                        } failureBlock: completionBlock];


           /*  [self addAssetURL: assetURL 
                           toAlbum:tag[@"album"] 
                        withCompletionBlock:^(NSURL *assetURL, NSError *saveError) {
        if (saveError) {
          reject(RCTRNSPAErrorUnableToSave, nil, saveError);
        } else {
          resolve(assetURL.absoluteString);
        }
      }];*/

            
          }
        }];
      });
    }];
  }
}

/*
+(void)addAssetURL:(NSURL*)assetURL toAlbum:(NSString*)albumName withCompletionBlock:(void (^)(NSURL *assetURL))completionBlock
{
    __block BOOL albumWasFound = NO;
    
    //search all photo albums in the library
    [self enumerateGroupsWithTypes:ALAssetsGroupAlbum 
                        usingBlock:^(ALAssetsGroup *group, BOOL *stop) {
 
                            //compare the names of the albums
                            if ([albumName compare: [group valueForProperty:ALAssetsGroupPropertyName]]==NSOrderedSame) {
                                
                                //target album is found
                                albumWasFound = YES;
                                
                                //get a hold of the photo's asset instance
                                [self assetForURL: assetURL 
                                      resultBlock:^(ALAsset *asset) {
                                                  
                                          //add photo to the target album
                                          [group addAsset: asset];
                                          
                                          //run the completion block
                                          completionBlock(nil);
                                          
                                      } failureBlock: completionBlock];
 
                                //album was found, bail out of the method
                                return;
                            }
                            
                            if (group==nil && albumWasFound==NO) {
                                //photo albums are over, target album does not exist, thus create it
                                
                                 ALAssetsLibrary* weakSelf = self;
 
                                //create new assets album
                                [self addAssetsGroupAlbumWithName:albumName 
                                                      resultBlock:^(ALAssetsGroup *group) {
                                                                  
                                                          //get the photo's instance
                                                          [weakSelf assetForURL: assetURL 
                                                                        resultBlock:^(ALAsset *asset) {
 
                                                                            //add photo to the newly created album
                                                                            [group addAsset: asset];
                                                                            
                                                                            //call the completion block
                                                                            completionBlock(nil);
 
                                                                        } failureBlock: completionBlock];
                                                          
                                                      } failureBlock: completionBlock];
 
                                //should be the last iteration anyway, but just in case
                                return;
                            }
                            
                        } failureBlock: completionBlock];
    
}
 */



@end
