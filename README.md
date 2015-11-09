# MavlinkSwiftConnectDemo

Demonstrates how to decode [MAVLink](http://qgroundcontrol.org/mavlink/start) messages using a Swift based Xcode project. This is of interest if you’re attempting to write your own ground control station software for the Mac (or iOS).

![Screenshot](http://kouky.org/assets/mavlink-connect/mavlink-connect.png)

For a more detailed discussion please refer to my blog post, *[Decoding MAVLink Messages with Swift](http://kouky.org/blog/2015/11/09/decoding-mavlink-messages-with-swift.html)*.

## Getting Started

Follow these steps after cloning the repository to get the Mac app running.

Initialize and update git submodules.

    git submodule update --init

Build the [ORSSerialPort](https://github.com/armadsen/ORSSerialPort) framework dependency.

    carthage build

If you don't have the [Carthage](https://github.com/Carthage/Carthage) dependency manager it can be installed with [Homebrew](http://brew.sh).

    brew install carthage

Build and run the demo using Xcode 7 or above.

## Notes when using application with Pixhawk

The sample project is only tested with an authentic 3DR Pixhawk running PX4 firmware.

Communication with 3DR bluetooth and radio telemetry requires a connection to telemetry port 1.

## Contributions

Pull requests are always welcome!

[![GitHub License Badge](https://img.shields.io/badge/license-MIT-blue.svg)](https://raw.githubusercontent.com/kouky/MavlinkSwiftConnectDemo/master/LICENSE)
