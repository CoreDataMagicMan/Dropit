//
//  DynamicBehavior.m
//  Dropit
//
//  Created by mtt0150 on 15/9/2.
//  Copyright (c) 2015年 MT. All rights reserved.
//

#import "DynamicBehavior.h"
@interface DynamicBehavior ()
//声明一个重力动作
@property (strong, nonatomic) UIGravityBehavior *gravity;
//声明一个碰撞行为
@property (strong, nonatomic) UICollisionBehavior *collision;
//添加一个动力选项属性的设置
@property (strong, nonatomic) UIDynamicItemBehavior *itemBehaviorOptions;
@end
@implementation DynamicBehavior
//初始化一个重力动作
- (UIGravityBehavior *)gravity{
    if (!_gravity) {
        _gravity = [[UIGravityBehavior alloc] init];
        //修改重力值，值越大重力越明显
        _gravity.magnitude = 1.0;
        //给动画者添加一个重力动作self.animator会去先执行setter函数，再返回他的对象，而_animator是直接取得当前对象。
       
    }
    return _gravity;
}
//初始化一个碰撞行为
- (UICollisionBehavior *)collision{
    if (!_collision) {
        _collision = [[UICollisionBehavior alloc] init];
        //给动画者添加这个行为
        //设置碰撞边界为当前参考视图self.gameView的bounds
        _collision.translatesReferenceBoundsIntoBoundary = YES;
       
    }
    return _collision;
}
//初始化一个动力属性设置
- (UIDynamicItemBehavior *)itemBehaviorOptions{
    if (!_itemBehaviorOptions) {
        _itemBehaviorOptions = [[UIDynamicItemBehavior alloc] init];
        //禁止动力项旋转
        _itemBehaviorOptions.allowsRotation = NO;
    }
    return _itemBehaviorOptions;
}
- (void)addItem:(id <UIDynamicItem>)item{
    [self.gravity addItem:item];
    [self.collision addItem:item];
    [self.itemBehaviorOptions addItem:item];
}

- (void)removeItem:(id <UIDynamicItem>)item{
    [self.gravity removeItem:item];
    [self.collision removeItem:item];
    [self.itemBehaviorOptions removeItem:item];
}
- (instancetype)init{
    self = [super init];
    //在初始化方法中添加子行为
    [self addChildBehavior:self.gravity];
    [self addChildBehavior:self.collision];
    [self addChildBehavior:self.itemBehaviorOptions];
    return self;
}
@end
