using Toybox.Application;
import Toybox.Lang;
using Toybox.System;
using Toybox.WatchUi;
using Toybox.BluetoothLowEnergy as Ble;

class BleDiscoverController extends WatchUi.BehaviorDelegate {
    hidden var _view;
    hidden var _model;

    function initialize(model) {
        BehaviorDelegate.initialize();
        _model = model;
    }

    function onStart() {
        Debug.log("BleDiscoverController on start");
        Ble.setDelegate(_model);
    }

    function onStop() {}

    // onSelect has too many details about model; they all should be hidden (probably in the model)
    function onSelect() {
        Debug.log("onSelect");

        Debug.log("APP_STATE_IDLE = " + self._model.app_state);

        switch (self._model.app_state) {
            case APP_STATE_IDLE: {
                // start scanning
                Debug.log("Start scanning...");
                Ble.setScanState(Ble.SCAN_STATE_SCANNING);
                break;
            }
            case APP_STATE_CONNECTED: {
                // do action
                Debug.log("Perfrom action on BLE device.");

                self._model.sendData();
                WatchUi.requestUpdate();
                break;
            }
        }

        return true;
    }

    function onMenu() as Boolean {
        Debug.log("onMenu");

        // XXX TODO debug:
        var d = { 1 => 3.14159 };
        System.println(Pretty.dumps(d));

        WatchUi.requestUpdate();
        return true;
    }

    function getInitialView() {
        _view = new BleDiscoverView(_model);
        return [_view, self];
    }
}
