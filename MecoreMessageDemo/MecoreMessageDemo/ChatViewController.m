//
//  ChatViewController.m
//  CocoaPods
//
//  Created by 李泽鲁 on 14-9-24.
//  Copyright (c) 2014年 Mrli. All rights reserved.
//

#import "ChatViewController.h"
#import "MyViewController.h"
#import "TextCell.h"
#import "ToolView.h"
#import "VoiceCellTableViewCell.h"
#import "heImageCell.h"
#import "MyImageCell.h"
#import "ImageViewController.h"
#import <XMPPMessageArchiving_Message_CoreDataObject.h>



//枚举Cell类型
typedef enum : NSUInteger {
    SendText,
    SendImage,
    SendVoice

} MySendContentType;

@interface ChatViewController ()

//工具栏
@property (nonatomic,strong) ToolView *toolView;

//音量图片
@property (strong, nonatomic) UIImageView *volumeImageView;

//工具栏的高约束，用于当输入文字过多时改变工具栏的约束
@property (strong, nonatomic) NSLayoutConstraint *tooViewConstraintHeight;
//storyBoard上的控件
@property (strong, nonatomic) IBOutlet UITableView *myTableView;

//从相册获取图片
@property (strong, nonatomic) UIImagePickerController *imagePiceker;

//发送类型
@property (assign, nonatomic)MySendContentType sentType;

//从数据库中获取发送内容的xmppManagedObjectContext
@property(nonatomic,strong)NSManagedObjectContext *xmppManagedObjectContext;

//显示在tableView上
@property(nonatomic,strong)NSFetchedResultsController *fetchedResultsController;

//XMPPSteam流
@property (strong, nonatomic) XMPPStream * xmppStream;

@end

@implementation ChatViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.navigationItem.title = self.sendUserName;
    
    //初始化XMPP
    [self initXmpp];
   
    //设置接收者
//    self.sendUserName = @"lizelu";
    
    //TableView的回调
    self.myTableView.delegate = self;
    self.myTableView.dataSource = self;
    
    //选图片
    self.imagePiceker = [[UIImagePickerController alloc] init];
    self.imagePiceker.allowsEditing = YES;
    self.imagePiceker.delegate = self;
    
    // Do any additional setup after loading the view.

    //添加基本的子视图
    [self addMySubView];
    
    //给子视图添加约束
    [self addConstaint];
    
    //设置工具栏的回调
    [self setToolViewBlock];
    
    //获取通知中心
    NSNotificationCenter *notificationCenter = [NSNotificationCenter defaultCenter];
    //注册为被通知者
    [notificationCenter addObserver:self selector:@selector(keyChange:) name:UIKeyboardWillChangeFrameNotification object:nil];
}


-(void)initXmpp
{
    UIApplication * app = [UIApplication sharedApplication];
    id delegate = [app delegate];
    //获取xmpp的上下文，用于获取消息记录
    self.xmppManagedObjectContext = [delegate xmppManagedObjectContext];
    //获取xmppStream
    self.xmppStream = [delegate xmppStream];
    [self.xmppStream addDelegate:self delegateQueue:dispatch_get_main_queue()];
    
    
    //通过实体获取request()
    NSFetchRequest * request = [[NSFetchRequest alloc]initWithEntityName:NSStringFromClass([XMPPMessageArchiving_Message_CoreDataObject class])];
    NSSortDescriptor * sortD = [NSSortDescriptor sortDescriptorWithKey:@"timestamp" ascending:YES];
    [request setSortDescriptors:@[sortD]];
    
    NSPredicate *predicate = [NSPredicate predicateWithFormat:[NSString stringWithFormat:@"bareJidStr=='%@'",self.jidStr]];
    [request setPredicate:predicate];
    
    
    self.fetchedResultsController = [[NSFetchedResultsController alloc]initWithFetchRequest:request managedObjectContext:self.xmppManagedObjectContext sectionNameKeyPath:nil cacheName:nil];
    
    self.fetchedResultsController.delegate = self;
    
    NSError * error;
    ;
    if (![self.fetchedResultsController performFetch:&error])
    {
        NSLog(@"%s  %@",__FUNCTION__,[error localizedDescription]);
    }

}



