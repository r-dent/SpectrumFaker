//
//  ViewController.swift
//  SpectrumFaker
//
//  Created by Roman Gille on 20.04.16.
//  Copyright © 2016 Roman Gille. All rights reserved.
//

import UIKit

import AVFoundation

class ViewController: UIViewController {
    
    private var _recorder: AVAudioRecorder?
    private var _displayLink: CADisplayLink?
    
    @IBOutlet weak var spectrum1: SpectrumFaker!
    @IBOutlet weak var spectrum2: SpectrumFaker!
    @IBOutlet weak var spectrum3: SpectrumFaker!
    
    let audioFilePath = NSTemporaryDirectory().stringByAppendingString("/tmp.caf")

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        spectrum1.fakeChannels = 16
        spectrum1.barsAlignment = .Top
        spectrum1.color = UIColor.lightGrayColor()
        
        spectrum2.fakeChannels = 100
        spectrum2.barsAlignment = .Middle
        spectrum2.color = UIColor.lightGrayColor()
        
        spectrum3.fakeChannels = 6
        spectrum3.color = UIColor.lightGrayColor()
        
        startRecording()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    func updateMeter() {
        _recorder?.updateMeters()
        
        let power =  max(0, (_recorder!.averagePowerForChannel(0) + 34) / 34)
        
        spectrum1.powerChannels = [Double(power)]
        spectrum2.powerChannels = [Double(power)]
        spectrum3.powerChannels = [Double(power)]
    }
    
    func startRecording() {
        // Early exit when we are already recording.
        if let rec = _recorder where rec.recording {return}
        
        do {
            let session = AVAudioSession.sharedInstance()
            try session.setCategory(AVAudioSessionCategoryRecord)
            try session.setActive(true)
        }
        catch {}
        
        let options: [String:AnyObject] = [
            AVFormatIDKey: Int(kAudioFormatAppleIMA4),
            AVSampleRateKey: 44100,
            AVNumberOfChannelsKey: 1,
            AVLinearPCMBitDepthKey: 16,
            AVLinearPCMIsBigEndianKey: 0,
            AVLinearPCMIsFloatKey: 0
        ]
        
        if let url = NSURL(string: audioFilePath) {
            _recorder = try? AVAudioRecorder(URL: url, settings: options)
        }
        
        if let recorder = _recorder {
            recorder.meteringEnabled = true
            recorder.record()
            
            // Add a display link to update the waveform
            let displayLink = CADisplayLink(target: self, selector: #selector(updateMeter))
            displayLink.frameInterval = 2
            displayLink.addToRunLoop(NSRunLoop.currentRunLoop(), forMode: NSRunLoopCommonModes) // See: http://stackoverflow.com/a/4878182/1057968
            _displayLink = displayLink
        }
    }
    
    func stopRecording() {
        // Early return if there is no current recording.
        if _recorder == nil && _displayLink == nil {return}
        
        _displayLink?.invalidate()
        _displayLink = nil
        
        _recorder?.stop()
        _recorder = nil
        
        do {
            try AVAudioSession.sharedInstance().setActive(false)
            try NSFileManager.defaultManager().removeItemAtPath(audioFilePath)
        }
        catch {
            print("Error")
        }
    }

}

