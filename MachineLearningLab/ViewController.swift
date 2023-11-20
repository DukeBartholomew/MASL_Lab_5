//
//  ViewController.swift
//  MachineLearningLab
//
//  Created by Duke Bartholomew on 11/15/23.
//

import UIKit

class ViewController: UIViewController, URLSessionDelegate {
    
    
    
    // MARK: Class Properties
    lazy var session: URLSession = {
        let sessionConfig = URLSessionConfiguration.ephemeral
        
        sessionConfig.timeoutIntervalForRequest = 5.0
        sessionConfig.timeoutIntervalForResource = 8.0
        sessionConfig.httpMaximumConnectionsPerHost = 1
        
        return URLSession(configuration: sessionConfig,
                          delegate: self,
                          delegateQueue:self.operationQueue)
    }()
    let operationQueue = OperationQueue()
    
    
    @IBOutlet weak var goodbyeButton: UIButton!
    @IBOutlet weak var adiosButton: UIButton!
    @IBOutlet weak var sayonaraButton: UIButton!
    @IBOutlet weak var aurevoirButton: UIButton!
    @IBOutlet weak var ciaoButton: UIButton!
    @IBOutlet weak var trainButton: UIButton!
    @IBOutlet weak var bothModelPredictions: UILabel!
    @IBOutlet weak var finalPrediction: UILabel!
    @IBOutlet weak var predictButton: UIButton!
    
    struct AudioConstants{
        static let AUDIO_BUFFER_SIZE = 1024*4
    }
    // setup audio model
    let audio = AudioModel(buffer_size: AudioConstants.AUDIO_BUFFER_SIZE)
    let server = ServerModel()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        // Add targets for the button events
        self.goodbyeButton.addTarget(self, action: #selector(buttonTouchDown), for: .touchDown)
        self.goodbyeButton.addTarget(self, action: #selector(buttonTouchUpInside), for: .touchUpInside)
        
        self.adiosButton.addTarget(self, action: #selector(buttonTouchDown), for: .touchDown)
        self.adiosButton.addTarget(self, action: #selector(buttonTouchUpInside), for: .touchUpInside)
        
        self.sayonaraButton.addTarget(self, action: #selector(buttonTouchDown), for: .touchDown)
        self.sayonaraButton.addTarget(self, action: #selector(buttonTouchUpInside), for: .touchUpInside)
        
        self.aurevoirButton.addTarget(self, action: #selector(buttonTouchDown), for: .touchDown)
        self.aurevoirButton.addTarget(self, action: #selector(buttonTouchUpInside), for: .touchUpInside)
        
        self.ciaoButton.addTarget(self, action: #selector(buttonTouchDown), for: .touchDown)
        self.ciaoButton.addTarget(self, action: #selector(buttonTouchUpInside), for: .touchUpInside)
        
        self.predictButton.addTarget(self, action: #selector(predicitonButtonTouchDown), for: .touchDown)
        self.predictButton.addTarget(self, action: #selector(predictButtonTouchUp), for: .touchUpInside)
        
        self.trainButton.addTarget(self, action: #selector(trainButtonTouchDown), for: .touchDown)
        
        
        
    }
    
    @objc func trainButtonTouchDown(_ sender: UIButton){
        self.server.trainModels { [weak self] accuracy in
            DispatchQueue.main.async {
                // Replace commas with newlines
                let formattedAccuracy = accuracy.replacingOccurrences(of: ",", with: "\n")
                
                // Create a substring excluding the first and last character
                let startIndex = formattedAccuracy.index(formattedAccuracy.startIndex, offsetBy: 1)
                let endIndex = formattedAccuracy.index(formattedAccuracy.endIndex, offsetBy: -1)
                let trimmedAccuracy = String(formattedAccuracy[startIndex..<endIndex])
                
                self?.bothModelPredictions.text = trimmedAccuracy
            }
        }
    }
    
    
    @objc func buttonTouchDown(_ sender: UIButton) {
        // Button is being held down (touch down), change background color to red
        //set up audio model
        self.audio.play()
        self.audio.startMicrophoneProcessing(withFps: 20) // preferred number of FFT calculations per second
        print("ON \(sender.titleLabel?.text ?? "")")
    }
    
    @objc func predicitonButtonTouchDown(_ sender: UIButton) {
        // Button is being held down (touch down), change background color to red
        //set up audio model
        self.audio.play()
        self.audio.startMicrophoneProcessing(withFps: 20) // preferred number of FFT calculations per second
        self.finalPrediction.text = "Listening..."
        print("ON \(sender.titleLabel?.text ?? "")")
    }
    
    @objc func buttonTouchUpInside(_ sender: UIButton) {
        // Button is released (touch up), change background color back to normal
        print("OFF \(sender.titleLabel?.text ?? "")")
        self.audio.pause()
        self.server.sendPostRequest(fftData: self.audio.fftData, languageLabel: sender.titleLabel?.text ?? "")
        
    }
    
    @objc func predictButtonTouchUp(_ sender: UIButton){
        //        self.server.sendPredictionRequest(fftData: self.audio.fftData)
        //        finalPrediction.text = self.server.predictionLabel
        self.server.sendPredictionRequest(fftData: self.audio.fftData) { [weak self] finalPrediction in
            DispatchQueue.main.async {
                let startIndex = finalPrediction.index(finalPrediction.startIndex, offsetBy: 2)
                let endIndex = finalPrediction.index(finalPrediction.endIndex, offsetBy: -2)
                let trimmedPrediction = String(finalPrediction[startIndex..<endIndex])
                
                self?.finalPrediction.text = trimmedPrediction
            }
        }
        
        
        
        
        
        
        
        
        
        
    }
}
