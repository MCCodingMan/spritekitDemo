//
//  UserBulletSpriteNode.h
//  spritekitDemo
//
//  Created by wr on 2019/3/8.
//  Copyright © 2019年 wanmengchao. All rights reserved.
//

#import <SpriteKit/SpriteKit.h>
#import "MacroDefinition.h"


NS_ASSUME_NONNULL_BEGIN

@interface UserBulletSpriteNode : SKSpriteNode

@property(nonatomic, assign) SKBulletType bulletType;

@property(nonatomic, assign) float nodePower;

@property(nonatomic, assign) float nodeSpeed;

@property(nonatomic, assign) BOOL isFollowingEnemy;

@property(nonatomic, assign) BOOL isBulletTypeTracking;

@property(nonatomic, strong) SKAction *currentActions;

@end

NS_ASSUME_NONNULL_END
