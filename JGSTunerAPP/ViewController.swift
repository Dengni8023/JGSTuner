//
//  ViewController.swift
//  JGSTunerDemo
//
//  Created by 梅继高 on 2023/6/28.
//  Copyright © 2023 MeiJigao. All rights reserved.
//

import UIKit
import JGSTuner
import JGSourceBase

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        title = "Demo-Swift"
        view.backgroundColor = UIColor(white: 0.99, alpha: 1.0)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        JGSEnableLogWithMode(.func)
        navigationController?.navigationBar.tintColor = .white
        navigationController?.navigationBar.barTintColor = JGSColorHex(0x4B73F1)
        navigationController?.navigationBar.titleTextAttributes = [
            NSAttributedString.Key.foregroundColor: UIColor.white
        ]
        navigationController?.navigationBar.shadowImage = UIImage()
        
        if #available(iOS 15.0, *) {
            // NavigationBar
            let navBarAppearance = UINavigationBarAppearance()
            navBarAppearance.backgroundColor = JGSColorHex(0x4B73F1)
            navBarAppearance.titleTextAttributes = navigationController?.navigationBar.titleTextAttributes ?? [:]
            navBarAppearance.backgroundEffect = nil
            navBarAppearance.shadowColor = .clear
            navBarAppearance.shadowImage = navigationController?.navigationBar.shadowImage ?? UIImage()
            
            navigationController?.navigationBar.scrollEdgeAppearance = navBarAppearance;
            navigationController?.navigationBar.standardAppearance = navBarAppearance;
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        if tuner.didReceiveAudio {
            tuner.stop()
        }
    }
    
    // MARK: - Tuner
    private lazy var tuner = JGSTuner() { [weak self] in
        
        let microDesc = Bundle.main.object(forInfoDictionaryKey: "NSMicrophoneUsageDescription") as? String
        let alert = UIAlertController(title: microDesc, message: "请在 设置 -> 隐私与安全 -> 麦克风 设置中允许本应用使用麦克风，以采集音频输入信号。", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "知道了", style: .cancel))
        alert.addAction(UIAlertAction(title: "去设置", style: .default) { _ in
            UIApplication.shared.open(URL(string: UIApplication.openSettingsURLString)!)
        })
        self?.present(alert, animated: true)
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        
        if tuner.didReceiveAudio {
            tuner.stop()
        } else {
            Task { [weak self] in
                guard let `self` = self else { return }
                
                let success = await self.tuner.start(amplitudeThreshold: 0.025, standardA4Frequency: 440.0, analyzeCallback: { frequency, amplitude, names, octave, distance, standardFrequency in
                    JGSLog(frequency, amplitude, names.joined(separator: "/"), octave, distance, standardFrequency)
                })
                JGSLog("Start", success ? "success" : "fail")
            }
        }
    }
}

class NavigationController: UINavigationController {
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        navigationBar.tintColor = JGSColorHex(0x4B73F1)
        navigationBar.barTintColor = .white
        navigationBar.titleTextAttributes = [
            NSAttributedString.Key.foregroundColor: UIColor.white
        ]
        navigationBar.shadowImage = UIImage()
    }
}
