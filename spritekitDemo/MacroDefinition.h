//
//  MacroDefinition.h
//  spritekitDemo
//
//  Created by wr on 2019/3/8.
//  Copyright © 2019年 wanmengchao. All rights reserved.
//

#ifndef MacroDefinition_h
#define MacroDefinition_h

#define SCREEN_WIDTH  [UIScreen mainScreen].bounds.size.width
#define SCREEN_HEIGHT [UIScreen mainScreen].bounds.size.height

typedef enum{
    SKPhysicsBodyEnemy        = 0x1<<1,
    SKPhysicsBodyEnemyBullets = 0x1<<2,
    SKPhysicsBodyUser         = 0x1<<3,
    SKPhysicsBodyUserBullets  = 0x1<<4,
    SKPhysicsBodyBackGround   = 0x1<<5,
    SKPhysicsBodyFlower       = 0x1<<6,
    SKPhysicsBodyFlower1      = 0x1<<7,
    SKPhysicsBodyHighLight    = 0x1<<8,
    SKPhysicsBodyNone         = 0,
}SKPhysicBodyNodeType;

typedef enum {
    SKBulletTypeMini = 0,
    SKBulletTypeTracking,
    SKBulletTypeLaser,
    SKBulletTypeMissile,
    SKBulletTypeFlower
}SKBulletType;

#endif /* MacroDefinition_h */
