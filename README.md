# MavlinkSwiftConnectDemo

## Getting Started

Follow these steps after cloning the repository to get the Mac app running.

Initialize and update git submodules.

    git submodule update --init

Build the [ORSSerialPort](https://github.com/armadsen/ORSSerialPort) framework dependency.

    carthage build

If you don't have the [Carthage](https://github.com/Carthage/Carthage) dependency manager it can be installed with [Homebrew](http://brew.sh).

    brew install carthage

Build and run the demo using Xcode 7 or above.

## Contributions

Pull requests are always welcome!

[![GitHub License Badge](https://img.shields.io/badge/license-MIT-blue.svg)](https://raw.githubusercontent.com/kouky/MavlinkSwiftConnectDemo/master/LICENSE)
