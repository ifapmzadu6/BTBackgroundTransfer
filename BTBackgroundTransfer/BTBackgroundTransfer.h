//
//  BTBackgroundTransfer.h
//  BTBackgroundTransferExample
//
//  Created by Keisuke Karijuku on 2014/08/08.
//  Copyright (c) 2014年 Keisuke Karijuku. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol BTBackgroundTransferDelegate <NSObject>
@optional

/**
 *  Delegate - Download
 **/
- (void)didFinishDownloadingToFileURL:(NSURL *)location url:(NSURL *)url error:(NSError *)error;
- (void)didFinishDownloadingToFileURL:(NSURL *)location request:(NSURLRequest *)request response:(NSURLResponse *)response;

- (void)didFinishDownloadingToData:(NSData *)data url:(NSURL *)url error:(NSError *)error;
- (void)didFinishDownloadingToData:(NSData *)data request:(NSURLRequest *)request response:(NSURLResponse *)response;

/**
 *  Delegate - Download Proccess
 **/



/**
 *  Delegate - Upload
 **/
- (void)didFinishUploadingURL:(NSURL *)url didReceiveData:(NSData *)data;
- (void)didFinishUploadingRequest:(NSURLRequest *)request response:(NSURLResponse *)response didReceiveData:(NSData *)data;

@end

@interface BTBackgroundTransfer : NSObject

/**
 *  Singleton Manager
 **/
+ (BTBackgroundTransfer *)sharedManager;

- (id)initWithBackgroundSessionName:(NSString *)backgroundSessionName;


/**
 *  Delegate
 **/
@property (weak, nonatomic) id<BTBackgroundTransferDelegate> delegate;


/**
 *  Blocks - Download
 **/
@property (copy, nonatomic) void (^didFinishDownloadingToFileURLBlock)(NSURL *location, NSURL *url, NSError *error);
@property (copy, nonatomic) void (^didFinishDownloadingToFileURLWithRequestBlock)(NSURL *location, NSURLRequest *request, NSURLResponse *response);

@property (copy, nonatomic) void (^didFinishDownloadingToDataBlock)(NSData *data, NSURL *url, NSError *error);
@property (copy, nonatomic) void (^didFinishDownloadingToDataWithRequestBlock)(NSData *data, NSURLRequest *request, NSURLResponse *response);

/**
 *  Blocks - Upload
 **/
@property (copy, nonatomic) void (^didFinishUploadingURLBlock)(NSURL *url, NSData *data);
@property (copy, nonatomic) void (^didFinishUploadingRequestBlock)(NSURLRequest *request, NSURLResponse *response, NSData *data);



/**
 *  [Important]  Add those methods to AppDelegate.m to enable BackgroundTransfer.
 *
 *  - (void)application:(UIApplication *)application handleEventsForBackgroundURLSession:(NSString *)identifier completionHandler:(void (^)())completionHandler {
 *     BackgroundTransferManager *sharedManager = [BackgroundTransferManager sharedManager];
 *     sharedManager.backgroundComplecationHandler = completionHandler;
 *  }
 **/
@property (copy, nonatomic) void (^backgroundComplecationHandler)();


/**
 *  Start downloading the URL.
 *  You can receive the data from delegate or block.
 **/
- (void)startDownloadURL:(NSURL *)url;

/**
 *  Start downloading the request.
 *  You can receive the data from delegate or block.
 **/
- (void)startDownloadURLRequest:(NSURLRequest *)request;


/**
 *  Start uploading the URL.
 *  You can receive the response from delegate or block.
 **/
- (void)startUploadURL:(NSURL *)url data:(NSData *)data;

/**
 *  Start uploading the request.
 *  You can receive the response from delegate or block.
 **/
- (void)startUploadRequst:(NSURLRequest *)request data:(NSData *)data;

/**
 *  Start uploading the URL.
 *  You can receive the response from delegate or block.
 **/
- (void)startUploadURL:(NSURL *)url fileURL:(NSURL *)fileURL;

/**
 *  Start uploading the request.
 *  You can receive the response from delegate or block.
 **/
- (void)startUploadRequest:(NSURLRequest *)request fileURL:(NSURL *)fileURL;


/**
 *  Resume All Tasks.
 **/
- (void)resume;

/**
 *  Cancel All Tasks.
 **/
- (void)cancel;

/**
 *  Suspend All Tasks.
 **/
- (void)suspend;

@end
