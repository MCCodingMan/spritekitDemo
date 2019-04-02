//
//  firstScene.m
//  spritekitDemo
//
//  Created by wr on 2019/3/6.
//  Copyright © 2019年 wanmengchao. All rights reserved.
//

#import "firstScene.h"
#import "MacroDefinition.h"
#import "EnemySpriteNode.h"
#import "UserBulletSpriteNode.h"
#import "UserSpriteNode.h"
#import "FlowerBulletNode.h"
#import "HighLightBulletNode.h"

#define SCREEN_WIDTH  [UIScreen mainScreen].bounds.size.width
#define SCREEN_HEIGHT [UIScreen mainScreen].bounds.size.height

@interface firstScene()<SKPhysicsContactDelegate>

@end

@implementation firstScene {
    SKSpriteNode *backNode1;
    SKSpriteNode *backNode2;
    UserSpriteNode *userNode;
    NSMutableArray<EnemySpriteNode *> *enemys;
    NSMutableArray<UserBulletSpriteNode *> *bullets;
    NSMutableArray<SKSpriteNode *> *enemyBullets;
    SKLabelNode *scoreNode;
    BOOL isSelectUserAir;
    BOOL isFir;
    CGPoint flowerBomPoint;
    double killEnemyNum;
    SKAction *changeColorAction;
}

- (void)didMoveToView:(SKView *)view {
    [self initBackGroundNode];
    [self initSomeSetting];
    [self initPlanNode];
}

- (void)initSomeSetting {
    self.physicsBody = [SKPhysicsBody bodyWithEdgeLoopFromRect:self.frame];
    self.physicsBody.categoryBitMask = SKPhysicsBodyBackGround;
    self.physicsBody.contactTestBitMask = SKPhysicsBodyNone;
    self.physicsBody.collisionBitMask = SKPhysicsBodyNone;
    self.physicsWorld.gravity = CGVectorMake(0, 0);
    self.physicsWorld.contactDelegate = self;
    enemys = [[NSMutableArray alloc] init];
    bullets = [[NSMutableArray alloc] init];
    enemyBullets = [[NSMutableArray alloc] init];
    scoreNode = [SKLabelNode labelNodeWithText:@"击杀敌人数:0"];
    scoreNode.fontColor = [SKColor greenColor];
    scoreNode.fontSize = 14;
    scoreNode.position = CGPointMake(SCREEN_WIDTH - 25, SCREEN_HEIGHT - 20);
    [self addChild:scoreNode];
    killEnemyNum = 0;
    changeColorAction =[SKAction repeatActionForever:
                        [SKAction sequence:@[[SKAction colorizeWithColor:[SKColor redColor] colorBlendFactor:0.5 duration:0.2],
                                             [SKAction waitForDuration:0.1],
                                             [SKAction colorizeWithColorBlendFactor:0 duration:0.1]]]];
}

- (void)initPlanNode {
    userNode = [UserSpriteNode spriteNodeWithTexture:[SKTexture textureWithImage:[UIImage imageNamed:@"Air"]] size:CGSizeMake(50, 50)];
    userNode.position = self.view.center;
    userNode.name = @"UserAir";
    userNode.zPosition = 0;
    userNode.bulletNum = 1;
    userNode.currentBulletType = SKBulletTypeTracking;
    flowerBomPoint = CGPointMake(userNode.position.x, userNode.position.y + 200);
    [self addChild:userNode];
    SKPhysicsBody *userPhysicBody = [SKPhysicsBody bodyWithCircleOfRadius:20];
    userPhysicBody.categoryBitMask    = SKPhysicsBodyUser;
    userPhysicBody.contactTestBitMask = SKPhysicsBodyEnemy | SKPhysicsBodyEnemyBullets;
    userPhysicBody.collisionBitMask   = SKPhysicsBodyNone;
    userNode.physicsBody = userPhysicBody;
    isFir = YES;
}

- (void)initBackGroundNode {
    backNode1 = [SKSpriteNode spriteNodeWithTexture:[SKTexture textureWithImage:[UIImage imageNamed:@"bg1"]]];
    backNode1.size = CGSizeMake(self.size.width, self.size.height + 100);
    backNode1.position = self.view.center;
    backNode1.zPosition = -1;
    [self addChild:backNode1];
    backNode2 = [SKSpriteNode spriteNodeWithTexture:[SKTexture textureWithImage:[UIImage imageNamed:@"bg1"]]];
    backNode2.size = backNode1.size;
    backNode2.position = CGPointMake(backNode1.position.x, backNode1.position.y + backNode1.size.height);
    backNode2.zPosition = -1;
    [self addChild:backNode2];
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    UITouch *touch = [touches anyObject];
    CGPoint clickPoint = [touch locationInView:[touch view]];
    if (touch.tapCount == 2) {
        float horizontalLevel = clickPoint.x;
        float verticalLevel = SCREEN_HEIGHT - clickPoint.y;
        flowerBomPoint = CGPointMake(horizontalLevel, verticalLevel);
    }
}

