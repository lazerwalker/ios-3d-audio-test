import UIKit
import AVFoundation

func delay(delay:Double, closure:()->()) {
    dispatch_after(
        dispatch_time(
            DISPATCH_TIME_NOW,
            Int64(delay * Double(NSEC_PER_SEC))
        ),
        dispatch_get_main_queue(), closure)
}

class ViewController: UIViewController {
    let engine = AVAudioEngine()
    let environment = AVAudioEnvironmentNode()

    override func viewDidLoad() {
        super.viewDidLoad()

        environment.listenerPosition = AVAudio3DPoint(x: 3.0, y: 0, z: 0)
        environment.listenerAngularOrientation = AVAudioMake3DAngularOrientation(0.0, 0, 0)

        engine.attachNode(environment)


        let reverbParameters = environment.reverbParameters
        reverbParameters.enable = true
        reverbParameters.loadFactoryReverbPreset(.LargeHall)

        let node = AVAudioPlayerNode()
        node.position = AVAudio3DPoint(x: 0, y: 0, z: 2)
        node.reverbBlend = 0.2
        node.renderingAlgorithm = .HRTF

        let url = NSBundle.mainBundle().URLForResource("kennedy", withExtension: "mp3")!
        let file = try! AVAudioFile(forReading: url)
        let buffer = AVAudioPCMBuffer(PCMFormat: file.processingFormat, frameCapacity: AVAudioFrameCount(file.length))
        try! file.readIntoBuffer(buffer)
        node
        engine.attachNode(node)
        engine.connect(node, to: environment, format: buffer.format)
        print("format", file.fileFormat)
        engine.connect(environment, to: engine.mainMixerNode, format: nil)
        node.scheduleBuffer(buffer, atTime: nil, options: AVAudioPlayerNodeBufferOptions(rawValue: 0), completionHandler: nil)
        engine.prepare()

        delay(5.0) { 
            node.position = AVAudio3DPoint(x:0, y: 1, z: 100)
            print("Moving")
        }

        do {
            try engine.start()
            node.play()
            print("Started")
        } catch let e as NSError {
            print("Couldn't start engine", e)
        }
    }

}

