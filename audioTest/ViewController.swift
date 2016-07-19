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
    let motionManager = CMMotionManager()
    let environment = AVAudioEnvironmentNode()

    @IBOutlet weak var yawLabel: UILabel!
    @IBOutlet weak var pitchLabel: UILabel!
    @IBOutlet weak var rollLabel: UILabel!

    override func viewDidLoad() {
        super.viewDidLoad()

        if motionManager.deviceMotionAvailable {
            motionManager.deviceMotionUpdateInterval = 0.01
            motionManager.startDeviceMotionUpdatesUsingReferenceFrame(.XTrueNorthZVertical, toQueue: NSOperationQueue.mainQueue()) { (data: CMDeviceMotion?, error: NSError?) in
                if let data = data {

                    // YAW: goes from -PI to PI
                    // When phone is sitting on a table:
                    //      0: Due West
                    //      -PI/PI: due East
                    //      -PI/2: due North
                    //      PI/2: due South
                    self.rollLabel.text = data.attitude.roll.description
                    self.pitchLabel.text = data.attitude.pitch.description

                    let yaw = radToDeg(data.attitude.yaw)
                    self.yawLabel.text = yaw.description

                    self.environment.listenerAngularOrientation = AVAudioMake3DAngularOrientation(yaw, 0, 0)
                } else {
                    print(error)
                }
            }
        }


        environment.listenerPosition = AVAudio3DPoint(x: 0, y: 0, z: 0)
        environment.listenerAngularOrientation = AVAudioMake3DAngularOrientation(0.0, 0, 0)

        engine.attachNode(environment)


        let reverbParameters = environment.reverbParameters
        reverbParameters.enable = true
        reverbParameters.loadFactoryReverbPreset(.LargeHall)

        let node = AVAudioPlayerNode()

        node.position = AVAudio3DPoint(x: 0, y: 0, z: 10)
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
    }
}