//
//  GameViewController.m
//  spritekitDemo
//
//  Created by wr on 2019/3/6.
//  Copyright © 2019年 wanmengchao. All rights reserved.
//

#import "GameViewController.h"
#import "firstScene.h"

@implementation GameViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    // Load 'GameScene.sks' as a GKScene. This provides gameplay related content
    // including entities and graphs.
    firstScene *scene = [firstScene sceneWithSize:self.view.bounds.size];
    scene.scaleMode = SKSceneScaleModeAspectFit;
    SKView *view = (SKView *)self.view;
    view.showsFPS = YES;
    view.showsNodeCount = YES;
    view.ignoresSiblingOrder = YES;
    [view presentScene:scene];
    
}

- (BOOL)shouldAutorotate {
    return YES;
}

- (UIInterfaceOrientationMask)supportedInterfaceOrientations {
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
        return UIInterfaceOrientationMaskAllButUpsideDown;
    } else {
        return UIInterfaceOrientationMaskAll;
    }
}

- (BOOL)prefersStatusBarHidden {
    return YES;
}

@end
