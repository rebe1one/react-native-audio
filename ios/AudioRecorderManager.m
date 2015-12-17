//
//  AudioRecorderManager.m
//  AudioRecorderManager
//
//  Created by Joshua Sierles on 15/04/15.
//  Copyright (c) 2015 Joshua Sierles. All rights reserved.
//

#import "AudioRecorderManager.h"
#import "RCTConvert.h"
#import "RCTBridge.h"
#import "RCTEventDispatcher.h"
#import <AVFoundation/AVFoundation.h>

NSString *const AudioRecorderEventProgress = @"recordingProgress";
NSString *const AudioRecorderEventFinished = @"recordingFinished";

@implementation AudioRecorderManager {

  AVAudioRecorder *_audioRecorder;
  AVAudioPlayer *_audioPlayer;

  NSTimeInterval _currentTime;
  id _progressUpdateTimer;
  int _progressUpdateInterval;
  NSDate *_prevProgressUpdateTime;
  NSURL *_audioFileURL;
  AVAudioSession *_recordSession;
}

@synthesize bridge = _bridge;

RCT_EXPORT_MODULE();

- (void)sendProgressUpdate {
  if (_audioRecorder && _audioRecorder.recording) {
    _currentTime = _audioRecorder.currentTime;
  } else if (_audioPlayer && _audioPlayer.playing) {
    _currentTime = _audioPlayer.currentTime;
  } else {
    return;
  }

  if (_prevProgressUpdateTime == nil ||
   (([_prevProgressUpdateTime timeIntervalSinceNow] * -1000.0) >= _progressUpdateInterval)) {
      [self.bridge.eventDispatcher sendAppEventWithName:AudioRecorderEventProgress body:@{
      @"currentTime": [NSNumber numberWithFloat:_currentTime]
    }];

    _prevProgressUpdateTime = [NSDate date];
  }
}

- (void)stopProgressTimer {
  [_progressUpdateTimer invalidate];
}

- (void)startProgressTimer {
  _progressUpdateInterval = 250;
  _prevProgressUpdateTime = nil;

  [self stopProgressTimer];

  _progressUpdateTimer = [CADisplayLink displayLinkWithTarget:self selector:@selector(sendProgressUpdate)];
  [_progressUpdateTimer addToRunLoop:[NSRunLoop mainRunLoop] forMode:NSDefaultRunLoopMode];
}

- (void)audioRecorderDidFinishRecording:(AVAudioRecorder *)recorder successfully:(BOOL)flag {
  [self.bridge.eventDispatcher sendAppEventWithName:AudioRecorderEventFinished
                                               body:@{ @"status": flag ? @"OK" : @"ERROR",
                                                       @"filePath" : [_audioFileURL absoluteString]
                                                      }];
}

- (NSString *) applicationDocumentsDirectory
{
  NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
  NSString *basePath = ([paths count] > 0) ? [paths objectAtIndex:0] : nil;
  return basePath;
}

- (NSDictionary *)convertSettingsDictionary:(NSDictionary *)inDict
{
  NSMutableDictionary *outDict = [[NSMutableDictionary alloc] initWithCapacity:inDict.count];
  for (NSString *key in inDict) {
    if ([key isEqualToString:@"format"]) {
      NSString *format = [inDict objectForKey:@"format"];
      [outDict setObject:[NSNumber numberWithInt:[self formatIDFromString:format]] forKey:AVFormatIDKey];
    } else if ([key isEqualToString:@"sampleRate"]) {
      [outDict setObject:[inDict objectForKey:@"sampleRate"] forKey:AVSampleRateKey];
    } else if ([key isEqualToString:@"numberOfChannels"]) {
      [outDict setObject:[inDict objectForKey:@"numberOfChannels"] forKey:AVNumberOfChannelsKey];
    } else if ([key isEqualToString:@"encoderAudioQuality"]) {
      [outDict setObject:[inDict objectForKey:@"encoderAudioQuality"] forKey:AVEncoderAudioQualityKey];
    } else if ([key isEqualToString:@"encoderBitRate"]) {
      [outDict setObject:[inDict objectForKey:@"encoderBitRate"] forKey:AVEncoderBitRateKey];
    }
  }
  return outDict;
}

