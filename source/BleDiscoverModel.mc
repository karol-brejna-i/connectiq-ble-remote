using Toybox.System;
using Toybox.WatchUi;
using Toybox.BluetoothLowEnergy as Ble;
import Toybox.Lang;

const DEVICE_NAME = "Bramator";
const SERVICE_UUID = "00001234-0000-1000-8000-00805F9B34FB";
const CHARACTERISTIC_UUID = "00005678-0000-1000-8000-00805F9B34FB";

class BleDiscoverModel extends Ble.BleDelegate {
    // is the watch scanning for BLE devices?
    var _scanState;
    // result of the last call to setScanState(). STATUS_SUCCESS = 0, other states are fails
    var _status;

    var pairedDevice as Ble.Device?;

    var profile = {
        :uuid => Ble.stringToUuid(SERVICE_UUID),
        :characteristics => [
            {
                :uuid => Ble.stringToUuid(CHARACTERISTIC_UUID)
                // :descriptors => [Ble.cccdUuid()]
            }
        ]
    };

    function initialize() {
        System.println("Initializing bledelegate");
        BleDelegate.initialize();

        _scanState = Ble.SCAN_STATE_OFF;
        _status = -1;
    }

    // XXX TODO: for me onStart suggest tht this is some kind of callback invoced on start. maybe change to start();
    function onStart() {
        System.println("blemodel onstart");
        Ble.registerProfile(self.profile);
    }

    function onStop() {}

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

    private function connect(sr as Ble.ScanResult) {
        System.println("connect");
        Ble.setScanState(Ble.SCAN_STATE_OFF);
        Ble.pairDevice(sr);
    }

    function write(data) {
        System.println("write: " + data);

        if (pairedDevice == null) {
            System.println("write: not connected");
            return;
        }

        var service = pairedDevice.getService(Ble.stringToUuid(SERVICE_UUID));
        System.println("service: " + service);
        var ch = service.getCharacteristic(Ble.stringToUuid(CHARACTERISTIC_UUID));
        System.println("Characteristic: " + ch);
        try {
            ch.requestWrite(data, { :writeType => Ble.WRITE_TYPE_DEFAULT });
        } catch (ex) {
            System.println(ex.getErrorMessage());
            System.println("write: can't start char write");
        }
    }

    /**
     * Compare ScanResult object with currently remembered device.
     */
    function matchDevice(sr as Ble.ScanResult) {
        var name = sr.getDeviceName();
        if (name != null && name.equals(DEVICE_NAME)) {
            System.println("Device matched.");
            return true;
        }

        return false;
    }

    function isScanning() {
        return _scanState != Ble.SCAN_STATE_OFF;
    }

    /*****************************************
     * BleDelegate callbacks
     */
    function onScanResults(scanResults) {
        System.println("onScanResults");
        for (var result = scanResults.next(); result != null; result = scanResults.next()) {
            if (result instanceof Ble.ScanResult) {
                if (matchDevice(result)) {
                    connect(result);

                    break;
                }
            }
        }
        WatchUi.requestUpdate();
    }

    /**
     * Called when device got connected or disconnected.
     */
    function onConnectedStateChanged(device as Ble.Device, state as Ble.ConnectionState) {
        System.println("connected: " + state);
        if (device != null) {
            System.println("Get device name = " + device.getName());
        }
        if (state == Ble.CONNECTION_STATE_CONNECTED) {
            // remember paired device:
            self.pairedDevice = device;
            System.println("device connected");
        } else {
            // disconnected, forget bleDevice
            System.println("Disconnected! Clearing bleDevice.");
            self.pairedDevice = null;
        }
    }

    // TODO XXX when starting scanning again, we probably want to disconnect/forget about last paired bramator
    function onScanStateChange(scanState, status) {
        System.println("onScanStateChange: " + scanState + ", " + status);
        _scanState = scanState;
        _status = status;
        WatchUi.requestUpdate();
    }

    function onProfileRegister(uuid, status) {
        System.println("onProfileRegister: " + uuid + ", " + status);
    }

    //! Handle the completion of a write operation on a characteristic
    //! @param characteristic The characteristic that was written
    //! @param status The BluetoothLowEnergy status indicating the result of the operation
    // will not be invoked when using WRITE_TYPE_DEFAULT during write.
    function onCharacteristicWrite(characteristic as Ble.Characteristic, status as Ble.Status) as Void {
        System.println("onbCharacteristicWrite: " + characteristic + ", " + status);
    }
}