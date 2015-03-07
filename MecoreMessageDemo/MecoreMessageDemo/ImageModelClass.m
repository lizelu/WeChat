//
//  ImageModelClass.m
//  MyKeyBoard
//
//  Created by 李泽鲁 on 14-9-16.
//  Copyright (c) 2014年 Mrli. All rights reserved.
//

#import "ImageModelClass.h"

@interface ImageModelClass ()

@property (nonatomic, strong) NSManagedObjectContext *manager;

@end

@implementation ImageModelClass
- (instancetype)init
{
    self = [super init];
    if (self) {
        //通过上下文获取manager
        UIApplication *application = [UIApplication sharedApplication];
        id delegate = application.delegate;
        self.manager = [delegate managedObjectContext];
    }
    return self;
}

-(void)save:(NSData *)image ImageText:(NSString *)imageText
{
    if (image != nil) {
        NSArray *result = [self search:imageText];
        
        HistoryImage *myImage;
        
        if (result.count == 0)
        {
            myImage = [NSEntityDescription insertNewObjectForEntityForName:NSStringFromClass([HistoryImage class]) inManagedObjectContext:self.manager];
            myImage.imageText = imageText;
            myImage.headerImage = image;
            myImage.time = [NSDate date];
        }
        else
        {
            myImage = result[0];
            myImage.time = [NSDate date];
        }
        
        //存储实体
        NSError *error = nil;
        if (![self.manager save:&error]) {
            NSLog(@"保存出错%@", [error localizedDescription]);
        }

    }

}


//查找
-(NSArray *)search:(NSString *) image
{
    NSArray *result;
    
        //新建查询条件
        NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] initWithEntityName:NSStringFromClass([HistoryImage class])];
        
        //添加谓词
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"imageText=%@",image];
        
        //把谓词给request
        [fetchRequest setPredicate:predicate];
        
        //执行查询
        NSError *error = nil;
        result = [self.manager executeFetchRequest:fetchRequest error:&error];
        if (error) {
            NSLog(@"查询错误：%@", [error localizedDescription]);
        }
    return result;
}



//查询所有的
-(NSArray *) queryAll
{
    //新建查询条件
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] initWithEntityName:NSStringFromClass([HistoryImage class])];
    
    //添加排序规则
    //定义排序规则
    NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"time" ascending:NO];
    
    //添加排序规则
    [fetchRequest setSortDescriptors:@[sortDescriptor]];

    
    //执行查询
    NSError *error = nil;
    NSArray *result = [self.manager executeFetchRequest:fetchRequest error:&error];
    if (error) {
        NSLog(@"查询错误：%@", [error localizedDescription]);
    }
    
    return result;
}

@end
