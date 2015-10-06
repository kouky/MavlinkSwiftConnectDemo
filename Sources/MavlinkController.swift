//
//  MavlinkController.swift
//  MavlinkSwiftConnectDemo
//
//  Created by Michael Koukoullis on 5/10/2015.
//  Copyright © 2015 Michael Koukoullis. All rights reserved.
//

import Cocoa
import ORSSerial

class MavlinkController: NSObject {
	
	let serialPortManager = ORSSerialPortManager.sharedSerialPortManager()
	
	@IBOutlet weak var openCloseButton: NSButton!
	
	// MARK: Actions
	
	@IBAction func openOrClosePort(sender: AnyObject) {
		print("Button press")
	}
}
