//
//  ViewController.swift
//  SpectrumFaker
//
//  Created by Roman Gille on 20.04.16.
//  Copyright © 2016 Roman Gille. All rights reserved.
//

import UIKit

import AVFoundation

class ViewController: UIViewController, AVAudioPlayerDelegate {
    
    private var _player: AVAudioPlayer?
    private var _displayLink: CADisplayLink?
    
    @IBOutlet weak var spectrum1: SpectrumFaker!
    @IBOutlet weak var spectrum2: SpectrumFaker!
    @IBOutlet weak var spectrum3: SpectrumFaker!
    
    let audioFilePath = NSBundle.mainBundle().pathForResource("scratch", ofType: "mp3")

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        spectrum1.fakeChannels = 16
        spectrum1.barsAlignment = .Top
        spectrum1.color = UIColor.lightGrayColor()
        
        spectrum2.fakeChannels = 80
        spectrum2.barsAlignment = .Middle
        spectrum2.color = UIColor.lightGrayColor()
        
        spectrum3.fakeChannels = 6
        spectrum3.color = UIColor.lightGrayColor()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func togglePlayback(sender: AnyObject?) {
        if let player = _player where player.playing {
            stopPlaying()
        }
        else {
            playSound()
        }
    }

    func updateMeter() {
        _player?.updateMeters()
        
        let push = Float(34.0)
        let powerA =  max(0, (_player!.averagePowerForChannel(0) + push) / push)
        let powerB =  max(0, (_player!.averagePowerForChannel(1) + push) / push)
        
        spectrum1.powerChannels = [Double(powerA), Double(powerB)]
        spectrum2.powerChannels = [Double(powerA), Double(powerB)]
        spectrum3.powerChannels = [Double(powerA), Double(powerB)]
    }
    
    func playSound() {
        // Early exit when we are already recording.
        if let player = _player where player.playing {return}
        
        do {
            let session = AVAudioSession.sharedInstance()
            try session.setCategory(AVAudioSessionCategoryPlayback)
            try session.setActive(true)
        }
        catch {}
        
        if let path = audioFilePath {
            let url = NSURL.fileURLWithPath(path)
            _player = try? AVAudioPlayer(contentsOfURL: url)
        }
        
        if let player = _player {
            player.delegate = self
            player.meteringEnabled = true
            player.play()
            
            // Add a display link to update the waveform
            let displayLink = CADisplayLink(target: self, selector: #selector(updateMeter))
            displayLink.frameInterval = 2
            displayLink.addToRunLoop(NSRunLoop.currentRunLoop(), forMode: NSRunLoopCommonModes) // See: http://stackoverflow.com/a/4878182/1057968
            _displayLink = displayLink
        }
    }
    
    func stopPlaying() {
        // Early return if there is no current recording.
        if _player == nil && _displayLink == nil {return}
        
        _displayLink?.invalidate()
        _displayLink = nil
        
        _player?.stop()
        _player = nil
    }
    
    
    // MARK: - AVAudioPlayerDelegate
    
    func audioPlayerDidFinishPlaying(player: AVAudioPlayer, successfully flag: Bool) {
        stopPlaying()
    }

}

