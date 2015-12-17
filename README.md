## react-native-audio

An audio recording and playback library for react-native.

This release recording and playback of the recording only. PRs are welcome for configuring the audio settings.

Recorder accepts a settings parameter which is a dictionary with the desired audio parameters. 
Currently this supports:

format
sampleRate
numberOfChannels
encoderAudioQuality
encoderBitRate

NOTE: If not supplying a valid settings dictionary, the target filename must have an extension of '.caf' to record properly.

### Installation

1. `npm install react-native-audio`
2. In the XCode's "Project navigator", right click on project's name ➜ `Add Files to <...>`
3. Go to `node_modules` ➜ `react-native-audio`
4. Select the `ios/Audio*Manager.*` files

### Sample App

In the AudioExample directory:

1. `npm install`
2. open AudioExample.xcodeproj
3. Run

### TODO

* Documentation
* Allow setting audio properties
* Convert JS api to a react component
* Store audio to media library
* Error handling over the js bridge
* Recommend react-native-video (media) for playback

Thanks to Brent Vatne, Johannes Lumpe, Kureev Alexey and the React Native community for assistance.

Progress tracking code borrowed from https://github.com/brentvatne/react-native-video.
