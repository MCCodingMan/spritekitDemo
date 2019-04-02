//
//  UserBulletSpriteNode.m
//  spritekitDemo
//
//  Created by wr on 2019/3/8.
//  Copyright © 2019年 wanmengchao. All rights reserved.
//

#import "UserBulletSpriteNode.h"

@implementation UserBulletSpriteNode

- (void)setBulletType:(SKBulletType)bulletType {
    _bulletType = bulletType;
    _isBulletTypeTracking = NO;
    self.name = @"UserBullet";
    switch (bulletType) {
        case SKBulletTypeMini:
            self.nodePower = 50;
            self.nodeSpeed = 30;
            self.physicsBody = [SKPhysicsBody bodyWithCircleOfRadius:15];
            break;
        case SKBulletTypeTracking:
            self.nodePower = 70;
            self.nodeSpeed = 20;
            self.physicsBody = [SKPhysicsBody bodyWithCircleOfRadius:15];
            _isBulletTypeTracking = YES;
            break;
        case SKBulletTypeLaser:
            self.nodePower = 100;
            break;
        case SKBulletTypeMissile:
            self.nodePower = 150;
            self.physicsBody = [SKPhysicsBody bodyWithRectangleOfSize:self.size];
            self.nodeSpeed = 15;
            break;
        case SKBulletTypeFlower:
            self.nodePower = 85;
            break;
        default:
            break;
    }
    self.physicsBody.categoryBitMask = SKPhysicsBodyUserBullets;
    self.physicsBody.contactTestBitMask = SKPhysicsBodyEnemy | SKPhysicsBodyEnemyBullets;
    self.physicsBody.collisionBitMask = SKPhysicsBodyNone;
}

- (void)removeFromParent {
    NSLog(@"消失位置:(%f,%f),屏幕宽高:(%f,%f)",self.position.x,self.position.y,[UIScreen mainScreen].bounds.size.width,[UIScreen mainScreen].bounds.size.height);
    [super removeFromParent];
}

@end