- (void)touchesMoved:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    UITouch *touch = [touches anyObject];
    CGPoint clickPoint = [touch locationInView:[touch view]];
    float horizontalLevel = clickPoint.x;
    float verticalLevel = SCREEN_HEIGHT - clickPoint.y;
    if (horizontalLevel < 20) {
        horizontalLevel = 20;
    }else if (horizontalLevel > SCREEN_WIDTH - 20) {
        horizontalLevel = SCREEN_WIDTH - 20;
    }
    if (verticalLevel < 20) {
        verticalLevel = 20;
    }else if (verticalLevel > SCREEN_HEIGHT - 20) {
        verticalLevel = SCREEN_HEIGHT - 20;
    }
    SKAction *moveAction = [SKAction moveTo:CGPointMake(horizontalLevel, verticalLevel) duration:1];
    moveAction.speed = 10;
    [userNode runAction:moveAction];
}

- (void)update:(NSTimeInterval)currentTime {
    [self updateBackGroundNode:currentTime];
    [self generateEnemys];
    if (isFir) {
        [self jugeBulletNumAndType];
    }
    if (killEnemyNum == 50 * pow(2, userNode.bulletNum - 1) && userNode.bulletNum < 5) {
        userNode.bulletNum++;
    }
}

- (void)jugeBulletNumAndType {
    static int generateBulletTime = 0;
    generateBulletTime++;
    switch (userNode.currentBulletType) {
        case SKBulletTypeMini:
            if (generateBulletTime >= 2) {
                [self generateBulletMini:userNode.bulletNum];
                generateBulletTime = 0;
            }
            break;
        case SKBulletTypeTracking:
            if (generateBulletTime >= 20) {
                [self generateBulletTracking:userNode.bulletNum];
                generateBulletTime = 0;
            }
            [self followEnemy];
            break;
        case SKBulletTypeLaser:
            [self generateBulletLaser];
            break;
        case SKBulletTypeMissile:
            if (generateBulletTime >= 100) {
                [self generateBulletMissile:userNode.bulletNum];
                generateBulletTime = 0;
            }
            break;
        case SKBulletTypeFlower:
            if (generateBulletTime >= 100) {
                [self generateBulletFlower];
                generateBulletTime = 0;
            }
            break;
        default:
            break;
    }
    
}

- (void)followEnemy {
    if (enemys.count > 0) {
        int enemyIndex = rand() % enemys.count;
        CGPoint firstEnemyPosition = [enemys objectAtIndex:enemyIndex].position;
        if (bullets.count > 0) {
            NSPredicate *predicate = [NSPredicate predicateWithFormat:@"isFollowingEnemy==NO"];
            NSPredicate *predicate1 = [NSPredicate predicateWithFormat:@"isBulletTypeTracking==YES"];
            NSArray<UserBulletSpriteNode *> *bulletArr = [bullets filteredArrayUsingPredicate:predicate];
            bulletArr = [bulletArr filteredArrayUsingPredicate:predicate1];
            if (bulletArr.count > 0) {
                int bulletIndex = rand() % bullets.count;
                UserBulletSpriteNode *firstBulletNode = [bullets objectAtIndex:bulletIndex];
                firstBulletNode.isFollowingEnemy = YES;
                firstBulletNode.zRotation = [self nodeMoveRotate:firstBulletNode.position movePoint:firstEnemyPosition];
                NSTimeInterval moveTime = sqrt(pow(firstEnemyPosition.x - firstBulletNode.position.x, 2) + pow(firstEnemyPosition.y - firstBulletNode.position.y, 2))/firstBulletNode.nodeSpeed;
                SKAction *action = [SKAction moveTo:firstEnemyPosition duration:moveTime];
                action.speed = firstBulletNode.nodeSpeed;
                [firstBulletNode removeAllActions];
                [firstBulletNode runAction:[SKAction repeatAction:[SKAction sequence:@[action,firstBulletNode.currentActions]] count:1] completion:^{
                    if (firstBulletNode) {
                        firstBulletNode.isFollowingEnemy = NO;
                    }
                }];
            }
        }
    }
}

