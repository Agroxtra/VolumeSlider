//
//  VolumeSliderView.swift
//  VolumeSlider
//
//  Created by Martin Zörfuss on 24.10.18.
//  Copyright © 2018 Martin Zörfuss. All rights reserved.
//

import UIKit

private extension UIColor {
    convenience init(red: Int, green: Int, blue: Int) {
        assert(red >= 0 && red <= 255, "Invalid red component")
        assert(green >= 0 && green <= 255, "Invalid green component")
        assert(blue >= 0 && blue <= 255, "Invalid blue component")
        
        self.init(red: CGFloat(red) / 255.0, green: CGFloat(green) / 255.0, blue: CGFloat(blue) / 255.0, alpha: 1.0)
    }
    
    convenience init(rgb: Int) {
        self.init(
            red: (rgb >> 16) & 0xFF,
            green: (rgb >> 8) & 0xFF,
            blue: rgb & 0xFF
        )
    }
}

protocol VolumeSliderDelegate {
    func didChange(volume: CGFloat)
}

class VolumeSliderView : UIView {
    private enum SpeakerImage : String {
        case off = "volume_off", low = "volume_low", mid = "volume_mid", high = "volume_high"
        
        func image()->UIImage? {
            return UIImage(named: self.rawValue)?.withRenderingMode(.alwaysTemplate)
        }
    }
    
    private var volumeLayer : CALayer!
    private var volume : CGFloat = 0
    private var isChanging = false
    private var speakerImgView : UIImageView!
    private var currentSpeakerImage : SpeakerImage = .off
    
    //    private var touchWasForceTouch = false
    
    public var delegate : VolumeSliderDelegate?
    
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.setup()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.setup()
    }
    
    private func setup(){
        self.accessibilityIdentifier = "volumeSlider"
        self.backgroundColor = UIColor(rgb: 0x333333)
        self.alpha = 0.8
        self.layer.masksToBounds = true
        self.layer.cornerRadius = 15
        self.volumeLayer = CALayer()
        self.volumeLayer.backgroundColor = UIColor.white.cgColor
        self.volumeLayer.frame = self.layer.bounds
        self.volumeLayer.frame = CGRect(origin: .zero, size: CGSize(width: self.layer.bounds.width, height: 0))
        self.layer.addSublayer(self.volumeLayer)
        
        
        self.speakerImgView = UIImageView(frame: .zero)
        self.speakerImgView.tintColor = UIColor.gray
        self.speakerImgView.contentMode = .scaleAspectFit
        self.speakerImgView.image = self.currentSpeakerImage.image()
        self.speakerImgView.isUserInteractionEnabled = false
        self.addSubview(self.speakerImgView)
        self.speakerImgView.translatesAutoresizingMaskIntoConstraints = false
        self.speakerImgView.widthAnchor.constraint(equalToConstant: 40).isActive = true
        self.speakerImgView.heightAnchor.constraint(equalToConstant: 40).isActive = true
        self.speakerImgView.bottomAnchor.constraint(equalTo: self.bottomAnchor, constant: -10).isActive = true
        self.speakerImgView.centerXAnchor.constraint(equalTo: self.centerXAnchor).isActive = true
        
        let recog = UIPanGestureRecognizer(target: self, action: #selector(self.panRecognized(_:)))
        self.addGestureRecognizer(recog)
        
        self.updateLevel(0)
        
    }
    
    public func updateLevel(_ volume: CGFloat, animated : Bool = true){
        self.volume = volume
        let newHeight : CGFloat = self.layer.bounds.height * volume
        let newY : CGFloat = self.layer.bounds.height - newHeight
        if !animated {
            CATransaction.setValue(kCFBooleanTrue, forKey:kCATransactionDisableActions)
        }
        self.volumeLayer.frame = CGRect(x: 0, y: newY, width: self.layer.bounds.width, height: newHeight)
        if !animated {
            CATransaction.commit()
        }
        
        if (volume == 0) {
            if self.currentSpeakerImage != .off {
                self.currentSpeakerImage = .off
                self.speakerImgView.image = self.currentSpeakerImage.image()
            }
        } else if (volume <= 1/3) {
            if self.currentSpeakerImage != .low {
                self.currentSpeakerImage = .low
                self.speakerImgView.image = self.currentSpeakerImage.image()
            }
        } else if (volume <= 2/3) {
            if self.currentSpeakerImage != .mid {
                self.currentSpeakerImage = .mid
                self.speakerImgView.image = self.currentSpeakerImage.image()
            }
        } else {
            if self.currentSpeakerImage != .high {
                self.currentSpeakerImage = .high
                self.speakerImgView.image = self.currentSpeakerImage.image()
            }
        }
        
        self.delegate?.didChange(volume: volume)
    }
    
    
    // MARK: Handle Gestures
    @objc private func panRecognized(_ sender: UIPanGestureRecognizer){
        if sender.state == .began || sender.state == .changed {
            let newVolume = max(0, min(1.0 - sender.location(in: self).y/self.bounds.height, 1))
            self.isChanging = true
            self.updateLevel(newVolume, animated: false)
        } else {
            self.isChanging = false
            UIView.animate(withDuration: 0.2) {
                self.transform = CGAffineTransform.identity
            }
        }
    }
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)
        /*if touches.count == 1 && touches.first!.force/touches.first!.maximumPossibleForce > 0.5 && !self.touchWasForceTouch {
         self.touchWasForceTouch = true
         let gen = UIImpactFeedbackGenerator(style: .medium)
         gen.impactOccurred()
         } else {*/
        UIView.animate(withDuration: 0.2) {
            self.transform = CGAffineTransform(scaleX: 1.1, y: 1.1)
        }
        //        }
    }
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesMoved(touches, with: event)
        /*if touches.count == 1 && touches.first!.force/touches.first!.maximumPossibleForce > 0.5 && !touchWasForceTouch {
         self.touchWasForceTouch = false
         let gen = UIImpactFeedbackGenerator(style: .medium)
         gen.impactOccurred()
         }*/
    }
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesEnded(touches, with: event)
        /*if touchWasForceTouch {
         self.touchWasForceTouch = false
         let gen = UIImpactFeedbackGenerator(style: .medium)
         gen.impactOccurred()
         }*/
        UIView.animate(withDuration: 0.2) {
            self.transform = .identity
        }
    }
    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesCancelled(touches, with: event)
        
        if !isChanging {
            /*if touchWasForceTouch {
             self.touchWasForceTouch = false
             let gen = UIImpactFeedbackGenerator(style: .medium)
             gen.impactOccurred()
             }*/
            UIView.animate(withDuration: 0.2) {
                self.transform = .identity
            }
        }
    }
}
