//
//  DynamicBehavior.h
//  Dropit
//
//  Created by mtt0150 on 15/9/2.
//  Copyright (c) 2015年 MT. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface DynamicBehavior : UIDynamicBehavior
//提供两个街口，为这个自定义的行为添加施加对象
- (void)addItem:(id <UIDynamicItem>)item;
- (void)removeItem:(id <UIDynamicItem>)item;
@end
