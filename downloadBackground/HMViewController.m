//
//  HMViewController.m
//  downloadBackground
//
//  Created by Tony on 14-6-17.
//  Copyright (c) 2014年 HM. All rights reserved.
//

#import "HMViewController.h"
#import "HMAppDelegate.h"

#define DOWNLOAD_URL @"http://www.zyprosoft.com/samplesource/love.mp3"

@interface HMViewController ()

@end

@implementation HMViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	self.session = [self backgroundSession];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (NSURLSession *)backgroundSession {
    static NSURLSession *session = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        
        //这个sessionConfiguration 很重要， com.zyprosoft.xxx  这里，这个com.company.这个一定要和 bundle identifier 里面的一致，否则ApplicationDelegate 不会调用handleEventsForBackgroundURLSession代理方法
        NSURLSessionConfiguration *configuration = [NSURLSessionConfiguration backgroundSessionConfiguration:@"hm.net.downloadBackground"];
        session = [NSURLSession sessionWithConfiguration:configuration delegate:self delegateQueue:nil];
    });
    return session;
}

- (IBAction)startDownload:(id)sender
{
    if (self.downloadTask)
    {
        return;
    }
    NSURL *downloadUrl = [NSURL URLWithString:DOWNLOAD_URL];
    NSURLRequest *request = [NSURLRequest requestWithURL:downloadUrl];
    self.downloadTask = [self.session downloadTaskWithRequest:request];
    [self.downloadTask resume];
    self.progressView.hidden = NO;
    
}

- (void)URLSession:(NSURLSession *)session downloadTask:(NSURLSessionDownloadTask *)downloadTask didWriteData:(int64_t)bytesWritten totalBytesWritten:(int64_t)totalBytesWritten totalBytesExpectedToWrite:(int64_t)totalBytesExpectedToWrite
{
    if (downloadTask == self.downloadTask)
    {
        double progress2 = (double)totalBytesWritten / (double)totalBytesExpectedToWrite;
        NSLog(@"下载任务：%@ 进度：%lf",downloadTask,progress2);
        dispatch_sync(dispatch_get_main_queue(),
                      ^{
                            self.progressView.progress = progress2;
                      });
        
    }
}

- (void)URLSession:(NSURLSession *)session downloadTask:(NSURLSessionDownloadTask *)downloadTask didFinishDownloadingToURL:(NSURL *)location
{
    NSFileManager *fileManger = [NSFileManager defaultManager];
    NSArray *URLs = [fileManger URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask];
    NSURL *documentDirectory = [URLs objectAtIndex:0];
    NSURL *originalUrl = [[downloadTask originalRequest] URL];
    NSURL *destinationURL = [documentDirectory URLByAppendingPathComponent:[originalUrl lastPathComponent]];
    
    NSError *error;
    [fileManger removeItemAtURL:destinationURL error:nil];
    BOOL success = [fileManger copyItemAtURL:location toURL:destinationURL error:&error];
    
    if (success) {
        dispatch_async(dispatch_get_main_queue(), ^{
            //download finished - open the pdf
            
            //原文下载的苹果的pdf，感觉有点慢，自己又没找到比较大一点的pdf，干脆就放了个mp3歌曲在自己服务器上，所以下载完就播放mp3吧
            //            self.documentInteractionController = [UIDocumentInteractionController interactionControllerWithURL:destinationURL];
            //            // Configure Document Interaction Controller
            //            [self.documentInteractionController setDelegate:self];
            //            // Preview PDF
            //            [self.documentInteractionController presentPreviewAnimated:YES];
            //            self.progressView.hidden = YES;
            
            //播放音乐
            self.player = [AVPlayer playerWithURL:destinationURL];
            self.player.volume = 0.1;
            [self.player play];
            
            
        });
    } else {
        NSLog(@"复制文件发生错误: %@", [error localizedDescription]);
    }
    
}

- (void)URLSession:(NSURLSession *)session downloadTask:(NSURLSessionDownloadTask *)downloadTask didResumeAtOffset:(int64_t)fileOffset expectedTotalBytes:(int64_t)expectedTotalBytes
{
    
}

- (void)URLSession:(NSURLSession *)session task:(NSURLSessionTask *)task didCompleteWithError:(NSError *)error
{
    if (error == nil) {
        NSLog(@"r任务%@成功完成",task);
    }
    else
    {
        NSLog(@"r任务%@发生错误%@",task,[error localizedDescription]);
    }
    double progress2 = (double)task.countOfBytesReceived / (double)task.countOfBytesExpectedToReceive;
    dispatch_sync(dispatch_get_main_queue(), ^{self.progressView.progress = progress2;});
    self.downloadTask = nil;
}

#pragma mark - NSURLSessionDelegate
- (void)URLSessionDidFinishEventsForBackgroundURLSession:(NSURLSession *)session
{
    HMAppDelegate *appDelegate = (HMAppDelegate *)[[UIApplication sharedApplication] delegate];
    if (appDelegate.backgroundSessionCompletionHandler) {
        void (^completionHandler)() = appDelegate.backgroundSessionCompletionHandler;
        appDelegate.backgroundSessionCompletionHandler = nil;
        completionHandler();
    }
    NSLog(@"所有任务已完成!");
}

@end
