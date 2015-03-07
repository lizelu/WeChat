//
//  ChatViewController.h
//  CocoaPods
//
//  Created by 李泽鲁 on 14-9-24.
//  Copyright (c) 2014年 Mrli. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ChatViewController : UIViewController<UITableViewDataSource,UITableViewDelegate,UINavigationControllerDelegate, UIImagePickerControllerDelegate,NSFetchedResultsControllerDelegate,XMPPStreamDelegate>

//好友的jid
@property (strong, nonatomic) NSString *sendUserName;
@property (strong, nonatomic) NSString *jidStr;

@end
