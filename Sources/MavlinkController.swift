//
//  MavlinkController.swift
//  MavlinkSwiftConnectDemo
//
//  Created by Michael Koukoullis on 5/10/2015.
//  Copyright © 2015 Michael Koukoullis. All rights reserved.
//

import Cocoa
import ORSSerial
import Mavlink

class MavlinkController: NSObject {

    // MARK: Stored Properties
    
    let serialPortManager = ORSSerialPortManager.sharedSerialPortManager()
	
    var serialPort: ORSSerialPort? {
        didSet {
            oldValue?.close()
            oldValue?.delegate = nil
            serialPort?.delegate = self
            serialPort?.baudRate = 57600
            serialPort?.numberOfStopBits = 1
            serialPort?.parity = .None
        }
    }
    
    // MARK: IBOutlets
	
    @IBOutlet weak var openCloseButton: NSButton!
    @IBOutlet weak var usbRadioButton: NSButton!
    @IBOutlet weak var telemetryRadioButton: NSButton!
    @IBOutlet var receivedMessageTextView: NSTextView!
    @IBOutlet weak var clearTextViewButton: NSButton!
   
    // MARK: Initializers
    
    override init() {
        super.init()
        
        let notificationCenter = NSNotificationCenter.defaultCenter()
        notificationCenter.addObserver(self, selector: "serialPortsWereConnected:", name: ORSSerialPortsWereConnectedNotification, object: nil)
        notificationCenter.addObserver(self, selector: "serialPortsWereDisconnected:", name: ORSSerialPortsWereDisconnectedNotification, object: nil)
        
        NSUserNotificationCenter.defaultUserNotificationCenter().delegate = self
    }
    
    deinit {
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }

    // MARK: - Actions

    @IBAction func openOrClosePort(sender: AnyObject) {
        guard let port = serialPort else {
            return
        }
        
        if port.open {
            port.close()
        }
        else {
            clearTextView(self)
            port.open()
            
            if usbRadioButton.state != 0 {
                startUsbMavlinkSession()
            }
        }
    }
    
    func startUsbMavlinkSession() {
        guard let port = self.serialPort where port.open else {
            print("Serial port is not open")
            return
        }
        
        guard let data = "mavlink start -d /dev/ttyACM0\n".dataUsingEncoding(NSUTF32LittleEndianStringEncoding) else {
            print("Cannot create mavlink USB start command")
            return
        }
        
        port.sendData(data)
    }
    
    @IBAction func clearTextView(sender: AnyObject) {
        self.receivedMessageTextView.textStorage?.mutableString.setString("")
    }
    
    @IBAction func radioButtonSelected(sender: AnyObject) {
        // No-op - required to make radio buttons behave as a group
    }

    // MARK: - ORSSerialPortDelegate Protocol

    // MARK: - Mavlink Message Decoding
    
    func descriptionForMavlinkMessage(var message: mavlink_message_t) -> String {
        var description: String
        switch message.msgid {
        case 0:
            var heartbeat = mavlink_heartbeat_t()
            mavlink_msg_heartbeat_decode(&message, &heartbeat);
            description = "HEARTBEAT mavlink_version: \(heartbeat.mavlink_version)"
        case 1:
            var sys_status = mavlink_sys_status_t()
            mavlink_msg_sys_status_decode(&message, &sys_status)
            description = "SYS_STATUS comms drop rate: \(sys_status.drop_rate_comm)%"
        case 30:
            var attitude = mavlink_attitude_t()
            mavlink_msg_attitude_decode(&message, &attitude)
            description = "ATTITUDE roll: \(attitude.roll) pitch: \(attitude.pitch) yaw: \(attitude.yaw)"
        case 32:
            description = "LOCAL_POSITION_NED"
        case 33:
            description = "GLOBAL_POSITION_INT"
        case 74:
            var vfr_hud = mavlink_vfr_hud_t()
            mavlink_msg_vfr_hud_decode(&message, &vfr_hud)
            description = "VFR_HUD heading: \(vfr_hud.heading) degrees"
        case 87:
            description = "POSITION_TARGET_GLOBAL_INT:"
        case 105:
            var highres_imu = mavlink_highres_imu_t()
            mavlink_msg_highres_imu_decode(&message, &highres_imu)
            description = "HIGHRES_IMU Pressure: \(highres_imu.abs_pressure) millibar"
        case 147:
            var battery_status = mavlink_battery_status_t()
            mavlink_msg_battery_status_decode(&message, &battery_status)
            description = "BATTERY_STATUS current consumed: \(battery_status.current_consumed) mAh"
        default:
            description = "OTHER Message id \(message.msgid) received"
        }
        
        return "\(description)\n"
    }
    
