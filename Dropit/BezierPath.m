//
//  BezierPath.m
//  Dropit
//
//  Created by mtt0150 on 15/9/2.
//  Copyright (c) 2015年 MT. All rights reserved.
//

#import "BezierPath.h"

@implementation BezierPath
- (void)setPath:(UIBezierPath *)path{
    _path = path;
    [self setNeedsDisplay];
}
- (void)drawRect:(CGRect)rect{
    [self.path stroke];
}
@end
