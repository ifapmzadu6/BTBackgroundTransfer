//
//  BTBackgroundTransfer.m
//  BTBackgroundTransferExample
//
//  Created by Keisuke Karijuku on 2014/08/08.
//  Copyright (c) 2014年 Keisuke Karijuku. All rights reserved.
//

#import "BTBackgroundTransfer.h"

static NSString * const kBTBackgroundTransferDefaultSessionName = @"kBTMDSN";

@interface BTBackgroundTransfer () <NSURLSessionDataDelegate, NSURLSessionDelegate, NSURLSessionDownloadDelegate, NSURLSessionTaskDelegate>

@property (strong, nonatomic) NSURLSession *backgroundSession;

@property (strong, nonatomic) NSMutableDictionary *locations;

@end


@implementation BTBackgroundTransfer

+ (BTBackgroundTransfer *)sharedManager {
    static dispatch_once_t once;
    static id instance;
    dispatch_once(&once, ^{
        instance = self.new;
    });
    return instance;
}

- (id)init {
    self = [self initWithBackgroundSessionName:kBTBackgroundTransferDefaultSessionName];
    if (self) {
        
    }
    return self;
}

- (id)initWithBackgroundSessionName:(NSString *)backgroundSessionName {
    self = [super init];
    if (self) {
        NSURLSessionConfiguration *config = [NSURLSessionConfiguration backgroundSessionConfiguration:backgroundSessionName];
        self.backgroundSession = [NSURLSession sessionWithConfiguration:config delegate:self delegateQueue:[NSOperationQueue mainQueue]];
    }
    return self;
}


#pragma mark StartDownloading
- (void)startDownloadURL:(NSURL *)url {
    NSLog(@"%@", url.absoluteString);
    NSURLRequest *request = [NSURLRequest requestWithURL:url];
    NSURLSessionDownloadTask *downloadTask = [self.backgroundSession downloadTaskWithRequest:request];
    [downloadTask resume];
}

- (void)startDownloadURLRequest:(NSURLRequest *)request {
    NSURLSessionDownloadTask *downloadTask = [self.backgroundSession downloadTaskWithRequest:request];
    [downloadTask resume];
}


#pragma mark StartUploading
- (void)startUploadURL:(NSURL *)url data:(NSData *)data {
    NSURLRequest *request = [NSURLRequest requestWithURL:url];
    NSURLSessionUploadTask *uploadTask = [self.backgroundSession uploadTaskWithRequest:request fromData:data];
    [uploadTask resume];
}

- (void)startUploadRequst:(NSURLRequest *)request data:(NSData *)data {
    NSURLSessionUploadTask *uploadTask = [self.backgroundSession uploadTaskWithRequest:request fromData:data];
    [uploadTask resume];
}

- (void)startUploadURL:(NSURL *)url fileURL:(NSURL *)fileURL {
    NSURLRequest *request = [NSURLRequest requestWithURL:url];
    NSURLSessionUploadTask *uploadTask = [self.backgroundSession uploadTaskWithRequest:request fromFile:fileURL];
    [uploadTask resume];
}

- (void)startUploadRequest:(NSURLRequest *)request fileURL:(NSURL *)fileURL {
    NSURLSessionUploadTask *uploadTask = [self.backgroundSession uploadTaskWithRequest:request fromFile:fileURL];
    [uploadTask resume];
}


#pragma mark Resume, Cancel, Suspend
- (void)resume {
    [self.backgroundSession getTasksWithCompletionHandler:^(NSArray *dataTasks, NSArray *uploadTasks, NSArray *downloadTasks) {
        for (NSURLSessionTask *task in dataTasks) [task resume];
        for (NSURLSessionTask *task in uploadTasks) [task resume];
        for (NSURLSessionTask *task in downloadTasks) [task resume];
    }];
}

- (void)cancel {
    [self.backgroundSession getTasksWithCompletionHandler:^(NSArray *dataTasks, NSArray *uploadTasks, NSArray *downloadTasks) {
        for (NSURLSessionTask *task in dataTasks) [task cancel];
        for (NSURLSessionTask *task in uploadTasks) [task cancel];
        for (NSURLSessionTask *task in downloadTasks) [task cancel];
    }];
}

- (void)suspend {
    [self.backgroundSession getTasksWithCompletionHandler:^(NSArray *dataTasks, NSArray *uploadTasks, NSArray *downloadTasks) {
        for (NSURLSessionTask *task in dataTasks) [task suspend];
        for (NSURLSessionTask *task in uploadTasks) [task suspend];
        for (NSURLSessionTask *task in downloadTasks) [task suspend];
    }];
}


