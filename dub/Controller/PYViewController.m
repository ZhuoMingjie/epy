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

#import "lame.h"

#define mp3FileName           @"new.mp3"
#define mp3hcFileName           @"new_hc.mp3"
#define synthesisFileName     @"synthesis.mp3"
#define KFILESIZE (1 * 1024 * 1024)

@interface PYViewController ()<AVAudioPlayerDelegate,AVAudioRecorderDelegate>

@property(nonatomic,retain) AVAudioPlayer *bjPlayer;
@property(nonatomic,retain) AVAudioPlayer *pyPlayer;
@property(nonatomic,retain) AVPlayerViewController *spPlayer;


@property(nonatomic,retain) AVAudioPlayer *hcPlayer;

@property(nonatomic,retain) AVAudioRecorder *recorder;

@property(nonatomic,strong)NSString *filePath;
/**录音的设置**/
@property(nonatomic, strong) NSMutableDictionary *setting;

/**真机时使用**/
@property(nonatomic, strong) AVAudioSession *session;


@property (nonatomic ,strong)  id playTimeObserver;
@property (nonatomic, strong) AVPlayerItem *playerItem;

@property (nonatomic,copy) NSString *mp3FilePath;
@end

@implementation PYViewController

- (void)viewDidLoad {
    [super viewDidLoad];
//    [self playerItem];
//    [self spPlayer];

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
//        NSString *path = [[NSBundle mainBundle] pathForResource:@"demo001_py" ofType:@"mp3"];

        NSString *filePath = [self.filePath stringByAppendingPathComponent:@"new.mp3"];
        NSFileManager *manager = [NSFileManager defaultManager];
        
        if ([manager fileExistsAtPath:filePath]) {
            
            _pyPlayer = [[AVAudioPlayer alloc] initWithContentsOfURL:[NSURL fileURLWithPath:filePath] error:nil];
            _pyPlayer.delegate = self;
            [_pyPlayer prepareToPlay];
            
        }else{
        }
//        NSString *path = [NSHomeDirectory() stringByAppendingPathComponent:@"Documents/record"];

    }
    return _pyPlayer;
}

- (AVPlayerItem *)playerItem {
    if (_playerItem == nil) {
        NSString *path = [[NSBundle mainBundle] pathForResource:@"demo001_sp" ofType:@"mp4"];
        _playerItem = [[AVPlayerItem alloc] initWithURL:[NSURL fileURLWithPath:path]];
    }
    return _playerItem;
}

- (AVPlayerViewController *)spPlayer {
    if (_spPlayer == nil) {
//        NSString *path = [[NSBundle mainBundle] pathForResource:@"demo001_sp" ofType:@"mp4"];
        _spPlayer = [[AVPlayerViewController alloc] init];
        _spPlayer.player = [[AVPlayer alloc] initWithPlayerItem:self.playerItem];
        _spPlayer.view.frame = CGRectMake(0, 0, 400, 300);
        [self.view addSubview:_spPlayer.view];
    }
    return _spPlayer;
}

- (AVAudioRecorder *)recorder {
    if (_recorder == nil) {
//        NSFileManager *fileManager = [NSFileManager defaultManager];
//        NSString *documentDirectory = [NSHomeDirectory() stringByAppendingPathComponent:@"Documents"];
//        [fileManager createDirectoryAtPath:[documentDirectory stringByAppendingPathComponent:@"record"] withIntermediateDirectories:YES attributes:nil error:nil];
//        NSString *path = [documentDirectory stringByAppendingPathComponent:@"record/001"];
//        NSString *path = [NSHomeDirectory() stringByAppendingPathComponent:@"Documents/record"];

        NSFileManager *manager = [NSFileManager defaultManager];
        
        if (![manager fileExistsAtPath:self.filePath]) {
            [manager createDirectoryAtPath:self.filePath
               withIntermediateDirectories:YES
                                attributes:nil
                                     error:nil];
        }
        NSString *filePath = [self.filePath stringByAppendingPathComponent:@"test"];


        _recorder = [[AVAudioRecorder alloc] initWithURL:[NSURL fileURLWithPath:filePath] settings:self.setting error:nil];
        _recorder.delegate = self;
        //真机使用
        [self.session setActive:YES error:nil];
        
        [_recorder prepareToRecord];
    }
    return _recorder;
}

