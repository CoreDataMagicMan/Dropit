//
//  DropitViewController.m
//  Dropit
//
//  Created by mtt0150 on 15/9/2.
//  Copyright (c) 2015年 MT. All rights reserved.
//

#import "DropitViewController.h"
#import "DynamicBehavior.h"
#import "BezierPath.h"
static const CGSize DROP_SIZE = {30, 30};
@interface DropitViewController () <UIDynamicAnimatorDelegate>
@property (weak, nonatomic) IBOutlet BezierPath *gameView;
//声明一个动画者
@property (strong, nonatomic) UIDynamicAnimator *animator;
//声明一个自定义的动作行为
//这个动作行为包含了两个动作：分别是重力的行为和碰撞的行为
@property (strong, nonatomic) DynamicBehavior *dynamicBehavior;
//添加一个吸附行为
@property (strong, nonatomic) UIAttachmentBehavior *attachment;
//正在掉落的正方体
@property (strong, nonatomic) UIView *droppingCircle;
@end

@implementation DropitViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Do any additional setup after loading the view.
}
- (void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    NSLog(@"%f",self.gameView.bounds.size.width);
}
//初始化一个动画者
- (UIDynamicAnimator *)animator{
    if (!_animator) {
        _animator = [[UIDynamicAnimator alloc] initWithReferenceView:self.gameView];
        _animator.delegate = self;
    }
    return _animator;
}
//初始化一个自定义的动作
- (DynamicBehavior *)dynamicBehavior{
    if (!_dynamicBehavior) {
        _dynamicBehavior = [[DynamicBehavior alloc] init];
        [self.animator addBehavior:_dynamicBehavior];
    }
    return _dynamicBehavior;
}
//单点的时候
- (IBAction)tap:(UITapGestureRecognizer *)sender {
    //当单点或者双击时执行的方法
    [self dropCircle];
}
//拖动的手势
- (IBAction)pan:(UIPanGestureRecognizer *)sender {
    //取得手势点击的位置
    CGPoint gesturePoint = [sender locationInView:self.gameView];
    if (sender.state == UIGestureRecognizerStateBegan) {
        //拖动开始.创建锚点和对象的吸附
        [self createAttachment:gesturePoint];
    }
    else if (sender.state == UIGestureRecognizerStateChanged){
        //拖动位置发生改变
        self.attachment.anchorPoint = gesturePoint;
    }
    else if (sender.state == UIGestureRecognizerStateEnded){
        //拖动结束
        [self.animator removeBehavior:_attachment];
        //移除贝塞尔曲线
        self.gameView.path = nil;
    }
}
- (void)createAttachment:(CGPoint)droppingPoint{
    if (self.droppingCircle) {
        _attachment = [[UIAttachmentBehavior alloc] initWithItem:self.droppingCircle attachedToAnchor:droppingPoint];
        //创建一个弱指针引用self
        __weak DropitViewController *weakSelf = self;
        //声明一个局部变量指向正在掉落的正方体
        UIView *droppingView = self.droppingCircle;
        //在这里绘制贝塞尔曲线
        _attachment.action = ^(){
        //在这个代码块中绘制path曲线,在这里用weak的原因是因为这个控制器self强引用了UIAttachmentBehavior，而attachment又强引用了action代码块，所以形成了一个内存保留环，需要创建一个weak的self（指这个控制器），就可以打破这个保留环
            //设置曲线的起始点
            //每次执行代码块更新，都要新创建一个贝塞尔曲线，否则上次的曲线将会被保留
            UIBezierPath *path = [[UIBezierPath alloc] init];
            [path moveToPoint:weakSelf.attachment.anchorPoint];
            //添加一条直线
            [path addLineToPoint:droppingView.center];
            weakSelf.gameView.path = path;
        };
        _droppingCircle = nil;
        //动画者开启吸附效果
        [self.animator addBehavior:_attachment];
    }
}
//掉落一个正方体
- (void)dropCircle{
    //首先需要创建一个正方体，需要指定他们的 frame
    CGRect frame;
    frame.origin = CGPointZero;
    frame.size = DROP_SIZE;
    int x = (arc4random() % (int)_gameView.bounds.size.width) / DROP_SIZE.width;
    //取得每个正方体的坐标
    frame.origin.x = x * DROP_SIZE.width;
    UIView *dropView = [[UIView alloc] initWithFrame:frame];
    //取得随机颜色
    dropView.backgroundColor = [self randomColor];
    [self.gameView addSubview:dropView];
    //增加正在掉落的正方体
    self.droppingCircle = dropView;
    [self.dynamicBehavior addItem:dropView];
}
- (UIColor *)randomColor{
    switch (arc4random() % 5) {
        case 0:
            return [UIColor redColor];
        case 1:
            return [UIColor blueColor];
        case 2:
            return [UIColor greenColor];
        case 3:
            return [UIColor yellowColor];
        case 4:
            return [UIColor purpleColor];
        }
    return [UIColor blackColor];
}
#pragma mark -UIDynamicAnimatorDelegate
- (void)dynamicAnimatorDidPause:(UIDynamicAnimator *)animator{
    [self removeCompletedRows];
}
//炸掉选定的行的方块
- (BOOL)removeCompletedRows{
    NSMutableArray *dropsToRemove = [[NSMutableArray alloc] init];
    for (CGFloat y = self.gameView.bounds.size.height - DROP_SIZE.height / 2; y > 0 ; y -= DROP_SIZE.height) {
        BOOL rowsIsComplete = YES;
        NSMutableArray *dropsFound = [[NSMutableArray alloc]init];
        for (CGFloat x = DROP_SIZE.width / 2; x <= self.gameView.bounds.size.width - DROP_SIZE.width / 2; x += DROP_SIZE.width) {
            UIView *hitView = [self.gameView hitTest:CGPointMake(x, y) withEvent:NULL];
            if ([hitView superview] == self.gameView) {
                [dropsFound addObject:hitView];
            }
            else{
                rowsIsComplete = NO;
                break;
            }
            
        }
        if (![dropsFound count]) break;
        if (rowsIsComplete) {
            [dropsToRemove addObjectsFromArray:dropsFound];
        }
    }
    
    //这里我们需要用动画的效果炸飞一行方格
    if (dropsToRemove.count) {
        for (UIView *drop in dropsToRemove) {
            //从自定义行为中移除行为施加对象
            [self.dynamicBehavior removeItem:drop];
        }
        //用动画移除视图中的方格
        [self removeItemWithAnimation:dropsToRemove];
    }
    return NO;
}
#pragma mark -cycle
- (void)removeItemWithAnimation:(NSMutableArray *)dropArray{
    [UIView animateWithDuration:1.0f animations:^{
        for (UIView *drop in dropArray) {
            //设置坐标在视图之外
            int x = (arc4random() % (int)self.gameView.bounds.size.width * 5) - (int)self.gameView.bounds.size.width * 2;
            int y = self.gameView.bounds.size.height;
            drop.center = CGPointMake(x, -y);
        }
    } completion:^(BOOL finished) {
        [dropArray makeObjectsPerformSelector:@selector(removeFromSuperview)];
    }];
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
