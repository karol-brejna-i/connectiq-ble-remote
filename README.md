# Garmin Connect IQ SDK BLE LED Control Project

This repository hosts a basic project that is an outcome of my own learning and experiments with programming Bluetooth Low Energy (BLE) communication on Garmin Watch, specifically using Fenix 7 and Fenix 5 Plus.

This project demonstrates how to use a Garmin watch to control an external BLE device (ESP32) and change its LED color.

In other words:
- the project assumes that there is working BLE device (server) that is able to accept data written to the exposed service/characteristics. The external device controls embedded LED and switches its state ("0" - turn off, "1", "2", "3" - Red, Green, Blue),
- the user can start scanning process during which the watch detects BLE devices in range and tries to connect to selected ESP32 device,
- when connection is establihsed, the user -- by pressing SELECT button -- sends commands to the remote device.

This project is intended for newbie Garmin developers, to help them quickly grasp basics of BLE communication with Connect IQ SDK.

## Overview

This project provides a fundamental BLE-based feature: the ability to connect to the ESP32 (with Garmin watch) and remotely change the built-in LED color. While this is a basic functionality, it covers the essential steps required for BLE communication on the ESP32, allowing you to:

-   Set up a basic BLE client on Garmin Watch
-   Manage connections state with BLE server (BLE-enabled device)
-   Send commands to the BLE server


I own **Fenix 7** and **Fenix 5 Plus** devices, so I was able to experiment with BLE communication on those devices only. From my experience, running BLE apps on the actual device is quite a different experience than running the same program in the simulator.

> Note: This repository focuses on implementation rather than BLE theory. Please refer to external resources if you need a primer on BLE fundamentals. Understanding of BLE concepts is strongly recommended, as it can save your time and energy when developing and debugging this type of functionality.

## Getting Started

There are a few requirements for working with the project:

### Garmin Development Tools

This project adheres to the directory structure of a standard Connect IQ SDK app.
It is assumed, that the following Garmin SDK Manager and Connect IQ SDK are installed.
These are required to build and run the code. See <https://developer.garmin.com/connect-iq/sdk/> for details.


### IDE
It is convinient to have Integrated Development Environment (IDE configured).
Currently, [Visual Studio Code](https://code.visualstudio.com/) with [Monkey C extension](https://developer.garmin.com/connect-iq/reference-guides/visual-studio-code-extension/) is most advanced and up-to-date option.

### ESP32 device
It is possible to run and test the app in the simulator.
If you want to work with real BLE controlled device, you would need ESP32 board with a dedicated firmware.

There is [an accompanying ESP32 project](https://github.com/karol-brejna-i/M5StampS3-BLE-example) that you could use directy (or as a source of inspiration for your own design).


## Testing the code

### Testing in the simulator
TBD

### Testing with a real ESP32 device

## Code walkthrough

TBD
