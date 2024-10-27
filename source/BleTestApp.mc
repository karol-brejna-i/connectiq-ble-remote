import Toybox.Application;
import Toybox.Lang;
import Toybox.WatchUi;
using Toybox.Application;
using Toybox.Graphics;
using Toybox.System;
using Toybox.WatchUi;
using Toybox.BluetoothLowEnergy as Ble;

class BleTestApp extends Application.AppBase {
    hidden var _controller;
    hidden var _model;

    function initialize() {
        AppBase.initialize();
    }

    function onStart(state) {
        _model = new BleDiscoverModel();
        _model.onStart();
        _controller = new BleDiscoverController(_model);
        _controller.onStart();

        System.println("model and controller started");
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