- (void)updateBackGroundNode:(NSTimeInterval)currentTime {
    if (backNode1.position.y < self.view.center.y - (self.size.height + 100)) {
        backNode1.position = CGPointMake(backNode1.position.x, backNode2.position.y + self.size.height + 100);
    }
    if (backNode2.position.y < self.view.center.y - (self.size.height + 100)) {
        backNode2.position = CGPointMake(backNode2.position.x, backNode1.position.y + self.size.height + 100);
    }
    backNode1.position = CGPointMake(backNode1.position.x, backNode1.position.y - currentTime * 0.00001);
    backNode2.position = CGPointMake(backNode2.position.x, backNode2.position.y - currentTime * 0.00001);
}

- (void)generateEnemys {
    static int generateTime = 0;
    generateTime++;
    if (generateTime % 30 == 0) {
        [self initEnemy];
        generateTime = 0;
    }
}

- (void)initEnemy {
    static float HP = 80;
    HP = HP + 0.1;
    EnemySpriteNode *enemy = [EnemySpriteNode spriteNodeWithTexture:[SKTexture textureWithImageNamed:@"Air"] size:CGSizeMake(50, 50)];
    enemy.name = @"Enemy";
    enemy.zPosition = 0;
    enemy.nodeHp = HP;
    float randamX = 20 + rand() % ((int)SCREEN_WIDTH - 40 + 1);
    enemy.position = CGPointMake(randamX, SCREEN_HEIGHT + 25);
    [self addChild:enemy];
    [self->enemys addObject:enemy];
    SKPhysicsBody *enemyBody = [SKPhysicsBody bodyWithCircleOfRadius:20];
    enemyBody.categoryBitMask = SKPhysicsBodyEnemy;
    enemyBody.contactTestBitMask = SKPhysicsBodyUser | SKPhysicsBodyUserBullets | SKPhysicsBodyFlower | SKPhysicsBodyFlower1;
    enemyBody.collisionBitMask = SKPhysicsBodyNone;
    enemy.physicsBody = enemyBody;
    float randamSpeed = 10 + rand() % 10;
    CGPoint enemyMoveEnd = CGPointMake(20 + rand() % ((int)SCREEN_WIDTH - 40 + 1), -30);
    SKAction *enemyMoveAction = [SKAction moveTo:enemyMoveEnd duration:[self onePointMoveToOtherPointTime:enemy.position otherPoint:enemyMoveEnd speed:randamSpeed]];
    enemyMoveAction.speed = randamSpeed;
    SKAction *groupAction;
    if (rand() % 100 == 1) {
        groupAction = [SKAction group:@[enemyMoveAction,changeColorAction]];
        enemy.isHighLightEnemy = YES;
    }else{
        groupAction = [SKAction group:@[enemyMoveAction]];
        enemy.isHighLightEnemy = NO;
    }
    [enemy runAction:groupAction completion:^{
        [enemy removeFromParent];
        [self->enemys removeObject:enemy];
    }];
}

