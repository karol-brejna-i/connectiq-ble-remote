using Toybox.Application;
using Toybox.System;
using Toybox.BluetoothLowEnergy as Ble;

class BleTestApp extends Application.AppBase {
    hidden var _controller;
    hidden var _model;

    function initialize() {
        AppBase.initialize();
    }

    function onStart(state) {
        _model = new BleDiscoverModel();
        _model.start();
        _controller = new BleDiscoverController(_model);
        _controller.onStart();

        Debug.log("model and controller started");
    }

    function onStop(state) {
        _controller.onStop();
        _controller = null;

        _model.onStop();
        _model = null;
    }

    function getInitialView() {
        return _controller.getInitialView();
    }
}
