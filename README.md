BTBackgroundTransfer
====================

BTBackgroundTransfer is compatible a Background Transfer function available from ios7.

# Installation & Use
You can do this in just 4 steps;

1, Import BTBackgroundTransfer.

2, Add this codes to AppDelegate.

    - (void)application:(UIApplication *)application handleEventsForBackgroundURLSession:(NSString *)identifier completionHandler:(void (^)())completionHandler {
        BTBackgroundTransfer *sharedManager = [BTBackgroundTransfer sharedManager];
        sharedManager.backgroundComplecationHandler = completionHandler;
    }

3, Download/Upload With a URL.

    - (void)startDownloadURL:(NSURL *)url;
    - (void)startUploadURL:(NSURL *)url data:(NSData *)data;

4, Received the Data by Delegate/Blosk.

    - (void)didFinishDownloadingToData:(NSData *)data url:(NSURL *)url error:(NSError *)error;
    - (void)didFinishUploadingURL:(NSURL *)url didReceiveData:(NSData *)data;

    @property (copy, nonatomic) void (^didFinishDownloadingToDataBlock)(NSData *data, NSURL *url, NSError *error);
    @property (copy, nonatomic) void (^didFinishUploadingURLBlock)(NSURL *url, NSData *data);

# License
MIT License.

©2014 Keisuke Karijuku.

