//
//  LoginViewController.m
//  MecoreMessageDemo
//
//  Created by 李泽鲁 on 14-9-26.
//  Copyright (c) 2014年 Mrli. All rights reserved.
//



#import "LoginViewController.h"

@interface LoginViewController ()

//定义XMPP数据流
@property (strong, nonatomic) XMPPStream * xmppStream;
@property (strong, nonatomic) IBOutlet UITextField *userNameTextFiled;
@property (strong, nonatomic) IBOutlet UITextField *passwordTextFiled;
@end

@implementation LoginViewController


- (void)viewDidLoad {
    [super viewDidLoad];
    
    UIColor *color = [UIColor colorWithPatternImage:[UIImage imageNamed:@"login.jpeg"]];
    self.view.backgroundColor = color;
    

    [self initXmpp];
    
    
    // 如果已登录就直接填充密码登陆
    NSUserDefaults *userDefult = [NSUserDefaults standardUserDefaults];
    
    NSString *userName = [userDefult objectForKey:@"username"];
    NSString *password = [userDefult objectForKey:@"password"];
    NSLog(@"%@,%@",userName,password);
    if (userName != nil && password != nil && ![userName isEqualToString:@""] && ![password isEqualToString:@""])
    {
        self.userNameTextFiled.text = userName;
        self.passwordTextFiled.text = password;
        [self xmppConnect];
    }
    
    self.userNameTextFiled.delegate = self;
    self.passwordTextFiled.delegate = self;
    
}

-(BOOL)textFieldShouldReturn:(UITextField *)textField {
    [textField resignFirstResponder];
    return YES;
}

- (void)initXmpp {
    //获取应用的xmppSteam(通过Application中的单例获取)
    UIApplication *application = [UIApplication sharedApplication];
    id delegate = [application delegate];
    self.xmppStream = [delegate xmppStream];
    
    //注册回调
    [self.xmppStream addDelegate:self delegateQueue:dispatch_get_main_queue()];
}


- (IBAction)tapButton:(id)sender {
    [self xmppConnect];
}

//连接服务器
- (void)xmppConnect {
    if (![self.userNameTextFiled.text isEqualToString:@""] &&
        self.userNameTextFiled.text != nil){
        //1.创建JID
        XMPPJID *jid = [XMPPJID jidWithUser:self.userNameTextFiled.text domain:MY_DOMAIN resource:@"iPhone"];
        
        //2.把JID添加到xmppSteam中
        [self.xmppStream setMyJID:jid];
        
        //连接服务器
        NSError *error = nil;
        [self.xmppStream connectWithTimeout:10 error:&error];
        if (error) {
            NSLog(@"连接出错：%@",[error localizedDescription]);
        }
    } else {
        UIAlertView *alter = [[UIAlertView alloc] initWithTitle:@"提示" message:@"用户名不能为空" delegate:nil cancelButtonTitle:@"取消" otherButtonTitles:nil];
        [alter show];
    }
}


//连接后的回调
-(void)xmppStreamDidConnect:(XMPPStream *)sender {
    if (![self.passwordTextFiled.text isEqualToString:@""] &&
        self.passwordTextFiled.text != nil) {
        //连接成功后认证用户名和密码
        NSError *error = nil;
        [self.xmppStream authenticateWithPassword:self.passwordTextFiled.text error:&error];
        if (error) {
            NSLog(@"认证错误：%@",[error localizedDescription]);
        }
    } else {
        UIAlertView *alter = [[UIAlertView alloc] initWithTitle:@"提示" message:@"密码不能为空" delegate:self cancelButtonTitle:@"取消" otherButtonTitles:nil];
        [alter show];
    }
}


//认证成功后的回调
-(void)xmppStreamDidAuthenticate:(XMPPStream *)sender {
    NSLog(@"登陆成功");
    
    //密码进入userDefault
    NSUserDefaults *userDefult = [NSUserDefaults standardUserDefaults];
    [userDefult setObject:self.userNameTextFiled.text forKey:@"username"];
    [userDefult setObject:self.passwordTextFiled.text forKey:@"password"];
    
    //设置在线状态
    XMPPPresence * pre = [XMPPPresence presence];
    [self.xmppStream sendElement:pre];
    
    UIStoryboard *storybard = [UIStoryboard storyboardWithName:@"Main" bundle:[NSBundle mainBundle]];
    UIViewController *viewController = [storybard instantiateViewControllerWithIdentifier:@"mainController"];
    [self presentViewController:viewController animated:YES completion:^{
    }];
}

//认证失败的回调
-(void)xmppStream:sender didNotAuthenticate:(DDXMLElement *)error {
    NSLog(@"认证失败");
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
@end
