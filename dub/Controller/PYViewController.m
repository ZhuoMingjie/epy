//
//  PYViewController.m
//  epy
//
//  Created by apple on 2017/5/24.
//  Copyright © 2017年 apple. All rights reserved.
//

#import "PYViewController.h"
#import <AVFoundation/AVFoundation.h>
#import <AVKit/AVKit.h>
#import <MobileCoreServices/MobileCoreServices.h>

@interface PYViewController ()<AVAudioPlayerDelegate>

@property(nonatomic,retain) AVAudioPlayer *bjPlayer;
@property(nonatomic,retain) AVAudioPlayer *pyPlayer;
@property(nonatomic,retain) AVPlayerViewController *spPlayer;

@end

@implementation PYViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (AVAudioPlayer *)bjPlayer {
    if (_bjPlayer == nil) {
        NSString *path = [[NSBundle mainBundle] pathForResource:@"demo001_bj" ofType:@"mp3"];
        _bjPlayer = [[AVAudioPlayer alloc] initWithContentsOfURL:[NSURL fileURLWithPath:path] error:nil];
        _bjPlayer.delegate = self;
        [_bjPlayer prepareToPlay];
    }
    return _bjPlayer;
}
- (AVAudioPlayer *)pyPlayer {
    if (_pyPlayer == nil) {
        NSString *path = [[NSBundle mainBundle] pathForResource:@"demo001_py" ofType:@"mp3"];
        _pyPlayer = [[AVAudioPlayer alloc] initWithContentsOfURL:[NSURL fileURLWithPath:path] error:nil];
        _pyPlayer.delegate = self;
        [_pyPlayer prepareToPlay];
    }
    return _pyPlayer;
}

- (AVPlayerViewController *)spPlayer {
    if (_spPlayer == nil) {
        NSString *path = [[NSBundle mainBundle] pathForResource:@"demo001_sp" ofType:@"mp4"];
        _spPlayer = [[AVPlayerViewController alloc] init];
        _spPlayer.player = [[AVPlayer alloc] initWithURL:[NSURL fileURLWithPath:path]];
        _spPlayer.view.frame = CGRectMake(0, 0, 400, 300);
        [self.view addSubview:_spPlayer.view];
    }
    return _spPlayer;
}

- (IBAction)playSP:(id)sender {
    UIButton *btn = sender;
    if (btn.isSelected) {
        [self.spPlayer.player play];
    }else{
        [self.spPlayer.player pause];
    }
}
- (IBAction)playPY:(id)sender {
    UIButton *btn = sender;
    btn.selected = !btn.selected;
    if (btn.selected) {
        self.spPlayer.player.volume = 0;
        [self.pyPlayer play];
    }else{
        self.spPlayer.player.volume = 0.5;
        [self.pyPlayer pause];
    }
}
- (IBAction)playBJ:(id)sender {
    UIButton *btn = sender;
    btn.selected = !btn.selected;
    if (btn.selected) {
        [self.bjPlayer play];
    }else{
        [self.bjPlayer pause];
    }
}

- (void)audioPlayerDidFinishPlaying:(AVAudioPlayer *)player successfully:(BOOL)flag {
    [player play];
}

@end