- (void)didBeginContact:(SKPhysicsContact *)contact {
    if (contact.bodyA.categoryBitMask == SKPhysicsBodyEnemy && (contact.bodyB.categoryBitMask == SKPhysicsBodyFlower || contact.bodyB.categoryBitMask == SKPhysicsBodyFlower1)) {
        EnemySpriteNode *enemyNode = (EnemySpriteNode *)contact.bodyA.node;
        SKEmitterNode *enemyBomEmitter = [NSKeyedUnarchiver unarchiveObjectWithFile:[[NSBundle mainBundle] pathForResource:@"enemyBoom" ofType:@"sks"]];
        if (contact.bodyB.categoryBitMask == SKPhysicsBodyFlower) {
            FlowerBulletNode *bulletNode = (FlowerBulletNode *)contact.bodyB.node;
            enemyNode.nodeHp -= bulletNode.nodePower;
            for (UserBulletSpriteNode *node in bullets) {
                [node removeFromParent];
            }
        }
        if (enemyNode.nodeHp <= 0) {
            enemyBomEmitter.position = enemyNode.position;
            enemyBomEmitter.numParticlesToEmit = 25;
            [self addChild:enemyBomEmitter];
            [enemyNode removeFromParent];
            [enemys removeObject:enemyNode];
            killEnemyNum++;
            scoreNode.text = [NSString stringWithFormat:@"击杀敌人数:%f",killEnemyNum];
        }
    }else if (contact.bodyB.categoryBitMask == SKPhysicsBodyEnemy && (contact.bodyA.categoryBitMask == SKPhysicsBodyFlower || contact.bodyA.categoryBitMask == SKPhysicsBodyFlower1)) {
        EnemySpriteNode *enemyNode = (EnemySpriteNode *)contact.bodyB.node;
        SKEmitterNode *enemyBomEmitter = [NSKeyedUnarchiver unarchiveObjectWithFile:[[NSBundle mainBundle] pathForResource:@"enemyBoom" ofType:@"sks"]];
        if (contact.bodyB.categoryBitMask == SKPhysicsBodyFlower) {
            FlowerBulletNode *bulletNode = (FlowerBulletNode *)contact.bodyA.node;
            enemyNode.nodeHp -= bulletNode.nodePower;
        }
        if (enemyNode.nodeHp <= 0) {
            enemyBomEmitter.position = enemyNode.position;
            enemyBomEmitter.numParticlesToEmit = 25;
            [self addChild:enemyBomEmitter];
            [enemyNode removeFromParent];
            [enemys removeObject:enemyNode];
            killEnemyNum++;
            scoreNode.text = [NSString stringWithFormat:@"击杀敌人数:%f",killEnemyNum];
        }
    }
    
    if (contact.bodyA.categoryBitMask == SKPhysicsBodyEnemy && contact.bodyB.categoryBitMask != SKPhysicsBodyUser) {
        [self BulletContactEnemy:(UserBulletSpriteNode *)contact.bodyB.node enemy:(EnemySpriteNode *)contact.bodyA.node];
    }else if (contact.bodyB.categoryBitMask == SKPhysicsBodyEnemy && contact.bodyA.categoryBitMask != SKPhysicsBodyUser) {
        [self BulletContactEnemy:(UserBulletSpriteNode *)contact.bodyA.node enemy:(EnemySpriteNode *)contact.bodyB.node];
    }
    if (contact.bodyA.categoryBitMask == SKPhysicsBodyUser) {
        if (contact.bodyB.categoryBitMask == SKPhysicsBodyHighLight) {
            HighLightBulletNode *highLightNode = (HighLightBulletNode *)contact.bodyB.node;
            userNode.currentBulletType = highLightNode.bulletType;
            [highLightNode removeFromParent];
        }else{
            SKEmitterNode *userBomEmitter = [NSKeyedUnarchiver unarchiveObjectWithFile:[[NSBundle mainBundle] pathForResource:@"userBoom" ofType:@"sks"]];
            userBomEmitter.position = contact.bodyA.node.position;
            userBomEmitter.numParticlesToEmit = 25;
            [self addChild:userBomEmitter];
            [contact.bodyA.node removeFromParent];
            [contact.bodyB.node removeFromParent];
            isFir = NO;
            [self removeAllChildren];
            [self removeFromParent];
            [self.view presentScene:self];
        }
    }else if (contact.bodyB.categoryBitMask == SKPhysicsBodyUser) {
        if (contact.bodyA.categoryBitMask == SKPhysicsBodyHighLight) {
            HighLightBulletNode *highLightNode = (HighLightBulletNode *)contact.bodyA.node;
            userNode.currentBulletType = highLightNode.bulletType;
            [highLightNode removeFromParent];
        }else{
            SKEmitterNode *userBomEmitter = [NSKeyedUnarchiver unarchiveObjectWithFile:[[NSBundle mainBundle] pathForResource:@"userBoom" ofType:@"sks"]];
            userBomEmitter.position = contact.bodyB.node.position;
            userBomEmitter.numParticlesToEmit = 25;
            [self addChild:userBomEmitter];
            [contact.bodyB.node removeFromParent];
            [contact.bodyA.node removeFromParent];
            isFir = NO;
            [self removeAllChildren];
            [self removeFromParent];
            [self.view presentScene:self];
        }
    }
}