- (IBAction)playSP:(id)sender {
    UIButton *btn = sender;
    if (btn.isSelected) {
        [self.spPlayer.player play];
    }else{
        [self.spPlayer.player pause];
    }
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        [self monitoringPlayback:_playerItem];
    });
}
- (IBAction)playPY:(id)sender {
    UIButton *btn = sender;
    btn.selected = !btn.selected;
    if (btn.selected) {
//        self.spPlayer.player.volume = 0;
        [self.pyPlayer play];
    }else{
//        self.spPlayer.player.volume = 0.5;
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

- (IBAction)record:(id)sender {
    UIButton *btn = sender;
    btn.selected = !btn.selected;
    if (btn.selected) {
        [self.recorder record];
    }else{
        [self.recorder stop];
    }
}


- (void)audioPlayerDidFinishPlaying:(AVAudioPlayer *)player successfully:(BOOL)flag {
    [player play];
}




-(NSString *)filePath{
    if (!_filePath) {
        _filePath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject];
        _filePath = [_filePath stringByAppendingPathComponent:@"record"];
    }
    
    return _filePath;
}


//- (NSMutableDictionary *)setting {
//    if (!_setting) {
//        _setting = [NSMutableDictionary dictionary];
//        [_setting setObject:[NSNumber numberWithInteger:44100] forKey:AVSampleRateKey];
//        [_setting setObject:[NSNumber numberWithInteger:kAudioFormatMPEGLayer3] forKey:AVFormatIDKey];
//        [_setting setObject:[NSNumber numberWithInteger:1] forKey:AVNumberOfChannelsKey];
//        [_setting setObject:[NSNumber numberWithInteger:AVAudioQualityHigh] forKey:AVEncoderAudioQualityKey];
//    }
//    
//    return _setting;
//}

- (NSMutableDictionary *)setting {
    if (!_setting) {
        _setting = [NSMutableDictionary dictionary];
        //录音格式 无法使用
        [_setting setValue:[NSNumber numberWithInt:kAudioFormatLinearPCM]
                    forKey:AVFormatIDKey];
        //采样率
        [_setting setValue:[NSNumber numberWithFloat:44100.0]
                    forKey:AVSampleRateKey]; // 44100.0 11025.0
        //通道数
        [_setting setValue:[NSNumber numberWithInt:2] forKey:AVNumberOfChannelsKey];
        //线性采样位数
        //[recordSettings setValue :[NSNumber numberWithInt:16] forKey:
        //AVLinearPCMBitDepthKey];
        //音频质量,采样质量
        [_setting setValue:[NSNumber numberWithInt:AVAudioQualityMin]
                    forKey:AVEncoderAudioQualityKey];
    }
    
    return _setting;
}

- (AVAudioSession *)session {
    if (!_session) {
        _session = [AVAudioSession sharedInstance];
        NSError *sessionError;
        [_session setCategory:AVAudioSessionCategoryPlayAndRecord
                        error:&sessionError];
    }
    
    return _session;
}

//录音完毕的回调
- (void)audioRecorderDidFinishRecording:(AVAudioRecorder *)recorder successfully:(BOOL)flag{
    //转换MP3
    NSString *souceFilePath = [recorder.url absoluteString];
    souceFilePath = [souceFilePath substringFromIndex:7];
    
    NSString *newFilePath = [self.filePath stringByAppendingPathComponent:mp3FileName];

    //开启子线程转换文件
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        
        //转换格式
        [self audio_PCMtoMP3:souceFilePath andDesPath:newFilePath];
        
        //删除录音文件
//        [recorder deleteRecording];
    });
}


#pragma mark 转换MP3

