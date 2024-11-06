import Toybox.Lang;
using Toybox.System;
using Toybox.WatchUi;
using Toybox.BluetoothLowEnergy as Ble;

const DEVICE_NAME = "Bramator";
const SERVICE_UUID = "00001234-0000-1000-8000-00805F9B34FB";
const CHARACTERISTIC_UUID = "00005678-0000-1000-8000-00805F9B34FB";

enum {
    APP_STATE_IDLE = "IDLE",
    APP_STATE_SCANNING = "SCANNING",
    APP_STATE_CONNECTING = "CONNECTING",
    APP_STATE_CONNECTED = "CONNECTED"
}

class BleDiscoverModel extends Ble.BleDelegate {
    var app_state = APP_STATE_IDLE;
    var pairedDevice as Ble.Device?;
    var payloadIdx as Number = 0;

    var profile = {
        :uuid => Ble.stringToUuid(SERVICE_UUID),
        :characteristics => [
            {
                :uuid => Ble.stringToUuid(CHARACTERISTIC_UUID),
                // :descriptors => [Ble.cccdUuid()]
            }
        ]
    };

    function initialize() {
        Debug.log("Initializing BleDelegate.");
        BleDelegate.initialize();
    }

    function start() {
        Debug.log("BleDelegate onStart");
        Ble.registerProfile(self.profile);
    }

    function stop() {}

    function serviceUUIDsAsArray() {
        return createArrayFromIterator(pairedDevice.getServices());
    }

    function createArrayFromIterator(iterator as Ble.Iterator) as Array {
        var array = [];

        for (var item = iterator.next(); item != null; item = iterator.next()) {
            array.add(item);
        }
        return array;
    }

    function dumpArray(a as Array) {
        for (var i = 0; i < a.size(); i += 1) {
            Debug.log(a[i].toString());
        }
    }

    private function connect(sr as Ble.ScanResult) {
        Debug.log("connect");
        Ble.setScanState(Ble.SCAN_STATE_OFF);
        Ble.pairDevice(sr);
    }

    function write(data) {
        Debug.log("write: " + data);

        if (pairedDevice == null) {
            Debug.log("write: not connected");
            return;
        }

        Debug.log("Dumping connected device info:");
        printPairedDeviceInfo();

        var service = self.pairedDevice.getService(Ble.stringToUuid(SERVICE_UUID));
        Debug.log("service: " + service);
        var chUUID = Ble.stringToUuid(CHARACTERISTIC_UUID);
        var ch = service.getCharacteristic(chUUID);
        Debug.log("Characteristic: " + ch);
        try {
            ch.requestWrite(data, { :writeType => Ble.WRITE_TYPE_DEFAULT });
        } catch (ex) {
            Debug.log(ex.getErrorMessage());
            Debug.log("write: can't start char write");
        }
    }

    /**
     * Compare ScanResult object with currently remembered device.
     */
    function matchDevice(sr as Ble.ScanResult) {
        var name = sr.getDeviceName();
        if (name != null && name.equals(DEVICE_NAME)) {
            Debug.log("Device matched.");
            return true;
        }

        return false;
    }

    function getNextPayloadIdx() {
        self.payloadIdx = payloadIdx + 1;
        if (self.payloadIdx > 3) {
            self.payloadIdx = 0;
        }

        return self.payloadIdx;
    }

    function debugBleDeviceInfo(device as Ble.Device?) {
        if (device != null) {
            Debug.log("BD: I have a paried device. " + device.getName());
        } else {
            Debug.log("BD: No paired device.");
            return;
        }

        var services = device.getServices();
        if (services != null) {
            Debug.log("BD: I have services iterator.");
        } else {
            Debug.log("BD: NO services iterator.");
        }

        
        var uuids = createArrayFromIterator(services);
        Debug.log("BD: Services list: " + Pretty.dumps(uuids));
    }

    function printPairedDeviceInfo() {
        self.debugBleDeviceInfo(self.pairedDevice);
    }

    function sendData() as Number {
        Debug.log("sendData");
        var idx = self.getNextPayloadIdx();
        var payload = [0x30 + idx, 0x00]b;
        write(payload);
        return payloadIdx;
    }

    /*****************************************
     * BleDelegate callbacks
     */
    function onScanResults(scanResults) {
        Debug.log("onScanResults");
        for (var result = scanResults.next(); result != null; result = scanResults.next()) {
            Debug.log("onScanResults. Incpecting scanned device..." + Pretty.dumps(result));
            
            if (result instanceof Ble.ScanResult) {
                Debug.log("onScanResults. scanned device name: " + result.getDeviceName());
                if (matchDevice(result)) {
                    connect(result);

                    break;
                }
            }
        }
        WatchUi.requestUpdate();
    }

    function setAppState(state) {
        var oldState = self.app_state;
        self.app_state = state;

        Debug.log("setAppState from " + oldState + " to " + state);
    }

    /**
     * Called when device got connected or disconnected.
     */
    function onConnectedStateChanged(device as Ble.Device, state as Ble.ConnectionState) {
        // CONNECTION_STATE_CONNECTED
        var stateDescription = state == Ble.CONNECTION_STATE_CONNECTED ? "OK" : state;
        Debug.log("onConnectedStateChanged. connected: " + stateDescription);
        if (device != null) {
            Debug.log("Get device name = " + device.getName());
        }
        if (state == Ble.CONNECTION_STATE_CONNECTED) {
            // remember paired device:
            self.pairedDevice = device;
            Debug.log("device connected.");
            printPairedDeviceInfo();
            setAppState(APP_STATE_CONNECTED);
        } else {
            // disconnected, forget bleDevice
            Debug.log("Disconnected! Clearing bleDevice.");
            self.pairedDevice = null;
            setAppState(APP_STATE_IDLE);
        }
        WatchUi.requestUpdate();
    }

    /**
     * Update scan state (and app state) acoordingly.
     */
    function updateScanState(isConnected as Boolean) as Void {
        if (isConnected) {
            self.app_state = APP_STATE_SCANNING;
        } else {
            if (self.app_state == APP_STATE_SCANNING or self.app_state == APP_STATE_CONNECTED) {
                self.app_state = APP_STATE_IDLE;
            }
        }
    }

    // TODO XXX when starting scanning again, we probably want to disconnect/forget about last paired bramator
    function onScanStateChange(scanState, status) {
        Debug.log("onScanStateChange: " + scanState + ", " + status);

        updateScanState(scanState == Ble.SCAN_STATE_SCANNING);
        WatchUi.requestUpdate();
    }

    function onProfileRegister(uuid, status as Ble.Status) {
        var statusDescription = status == 0 ? "OK" : status;
        Debug.log("onProfileRegister: " + uuid + ", " + statusDescription);
    }

    //! Handle the completion of a write operation on a characteristic
    //! @param characteristic The characteristic that was written
    //! @param status The BluetoothLowEnergy status indicating the result of the operation
    // will not be invoked when using WRITE_TYPE_DEFAULT during write.
    function onCharacteristicWrite(characteristic as Ble.Characteristic, status as Ble.Status) as Void {
        Debug.log("onbCharacteristicWrite: " + characteristic + ", " + status);
    }
}