- (AudioFormatID)formatIDFromString:(NSString *)formatString {
  if ([formatString isEqualToString:@"lpcm"]) return kAudioFormatLinearPCM;
  if ([formatString isEqualToString:@"ac-3"]) return kAudioFormatAC3;
  if ([formatString isEqualToString:@"cac3"]) return kAudioFormat60958AC3;
  if ([formatString isEqualToString:@"ima4"]) return kAudioFormatAppleIMA4;
  if ([formatString isEqualToString:@"aac "]) return kAudioFormatMPEG4AAC;
  if ([formatString isEqualToString:@"celp"]) return kAudioFormatMPEG4CELP;
  if ([formatString isEqualToString:@"hvxc"]) return kAudioFormatMPEG4HVXC;
  if ([formatString isEqualToString:@"twvq"]) return kAudioFormatMPEG4TwinVQ;
  if ([formatString isEqualToString:@"MAC3"]) return kAudioFormatMACE3;
  if ([formatString isEqualToString:@"MAC6"]) return kAudioFormatMACE6;
  if ([formatString isEqualToString:@"ulaw"]) return kAudioFormatULaw;
  if ([formatString isEqualToString:@"alaw"]) return kAudioFormatALaw;
  if ([formatString isEqualToString:@"QDMC"]) return kAudioFormatQDesign;
  if ([formatString isEqualToString:@"QDM2"]) return kAudioFormatQDesign2;
  if ([formatString isEqualToString:@"Qclp"]) return kAudioFormatQUALCOMM;
  if ([formatString isEqualToString:@".mp1"]) return kAudioFormatMPEGLayer1;
  if ([formatString isEqualToString:@".mp2"]) return kAudioFormatMPEGLayer2;
  if ([formatString isEqualToString:@".mp3"]) return kAudioFormatMPEGLayer3;
  if ([formatString isEqualToString:@"time"]) return kAudioFormatTimeCode;
  if ([formatString isEqualToString:@"midi"]) return kAudioFormatMIDIStream;
  if ([formatString isEqualToString:@"apvs"]) return kAudioFormatParameterValueStream;
  if ([formatString isEqualToString:@"alac"]) return kAudioFormatAppleLossless;
  if ([formatString isEqualToString:@"aach"]) return kAudioFormatMPEG4AAC_HE;
  if ([formatString isEqualToString:@"aacl"]) return kAudioFormatMPEG4AAC_LD;
  if ([formatString isEqualToString:@"aace"]) return kAudioFormatMPEG4AAC_ELD;
  if ([formatString isEqualToString:@"aacf"]) return kAudioFormatMPEG4AAC_ELD_SBR;
  if ([formatString isEqualToString:@"aacg"]) return kAudioFormatMPEG4AAC_ELD_V2;
  if ([formatString isEqualToString:@"aacp"]) return kAudioFormatMPEG4AAC_HE_V2;
  if ([formatString isEqualToString:@"aacs"]) return kAudioFormatMPEG4AAC_Spatial;
  if ([formatString isEqualToString:@"samr"]) return kAudioFormatAMR;
  if ([formatString isEqualToString:@"sawb"]) return kAudioFormatAMR_WB;
  if ([formatString isEqualToString:@"AUDB"]) return kAudioFormatAudible;
  if ([formatString isEqualToString:@"ilbc"]) return kAudioFormatiLBC;
  if ([formatString isEqualToString:@"iima"]) return kAudioFormatDVIIntelIMA;
  if ([formatString isEqualToString:@"mgsm"]) return kAudioFormatMicrosoftGSM;
  if ([formatString isEqualToString:@"aes3"]) return kAudioFormatAES3;
  if ([formatString isEqualToString:@"ec-3"]) return kAudioFormatEnhancedAC3;
  else return 0;
}

RCT_EXPORT_METHOD(prepareRecordingAtPath:(NSString *)path)
{
  [self prepareRecordingAtPath:path format:nil];
}

RCT_EXPORT_METHOD(prepareRecordingAtPath:(NSString *)path format:(NSDictionary *)format)
{

  _prevProgressUpdateTime = nil;
  [self stopProgressTimer];

  NSString *audioFilePath = [[self applicationDocumentsDirectory] stringByAppendingPathComponent:path];

  _audioFileURL = [NSURL fileURLWithPath:audioFilePath];

  NSDictionary *recordSettings;
  
  if (format != nil) {
    recordSettings = [self convertSettingsDictionary:format];
  } else {
    recordSettings = [NSDictionary dictionaryWithObjectsAndKeys:
                          [NSNumber numberWithInt:AVAudioQualityHigh], AVEncoderAudioQualityKey,
                          [NSNumber numberWithInt:16], AVEncoderBitRateKey,
                          [NSNumber numberWithInt: 2], AVNumberOfChannelsKey,
                          [NSNumber numberWithFloat:44100.0], AVSampleRateKey,
                          nil];
  }
  
  NSError *error = nil;

  _recordSession = [AVAudioSession sharedInstance];
  [_recordSession setCategory:AVAudioSessionCategoryPlayAndRecord error:nil];

  _audioRecorder = [[AVAudioRecorder alloc]
                initWithURL:_audioFileURL
                settings:recordSettings
                error:&error];

  _audioRecorder.delegate = self;

  if (error) {
      NSLog(@"error: %@", [error localizedDescription]);
      // TODO: dispatch error over the bridge
    } else {
      [_audioRecorder prepareToRecord];
  }
}

RCT_EXPORT_METHOD(startRecording)
{
  if (!_audioRecorder.recording) {
    [self startProgressTimer];
    [_recordSession setActive:YES error:nil];
    [_audioRecorder record];

  }
}

RCT_EXPORT_METHOD(stopRecording)
{
  if (_audioRecorder.recording) {
    [_audioRecorder stop];
    [_recordSession setActive:NO error:nil];
    _prevProgressUpdateTime = nil;
  }
}

RCT_EXPORT_METHOD(pauseRecording)
{
  if (_audioRecorder.recording) {
    [self stopProgressTimer];
    [_audioRecorder pause];
  }
}

RCT_EXPORT_METHOD(playRecording)
{
  if (_audioRecorder.recording) {
    NSLog(@"stop the recording before playing");
    return;

  } else {

    NSError *error;

    if (!_audioPlayer.playing) {
      _audioPlayer = [[AVAudioPlayer alloc]
        initWithContentsOfURL:_audioRecorder.url
        error:&error];

      if (error) {
        [self stopProgressTimer];
        NSLog(@"audio playback loading error: %@", [error localizedDescription]);
        // TODO: dispatch error over the bridge
      } else {
        [self startProgressTimer];
        [_audioPlayer play];
      }
    }
  }
}

RCT_EXPORT_METHOD(pausePlaying)
{
  if (_audioPlayer.playing) {
    [_audioPlayer pause];
  }
}

RCT_EXPORT_METHOD(stopPlaying)
{
  if (_audioPlayer.playing) {
    [_audioPlayer stop];
  }
}

@end
