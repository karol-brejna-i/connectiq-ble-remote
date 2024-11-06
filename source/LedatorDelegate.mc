using Toybox.Application;
import Toybox.Lang;
using Toybox.System;
using Toybox.WatchUi;
using Toybox.BluetoothLowEnergy as Ble;

class LedatorDelegate extends WatchUi.BehaviorDelegate {
    hidden var _view;
    hidden var _bleDelegate;

    function initialize(model) {
        BehaviorDelegate.initialize();
        _bleDelegate = model;
    }

    function onStart() {
        Debug.log("LedatorDelegate on start");
        Ble.setDelegate(_bleDelegate);
    }

    function onStop() {}

    // onSelect has too many details about model; they all should be hidden (probably in the model)
    function onSelect() {
        Debug.log("onSelect");

        Debug.log("APP_STATE_IDLE = " + self._bleDelegate.app_state);

        switch (self._bleDelegate.app_state) {
            case APP_STATE_IDLE: {
                // start scanning
                Debug.log("Start scanning...");
                Ble.setScanState(Ble.SCAN_STATE_SCANNING);
                break;
            }
            case APP_STATE_CONNECTED: {
                // do action
                Debug.log("Perfrom action on BLE device.");

                self._bleDelegate.sendData();
                WatchUi.requestUpdate();
                break;
            }
        }

        return true;
    }

    function onMenu() as Boolean {
        Debug.log("onMenu");

        WatchUi.requestUpdate();
        return true;
    }

    function getInitialView() {
        _view = new LedatorView(_bleDelegate);
        return [_view, self];
    }
}
