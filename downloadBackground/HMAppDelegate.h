//
//  HMAppDelegate.h
//  downloadBackground
//
//  Created by Tony on 14-6-17.
//  Copyright (c) 2014年 HM. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface HMAppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;
@property(copy) void (^backgroundSessionCompletionHandler)();

@end
