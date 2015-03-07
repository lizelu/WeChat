//
//  FriendTableViewController.h
//  MecoreMessageDemo
//
//  Created by 李泽鲁 on 14-9-27.
//  Copyright (c) 2014年 Mrli. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <XMPPRoster.h>

@interface FriendTableViewController : UITableViewController<XMPPStreamDelegate,NSFetchedResultsControllerDelegate,UITableViewDataSource,UITableViewDelegate,UINavigationControllerDelegate>

@end
