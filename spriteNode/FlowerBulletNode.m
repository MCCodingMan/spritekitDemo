//
//  FlowerBulletNode.m
//  spritekitDemo
//
//  Created by wr on 2019/3/11.
//  Copyright © 2019年 wanmengchao. All rights reserved.
//

#import "FlowerBulletNode.h"

@implementation FlowerBulletNode

- (void)setBulletType:(SKBulletType)bulletType {
    _bulletType = bulletType;
    self.name = @"UserBullet";
    self.nodePower = 85;
    self.nodeSpeed = 20;
    self.physicsBody = [SKPhysicsBody bodyWithCircleOfRadius:10];
    self.physicsBody.categoryBitMask = SKPhysicsBodyFlower;
    self.physicsBody.contactTestBitMask = SKPhysicsBodyEnemy | SKPhysicsBodyEnemyBullets;
    self.physicsBody.collisionBitMask = SKPhysicsBodyNone;
}

@end
