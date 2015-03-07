//
//  AppDelegate.h
//  MecoreMessageDemo
//
//  Created by 李泽鲁 on 14-9-25.
//  Copyright (c) 2014年 Mrli. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <XMPPRoster.h>
#import <XMPPMessageArchivingCoreDataStorage.h>
#import <XMPPRosterCoreDataStorage.h>

@interface AppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;

@property (readonly, strong, nonatomic) NSManagedObjectContext *managedObjectContext;
@property (readonly, strong, nonatomic) NSManagedObjectModel *managedObjectModel;
@property (readonly, strong, nonatomic) NSPersistentStoreCoordinator *persistentStoreCoordinator;


//XMPP数据流
@property (strong, nonatomic) XMPPStream * xmppStream;
@property (strong, nonatomic) NSManagedObjectContext *xmppManagedObjectContext;
@property (strong, nonatomic) NSManagedObjectContext *xmppRosterManagedObjectContext;

- (void)saveContext;
- (NSURL *)applicationDocumentsDirectory;

@end
