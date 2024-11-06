using Toybox.Application;
using Toybox.System;
using Toybox.BluetoothLowEnergy as Ble;

class LedatorApp extends Application.AppBase {
    hidden var _delegate as LedatorDelegate?;
    hidden var _bleDelegate as BleDiscoverModel?;

    function initialize() {
        AppBase.initialize();
    }

    function onStart(state) {
        _bleDelegate = new BleDiscoverModel();
        _bleDelegate.start();
        _delegate = new LedatorDelegate(_bleDelegate);
        _delegate.onStart();

        Debug.log("model and controller started");
    }

    function onStop(state) {
        _delegate.onStop();
        _delegate = null;

        _bleDelegate.stop();
        _bleDelegate = null;
    }

    function getInitialView() {
        return _delegate.getInitialView();
    }
}
