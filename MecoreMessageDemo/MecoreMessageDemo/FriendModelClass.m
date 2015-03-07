//
//  FriendModelClass.m
//  MecoreMessageDemo
//
//  Created by 李泽鲁 on 14-9-29.
//  Copyright (c) 2014年 Mrli. All rights reserved.
//

#import "FriendModelClass.h"

@interface FriendModelClass()

@property (nonatomic, strong) NSManagedObjectContext *managedObjectContext;

@end


@implementation FriendModelClass
//初始化函数
- (instancetype)init
{
    self = [super init];
    if (self) {
        //获取对应的上下文
        UIApplication *application = [UIApplication sharedApplication];
        id delegate = [application delegate];
        self.managedObjectContext = [delegate managedObjectContext];
    }
    return self;
}

-(void)saveHistoryFriend:(NSString *)nickName WithJid:(NSString *)jidStr
{
    //保存之前先做一个查询如果存在则更新，如果不存在则保存
    NSArray *result = [self search:jidStr];
    
    HistoryFrirend *myFirend;
    
    if (result.count == 0 )
    {
        //获取一个实体
        myFirend = [NSEntityDescription insertNewObjectForEntityForName:NSStringFromClass([HistoryFrirend class]) inManagedObjectContext:self.managedObjectContext];
        myFirend.nickname = nickName;
        myFirend.jidStr = jidStr;
        myFirend.timestap = [NSDate date];
    }
    else
    {
        //更新
        myFirend = result[0];
        myFirend.timestap = [NSDate date];
    }
    //存储实体
    NSError *error = nil;
    [self.managedObjectContext save:&error];
    if (error) {
        NSLog(@"保存出错%@",[error localizedDescription]);
    }
}



-(NSArray *)search:(NSString *)jidStr
{
    //创建查询请求
    NSFetchRequest *request = [[NSFetchRequest alloc] initWithEntityName:NSStringFromClass([HistoryFrirend class])];
    
    //添加查询谓词
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"jidStr=%@",jidStr];
    [request setPredicate:predicate];
    
    //执行查询
    NSError *error = nil;
    NSArray *result = [self.managedObjectContext executeFetchRequest:request error:&error];
    if (error) {
        NSLog(@"%@",[error localizedDescription]);
    }
    return result;
}



-(NSArray *)queryAll
{
    //查询所有历史记录
    NSFetchRequest *request = [[NSFetchRequest alloc] initWithEntityName:NSStringFromClass([HistoryFrirend class])];
    
    //添加查询条件
    NSSortDescriptor *sortDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"timestap" ascending:NO];
    [request setSortDescriptors:@[sortDescriptor]];
    
    NSError *error = nil;
    NSArray *result = [self.managedObjectContext executeFetchRequest:request error:&error];
    if (error) {
        NSLog(@"查询出错%@",[error localizedDescription]);
    }
    
    return result;
}


-(void) deleteFriendWithJid:(NSString *)jidStr
{
    //通过jidStr查询数据
    NSArray *result = [self search:jidStr];
    if (result.count != 0)
    {
        HistoryFrirend *friend = result[0];
        [self.managedObjectContext deleteObject:friend];
        
        NSError *error = nil;
        [self.managedObjectContext save:&error];
        if (error) {
            NSLog(@"保存上下文%@",[error localizedDescription]);
        }
      
    }
}

@end