-(void) addMySubView
{
    
    //imageView实例化
    self.volumeImageView = [[UIImageView alloc] init];
    self.volumeImageView.hidden = YES;
    self.volumeImageView.contentMode = UIViewContentModeScaleAspectFit;
    [self.volumeImageView setImage:[UIImage imageNamed:@"record_animate_01.png"]];
    [self.view addSubview:self.volumeImageView];
    
    
    //工具栏
    _toolView = [[ToolView alloc] initWithFrame:CGRectZero];
    [self.view addSubview:_toolView];

}

-(void) addConstaint
{
    
    //给volumeImageView进行约束
    _volumeImageView.translatesAutoresizingMaskIntoConstraints = NO;
    NSArray *imageViewConstrainH = [NSLayoutConstraint constraintsWithVisualFormat:@"H:|-60-[_volumeImageView]-60-|" options:0 metrics:0 views:NSDictionaryOfVariableBindings(_volumeImageView)];
    [self.view addConstraints:imageViewConstrainH];
    
    NSArray *imageViewConstaintV = [NSLayoutConstraint constraintsWithVisualFormat:@"V:|-150-[_volumeImageView(150)]" options:0 metrics:0 views:NSDictionaryOfVariableBindings(_volumeImageView)];
    [self.view addConstraints:imageViewConstaintV];
    
    
    //toolView的约束
    _toolView.translatesAutoresizingMaskIntoConstraints = NO;
    NSArray *toolViewContraintH = [NSLayoutConstraint constraintsWithVisualFormat:@"H:|[_toolView]|" options:0 metrics:0 views:NSDictionaryOfVariableBindings(_toolView)];
    [self.view addConstraints:toolViewContraintH];
    
    NSArray * tooViewConstraintV = [NSLayoutConstraint constraintsWithVisualFormat:@"V:[_toolView(44)]|" options:0 metrics:0 views:NSDictionaryOfVariableBindings(_toolView)];
    [self.view addConstraints:tooViewConstraintV];
    self.tooViewConstraintHeight = tooViewConstraintV[0];
}



//实现工具栏的回调
-(void)setToolViewBlock
{
    __weak __block ChatViewController *copy_self = self;
    //通过block回调接收到toolView中的text
    [self.toolView setMyTextBlock:^(NSString *myText) {
        NSLog(@"%@",myText);
        
        [copy_self sendMessage:SendText Content:myText];
    }];
    
    
    //回调输入框的contentSize,改变工具栏的高度
    [self.toolView setContentSizeBlock:^(CGSize contentSize) {
         [copy_self updateHeight:contentSize];
    }];
    
    
    //获取录音声量，用于声音音量的提示
    [self.toolView setAudioVolumeBlock:^(CGFloat volume) {
        
        copy_self.volumeImageView.hidden = NO;
        int index = (int)(volume*100)%6+1;
        [copy_self.volumeImageView setImage:[UIImage imageNamed:[NSString stringWithFormat:@"record_animate_%02d.png",index]]];
    }];
    
    //获取录音地址（用于录音播放方法）
    [self.toolView setAudioURLBlock:^(NSURL *audioURL) {
        copy_self.volumeImageView.hidden = YES;
        
        //[copy_self sendMessage:SendVoice Content:audioURL];
        //上传服务器
        copy_self.sentType = SendVoice;
        [copy_self sendContentToServer:audioURL];
    }];
    
    //录音取消（录音取消后，把音量图片进行隐藏）
    [self.toolView setCancelRecordBlock:^(int flag) {
        if (flag == 1) {
            copy_self.volumeImageView.hidden = YES;
        }
    }];
    
    
    //扩展功能回调
    [self.toolView setExtendFunctionBlock:^(int buttonTag) {
        switch (buttonTag) {
            case 1:
                //从相册获取
                [copy_self presentViewController:copy_self.imagePiceker animated:YES completion:^{
                    
                }];
                break;
            case 2:
                //拍照
                break;
                
            default:
                break;
        }
    }];
}


