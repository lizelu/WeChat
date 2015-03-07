//
//  HistoryFriendTableViewController.m
//  MecoreMessageDemo
//
//  Created by 李泽鲁 on 14-9-29.
//  Copyright (c) 2014年 Mrli. All rights reserved.
//

#import "HistoryFriendTableViewController.h"
#import "UserInfoCell.h"
#import "FriendModelClass.h"
#import "HistoryFrirend.h"
#import "LoginViewController.h"

@interface HistoryFriendTableViewController ()

@property (strong, nonatomic) NSArray *result;

@property (strong, nonatomic) FriendModelClass *historyFirend;

@end

@implementation HistoryFriendTableViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    
    _historyFirend = [[FriendModelClass alloc] init];
    self.result = [_historyFirend queryAll];
    NSLog(@"%@",self.result);
    [self.tableView reloadData];
    
}

- (IBAction)tapLoginOut:(id)sender {
    
    NSUserDefaults *userDefault = [NSUserDefaults standardUserDefaults];
    
    [userDefault removeObjectForKey:@"username"];
    [userDefault removeObjectForKey:@"password"];
    
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:[NSBundle mainBundle]];
    
    LoginViewController *loginViewController = [storyboard instantiateViewControllerWithIdentifier:@"loginViewController"];
    [self presentViewController:loginViewController animated:YES completion:^{
    }];
    
    
    
}




- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{

    return self.result.count;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 80;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    HistoryFrirend *friend = self.result[indexPath.row];
    
    UserInfoCell *cell = [tableView dequeueReusableCellWithIdentifier:@"rosterCell" forIndexPath:indexPath];
    
    [cell setCellValue:friend.nickname WithJid:@"(个性签名)"];
    
    return cell;
}



// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the specified item to be editable.
    return YES;
}


-(NSString *)tableView:(UITableView *)tableView titleForDeleteConfirmationButtonForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return @"删除";
}


// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        
        //获取数据
        HistoryFrirend *friend = self.result[indexPath.row];
        
        [self.historyFirend deleteFriendWithJid:friend.jidStr];
        
        [self viewDidLoad];
        
    }
}

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
       HistoryFrirend *friend = self.result[indexPath.row];
    
    //通过segue来获取我们目的视图控制器
    UIViewController *nextView = [segue destinationViewController];
    
    
    //通过KVC把参数传入目的控制器
    [nextView setValue:friend.nickname forKey:@"sendUserName"];
    [nextView setValue:friend.jidStr forKey:@"jidStr"];
    
    FriendModelClass *historyFriend = [[FriendModelClass alloc] init];
    [historyFriend saveHistoryFriend:friend.nickname WithJid:friend.jidStr];
    [self viewDidLoad];
}


@end
