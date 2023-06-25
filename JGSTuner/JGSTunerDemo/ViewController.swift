//
//  ViewController.swift
//  JGSTunerDemo
//
//  Created by 梅继高 on 2023/5/31.
//

import UIKit
import JGSTuner
import SwiftUI

class ViewController: UIViewController {
    
    private lazy var tunnerPitcher = JGSTunnerPicher { (buffer, time) in
        print("\(#function), Line: \(#line) buffer: \(buffer.frameLength), \(buffer.frameCapacity), time: \(time.sampleRate) \(time.sampleTime)")
    } microphoneAccessAlert: { [weak self] in
        
        let alert = UIAlertController(title: "提示", message: """
                            Please grant microphone access in the Settings app in the "Privacy ⇾ Microphone" section.
        """, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "确定", style: .cancel))
        alert.addAction(UIAlertAction(title: "去设置", style: .default) { _ in
            UIApplication.shared.open(URL(string: UIApplication.openSettingsURLString)!)
        })
        self?.present(alert, animated: true)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        
        if tunnerPitcher.didReceiveAudio {
            tunnerPitcher.stop()
        } else {
            Task { [weak self] in
                await self?.tunnerPitcher.start(debug: true)
            }
        }
    }
}