//获取图片后要做的方法
-(void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    UIImage *pickerImage = info[UIImagePickerControllerEditedImage];
    
    //发送图片
    //[self sendMessage:SendImage Content:pickerImage];
    self.sentType = SendImage;
    [self sendContentToServer:pickerImage];
    [self dismissViewControllerAnimated:YES completion:^{}];
    
}

-(void)imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
    //在ImagePickerView中点击取消时回到原来的界面
    [self dismissViewControllerAnimated:YES completion:^{}];
    
}


//显示表情,用属性字符串显示表情
-(NSMutableAttributedString *)showFace:(NSString *)str
{
    if (str != nil) {
        //加载plist文件中的数据
        NSBundle *bundle = [NSBundle mainBundle];
        //寻找资源的路径
        NSString *path = [bundle pathForResource:@"emoticons" ofType:@"plist"];
        //获取plist中的数据
        NSArray *face = [[NSArray alloc] initWithContentsOfFile:path];
        
        //创建一个可变的属性字符串
        
        NSMutableAttributedString *attributeString = [[NSMutableAttributedString alloc] initWithString:str];
        
        UIFont *baseFont = [UIFont systemFontOfSize:17];
        [attributeString addAttribute:NSFontAttributeName value:baseFont
                                range:NSMakeRange(0, str.length)];
        
        //正则匹配要替换的文字的范围
        //正则表达式
        NSString * pattern = @"\\[[a-zA-Z0-9\\u4e00-\\u9fa5]+\\]";
        NSError *error = nil;
        NSRegularExpression * re = [NSRegularExpression regularExpressionWithPattern:pattern options:NSRegularExpressionCaseInsensitive error:&error];
        
        if (!re) {
            NSLog(@"%@", [error localizedDescription]);
        }
        
        //通过正则表达式来匹配字符串
        NSArray *resultArray = [re matchesInString:str options:0 range:NSMakeRange(0, str.length)];
        
        
        //用来存放字典，字典中存储的是图片和图片对应的位置
        NSMutableArray *imageArray = [NSMutableArray arrayWithCapacity:resultArray.count];
        
        //根据匹配范围来用图片进行相应的替换
        for(NSTextCheckingResult *match in resultArray) {
            //获取数组元素中得到range
            NSRange range = [match range];
            
            //获取原字符串中对应的值
            NSString *subStr = [str substringWithRange:range];
            
            for (int i = 0; i < face.count; i ++)
            {
                if ([face[i][@"chs"] isEqualToString:subStr])
                {
                    
                    //face[i][@"gif"]就是我们要加载的图片
                    //新建文字附件来存放我们的图片
                    NSTextAttachment *textAttachment = [[NSTextAttachment alloc] init];
                    
                    //给附件添加图片
                    textAttachment.image = [UIImage imageNamed:face[i][@"png"]];
                    
                    //把附件转换成可变字符串，用于替换掉源字符串中的表情文字
                    NSAttributedString *imageStr = [NSAttributedString attributedStringWithAttachment:textAttachment];
                    
                    //把图片和图片对应的位置存入字典中
                    NSMutableDictionary *imageDic = [NSMutableDictionary dictionaryWithCapacity:2];
                    [imageDic setObject:imageStr forKey:@"image"];
                    [imageDic setObject:[NSValue valueWithRange:range] forKey:@"range"];
                    
                    //把字典存入数组中
                    [imageArray addObject:imageDic];
                    
                }
            }
        }
        
        //从后往前替换
        for (int i = (int)imageArray.count -1; i >= 0; i--)
        {
            NSRange range;
            [imageArray[i][@"range"] getValue:&range];
            //进行替换
            [attributeString replaceCharactersInRange:range withAttributedString:imageArray[i][@"image"]];
            
        }
        
        return  attributeString;
        
    }
    
    return nil;

}


