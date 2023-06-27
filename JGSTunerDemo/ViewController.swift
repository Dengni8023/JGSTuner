//
//  ViewController.swift
//  JGSTunerDemo
//
//  Created by 梅继高 on 2023/6/26.
//

import UIKit
import SwiftUI
import JGSTuner
import JGSourceBase

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        title = "Demo-Swift"
        view.backgroundColor = UIColor(white: 0.99, alpha: 1.0)
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "OCEntry", style: .plain, target: self, action: #selector(toOCEntry(sender:)))
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        navigationController?.navigationBar.tintColor = .white
        navigationController?.navigationBar.barTintColor = JGSColor(0x4B73F1)
        navigationController?.navigationBar.titleTextAttributes = [
            NSAttributedString.Key.foregroundColor: UIColor.white
        ]
        navigationController?.navigationBar.shadowImage = UIImage()
        
        if #available(iOS 15.0, *) {
            // NavigationBar
            let navBarAppearance = UINavigationBarAppearance()
            navBarAppearance.backgroundColor = JGSColor(0x4B73F1)
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
    
    @objc private func toOCEntry(sender: UIBarButtonItem) {
        
        navigationController?.pushViewController(OCViewController(), animated: true)
    }
    
    // MARK: - Tuner
    private lazy var tuner = JGSTuner { [weak self] in
        
        let alert = UIAlertController(title: "提示", message: """
                            Please grant microphone access in the Settings app in the "Privacy ⇾ Microphone" section.
        """, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "确定", style: .cancel))
        alert.addAction(UIAlertAction(title: "去设置", style: .default) { _ in
            UIApplication.shared.open(URL(string: UIApplication.openSettingsURLString)!)
        })
        self?.present(alert, animated: true)
    } analyzeCallback: { [weak self] (frequency, amplitude) in
        JGSLog(frequency, amplitude)
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        
        if tuner.didReceiveAudio {
            tuner.stop()
        } else {
            Task { [weak self] in
                await self?.tuner.start()
            }
        }
    }
}

class NavigationController: UINavigationController {
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        navigationBar.tintColor = JGSColor(0x4B73F1)
        navigationBar.barTintColor = .white
        navigationBar.titleTextAttributes = [
            NSAttributedString.Key.foregroundColor: UIColor.white
        ]
        navigationBar.shadowImage = UIImage()
    }
}
