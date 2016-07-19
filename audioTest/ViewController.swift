import UIKit
import AVFoundation
import CoreMotion

func delay(delay:Double, closure:()->()) {
    dispatch_after(
        dispatch_time(
            DISPATCH_TIME_NOW,
            Int64(delay * Double(NSEC_PER_SEC))
        ),
        dispatch_get_main_queue(), closure)
}

func radToDeg(rad:Double) -> Float {
    return Float(rad * 180.0 / M_PI)
}

class ViewController: UIViewController {
    let engine = AVAudioEngine()
    let environment = AVAudioEnvironmentNode()

    let motionManager = CMMotionManager()

    override func viewDidLoad() {
        super.viewDidLoad()

        environment.listenerPosition = AVAudio3DPoint(x: 0, y: 0, z: 0)
        environment.listenerAngularOrientation = AVAudioMake3DAngularOrientation(0.0, 0, 0)

        engine.attachNode(environment)


        let reverbParameters = environment.reverbParameters
        reverbParameters.enable = true
        reverbParameters.loadFactoryReverbPreset(.LargeHall)

        let node = AVAudioPlayerNode()
        node.position = AVAudio3DPoint(x: 2.0, y: 0, z: 0)
        node.reverbBlend = 0
        node.renderingAlgorithm = .HRTF

        let url = NSBundle.mainBundle().URLForResource("beep", withExtension: "wav")!
        let file = try! AVAudioFile(forReading: url)
        let buffer = AVAudioPCMBuffer(PCMFormat: file.processingFormat, frameCapacity: AVAudioFrameCount(file.length))
        try! file.readIntoBuffer(buffer)
        node
        engine.attachNode(node)
        engine.connect(node, to: environment, format: buffer.format)
        print("format", file.fileFormat)
        engine.connect(environment, to: engine.mainMixerNode, format: nil)
        node.scheduleBuffer(buffer, atTime: nil, options: .Loops, completionHandler: nil)
        engine.prepare()

        do {
            try engine.start()
            node.play()
            print("Started")
        } catch let e as NSError {
            print("Couldn't start engine", e)
        }

        motionManager.startDeviceMotionUpdatesUsingReferenceFrame(.XTrueNorthZVertical, toQueue: NSOperationQueue.mainQueue()) { (motion, error) in
            if let motion = motion {

                let orientation = AVAudio3DAngularOrientation(yaw: radToDeg(motion.attitude.roll), pitch: radToDeg(motion.attitude.pitch), roll: radToDeg(motion.attitude.yaw))

                print(orientation)
                self.environment.listenerAngularOrientation = orientation
            }
        }
    }
}