//发送消息
-(void)sendMessage:(MySendContentType) sendType Content:(id)content
{
    NSDictionary *bodyDic;
    
    if ([content isKindOfClass:[NSURL class]]) {
        
        bodyDic = @{@"type":@(sendType),
                     @"content":[NSString stringWithFormat:@"%@",content]};
    }
    else
    {
        bodyDic = @{@"type":@(sendType),
                    @"content":content};

    }
    //把bodyDic转换成data类型
    NSError *error = nil;
    
    NSData *bodyData = [NSJSONSerialization dataWithJSONObject:bodyDic options:NSJSONWritingPrettyPrinted error:&error];
    if (error)
    {
        NSLog(@"解析错误%@", [error localizedDescription]);
    }
    
    //把data转成字符串进行发送
    NSString *bodyString = [[NSString alloc] initWithData:bodyData encoding:NSUTF8StringEncoding];
    
    //发送字符串
    //1.构建JID
    XMPPJID *jid = [XMPPJID  jidWithUser:self.sendUserName domain:MY_DOMAIN resource:@"iPhone"];
    
    //2.获取XMPPMessage
    XMPPMessage *xmppMessage = [XMPPMessage messageWithType:@"chat" to:jid];
    
    //3.添加body
    [xmppMessage addBody:bodyString];
    
    //4.发送message
    [self.xmppStream sendElement:xmppMessage];
    
    
    //重载tableView
    [self.myTableView  reloadData];
    
}


//收消息
-(void)xmppStream:(XMPPStream *)sender didReceiveMessage:(XMPPMessage *)message
{
    
    //重载tableView
    [self.myTableView  reloadData];
    

}




//把图片和声音传到服务器上服务器会返回上传资源的地址
-(void)sendContentToServer:(id) resource
{
    
    __weak __block ChatViewController *copy_self = self;
    
    AFHTTPRequestOperationManager * m = [[AFHTTPRequestOperationManager alloc]init];
    AFHTTPRequestOperation * op = [m POST:HTTPSERVER parameters:nil constructingBodyWithBlock:^(id<AFMultipartFormData> formData) {
        
        
        //根据地址上传声音
        if ([resource isKindOfClass:[NSURL class]])
        {
            NSError * error;
            
            NSData *data = [NSData dataWithContentsOfURL:resource];
            NSLog(@"%@", data);
            
            [formData appendPartWithFileData:data name:@"file" fileName:@"123.aac" mimeType:@"aac"];
            if (error) {
                NSLog(@"拼接资源失败%@",[error localizedDescription]);
            }
        }
        
        //上传图片
        if ([resource isKindOfClass:[UIImage class]]) {
            //把图片转换成NSData类型的数据
            NSData *imageData = UIImagePNGRepresentation(resource);

            
            //把图片拼接到数据中
            [formData appendPartWithFileData:imageData name:@"file" fileName:@"123.png" mimeType:@"image/png"];
        }

        
        
    } success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSLog(@"%@",[NSJSONSerialization JSONObjectWithData:responseObject options:NSJSONReadingAllowFragments error:nil]);
        
        NSDictionary *mydic = [NSJSONSerialization JSONObjectWithData:responseObject options:NSJSONReadingAllowFragments error:nil];
        
        //获取上传地址的路径
        NSURL *myURL = [NSURL URLWithString:mydic[@"success"]];
        [copy_self sendMessage:copy_self.sentType Content:myURL];
        
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"失败！！%@",error);
    }];
    op.responseSerializer = [AFHTTPResponseSerializer serializer];
    [op start];
}




//更新toolView的高度约束
-(void)updateHeight:(CGSize)contentSize
{
    float height = contentSize.height + 18;
    if (height <= 80) {
        [self.view removeConstraint:self.tooViewConstraintHeight];
        
        NSString *string = [NSString stringWithFormat:@"V:[_toolView(%f)]", height];
        
        NSArray * tooViewConstraintV = [NSLayoutConstraint constraintsWithVisualFormat:string options:0 metrics:0 views:NSDictionaryOfVariableBindings(_toolView)];
        self.tooViewConstraintHeight = tooViewConstraintV[0];
        [self.view addConstraint:self.tooViewConstraintHeight];
    }
}



