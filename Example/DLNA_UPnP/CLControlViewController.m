//
//  CLControlViewController.m
//  DLNA_UPnP
//
//  Created by ClaudeLi on 16/10/8.
//  Copyright © 2016年 ClaudeLi. All rights reserved.
//

#import "CLControlViewController.h"

static NSString *urlStr2 = @"https://janus.97kid.com/264.flv";
static NSString *urlStr1 = @"https://janus.97kid.com/test.mp4";
static NSString *urlStr0 = @"http://live.hkstv.hk.lxdns.com/live/hks/playlist.m3u8";
//static NSString *urlStr3 = @"http://222.73.132.145/vkphls.tc.qq.com/mp4/8/yZ_j6ME6N3hgRF2xg_m13zCxeLHcQzm9bVK0v_J-08OdcAVc0rmGCA/q4WgUBCu27O21hhzjGXkPCaHr1EkTFuUGbXKrNbjMACA-wleQI3oi3woUdjgP-BtBxW34UkmIxlQ_TkPGeqTLwghaijDM7oFlQwmCbieZPLUh33Q7f8eag/i0021mzabfm.p209.mp4/i0021mzabfm.p209.mp4.av.m3u8";

@interface CLControlViewController ()<CLUPnPResponseDelegate>{
    BOOL _isPlaying;
    CLUPnPRenderer *render;
    NSTimer* timer;
    __weak IBOutlet UISlider *_volume;
    __weak IBOutlet UISlider *_position;
}

@end

@implementation CLControlViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    render = [[CLUPnPRenderer alloc] initWithModel:self.model];
    render.delegate = self;
    [render setAVTransportURL:urlStr2];
    [render setNextAVTransportURI:urlStr1];
    _volume.maximumValue = 100.f;
    _isPlaying = YES;
    self->timer = nil;
}

#pragma mark -
#pragma mark - 动作调用 -
- (IBAction)closeAction:(id)sender {
    [render stop];
    [self->timer invalidate];
}

- (IBAction)playOrPause:(id)sender {
    if (_isPlaying) {
        [render pause];
    }else{
        [render play];
    }
    _isPlaying = !_isPlaying;
}

- (IBAction)seekTo01:(id)sender {
    [render seekToTarget:@"00:00:01" Unit:unitREL_TIME];
}

- (IBAction)seekTo11:(id)sender {
    [render seekToTarget:@"00:00:11" Unit:unitREL_TIME];
}

- (IBAction)onPositionChange:(id)sender {
    NSLog(@"pos changed %f", _position.value);
    [render seek:_position.value];
}

- (IBAction)pro:(id)sender {
    [render previous];
}

- (IBAction)next:(id)sender {
    [render next];
}

- (IBAction)getPosition:(id)sender {
    [render getPositionInfo];
}

- (IBAction)getTransport:(id)sender {
    [render getTransportInfo];
}

- (IBAction)subV:(id)sender {
    [render setVolumeWith:@"0"];
}

- (IBAction)addV:(id)sender {
    [render setVolumeWith:@"25"];
}
- (IBAction)onVolumeChange:(id)sender {
    [render setVolumeWith: [NSString stringWithFormat:@"%f", _volume.value]];
}

#pragma mark -
#pragma mark - CLUPnPResponseDelegate -
- (void)upnpSetAVTransportURIResponse{
    [render play];
    [render getVolume];
    [render getPositionInfo];
    dispatch_async(dispatch_get_main_queue(), ^{
        [self->timer invalidate];
        self->timer = nil;
        self->timer = [NSTimer scheduledTimerWithTimeInterval:0.5f target:self selector:@selector(getPosition:) userInfo:nil repeats:YES];
        [[NSRunLoop currentRunLoop] addTimer:self->timer forMode:NSRunLoopCommonModes];
    });
}

- (void)upnpGetTransportInfoResponse:(CLUPnPTransportInfo *)info{
    //    STOPPED
    //    PAUSED_PLAYBACK
    NSLog(@"%@ === %@", info.currentTransportState, info.currentTransportStatus);
    if (!([info.currentTransportState isEqualToString:@"PLAYING"] || [info.currentTransportState isEqualToString:@"TRANSITIONING"])) {
        [render play];
    }
}

- (void)upnpPlayResponse{
    NSLog(@"播放");
}

- (void)upnpPauseResponse{
    NSLog(@"暂停");
}

- (void)upnpStopResponse{
    NSLog(@"停止");
}

- (void)upnpSeekResponse{
    NSLog(@"跳转完成");
}

- (void)upnpPreviousResponse{
    NSLog(@"前一个");
}

- (void)upnpNextResponse{
    NSLog(@"下一个");
    [render setNextAVTransportURI:urlStr2];
}

- (void)upnpSetVolumeResponse{
    NSLog(@"设置音量成功");
}

- (void)upnpSetNextAVTransportURIResponse{
    NSLog(@"设置下一个url成功");
}

- (void)upnpGetVolumeResponse:(NSString *)volume{
    NSLog(@"音量=%@", volume);
    dispatch_async(dispatch_get_main_queue(), ^{
        _volume.value = [volume floatValue];
    });
}

- (void)upnpGetPositionInfoResponse:(CLUPnPAVPositionInfo *)info{
    NSLog(@"%f, === %f === %f", info.trackDuration, info.absTime, info.relTime);
    dispatch_async(dispatch_get_main_queue(), ^{
        _position.maximumValue = info.trackDuration;
        _position.value = info.relTime;
    });
}

- (void)upnpUndefinedResponse:(NSString *)resXML postXML:(NSString *)postXML{
    NSLog(@"postXML = %@", postXML);
    NSLog(@"resXML = %@", resXML);
}


@end