#pragma mark BackgroundComplecationHandler
- (void)performBackgroundComplecationHandlerIfFinishAll {
    if (self.backgroundComplecationHandler == nil) {
        return;
    }
    
    [self.backgroundSession getTasksWithCompletionHandler:^(NSArray *dataTasks, NSArray *uploadTasks, NSArray *downloadTasks) {
        if (dataTasks.count == 0 && uploadTasks.count == 0 && downloadTasks.count == 0) {
            self.backgroundComplecationHandler();
        }
    }];
}


#pragma mark NSURLSessionDelegate
- (void)URLSession:(NSURLSession *)session didBecomeInvalidWithError:(NSError *)error {
}

- (void)URLSessionDidFinishEventsForBackgroundURLSession:(NSURLSession *)session {
}

#pragma mark NSURLSessionTaskDelegate
- (void)URLSession:(NSURLSession *)session task:(NSURLSessionTask *)task didSendBodyData:(int64_t)bytesSent totalBytesSent:(int64_t)totalBytesSent totalBytesExpectedToSend:(int64_t)totalBytesExpectedToSend {
}

- (void)URLSession:(NSURLSession *)session task:(NSURLSessionTask *)task didCompleteWithError:(NSError *)error {
    [self performBackgroundComplecationHandlerIfFinishAll];
}

#pragma mark NSURLSessionDownloadDelegate
- (void)URLSession:(NSURLSession *)session downloadTask:(NSURLSessionDownloadTask *)downloadTask didFinishDownloadingToURL:(NSURL *)location {
    NSLog(@"%s", __func__);
    
    if ([self.delegate respondsToSelector:@selector(didFinishDownloadingToFileURL:url:error:)]) {
        [self.delegate didFinishDownloadingToFileURL:location url:downloadTask.originalRequest.URL error:downloadTask.error];
    }
    if (self.didFinishDownloadingToFileURLBlock) {
        self.didFinishDownloadingToFileURLBlock(location, downloadTask.originalRequest.URL, downloadTask.error);
    }
    
    if ([self.delegate respondsToSelector:@selector(didFinishDownloadingToFileURL:request:response:)]) {
        [self.delegate didFinishDownloadingToFileURL:location request:downloadTask.originalRequest response:downloadTask.response];
    }
    if (self.didFinishDownloadingToFileURLWithRequestBlock) {
        self.didFinishDownloadingToFileURLWithRequestBlock(location, downloadTask.originalRequest, downloadTask.response);
    }
    
    
    if ([self.delegate respondsToSelector:@selector(didFinishDownloadingToData:url:error:)]) {
        NSData *data = [NSData dataWithContentsOfURL:location];
        [self.delegate didFinishDownloadingToData:data url:downloadTask.originalRequest.URL error:downloadTask.error];
    }
    if (self.didFinishDownloadingToDataBlock) {
        NSData *data = [NSData dataWithContentsOfURL:location];
        self.didFinishDownloadingToDataBlock(data, downloadTask.originalRequest.URL, downloadTask.error);
    }
    
    
    if ([self.delegate respondsToSelector:@selector(didFinishDownloadingToFileURL:request:response:)]) {
        [self.delegate didFinishDownloadingToFileURL:location request:downloadTask.originalRequest response:downloadTask.response];
    }
    if (self.didFinishDownloadingToFileURLWithRequestBlock) {
        self.didFinishDownloadingToFileURLWithRequestBlock(location, downloadTask.originalRequest, downloadTask.response);
    }
}

- (void)URLSession:(NSURLSession *)session downloadTask:(NSURLSessionDownloadTask *)downloadTask didWriteData:(int64_t)bytesWritten totalBytesWritten:(int64_t)totalBytesWritten totalBytesExpectedToWrite:(int64_t)totalBytesExpectedToWrite {
    
}

- (void)URLSession:(NSURLSession *)session downloadTask:(NSURLSessionDownloadTask *)downloadTask didResumeAtOffset:(int64_t)fileOffset expectedTotalBytes:(int64_t)expectedTotalBytes {
}

#pragma mark NSURLSessionDataTask
- (void)URLSession:(NSURLSession *)session dataTask:(NSURLSessionDataTask *)dataTask didReceiveData:(NSData *)data {
    if ([self.delegate respondsToSelector:@selector(didFinishUploadingURL:didReceiveData:)]) {
        [self.delegate didFinishUploadingURL:dataTask.originalRequest.URL didReceiveData:data];
    }
    if (self.didFinishUploadingURLBlock) {
        self.didFinishUploadingURLBlock(dataTask.originalRequest.URL, data);
    }
    
    
    if ([self.delegate respondsToSelector:@selector(didFinishUploadingRequest:response:didReceiveData:)]) {
        [self.delegate didFinishUploadingRequest:dataTask.originalRequest response:dataTask.response didReceiveData:data];
    }
    if (self.didFinishUploadingRequestBlock) {
        self.didFinishUploadingRequestBlock(dataTask.originalRequest, dataTask.response, data);
    }
}

@end