- (void)BulletContactEnemy:(UserBulletSpriteNode *)bulletNode enemy:(EnemySpriteNode *)enemyNode {
    SKEmitterNode *enemyBomEmitter = [NSKeyedUnarchiver unarchiveObjectWithFile:[[NSBundle mainBundle] pathForResource:@"enemyBoom" ofType:@"sks"]];
    if (bulletNode.bulletType == SKBulletTypeMini || bulletNode.bulletType == SKBulletTypeTracking) {
        [bulletNode removeFromParent];
        [bullets removeObject:bulletNode];
    }
    enemyNode.nodeHp -= bulletNode.nodePower;
    if (enemyNode.nodeHp <= 0) {
        enemyBomEmitter.position = enemyNode.position;
        enemyBomEmitter.numParticlesToEmit = 25;
        [self addChild:enemyBomEmitter];
        if (enemyNode.isHighLightEnemy) {
            int randamIndex = rand() % 3;
            SKColor *nodeColor;
            SKBulletType bulletType;
            if (randamIndex == 0) {
                nodeColor = [SKColor yellowColor];
                bulletType = SKBulletTypeMini;
            }else if (randamIndex == 1) {
                nodeColor = [SKColor greenColor];
                bulletType = SKBulletTypeTracking;
            }else {
                nodeColor = [SKColor redColor];
                bulletType = SKBulletTypeMissile;
            }
            HighLightBulletNode *node = [HighLightBulletNode spriteNodeWithColor:nodeColor size:CGSizeMake(20, 20)];
            node.position = enemyNode.position;
            node.bulletType = bulletType;
            [self addChild:node];
            SKAction *action =[SKAction repeatActionForever:[SKAction rotateByAngle:M_PI_4 duration:1]];
            [node runAction:action];
            
        }
        [enemyNode removeFromParent];
        [enemys removeObject:enemyNode];
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [enemyBomEmitter removeFromParent];
        });
        killEnemyNum++;
        scoreNode.text = [NSString stringWithFormat:@"击杀敌人数:%f",killEnemyNum];
    }
}

- (void)didEndContact:(SKPhysicsContact *)contact {
    
}

- (float)nodeMoveRotate:(CGPoint)nodePoint movePoint:(CGPoint)movePoint {
    const float dx = movePoint.x - nodePoint.x;
    const float dy = movePoint.y - nodePoint.y;
    if (dx > 0 && dy > 0) {
        return atan(dy/dx);
    }else if (dx < 0 && dy > 0){//第二象限
        return atan(dx/(-dy)) + M_PI * 0.5;
    }else if (dx < 0 && dy < 0){//第三象限
        return atan(dy/dx) + M_PI;
    }else {//第四象限
        return M_PI * 2 - atan((-dy)/dx);
    }
}

#pragma mark --生成子弹--

- (void)generateBulletMini:(int)bulletNum {
    if (bulletNum == 1) {
        [self createMiniNode:CGFLOAT_MAX cycle:0 endPont:0];
    }else if (bulletNum == 2) {
        [self generateBulletMini:1];
        for (int i = 0; i < 2; i++) {
            [self createMiniNode:2 cycle:i endPont:0];
        }
    }else if (bulletNum == 3) {
        [self generateBulletMini:2];
        for (int i = 0; i < 2; i++) {
            [self createMiniNode:1 cycle:i endPont:0];
        }
    }else if (bulletNum == 4) {
        [self generateBulletMini:3];
        for (int i = 0; i < 2; i++) {
            [self createMiniNode:2.0/3.0 cycle:i endPont:0];
        }
    }else{
        [self generateBulletMini:4];
        for (int i = 0; i < 2; i++) {
            float endPoint = userNode.position.x - (1 - 2 * i) * userNode.size.width * 2;
            [self createMiniNode:0.5 cycle:i endPont:endPoint];
        }
    }
}

- (void)createMiniNode:(float)denominator cycle:(int)cycle endPont:(float)endPointX {
    UserBulletSpriteNode *bulletNode = [UserBulletSpriteNode spriteNodeWithTexture:[SKTexture textureWithImageNamed:@"spark"] size:CGSizeMake(15, 15)];
    bulletNode.position = userNode.position;
    bulletNode.bulletType = userNode.currentBulletType;
    [self addChild:bulletNode];
    [bullets addObject:bulletNode];
    CGPoint endPoint1 = CGPointZero;
    if (endPointX == 0) {
        endPoint1 = CGPointMake(userNode.position.x - (1 - 2 * cycle) * userNode.size.width/denominator, userNode.position.y + userNode.size.height/2);
    }else{
        endPoint1 = CGPointMake(endPointX, userNode.position.y);
    }
    NSTimeInterval moveTimeOne = [self onePointMoveToOtherPointTime:endPoint1 otherPoint:bulletNode.position speed:bulletNode.nodeSpeed];
    SKAction *firstAction = [SKAction moveTo:endPoint1 duration:moveTimeOne];
    firstAction.speed = bulletNode.nodeSpeed;
    CGPoint endPoint2 = CGPointMake(endPoint1.x, SCREEN_HEIGHT + 10);
    NSTimeInterval moveTimeTwo = [self onePointMoveToOtherPointTime:endPoint2 otherPoint:endPoint1 speed:bulletNode.nodeSpeed];
    SKAction *secendAction = [SKAction moveTo:endPoint2 duration:moveTimeTwo];
    secendAction.speed = bulletNode.nodeSpeed;
    [bulletNode runAction:[SKAction sequence:@[firstAction,secendAction]] completion:^{
        [bulletNode removeFromParent];
    }];
}

