//
//  FunctionView.m
//  MyKeyBoard
//
//  Created by 李泽鲁 on 14-9-16.
//  Copyright (c) 2014年 Mrli. All rights reserved.
//

#import "FunctionView.h"
#import "FaceView.h"
#import "ImageModelClass.h"
#import "HistoryImage.h"

@interface FunctionView()

@property (strong, nonatomic) FunctionBlock block;
//暂存表情组件回调的表情和表情文字
@property (strong, nonatomic) UIImage *headerImage;
@property (strong, nonatomic) NSString *imageText;

//display我们的表情图片
@property (strong, nonatomic) UIScrollView *headerScrollView;

//定义数据模型用于获取历史表情
@property (strong, nonatomic) ImageModelClass *imageModel;

@end


@implementation FunctionView
- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        
        
        //实例化数据模型
        self.imageModel =[[ImageModelClass alloc] init];
       
        //实例化下面的button
        UIButton *faceButton = [[UIButton alloc] initWithFrame:CGRectZero];
        faceButton.backgroundColor = [UIColor grayColor];
        
        [faceButton setTitle:@"全部表情" forState:UIControlStateNormal];
        [faceButton setShowsTouchWhenHighlighted:YES];
        [faceButton addTarget:self action:@selector(tapButton1:) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:faceButton];
        
        
        //实例化常用表情按钮
        UIButton *moreButton = [[UIButton alloc] initWithFrame:CGRectZero];
        moreButton.backgroundColor = [UIColor orangeColor];
        [moreButton setTitle:@"常用表情" forState:UIControlStateNormal];
        [moreButton setShowsTouchWhenHighlighted:YES];
        [moreButton addTarget:self action:@selector(tapButton2:) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:moreButton];
        
        //给按钮添加约束
        faceButton.translatesAutoresizingMaskIntoConstraints = NO;
        moreButton.translatesAutoresizingMaskIntoConstraints = NO;
        //水平约束
        NSArray *buttonH = [NSLayoutConstraint constraintsWithVisualFormat:@"H:|[faceButton][moreButton(==faceButton)]|" options:0 metrics:0 views:NSDictionaryOfVariableBindings(faceButton,moreButton)];
        [self addConstraints:buttonH];
        
        //垂直约束
        NSArray *button1V = [NSLayoutConstraint constraintsWithVisualFormat:@"V:[faceButton(44)]|" options:0 metrics:0 views:NSDictionaryOfVariableBindings(faceButton)];
        [self addConstraints:button1V];
        
        NSArray *button2V = [NSLayoutConstraint constraintsWithVisualFormat:@"V:[moreButton(44)]|" options:0 metrics:0 views:NSDictionaryOfVariableBindings(moreButton)];
        [self addConstraints:button2V];
        
        //默认显示表情图片
        [self tapButton1:nil];
        
    }
    return self;
}

//接受回调
-(void)setFunctionBlock:(FunctionBlock)block
{
    self.block = block;
}

//点击全部表情按钮回调方法
-(void)tapButton1: (id) sender
{
    // 从plist文件载入资源
    NSBundle *bundle = [NSBundle mainBundle];
    NSString *path = [bundle pathForResource:self.plistFileName ofType:@"plist"];
    NSArray *headers = [NSArray arrayWithContentsOfFile:path];
    
    if (headers.count == 0) {
        NSLog(@"访问的plist文件不存在");
    }
    else
    {
        //调用headers方法显示表情
        [self header:headers];
    }
}

//点击历史表情的回调方法
-(void) tapButton2: (id) sender
{
    //从数据库中查询所有的图片
    NSArray *imageData = [self.imageModel queryAll];
    //解析请求到的数据
    NSMutableArray *headers = [NSMutableArray arrayWithCapacity:imageData.count];
    
    //数据实体，相当于javaBean的东西
    HistoryImage *tempData;
    
    for (int i = 0; i < imageData.count; i ++) {
        tempData = imageData[i];
        
        //解析数据，转换成函数headers要用的数据格式
        NSMutableDictionary *dic = [NSMutableDictionary dictionaryWithCapacity:2];
        [dic setObject:tempData.imageText forKey:@"chs"];
        UIImage *image = [UIImage imageWithData:tempData.headerImage];
        [dic setObject:image forKey:@"png"];
        
        [headers addObject:dic];
    }
    
    [self header:headers];
    
}


//负责把查出来的图片显示
-(void) header:(NSArray *)headers
{
    [self.headerScrollView removeFromSuperview];
    self.headerScrollView = [[UIScrollView alloc] initWithFrame:CGRectZero];
    self.headerScrollView.backgroundColor = [UIColor grayColor];
    [self addSubview:self.headerScrollView];
    
    //给scrollView添加约束
    self.headerScrollView.translatesAutoresizingMaskIntoConstraints = NO;
    //水平约束
    NSArray *scrollH = [NSLayoutConstraint constraintsWithVisualFormat:@"H:|-10-[_headerScrollView]-10-|" options:0   metrics:0 views:NSDictionaryOfVariableBindings(_headerScrollView)];
    [self addConstraints:scrollH];
    
    //垂直约束
    NSArray *scrolV = [NSLayoutConstraint constraintsWithVisualFormat:@"V:|-10-[_headerScrollView]-50-|" options:0 metrics:0 views:NSDictionaryOfVariableBindings(_headerScrollView)];
    [self addConstraints:scrolV];
    
    
    
    CGFloat scrollHeight = (self.frame).size.height-60;
    
    //根据图片量来计算scrollView的Contain的宽度
    CGFloat width = (headers.count/(scrollHeight/30))*30;
    self.headerScrollView.contentSize = CGSizeMake(width, scrollHeight);
    self.headerScrollView.pagingEnabled = YES;
    
    
    //图片坐标
    CGFloat x = 0;
    CGFloat y = 0;
    
    //往scroll上贴图片
    for (int i = 0; i < headers.count; i ++) {
        //获取图片信息
        UIImage *image;
        if ([headers[i][@"png"] isKindOfClass:[NSString class]])
        {
             image = [UIImage imageNamed:headers[i][@"png"]];
        }
        else
        {
            image = headers[i][@"png"];
        }
        
        NSString *imageText = headers[i][@"chs"];
        
        //计算图片位置
        y = (i%(int)(scrollHeight/30)) * 30;
        x = (i/(int)(scrollHeight/30)) * 30;
        
        FaceView *face = [[FaceView alloc] initWithFrame:CGRectMake(x, y, 0, 0)];
        [face setImage:image ImageText:imageText];
        
        //face的回调，当face点击时获取face的图片
        __weak __block FunctionView *copy_self = self;
        [face setFaceBlock:^(UIImage *image, NSString *imageText)
         {
             copy_self.block(image, imageText);
         }];
        
        [self.headerScrollView addSubview:face];
    }
    
    [self.headerScrollView setNeedsDisplay];

}



/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

@end
