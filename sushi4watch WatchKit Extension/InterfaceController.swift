//
//  InterfaceController.swift
//  sushi4watch WatchKit Extension
//
//  Created by Oka Yuya on 2016/11/26.
//  Copyright © 2016年 nnsnodnb. All rights reserved.
//

import WatchKit
import Foundation
import AVFoundation

class InterfaceController: WKInterfaceController {

    @IBOutlet var messageLabel: WKInterfaceLabel!
    @IBOutlet var sushiImage: WKInterfaceImage!

    let engine = AVAudioEngine()
    let audioPlayerNode = AVAudioPlayerNode()
    var audioFile:AVAudioFile!
    var imageNumber: Int!

    override func awake(withContext context: Any?) {
        super.awake(withContext: context)
        setup()
        setupAudio()
    }
    
    override func willActivate() {
        super.willActivate()
    }
    
    override func didDeactivate() {
        super.didDeactivate()
    }

    fileprivate func setup() {
        crownSequencer.focus()
        crownSequencer.delegate = self
        imageNumber = 1
        messageLabel.setText("寿司を廻せ！！！！")
        sushiImage.setImageNamed("sushi_1")
    }

    fileprivate func setupAudio() {
        do {
            let path = Bundle.main.path(forResource: "sushi", ofType: "mp3")
            if let path = path {
                audioFile = try AVAudioFile(forReading: URL(fileURLWithPath: path))
            }
        } catch {
            fatalError("\(error)")
        }
        engine.attach(audioPlayerNode)

        if let file = audioFile {
            engine.connect(audioPlayerNode, to: engine.mainMixerNode, format: file.processingFormat)
        }

        do {
            try self.engine.start()
        } catch {
            fatalError("\(error)")
        }
    }
}

extension InterfaceController : WKCrownDelegate {
    func crownDidRotate(_ crownSequencer: WKCrownSequencer?,
                        rotationalDelta: Double) {
        if let file = audioFile {
            audioPlayerNode.scheduleFile(file, at: nil, completionHandler: nil)
            audioPlayerNode.play()
        }
        

        if (rotationalDelta > 0) {
            imageNumber = imageNumber + 1
        }

        if (rotationalDelta < 0) {
            imageNumber = imageNumber - 1
        }

        if (imageNumber == 45) {
            imageNumber = 1
        }

        if (imageNumber == 0) {
            imageNumber = 44
        }

        let imageName = String(format: "sushi_%zd", imageNumber)
        sushiImage.setImageNamed(imageName)
        messageLabel.setText("おすしぐるぐる")
    }

    func crownDidBecomeIdle(_ crownSequencer: WKCrownSequencer?) {
        if let file = audioFile {
            audioPlayerNode.scheduleFile(file, at: nil, completionHandler: nil)
            audioPlayerNode.pause()
        }
        messageLabel.setText("( `o´)ﾍｲﾗｯｼｬｲ")
    }
}
