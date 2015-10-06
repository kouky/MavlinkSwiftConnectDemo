//
//  MavlinkController.swift
//  MavlinkSwiftConnectDemo
//
//  Created by Michael Koukoullis on 5/10/2015.
//  Copyright © 2015 Michael Koukoullis. All rights reserved.
//

import Cocoa
import ORSSerial

class MavlinkController: NSObject, ORSSerialPortDelegate {

    let serialPortManager = ORSSerialPortManager.sharedSerialPortManager()
	
    var serialPort: ORSSerialPort? {
        didSet {
            oldValue?.close()
            oldValue?.delegate = nil
            serialPort?.delegate = self
        }
    }
	
    @IBOutlet weak var openCloseButton: NSButton!

    // MARK: Actions

    @IBAction func openOrClosePort(sender: AnyObject) {
        if let port = serialPort {
            if (port.open) {
                port.close()
            }
            else {
    			port.baudRate = 57600
    			port.numberOfStopBits = 1
    			port.parity = .None
                port.open()
    			if let data = "mavlink start -d /dev/ttyACM0\n".dataUsingEncoding(NSUTF32LittleEndianStringEncoding) {
    				port.sendData(data)
    			}
            }
        }
    }

    // MARK: ORSSerialPortDelegate Protocol

    func serialPortWasOpened(serialPort: ORSSerialPort) {
        self.openCloseButton.title = "Close"
    }
    
    func serialPortWasClosed(serialPort: ORSSerialPort) {
        self.openCloseButton.title = "Open"
    }
    
    func serialPortWasRemovedFromSystem(serialPort: ORSSerialPort) {
        self.serialPort = nil
        self.openCloseButton.title = "Open"
    }
}