- (void)generateBulletTracking:(int)bulletNum {
    if (bulletNum == 1) {
        UserBulletSpriteNode *userBullet = [UserBulletSpriteNode spriteNodeWithTexture:[SKTexture textureWithImageNamed:@"弧1"] size:CGSizeMake(40, 40)];
        userBullet.position = userNode.position;
        userBullet.bulletType = userNode.currentBulletType;
        userBullet.isFollowingEnemy = NO;
        [self addChild:userBullet];
        [bullets addObject:userBullet];
        CGPoint bulletMovePoint;
        bulletMovePoint = CGPointMake(userBullet.position.x, SCREEN_HEIGHT + 10);
        NSTimeInterval time = (SCREEN_HEIGHT + 10 - userBullet.position.y)/userBullet.nodeSpeed;
        SKAction *userBulletAction = [SKAction moveTo:bulletMovePoint duration:time];
        userBulletAction.speed = userBullet.nodeSpeed;
        [userBullet runAction:userBulletAction completion:^{
            if (userBullet.position.x >= SCREEN_WIDTH || userBullet.position.x <= 0 || userBullet.position.y >= SCREEN_HEIGHT || userBullet.position.y <= 0) {
                NSLog(@"自然消失");
                [userBullet removeFromParent];
                [self->bullets removeObject:userBullet];
            }
        }];
        userBullet.currentActions = userBulletAction;
    } else if (bulletNum == 2) {
        [self generateBulletTracking:1];
        for (int i = 0; i < 2; i++) {
            UserBulletSpriteNode *userBullet = [UserBulletSpriteNode spriteNodeWithTexture:[SKTexture textureWithImageNamed:@"弧1"] size:CGSizeMake(40, 40)];
            float rotation = (1 - 2 * i) * M_PI_4;
            userBullet.position = userNode.position;
            userBullet.zRotation = rotation;
            userBullet.bulletType = userNode.currentBulletType;
            userBullet.isFollowingEnemy = NO;
            [self addChild:userBullet];
            [bullets addObject:userBullet];
            CGPoint bulletMovePoint;
            if (i == 0){
                bulletMovePoint = CGPointMake(0, userBullet.position.x + userBullet.position.y);
            }else {
                bulletMovePoint = CGPointMake(SCREEN_WIDTH, SCREEN_WIDTH - userBullet.position.x + userBullet.position.y);
            }
            NSTimeInterval time = sqrt(pow((bulletMovePoint.x - userBullet.position.x), 2) + pow(bulletMovePoint.y - userBullet.position.y, 2))/userBullet.nodeSpeed;
            SKAction *userBulletAction = [SKAction moveTo:bulletMovePoint duration:time];
            userBulletAction.speed = userBullet.nodeSpeed;
            [userBullet runAction:userBulletAction completion:^{
                if (userBullet.position.x >= SCREEN_WIDTH || userBullet.position.x <= 0 || userBullet.position.y >= SCREEN_HEIGHT || userBullet.position.y <= 0) {
                     NSLog(@"自然消失");
                    [userBullet removeFromParent];
                    [self->bullets removeObject:userBullet];
                }
            }];
            userBullet.currentActions = userBulletAction;
        }
    }else if (bulletNum == 3) {
        [self generateBulletTracking:2];
        for (int i = 0; i < 2; i++) {
            UserBulletSpriteNode *userBullet = [UserBulletSpriteNode spriteNodeWithTexture:[SKTexture textureWithImageNamed:@"弧1"] size:CGSizeMake(40, 40)];
            float rotation = (1 - 2 * i) * M_PI_2;
            userBullet.position = userNode.position;
            userBullet.zRotation = rotation;
            userBullet.bulletType = userNode.currentBulletType;
            userBullet.isFollowingEnemy = NO;
            [self addChild:userBullet];
            [bullets addObject:userBullet];
            CGPoint bulletMovePoint;
            if (i == 0) {
                bulletMovePoint = CGPointMake(0, userBullet.position.y);
            }else {
                bulletMovePoint = CGPointMake(SCREEN_WIDTH, userBullet.position.y);
            }
            NSTimeInterval time = sqrt(pow((bulletMovePoint.x - userBullet.position.x), 2) + pow(bulletMovePoint.y - userBullet.position.y, 2))/userBullet.nodeSpeed;
            SKAction *userBulletAction = [SKAction moveTo:bulletMovePoint duration:time];
            userBulletAction.speed = userBullet.nodeSpeed;
            [userBullet runAction:userBulletAction completion:^{
                if (userBullet.position.x >= SCREEN_WIDTH || userBullet.position.x <= 0 || userBullet.position.y >= SCREEN_HEIGHT || userBullet.position.y <= 0) {
                     NSLog(@"自然消失");
                    [userBullet removeFromParent];
                    [self->bullets removeObject:userBullet];
                }
            }];
            userBullet.currentActions = userBulletAction;
        }
    }else if (bulletNum == 4) {
        [self generateBulletTracking:3];
        for (int i = 2; i < 4; i++) {
            UserBulletSpriteNode *userBullet = [UserBulletSpriteNode spriteNodeWithTexture:[SKTexture textureWithImageNamed:@"弧1"] size:CGSizeMake(40, 40)];
            float rotation = (1 - 2 * i) * M_PI_4;
            userBullet.position = userNode.position;
            userBullet.zRotation = rotation;
            userBullet.bulletType = userNode.currentBulletType;
            userBullet.isFollowingEnemy = NO;
            [self addChild:userBullet];
            [bullets addObject:userBullet];
            CGPoint bulletMovePoint;
            if (i == 3) {
                bulletMovePoint = CGPointMake(0, userBullet.position.y - userBullet.position.x);
            }else {
                bulletMovePoint = CGPointMake(SCREEN_WIDTH, userBullet.position.y - SCREEN_WIDTH + userBullet.position.x);
            }
            NSTimeInterval time = sqrt(pow((bulletMovePoint.x - userBullet.position.x), 2) + pow(bulletMovePoint.y - userBullet.position.y, 2))/userBullet.nodeSpeed;
            SKAction *userBulletAction = [SKAction moveTo:bulletMovePoint duration:time];
            userBulletAction.speed = userBullet.nodeSpeed;
            [userBullet runAction:userBulletAction completion:^{
                if (userBullet.position.x >= SCREEN_WIDTH || userBullet.position.x <= 0 || userBullet.position.y >= SCREEN_HEIGHT || userBullet.position.y <= 0) {
                     NSLog(@"自然消失");
                    [userBullet removeFromParent];
                    [self->bullets removeObject:userBullet];
                }
            }];
            userBullet.currentActions = userBulletAction;
        }
    }else if (bulletNum >= 5) {
        [self generateBulletTracking:4];
        UserBulletSpriteNode *userBullet = [UserBulletSpriteNode spriteNodeWithTexture:[SKTexture textureWithImageNamed:@"弧1"] size:CGSizeMake(40, 40)];
        userBullet.position = userNode.position;
        userBullet.zRotation = M_PI;
        userBullet.bulletType = userNode.currentBulletType;
        userBullet.isFollowingEnemy = NO;
        [self addChild:userBullet];
        [bullets addObject:userBullet];
        CGPoint bulletMovePoint;
        bulletMovePoint = CGPointMake(userBullet.position.x, -10);
        NSTimeInterval time = (userBullet.position.y + 10)/userBullet.nodeSpeed;
        SKAction *userBulletAction = [SKAction moveTo:bulletMovePoint duration:time];
        userBulletAction.speed = userBullet.nodeSpeed;
        [userBullet runAction:userBulletAction completion:^{
            if (userBullet.position.x >= SCREEN_WIDTH || userBullet.position.x <= 0 || userBullet.position.y >= SCREEN_HEIGHT || userBullet.position.y <= 0) {
                 NSLog(@"自然消失");
                [userBullet removeFromParent];
                [self->bullets removeObject:userBullet];
            }
        }];
        userBullet.currentActions = userBulletAction;
    }
}

