//
//  FriendTableViewController.m
//  MecoreMessageDemo
//
//  Created by 李泽鲁 on 14-9-27.
//  Copyright (c) 2014年 Mrli. All rights reserved.
//

#import "FriendTableViewController.h"
#import <XMPPUserCoreDataStorageObject.h>
#import "UserInfoCell.h"

#import "FriendModelClass.h"


@interface FriendTableViewController ()
//从数据库中获取发送内容的xmppManagedObjectContext
@property(nonatomic,strong)NSManagedObjectContext *xmppRosterManagedObjectContext;
//显示在tableView上
@property(nonatomic,strong)NSFetchedResultsController *fetchedResultsController;


@end

@implementation FriendTableViewController
- (IBAction)tapRefrash:(id)sender {
    //获取Roster的上下文
    UIApplication *application = [UIApplication sharedApplication];
    id delegate = [application delegate];
    self.xmppRosterManagedObjectContext = [delegate xmppRosterManagedObjectContext];
    
    //从CoreData中获取数据
    //通过实体获取FetchRequest实体
    NSFetchRequest *request = [[NSFetchRequest alloc] initWithEntityName:NSStringFromClass([XMPPUserCoreDataStorageObject class])];
    //添加排序规则
    NSSortDescriptor * sortD = [NSSortDescriptor sortDescriptorWithKey:@"jidStr" ascending:YES];
    [request setSortDescriptors:@[sortD]];
    
    
    //获取FRC
    self.fetchedResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:request managedObjectContext:self.xmppRosterManagedObjectContext sectionNameKeyPath:nil cacheName:nil];
    self.fetchedResultsController.delegate = self;
    
    //获取内容
    
    
    NSError * error;
        if (![self.fetchedResultsController performFetch:&error])
        {
            NSLog(@"%s  %@",__FUNCTION__,[error localizedDescription]);
        }

        [self.tableView reloadData];
    
}


- (void)viewDidLoad
{
    [super viewDidLoad];
    [self tapRefrash:nil];
    
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    NSArray *sections = [self.fetchedResultsController sections];
    return sections.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    NSArray *sectoins = [self.fetchedResultsController sections];
    id<NSFetchedResultsSectionInfo> sectionInfo = sectoins[section];
    
    NSLog(@"%ld", [sectionInfo numberOfObjects]);
    return [sectionInfo numberOfObjects];
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    //获取数据
    XMPPUserCoreDataStorageObject *roster = [self.fetchedResultsController objectAtIndexPath:indexPath];
    
    UserInfoCell *cell = [tableView dequeueReusableCellWithIdentifier:@"rosterCell" forIndexPath:indexPath];
    //roster.jidStr
    [cell setCellValue:roster.nickname WithJid:@"(个性签名)"];
    
    return cell;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 80;
}


/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    } else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath
{
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/


#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    //做一个类型的转换
    UITableViewCell *cell = (UITableViewCell *)sender;
    
    //通过tableView获取cell对应的索引，然后通过索引获取实体对象
    NSIndexPath *indexPath = [self.tableView indexPathForCell:cell];
    
    //获取数据
    XMPPUserCoreDataStorageObject *roster = [self.fetchedResultsController objectAtIndexPath:indexPath];
    
    //通过segue来获取我们目的视图控制器
    UIViewController *nextView = [segue destinationViewController];
    
    
    //通过KVC把参数传入目的控制器
    [nextView setValue:roster.nickname forKey:@"sendUserName"];
    [nextView setValue:roster.jidStr forKey:@"jidStr"];
    
    FriendModelClass *historyFriend = [[FriendModelClass alloc] init];
    [historyFriend saveHistoryFriend:roster.nickname WithJid:roster.jidStr];  
}


- (void)controllerWillChangeContent:(NSFetchedResultsController *)controller {
    [self.tableView beginUpdates];
}


- (void)controller:(NSFetchedResultsController *)controller didChangeSection:(id <NSFetchedResultsSectionInfo>)sectionInfo
           atIndex:(NSUInteger)sectionIndex forChangeType:(NSFetchedResultsChangeType)type {
    
    switch(type) {
        case NSFetchedResultsChangeInsert:
            [self.tableView insertSections:[NSIndexSet indexSetWithIndex:sectionIndex]
                            withRowAnimation:UITableViewRowAnimationFade];
            break;
            
        case NSFetchedResultsChangeDelete:
            [self.tableView deleteSections:[NSIndexSet indexSetWithIndex:sectionIndex]
                            withRowAnimation:UITableViewRowAnimationFade];
            break;
    }
}


- (void)controller:(NSFetchedResultsController *)controller didChangeObject:(id)anObject
       atIndexPath:(NSIndexPath *)indexPath forChangeType:(NSFetchedResultsChangeType)type
      newIndexPath:(NSIndexPath *)newIndexPath {
    
    UITableView *tableView = self.tableView;
    
    switch(type) {
            
        case NSFetchedResultsChangeInsert:
            [tableView insertRowsAtIndexPaths:[NSArray arrayWithObject:newIndexPath]
                             withRowAnimation:UITableViewRowAnimationFade];
            break;
            
        case NSFetchedResultsChangeDelete:
            [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath]
                             withRowAnimation:UITableViewRowAnimationFade];
            break;
            
        case NSFetchedResultsChangeUpdate:
            [tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
            break;
            
        case NSFetchedResultsChangeMove:
            [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath]
                             withRowAnimation:UITableViewRowAnimationFade];
            [tableView insertRowsAtIndexPaths:[NSArray arrayWithObject:newIndexPath]
                             withRowAnimation:UITableViewRowAnimationFade];
            break;
    }
}

- (void)controllerDidChangeContent:(NSFetchedResultsController *)controller {
    [self.tableView endUpdates];
}
@end
