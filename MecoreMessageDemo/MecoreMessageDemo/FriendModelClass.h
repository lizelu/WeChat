//
//  FriendModelClass.h
//  MecoreMessageDemo
//
//  Created by 李泽鲁 on 14-9-29.
//  Copyright (c) 2014年 Mrli. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "HistoryFrirend.h"

@interface FriendModelClass : NSObject

//插入历史好友
-(void)saveHistoryFriend:(NSString *)nickName WithJid:(NSString *) jidStr;
-(NSArray *) queryAll;
-(void) deleteFriendWithJid:(NSString *)jidStr;
@end
