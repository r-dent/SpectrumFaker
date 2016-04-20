//  Copyright (c) 2016 Roman Gille, http://romangille.com
//
//  Permission is hereby granted, free of charge, to any person obtaining
//  a copy of this software and associated documentation files (the
//  "Software"), to deal in the Software without restriction, including
//  without limitation the rights to use, copy, modify, merge, publish,
//  distribute, sublicense, and/or sell copies of the Software, and to
//  permit persons to whom the Software is furnished to do so, subject to
//  the following conditions:
//
//  The above copyright notice and this permission notice shall be
//  included in all copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
//  EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
//  MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
//  NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE
//  LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION
//  OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION
//  WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

import UIKit

public class SpectrumFaker: UIView {
    
    public enum BarsAlignment {
        case Bottom, Middle, Top
    }
    
    // Only override drawRect: if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override public func drawRect(rect: CGRect) {
        let channelWidth = (rect.width - (spacing * CGFloat(_fakeChannels.count))) / CGFloat(_fakeChannels.count)
        self.color.set()
        
        for i in 0..<_fakeChannels.count {
            let height = rect.height * CGFloat(_fakeChannels[i])
            let x = CGFloat(i) * (channelWidth + spacing)
            let y: CGFloat
            
            switch self.barsAlignment {
            case .Bottom:
                y = rect.height - height
            case .Middle:
                y = (rect.height - height) / 2.0
            case .Top:
                y = 0
            }
            
            let path = UIBezierPath(rect: CGRect(x: x, y: y, width: channelWidth, height: height))
            path.fill();
        }
    }
    
    private var _powerChannels = [0.0]
    private var _fakeChannels: [Double] = [0.0]
    private var _fakeChannelDeltas: [Double] = [0.0]
    
    public var color = UIColor.whiteColor()
    public var spacing: CGFloat = 2.0
    public var barsAlignment: BarsAlignment = .Bottom
    
    var powerChannels: [Double] {
        set (newPowerChannels) {
            guard newPowerChannels != _powerChannels else {return}
            
            
            for i in 0..<_fakeChannels.count {
                let powerChannel = i % _powerChannels.count;
                let newPowerValue = newPowerChannels[powerChannel]
                let oldPowerValue = _powerChannels[powerChannel]
                let delta = newPowerValue - oldPowerValue
                
                _fakeChannels[i] = _fakeChannels[i] + (delta * _fakeChannelDeltas[i])
            }
            _powerChannels = newPowerChannels
            
            self.setNeedsDisplay()
        }
        get {
            return _powerChannels
        }
    }
    
    var fakeChannels: Int {
        set (newCount) {
            _fakeChannels = []
            _fakeChannelDeltas = []
            
            for _ in 0..<newCount {
                _fakeChannels.append(0.0)
                _fakeChannelDeltas.append(Double(arc4random() % 80 + 20) * 0.01)
            }
            
            self.setNeedsDisplay()
        }
        get {
            return _fakeChannels.count
        }
    }
    
    func reset() {
        for i in 0..<_powerChannels.count {
            _powerChannels[i] = 0.0
        }
        self.fakeChannels = _fakeChannels.count
    }
    
}
