//
//  UserSpriteNode.h
//  spritekitDemo
//
//  Created by wr on 2019/3/8.
//  Copyright © 2019年 wanmengchao. All rights reserved.
//

#import <SpriteKit/SpriteKit.h>
#import "UserBulletSpriteNode.h"



NS_ASSUME_NONNULL_BEGIN

@interface UserSpriteNode : SKSpriteNode

@property int bulletNum;

@property SKBulletType currentBulletType;

@end

NS_ASSUME_NONNULL_END