//调整cell的高度
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    XMPPMessageArchiving_Message_CoreDataObject * message = [self.fetchedResultsController objectAtIndexPath:indexPath];
    
    NSString * bodyStr = message.body;
    NSData * bodyData = [bodyStr dataUsingEncoding:NSUTF8StringEncoding];
    NSDictionary * dic = [NSJSONSerialization JSONObjectWithData:bodyData options:NSJSONReadingAllowFragments error:nil];
    
    NSLog(@"%@",dic);

 
    NSString *tempType = [NSString stringWithFormat:@"%@",dic[@"type"]];
    //根据文字计算cell的高度
    if ([tempType isEqualToString:[NSString stringWithFormat:@"%ld", SendText]]) {
        NSMutableAttributedString *contentText = [self showFace:dic[@"content"]];
        
        CGRect textBound = [contentText boundingRectWithSize:CGSizeMake(150, 1000) options:NSStringDrawingUsesLineFragmentOrigin context:nil];
        
        float height = textBound.size.height + 40;
        return height;
    }
    if ([dic[@"type"] isEqualToNumber:@(SendVoice)])
    {
        return 73;
    }
    
    if ([dic[@"type"] isEqualToNumber:@(SendImage)])
    {
        return 125;
    }
    
    return 100;
 }

//sections的个数
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    NSArray *secotions = [self.fetchedResultsController sections];
    return secotions.count;
}


//元素的个数
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    
    NSArray *sectoins = [self.fetchedResultsController sections];
    id<NSFetchedResultsSectionInfo> sectionInfo = sectoins[section];
    
    return [sectionInfo numberOfObjects];
}


//设置cell
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    XMPPMessageArchiving_Message_CoreDataObject * message = [self.fetchedResultsController objectAtIndexPath:indexPath];
    NSLog(@"%@",message);
    
    NSString * bodyStr = message.body;
    NSData * bodyData = [bodyStr dataUsingEncoding:NSUTF8StringEncoding];
    NSDictionary * dic = [NSJSONSerialization JSONObjectWithData:bodyData options:NSJSONReadingAllowFragments error:nil];
    
        NSLog(@"%@",dic);
    
    
    
    //根据类型选cell
    MySendContentType contentType = [dic[@"type"] integerValue];

    
    
    if (!message.isOutgoing) {
        switch (contentType) {
            case SendText:
            {
                TextCell *cell = [tableView dequeueReusableCellWithIdentifier:@"textCell" forIndexPath:indexPath];
                NSMutableAttributedString *contentText = [self showFace:dic[@"content"]];
                [cell setCellValue:contentText];
                return cell;
            }
                break;
                
            case SendImage:
            {
                heImageCell *cell = [tableView dequeueReusableCellWithIdentifier:@"heImageCell" forIndexPath:indexPath];
                [cell setCellValue:dic[@"content"]];
                
                
                __weak __block ChatViewController *copy_self = self;
                
                //传出cell中的图片
                [cell setButtonImageBlock:^(NSURL *imageURL) {
                    [copy_self displaySendImage:imageURL];
                }];
                return cell;
            }
                break;
                
            case SendVoice:
            {
                VoiceCellTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"heVoiceCell" forIndexPath:indexPath];
                [cell setCellValue:dic];
                return cell;
            }

                break;
                
            default:
                break;
        }

    }
        

    if (message.isOutgoing) {
    
        switch (contentType) {
            case SendText:
            {
                TextCell *cell = [tableView dequeueReusableCellWithIdentifier:@"myselfTextCell" forIndexPath:indexPath];
                NSMutableAttributedString *contentText = [self showFace:dic[@"content"]];
                [cell setCellValue:contentText];
                return cell;
            }
            break;
            
            case SendImage:
            {
                MyImageCell *cell = [tableView dequeueReusableCellWithIdentifier:@"myImageCell" forIndexPath:indexPath];
                [cell setCellValue:dic[@"content"]];
                
                __weak __block ChatViewController *copy_self = self;
                
                //传出cell中的图片
                [cell setButtonImageBlock:^(NSURL *imageURL) {
                    [copy_self displaySendImage:imageURL];
                }];

                
                return cell;
            }
                break;
            
            case SendVoice:
            {
                VoiceCellTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"myVoiceCell" forIndexPath:indexPath];
                [cell setCellValue:dic];
                return cell;
            }

                break;
                
            default:
                break;
        }
    }
    UITableViewCell *cell;
    return cell;
}


