//
//  ZVAudioManager.swift
//  Muse Zenvironment
//
//  Created by Evan Teters on 4/23/19.
//  Copyright © 2019 Evan Teters. All rights reserved.
//

import Foundation
import AVFoundation

class ZVAudioManager {
    var audioPlayer = AVAudioPlayer()
    let audioMix = AVAudioMix()
    
    let audioCollection = [Bundle.main.path(forResource: "1) Rain - medium thunder", ofType: "mp3"),
                           Bundle.main.path(forResource: "2) Rain - gentle thunder", ofType: "mp3"),
                           Bundle.main.path(forResource: "3) Rain - occasional thunder", ofType: "mp3"),
                           Bundle.main.path(forResource: "4) Rain - on trees", ofType: "mp3"),
                           Bundle.main.path(forResource: "5) Waves - loud", ofType: "mp3"),
                           Bundle.main.path(forResource: "6) Waves - med", ofType: "mp3"),
                           Bundle.main.path(forResource: "7) Nature - waterfall", ofType: "mp3"),
                           Bundle.main.path(forResource: "8) Nature - wind, cicadas", ofType: "mp3"),
                           Bundle.main.path(forResource: "9) Nature - birds, chimes", ofType: "mp3"),
                           Bundle.main.path(forResource: "10) Nature - birds, occasional insects", ofType: "mp3"),
                           Bundle.main.path(forResource: "11) Nature - birds only", ofType: "mp3")]
    
    var playerCollection:[AVAudioPlayer]!
    
    
    func startAudioSession()  {
        
        playerCollection = audioCollection.map { (pathString) -> AVAudioPlayer in
            do {
                return try AVAudioPlayer(contentsOf: URL(fileURLWithPath: pathString!))
            }
            catch {
                print(error)
                return AVAudioPlayer()
            }
        }
    }
    
    func updateWhatShouldPlay(value:Double) {
        switch value {
        case 0.9..<1.01:
            let index = 10
            playSoundsBefore(startIndex: index)
            stopSoundsAfter(stopIndex: index)
        case 0.8..<0.89:
            let index = 8
            playSoundsBefore(startIndex: index)
            stopSoundsAfter(stopIndex: index)
        case 0.7..<0.79:
            let index = 7
            playSoundsBefore(startIndex: index)
            stopSoundsAfter(stopIndex: index)
        case 0.6..<0.69:
            let index = 6
            playSoundsBefore(startIndex: index)
            stopSoundsAfter(stopIndex: index)
        case 0.5..<0.59:
            let index = 5
            playSoundsBefore(startIndex: index)
            stopSoundsAfter(stopIndex: index)
        case 0.4..<0.49:
            let index = 4
            playSoundsBefore(startIndex: index)
            stopSoundsAfter(stopIndex: index)
        case 0.3..<0.39:
            let index = 3
            playSoundsBefore(startIndex: index)
            stopSoundsAfter(stopIndex: index)
        case 0.2..<0.29:
            let index = 2
            playSoundsBefore(startIndex: index)
            stopSoundsAfter(stopIndex: index)
        case 0.1..<0.19:
            let index = 1
            playSoundsBefore(startIndex: index)
            stopSoundsAfter(stopIndex: index)
        case 0..<0.09:
            let index = 0
            playSoundsBefore(startIndex: index)
            stopSoundsAfter(stopIndex: index)
        default:
            return
        }
    }
    
    private func stopSoundsAfter(stopIndex:Int) {
        var currentIndex = 10
        while (stopIndex != currentIndex) {
            playerCollection[currentIndex].setVolume(0, fadeDuration: 1)
            currentIndex = currentIndex-1
        }
    }
    private func playSoundsBefore(startIndex:Int){
        var currentIndex = startIndex
        while (currentIndex >= 0) {
            if !playerCollection[currentIndex].isPlaying {
                playerCollection[currentIndex].play()
                print(playerCollection[currentIndex].volume)
            }
            else{
                playerCollection[currentIndex].setVolume(1, fadeDuration: 0.5)
            }
            currentIndex = playerCollection.index(before: currentIndex)
        }
    }
}
