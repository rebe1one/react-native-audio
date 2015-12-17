'use strict';

/**
 * This module is a thin layer over the native module. It's aim is to obscure
 * implementation details for registering callbacks, changing settings, etc.
*/

var React, {NativeModules, NativeAppEventEmitter, DeviceEventEmitter} = require('react-native');

var AudioPlayerManager = NativeModules.AudioPlayerManager;
var AudioRecorderManager = NativeModules.AudioRecorderManager;

var AudioPlayer = {
  play: function(path) {
    AudioPlayerManager.play(path);
  },
  playWithUrl: function(url) {
    AudioPlayerManager.playWithUrl(url);
  },
  pause: function() {
    AudioPlayerManager.pause();
  },
  unpause: function() {
    AudioPlayerManager.unpause();
  },
  stop: function() {
    AudioPlayerManager.stop();
    if (this.subscription) {
      this.subscription.remove();
    }
  },
  setCurrentTime: function(time) {
    AudioPlayerManager.setCurrentTime(time);
  },
  setProgressSubscription: function() {
    this.progressSubscription = DeviceEventEmitter.addListener('playerProgress',
      (data) => {
        if (this.onProgress) {
          this.onProgress(data);
        }
      }
    );
  },
  setFinishedSubscription: function() {
    this.progressSubscription = DeviceEventEmitter.addListener('playerFinished',
      (data) => {
        if (this.onProgress) {
          this.onFinished(data);
        }
      }
    );
  },
  getDuration: function(callback) {
    AudioPlayerManager.getDuration((error, duration) => {
      callback(duration);
    })
  },
};

var AudioFormat = {
    kAudioFormatLinearPCM               : 'lpcm',
    kAudioFormatAC3                     : 'ac-3',
    kAudioFormat60958AC3                : 'cac3',
    kAudioFormatAppleIMA4               : 'ima4',
    kAudioFormatMPEG4AAC                : 'aac ',
    kAudioFormatMPEG4CELP               : 'celp',
    kAudioFormatMPEG4HVXC               : 'hvxc',
    kAudioFormatMPEG4TwinVQ             : 'twvq',
    kAudioFormatMACE3                   : 'MAC3',
    kAudioFormatMACE6                   : 'MAC6',
    kAudioFormatULaw                    : 'ulaw',
    kAudioFormatALaw                    : 'alaw',
    kAudioFormatQDesign                 : 'QDMC',
    kAudioFormatQDesign2                : 'QDM2',
    kAudioFormatQUALCOMM                : 'Qclp',
    kAudioFormatMPEGLayer1              : '.mp1',
    kAudioFormatMPEGLayer2              : '.mp2',
    kAudioFormatMPEGLayer3              : '.mp3',
    kAudioFormatTimeCode                : 'time',
    kAudioFormatMIDIStream              : 'midi',
    kAudioFormatParameterValueStream    : 'apvs',
    kAudioFormatAppleLossless           : 'alac',
    kAudioFormatMPEG4AAC_HE             : 'aach',
    kAudioFormatMPEG4AAC_LD             : 'aacl',
    kAudioFormatMPEG4AAC_ELD            : 'aace',
    kAudioFormatMPEG4AAC_ELD_SBR        : 'aacf',
    kAudioFormatMPEG4AAC_ELD_V2         : 'aacg',
    kAudioFormatMPEG4AAC_HE_V2          : 'aacp',
    kAudioFormatMPEG4AAC_Spatial        : 'aacs',
    kAudioFormatAMR                     : 'samr',
    kAudioFormatAMR_WB                  : 'sawb',
    kAudioFormatAudible                 : 'AUDB',
    kAudioFormatiLBC                    : 'ilbc',
    kAudioFormatDVIIntelIMA             : 'iima',
    kAudioFormatMicrosoftGSM            : 'mgsm',
    kAudioFormatAES3                    : 'aes3',
    kAudioFormatEnhancedAC3             : 'ec-3'
}

var AudioRecorder = {
  prepareRecordingAtPath: function(path, format) {
    AudioRecorderManager.prepareRecordingAtPath(path, format);
    this.progressSubscription = NativeAppEventEmitter.addListener('recordingProgress',
      (data) => {
        console.log(data);
        if (this.onProgress) {
          this.onProgress(data);
        }
      }
    );

    this.FinishedSubscription = NativeAppEventEmitter.addListener('recordingFinished',
      (data) => {
        if (this.onFinished) {
          this.onFinished(data);
        }
      }
    );
  },
  startRecording: function() {
    AudioRecorderManager.startRecording();
  },
  pauseRecording: function() {
    AudioRecorderManager.pauseRecording();
  },
  stopRecording: function() {
    AudioRecorderManager.stopRecording();
    if (this.subscription) {
      this.subscription.remove();
    }
  },
  playRecording: function() {
    AudioRecorderManager.playRecording();
  },
  stopPlaying: function() {
    AudioRecorderManager.stopPlaying();
  }
};

module.exports = {AudioPlayer, AudioRecorder, AudioFormat};