//发送图片的放大
-(void) displaySendImage : (NSURL *)imageURL
{
    //把照片传到放大的controller中
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:[NSBundle mainBundle]];
    
    ImageViewController *imageController = [storyboard instantiateViewControllerWithIdentifier:@"imageController"];
    [imageController setValue:imageURL forKeyPath:@"imageURL"];
    
   [self.navigationController pushViewController:imageController animated:YES];
    

}

//屏幕旋转改变toolView的表情键盘的高度
-(void)willAnimateRotationToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration
{
    //纵屏
    if (UIInterfaceOrientationIsPortrait(toInterfaceOrientation)) {
        [self.toolView changeFunctionHeight:216];
        //self.moreView.frame = frame;
        
    }
    //横屏
    if (UIInterfaceOrientationIsLandscape(toInterfaceOrientation)) {
        [self.toolView changeFunctionHeight:150];
       
        //self.moreView.frame = frame;
        
    }
}



//键盘出来的时候调整tooView的位置
-(void) keyChange:(NSNotification *) notify
{
    NSDictionary *dic = notify.userInfo;
    
    
    CGRect endKey = [dic[@"UIKeyboardFrameEndUserInfoKey"] CGRectValue];
    //坐标系的转换
    CGRect endKeySwap = [self.view convertRect:endKey fromView:self.view.window];
    //运动时间
    [UIView animateWithDuration:[dic[UIKeyboardAnimationDurationUserInfoKey] floatValue] animations:^{
        
        [UIView setAnimationCurve:[dic[UIKeyboardAnimationCurveUserInfoKey] doubleValue]];
        CGRect frame = self.view.frame;
        
        frame.size.height = endKeySwap.origin.y;
        
        self.view.frame = frame;
        [self.view layoutIfNeeded];
    }];
}




- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

- (void)controllerWillChangeContent:(NSFetchedResultsController *)controller {
    [self.myTableView beginUpdates];
}


- (void)controller:(NSFetchedResultsController *)controller didChangeSection:(id <NSFetchedResultsSectionInfo>)sectionInfo
           atIndex:(NSUInteger)sectionIndex forChangeType:(NSFetchedResultsChangeType)type {
    
    switch(type) {
        case NSFetchedResultsChangeInsert:
            [self.myTableView insertSections:[NSIndexSet indexSetWithIndex:sectionIndex]
                          withRowAnimation:UITableViewRowAnimationFade];
            break;
            
        case NSFetchedResultsChangeDelete:
            [self.myTableView deleteSections:[NSIndexSet indexSetWithIndex:sectionIndex]
                          withRowAnimation:UITableViewRowAnimationFade];
            break;
    }
}


- (void)controller:(NSFetchedResultsController *)controller didChangeObject:(id)anObject
       atIndexPath:(NSIndexPath *)indexPath forChangeType:(NSFetchedResultsChangeType)type
      newIndexPath:(NSIndexPath *)newIndexPath {
    
    UITableView *tableView = self.myTableView;
    
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

-(void) scrollBottom
{
    NSArray *sectoins = [self.fetchedResultsController sections];
    id<NSFetchedResultsSectionInfo> sectionInfo = sectoins[0];
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:[sectionInfo numberOfObjects]-1 inSection:0];
    
    [self.myTableView scrollToRowAtIndexPath:indexPath atScrollPosition:UITableViewScrollPositionBottom animated:YES];
}

- (void)controllerDidChangeContent:(NSFetchedResultsController *)controller {
    [self.myTableView endUpdates];
    
    [self performSelector:@selector(scrollBottom) withObject:nil afterDelay:0.1];
}


@end
