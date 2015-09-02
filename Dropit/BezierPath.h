//
//  BezierPath.h
//  Dropit
//
//  Created by mtt0150 on 15/9/2.
//  Copyright (c) 2015年 MT. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface BezierPath : UIView
//声明一个公共的属性，这个是一个贝塞尔曲线
@property (strong, nonatomic) UIBezierPath *path;
@end
