# iOS 3D Audio Test

Playing around with [Core Motion](https://developer.apple.com/library/ios/documentation/CoreMotion/Reference/CoreMotion_Reference/index.html) and [AVAudioEnvironmentNode](https://developer.apple.com/library/ios/documentation/AVFoundation/Reference/AVAudioEnvironmentNode_Class/) to provide a binaural 3D sound environment (using HRTF) that adjusts the listener's orientation based on device motion.

This isn't a perfect system for a few reasons. Some of them are:

* For binaural audio, you really really want head tracking, not smartphone-in-pocket tracking
* Apple's positional 3D audio system doesn't seem as robust as many proprietary third-party alternatives
* The iOS magnetometer is notoriously noisy. Figuring out how to consistently orient the user in space isn't a problem I've tackled yet. Presumably, having the user manually calibrate (e.g. press a button to say "I'm now facing the -Z direction") is the right way to solve this, assuming you don't need a relation to true north (or, if working in a specific physical space, you can make the user calibrate relative to a known good direction). After I've done such calibration, I'd like to run tests to see what sort of drift occurs over time.
* This works if you're holding your phone in front of you in portrait mode, with your screen either parallel to the ground or parallel to your torso. Ideally, it would let you put your phone in your pocket/purse.

## Some notes for myself

### CoreMotion

For just tracking basic "head" motion (rotation in a circle parallel to the ground), I only care about yaw (`CMDeviceMotion.data.attitude.yaw`). It goes from `-Pi` to `Pi`. AVFoundation wants this in degrees, but it's [easy to convert](https://github.com/lazerwalker/ios-3d-audio-test/blob/master/audioTest/ViewController.swift#L14-L16).

When your phone is sitting flat on the table, and the reference frame is `.XTrueNorthZVertical`:

```
0: due West
-Pi or Pi: due East
-Pi/2: due North
Pi/2: due South
```

(it's rotated 90° from what you'd expect because it's tracking the right edge of the phone, not the top)


### AVAudioEnvironmentNode

For my tests thus far, I've generally left the `listenerPosition` at `(0, 0, 0)` and rotated the `listenerAngularOrientation` as `([yaw], 0, 0)`.

AVFoundation's coordinate system is thus (again, assuming yaw is coming from a `CMMotionManager` using a reference frame of `.XTrueNorthZVertical`)

```
Z-axis: east-west (-Z = west, +Z = east)
X-axis: north-south (-X = south, +X = north)
Y-axis: up-down (-Y = down, +Y = up)
```

# License

This project is licensed under the MIT License. See the LICENSE file in this repository for more information.