    // MARK: - Notifications
    
    func serialPortsWereConnected(notification: NSNotification) {
        if let userInfo = notification.userInfo {
            let connectedPorts = userInfo[ORSConnectedSerialPortsKey] as! [ORSSerialPort]
            print("Ports were connected: \(connectedPorts)")
            postUserNotificationForConnectedPorts(connectedPorts)
        }
    }
    
    func serialPortsWereDisconnected(notification: NSNotification) {
        if let userInfo = notification.userInfo {
            let disconnectedPorts: [ORSSerialPort] = userInfo[ORSDisconnectedSerialPortsKey] as! [ORSSerialPort]
            print("Ports were disconnected: \(disconnectedPorts)")
            postUserNotificationForDisconnectedPorts(disconnectedPorts)
        }
    }
    
    func postUserNotificationForConnectedPorts(connectedPorts: [ORSSerialPort]) {
        let unc = NSUserNotificationCenter.defaultUserNotificationCenter()
        for port in connectedPorts {
            let userNote = NSUserNotification()
            userNote.title = NSLocalizedString("Serial Port Connected", comment: "Serial Port Connected")
            userNote.informativeText = "Serial Port \(port.name) was connected to your Mac."
            userNote.soundName = nil;
            unc.deliverNotification(userNote)
        }
    }
    
    func postUserNotificationForDisconnectedPorts(disconnectedPorts: [ORSSerialPort]) {
        let unc = NSUserNotificationCenter.defaultUserNotificationCenter()
        for port in disconnectedPorts {
            let userNote = NSUserNotification()
            userNote.title = NSLocalizedString("Serial Port Disconnected", comment: "Serial Port Disconnected")
            userNote.informativeText = "Serial Port \(port.name) was disconnected from your Mac."
            userNote.soundName = nil;
            unc.deliverNotification(userNote)
        }
    }
}

extension MavlinkController: ORSSerialPortDelegate {
    
    func serialPortWasOpened(serialPort: ORSSerialPort) {
        openCloseButton.title = "Close"
    }
    
    func serialPortWasClosed(serialPort: ORSSerialPort) {
        openCloseButton.title = "Open"
    }
    
    func serialPortWasRemovedFromSystem(serialPort: ORSSerialPort) {
        self.serialPort = nil
        self.openCloseButton.title = "Open"
    }
    
    func serialPort(serialPort: ORSSerialPort, didReceiveData data: NSData) {
        var bytes = [UInt8](count: data.length, repeatedValue: 0)
        data.getBytes(&bytes, length: data.length)
        
        for byte in bytes {
            var message = mavlink_message_t()
            var status = mavlink_status_t()
            let channel = UInt8(MAVLINK_COMM_1.rawValue)
            if mavlink_parse_char(channel, byte, &message, &status) != 0 {
                let messageDescription = descriptionForMavlinkMessage(message)
                receivedMessageTextView.textStorage?.mutableString.appendString(messageDescription)
                receivedMessageTextView.needsDisplay = true
            }
        }
    }
    
    func serialPort(serialPort: ORSSerialPort, didEncounterError error: NSError) {
        print("SerialPort \(serialPort.name) encountered an error: \(error)")
    }
}

extension MavlinkController: NSUserNotificationCenterDelegate {
    
    func userNotificationCenter(center: NSUserNotificationCenter, didDeliverNotification notification: NSUserNotification) {
        let popTime = dispatch_time(DISPATCH_TIME_NOW, Int64(3.0 * Double(NSEC_PER_SEC)))
        dispatch_after(popTime, dispatch_get_main_queue()) { () -> Void in
            center.removeDeliveredNotification(notification)
        }
    }
    
    func userNotificationCenter(center: NSUserNotificationCenter, shouldPresentNotification notification: NSUserNotification) -> Bool {
        return true
    }
}
