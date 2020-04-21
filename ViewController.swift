//
//  ViewController.swift
//  Nahulog
//
//  Created by LS on 6/25/17.
//  Copyright © 2017 Gowi Apps. All rights reserved.
//

import UIKit
import AVFoundation
import CoreMotion
import os.log

class ViewController: UIViewController {

    let _motion = CMMotionManager()
    var _taskId:UIBackgroundTaskIdentifier?
    var _audioPlayer:AVAudioPlayer?
    
    var _isDropped:Bool = false
    
    var _timer:Timer? = nil
    var _isTimerFired:Bool = false
    
    func timerFireMethod(_:Timer){
//        os_log("FIRE TIMER")
        self._isTimerFired = true
    }
    
    func startDropDetector(){
        
        if(_motion.isAccelerometerAvailable){
            
            _motion.accelerometerUpdateInterval = 0.005
            
            _motion.startAccelerometerUpdates(to: OperationQueue.main, withHandler: { data, error in
                
                let x = Int(fabs((data?.acceleration.x)!))
                let y = Int(fabs((data?.acceleration.y)!))
                let z = Int(fabs((data?.acceleration.z)!))
                
                if(!self._isDropped){
                    
                    if((x|y|z) >= 4){
                        self.startPlayer()
                        self.startTimer()
                        self._isDropped = true
                    }
                    
                }else if(self._isDropped){
                    
                    if((x|y|z) >= 2 && self._isTimerFired){
                        self.stopPlayer()
                        self.stopTimer()
                        self._isDropped = false
                    }
                    
                }
            })
        }
    }
    
    func stopDropDetector(){
        if(_motion.isAccelerometerActive){
            _motion.stopAccelerometerUpdates()
        }
    }
    
    func startTimer(){

        if(self._timer == nil){
//            os_log("INIT TIMER")
            self._timer = Timer.init(fireAt: Date.init(timeIntervalSinceNow: 3), interval: 2, target: self, selector: #selector(timerFireMethod(_:)), userInfo: nil, repeats: false)
            RunLoop.main.add(self._timer!, forMode: RunLoopMode.defaultRunLoopMode)
        }
        
//        os_log("START TIMER")

        if(self._isTimerFired){ return }
        
    }
    
    func stopTimer(){
//        os_log("STOP TIMER")

        self._isTimerFired = false
        self._timer = nil
    }
    
    func startPlayer(){
        
        if(self._audioPlayer == nil)
        {
            let url = URL(fileURLWithPath: "mahulog_apple.aiff", relativeTo: Bundle.main.bundleURL)
            
            do{
                self._audioPlayer = try AVAudioPlayer(contentsOf: url)
            }catch{
                
            }
        }
        
        guard let audioPlayer = self._audioPlayer else { return }
        
        if(!audioPlayer.isPlaying){
            audioPlayer.prepareToPlay()
            audioPlayer.play()
        }
    }
    
    func stopPlayer(){
        guard let audioPlayer = self._audioPlayer else { return }
        
        if(audioPlayer.isPlaying){
            audioPlayer.stop()
            audioPlayer.currentTime = 0
        }
    }
    
    func startRunOnBackground(){
        
        _taskId = UIApplication.shared.beginBackgroundTask {
            
        }
    }
    
    func stopRunOnBackground(){
        
        guard _taskId != nil else { return }
        
        UIApplication.shared.endBackgroundTask(_taskId!)
    }
    
    func buttonControl(){
        stopPlayer()
        stopDropDetector()
        startDropDetector()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let button:UIButton = self.view.viewWithTag(36) as! UIButton
        button.addTarget(self, action: #selector(ViewController.buttonControl), for: UIControlEvents.touchDown)
        
        startDropDetector();
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }


}

