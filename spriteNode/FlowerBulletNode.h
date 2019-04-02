//
//  FlowerBulletNode.h
//  spritekitDemo
//
//  Created by wr on 2019/3/11.
//  Copyright © 2019年 wanmengchao. All rights reserved.
//

#import <SpriteKit/SpriteKit.h>
#import "MacroDefinition.h"

NS_ASSUME_NONNULL_BEGIN

@interface FlowerBulletNode : SKSpriteNode

@property(nonatomic, assign) SKBulletType bulletType;

@property(nonatomic, assign) float nodePower;

@property(nonatomic, assign) float nodeSpeed;

@end

NS_ASSUME_NONNULL_END
