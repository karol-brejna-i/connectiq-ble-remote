# Garmin Connect IQ SDK BLE LED Control Project

This repository hosts a basic project that is an outcome of my own learning and experiments with programming Bluetooth Low Energy (BLE) communication on Garmin Watch, specifically using Fenix 7 and Fenix 5 Plus.

This project demonstrates how to control an external BLE device (ESP32) using a Garmin watch to manipulate its LED color."

In other words:
- the project assumes that there is working BLE device (server) that is able to accept "0", "1", "2", "3" data written to the exposed service/characteristics. The extenraln device controls embedded LED and switches its state ("0" - turn off, "1", "2", "3" - Red, Green, Blue),
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

TBD

## Running the project

TBD

## Testing the code

TBD

## Code walkthrough

TBD
