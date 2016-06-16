import UIKit
import AVFoundation

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
        node.position = AVAudio3DPoint(x: 5, y: 0, z: 0)
        node.reverbBlend = 0.2
        node.renderingAlgorithm = .HRTF

        let url = NSBundle.mainBundle().URLForResource("kennedy", withExtension: "mp3")!
        let file = try! AVAudioFile(forReading: url)

        engine.attachNode(node)
        print("format", file.fileFormat)
        engine.connect(node, to: engine.mainMixerNode, format: engine.mainMixerNode.outputFormatForBus(0))
        node.scheduleFile(file, atTime: nil, completionHandler: nil)
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

