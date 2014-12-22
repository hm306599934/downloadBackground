//
//  HMViewController.h
//  downloadBackground
//
//  Created by Tony on 14-6-17.
//  Copyright (c) 2014年 HM. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>

@interface HMViewController : UIViewController<NSURLSessionTaskDelegate,NSURLSessionDelegate,NSURLSessionDownloadDelegate,UIDocumentInteractionControllerDelegate>

- (IBAction)startDownload:(id)sender;
@property (weak, nonatomic) IBOutlet UIProgressView *progressView;

@property(nonatomic) NSURLSession *session;
@property(nonatomic) NSURLSessionDownloadTask *downloadTask;
@property(strong,nonatomic)UIDocumentInteractionController *documentInteractionController;
@property (nonatomic,strong)AVPlayer *player;
@end
