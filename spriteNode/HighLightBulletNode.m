//
//  HighLightBulletNode.m
//  spritekitDemo
//
//  Created by wr on 2019/3/12.
//  Copyright © 2019年 wanmengchao. All rights reserved.
//

#import "HighLightBulletNode.h"

@implementation HighLightBulletNode

-(void)setBulletType:(SKBulletType)bulletType {
    _bulletType = bulletType;
    self.physicsBody = [SKPhysicsBody bodyWithCircleOfRadius:10];
    self.physicsBody.categoryBitMask = SKPhysicsBodyHighLight;
    self.physicsBody.contactTestBitMask = SKPhysicsBodyUser;
    self.physicsBody.collisionBitMask = SKPhysicsBodyNone;
}

@end
