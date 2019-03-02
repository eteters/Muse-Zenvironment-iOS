//
//  HeabandReceiver.swift
//  Muse Zenvironment
//
//  Created by Evan Teters on 1/30/19.
//  Copyright © 2019 Evan Teters. All rights reserved.
//

import Foundation
import UIKit

protocol HeadbandReceiverDelegate: class {
    func receivedMessage(message: HeadbandMessage)
    func messageError(errorString: String)
}


class HeadbandReceiver: NSObject {
    var inputStream: InputStream!
    var outputStream: OutputStream!
    let maxReadLength = 4096

    weak var delegate:HeadbandReceiverDelegate? //why weak?
    
    func setupNetworkConnection() {
        //why unmanaged?
        var readStream: Unmanaged<CFReadStream>?
        var writeStream: Unmanaged<CFWriteStream>?

        CFStreamCreatePairWithSocketToHost(kCFAllocatorDefault, "localhost" as CFString, 8080, &readStream, &writeStream)

        inputStream = readStream!.takeRetainedValue()
        outputStream = writeStream!.takeRetainedValue()
        
        inputStream.delegate = self
        outputStream.delegate = self
        
        inputStream.schedule(in: .current, forMode: .common )
        inputStream.open()

    }
}

extension HeadbandReceiver: StreamDelegate {
 
    func stream(_ aStream: Stream, handle eventCode: Stream.Event) {
        switch eventCode {
        case Stream.Event.hasBytesAvailable:
            print("new message received")
            readAvailableBytes(stream: aStream as! InputStream)
        case Stream.Event.endEncountered:
            print("new message received")
            //not sure what case this is, end of connection? If so, needs .messageError
        case Stream.Event.errorOccurred:
            print("error occurred")
            delegate?.messageError(errorString: "Stream error occurred")
        case Stream.Event.hasSpaceAvailable:
            print("has space available")
        default:
            print("some other event...")
            delegate?.messageError(errorString: "Stream error occurred")
            break
        }
    }
    
    private func readAvailableBytes(stream: InputStream) {
        let buffer = UnsafeMutablePointer<UInt8>.allocate(capacity:maxReadLength)
        
        while stream.hasBytesAvailable {
            let numberOfBytesRead = inputStream.read(buffer, maxLength: maxReadLength)
            
            if numberOfBytesRead < 0 {
                if let _ = stream.streamError{
                    print("stream error?")
                    delegate?.messageError(errorString: "Stream error occurred")
                    break
                }
            }
            if let message = processedHeadbandMessage(buffer: buffer, length: numberOfBytesRead){
                print(message)
                delegate?.receivedMessage(message: message)
            }
            else {
                print("error!")
                delegate?.messageError(errorString: "Stream error occurred")
            }
        }
    }
    
    private func processedHeadbandMessage(buffer: UnsafeMutablePointer<UInt8>, length: Int) -> HeadbandMessage? {
        //                guard let responseObject = try? JSONDecoder().decode(HeadbandMessage, from: buffer)
        //TODO: This two step process may not need to be this complicated ie one step
        guard
            let stringArray = String(bytesNoCopy: buffer,
                                       length: length,
                                       encoding: .ascii,
                                       freeWhenDone: true)
        else {
            return nil
        }
        
        print(stringArray)
        
        guard
            let data = stringArray.data(using: String.Encoding.utf8),
            let messageObject = try? JSONDecoder().decode(HeadbandMessage.self, from: data )
        else{
            print("could not convert string message into message object")
            delegate?.messageError(errorString: "could not convert string message into message object")
            return nil
        }
        
        return messageObject
    }

}