- (void)generateBulletLaser {
    
}

- (void)generateBulletMissile:(int)bulletNum {
    if (bulletNum == 1) {
        UserBulletSpriteNode *bulletNode = [UserBulletSpriteNode spriteNodeWithTexture:[SKTexture textureWithImageNamed:@"火箭"] size:CGSizeMake(20, 40)];
        bulletNode.position = userNode.position;
        bulletNode.bulletType = userNode.currentBulletType;
        [self addChild:bulletNode];
        SKEmitterNode *enemyEmitter = [NSKeyedUnarchiver unarchiveObjectWithFile:[[NSBundle mainBundle] pathForResource:@"missleParticle" ofType:@"sks"]];
        enemyEmitter.position = CGPointMake(0, - bulletNode.size.height/2);
        [bulletNode addChild:enemyEmitter];
        [bullets addObject:bulletNode];
        CGPoint endPoint = CGPointMake(bulletNode.position.x, SCREEN_HEIGHT + 10);
        SKAction *action = [SKAction moveTo:endPoint duration:(SCREEN_HEIGHT + 10 - bulletNode.position.y)/bulletNode.nodeSpeed];
        action.speed = bulletNode.nodeSpeed;
        action.timingMode = SKActionTimingEaseIn;
        [bulletNode runAction:action completion:^{
            [bulletNode removeAllChildren];
            [bulletNode removeFromParent];
            [self->bullets removeObject:bulletNode];
        }];
    }else if (bulletNum == 2) {
        [self generateBulletMissile:1];
        for (int i = 0; i < 2; i++) {
            [self createBulletMissile:40 cycle:i];
        }
    }else if (bulletNum == 3) {
        [self generateBulletMissile:2];
        for (int i = 0; i < 2; i++) {
            [self createBulletMissile:80 cycle:i];
        }
    }else if (bulletNum == 4) {
        [self generateBulletMissile:3];
        for (int i = 0; i < 2; i++) {
            [self createBulletMissile:120 cycle:i];
        }
    }else if (bulletNum >= 5) {
        [self generateBulletMissile:4];
        for (int i = 0; i < 2; i++) {
            [self createBulletMissile:160 cycle:i];
        }
    }
}