- (void)audio_PCMtoMP3:(NSString *)soucePath andDesPath:(NSString *)desPath {
    NSLog(@"开始转换");
    
    @try {
        int read, write;
        
        FILE *pcm = fopen([soucePath cStringUsingEncoding:1],
                          "rb"); // source 被转换的音频文件位置
        fseek(pcm, 4 * 1024, SEEK_CUR); // skip file header
        FILE *mp3 = fopen([desPath cStringUsingEncoding:1],
                          "wb"); // output 输出生成的Mp3文件位置
        
        const int PCM_SIZE = 8192;
        const int MP3_SIZE = 8192;
        short int pcm_buffer[PCM_SIZE * 2];
        unsigned char mp3_buffer[MP3_SIZE];
        
        lame_t lame = lame_init();
        lame_set_in_samplerate(lame, 44100.0);
        lame_set_VBR(lame, vbr_default);
        lame_init_params(lame);
        
        do {
            read = fread(pcm_buffer, 2 * sizeof(short int), PCM_SIZE, pcm);
            if (read == 0)
                write = lame_encode_flush(lame, mp3_buffer, MP3_SIZE);
            else
                write = lame_encode_buffer_interleaved(lame, pcm_buffer, read,
                                                       mp3_buffer, MP3_SIZE);
            
            fwrite(mp3_buffer, write, 1, mp3);
            
        } while (read != 0);
        
        lame_close(lame);
        fclose(mp3);
        fclose(pcm);
    } @catch (NSException *exception) {
        NSLog(@"%@", [exception description]);
    } @finally {
        NSLog(@"MP3生成成功");
    }
}

- (void)cafToMp3:(NSString*)cafFileName
{
    NSArray *dirPaths;
    NSString *docsDir;
    
    dirPaths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    docsDir = [dirPaths objectAtIndex:0];
    _mp3FilePath = [docsDir stringByAppendingPathComponent:@"m4atomp3_5.mp3"];
    
    @try {
        int read, write;
        FILE *pcm = fopen([cafFileName cStringUsingEncoding:1], "rb");
        FILE *mp3 = fopen([_mp3FilePath cStringUsingEncoding:1], "wb");
        const int PCM_SIZE = 8192;
        const int MP3_SIZE = 8192;
        short int pcm_buffer[PCM_SIZE*2];
        unsigned char mp3_buffer[MP3_SIZE];
        
        lame_t lame = lame_init();
        lame_set_in_samplerate(lame, 44100);
        lame_set_VBR(lame, vbr_default);
        lame_init_params(lame);
        
        do {
            read = fread(pcm_buffer, 2*sizeof(short int), PCM_SIZE, pcm);
            if (read == 0)
                write = lame_encode_flush(lame, mp3_buffer, MP3_SIZE);
            else
                write = lame_encode_buffer_interleaved(lame, pcm_buffer, read, mp3_buffer, MP3_SIZE);
            
            fwrite(mp3_buffer, write, 1, mp3);
            
        } while (read != 0);
        
        lame_close(lame);
        fclose(mp3);
        fclose(pcm);
    }
    @catch (NSException *exception) {
        NSLog(@"%@",[exception description]);
    }
    @finally {
        //Detrming the size of mp3 file
        NSFileManager *fileManger = [NSFileManager defaultManager];
        NSData *data = [fileManger contentsAtPath:_mp3FilePath];
        NSString* str = [NSString stringWithFormat:@"%d K",[data length]/1024];
        NSLog(@"size of mp3=%@",str);
        
    }
}

#pragma mark--视频处理
// 观察播放进度
- (void)monitoringPlayback:(AVPlayerItem *)item {
    __weak typeof(self)WeakSelf = self;
    
    // 播放进度, 每秒执行30次， CMTime 为30分之一秒
    _playTimeObserver = [self.spPlayer.player addPeriodicTimeObserverForInterval:CMTimeMake(1, 30.0) queue:dispatch_get_main_queue() usingBlock:^(CMTime time) {
        float currentPlayTime = (double)item.currentTime.value/ item.currentTime.timescale;
        NSLog(@"当前播放时间:%.1f",currentPlayTime);
        [WeakSelf handlePlayerTime:currentPlayTime];
    }];
}

