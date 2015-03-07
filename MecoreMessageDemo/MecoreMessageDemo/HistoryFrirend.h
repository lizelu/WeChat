//
//  HistoryFrirend.h
//  MecoreMessageDemo
//
//  Created by 李泽鲁 on 14-9-29.
//  Copyright (c) 2014年 Mrli. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface HistoryFrirend : NSManagedObject

@property (nonatomic, retain) NSString * nickname;
@property (nonatomic, retain) NSString * jidStr;
@property (nonatomic, retain) NSDate * timestap;

@end
