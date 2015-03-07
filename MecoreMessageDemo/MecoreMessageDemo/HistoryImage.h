//
//  HistoryImage.h
//  CocoaPods
//
//  Created by 李泽鲁 on 14-9-24.
//  Copyright (c) 2014年 Mrli. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface HistoryImage : NSManagedObject

@property (nonatomic, retain) NSData * headerImage;
@property (nonatomic, retain) NSString * imageText;
@property (nonatomic, retain) NSDate * time;

@end