- (void)handlePlayerTime:(CGFloat)playTime {
    if (playTime > 10) {
//        self.playerItem.currentTime.value/self.playerItem.currentTime.timescale+10
        [self.playerItem seekToTime:CMTimeMakeWithSeconds(5, self.playerItem.currentTime.timescale) toleranceBefore:CMTimeMake(1, self.playerItem.currentTime.timescale) toleranceAfter:CMTimeMake(1, self.playerItem.currentTime.timescale)];
    }
}

- (IBAction)compareAudio:(id)sender {
//    [self compareAudioTest];
    [self zhuanhuan];
}

- (void)zhuanhuan {
    NSString *auidoPath1 = [[NSBundle mainBundle] pathForResource:@"test" ofType:@""];
    [self cafToMp3:auidoPath1];
}

- (void)compareAudioTest {
    NSString *auidoPath1 = [[NSBundle mainBundle] pathForResource:@"hc001" ofType:@"mp3"];

    NSString *audioPath2 = [[NSBundle mainBundle] pathForResource:@"hc002" ofType:@"mp3"];

    AVURLAsset *audioAsset1 = [AVURLAsset assetWithURL:[NSURL fileURLWithPath:auidoPath1]];
    AVURLAsset *audioAsset2 = [AVURLAsset assetWithURL:[NSURL fileURLWithPath:audioPath2]];
    
    AVMutableComposition *composition = [AVMutableComposition composition];
    
    // 音频轨道
    AVMutableCompositionTrack *audioTrack1 = [composition addMutableTrackWithMediaType:AVMediaTypeAudio preferredTrackID:0];
    AVMutableCompositionTrack *audioTrack2 = [composition addMutableTrackWithMediaType:AVMediaTypeAudio preferredTrackID:0];
    
    // 音频素材轨道
    AVAssetTrack *audioAssetTrack1 = [[audioAsset1 tracksWithMediaType:AVMediaTypeAudio] firstObject];
    AVAssetTrack *audioAssetTrack2 = [[audioAsset2 tracksWithMediaType:AVMediaTypeAudio] firstObject];
    
    // 音频合并 - 插入音轨文件
    [audioTrack1 insertTimeRange:CMTimeRangeMake(kCMTimeZero, CMTimeAdd(audioAsset1.duration, audioAsset2.duration)) ofTrack:audioAssetTrack1 atTime:kCMTimeZero error:nil];
    [audioTrack2 insertTimeRange:CMTimeRangeMake(kCMTimeZero, CMTimeAdd(audioAsset1.duration, audioAsset2.duration)) ofTrack:audioAssetTrack2 atTime:audioAsset1.duration error:nil];
 
    
    // 合并后的文件导出 - 音频文件目前只找到合成m4a类型的
    AVAssetExportSession *session = [[AVAssetExportSession alloc] initWithAsset:composition presetName:AVAssetExportPresetAppleM4A];
    NSString *outPutFilePath = [[self.filePath stringByDeletingLastPathComponent] stringByAppendingPathComponent:@"008.m4a"];
    session.outputURL = [NSURL fileURLWithPath:outPutFilePath];
    session.outputFileType = AVFileTypeAppleM4A;
    [session exportAsynchronouslyWithCompletionHandler:^{

//        NSString *newFilePath = [self.filePath stringByAppendingPathComponent:mp3hcFileName];
//        
//        //开启子线程转换文件
//        dispatch_async(dispatch_get_global_queue(0, 0), ^{
//            
//            //转换格式
//            [self audio_PCMtoMP3:outPutFilePath andDesPath:newFilePath];
//            NSLog(@"转换完成----%@", newFilePath);
//        });
        
        [self cafToMp3:outPutFilePath];
        
//        NSLog(@"合并完成----%@", outPutFilePath);
//        self.hcPlayer = [[AVAudioPlayer alloc] initWithContentsOfURL:[NSURL fileURLWithPath:outPutFilePath] error:nil];
//        [self.hcPlayer play];
    }];


}

@end