- (void)createBulletMissile:(float)denominator cycle:(int)cycle {
    UserBulletSpriteNode *bulletNode = [UserBulletSpriteNode spriteNodeWithTexture:[SKTexture textureWithImageNamed:@"火箭"] size:CGSizeMake(20, 40)];
    bulletNode.position = userNode.position;
    bulletNode.bulletType = userNode.currentBulletType;
    [self addChild:bulletNode];
    SKEmitterNode *enemyEmitter = [NSKeyedUnarchiver unarchiveObjectWithFile:[[NSBundle mainBundle] pathForResource:@"missleParticle" ofType:@"sks"]];
    enemyEmitter.position = CGPointMake(0, -bulletNode.size.height/2);
    [bulletNode addChild:enemyEmitter];
    [bullets addObject:bulletNode];
    CGPoint endPoint1 = CGPointMake(bulletNode.position.x + (1 - 2 * cycle) * denominator, bulletNode.position.y);
    SKAction *oneAction = [SKAction moveTo:endPoint1 duration:1];
    CGPoint endPoint2 = CGPointMake(endPoint1.x, SCREEN_HEIGHT + 10);
    SKAction *action = [SKAction moveTo:endPoint2 duration:(SCREEN_HEIGHT + 10 - bulletNode.position.y)/bulletNode.nodeSpeed];
    action.speed = bulletNode.nodeSpeed;
    action.timingMode = SKActionTimingEaseIn;
    [bulletNode runAction:[SKAction sequence:@[oneAction,action]] completion:^{
        [bulletNode removeAllChildren];
        [bulletNode removeFromParent];
        [self->bullets removeObject:bulletNode];
    }];
}

- (void)generateBulletFlower {
    FlowerBulletNode *flowerNode = [FlowerBulletNode spriteNodeWithTexture:[SKTexture textureWithImageNamed:@"spark"] size:CGSizeMake(15, 15)];
    flowerNode.position = userNode.position;
    flowerNode.bulletType = SKBulletTypeFlower;
    [self addChild:flowerNode];
    CGPoint endPoint = flowerBomPoint;
    SKAction *action = [SKAction moveTo:endPoint duration:fabs(endPoint.y - flowerNode.position.y)/flowerNode.nodeSpeed];
    action.speed = flowerNode.nodeSpeed;
    action.timingMode = SKActionTimingEaseInEaseOut;
    [flowerNode runAction:action completion:^{
        [flowerNode removeFromParent];
    }];
}

- (NSTimeInterval)onePointMoveToOtherPointTime:(CGPoint)pointOne otherPoint:(CGPoint)otherPoint speed:(float)speed {
    return sqrt(pow(pointOne.x - otherPoint.x, 2) + pow(pointOne.y - otherPoint.y, 2))/speed;
}

@end
