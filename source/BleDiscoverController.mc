using Toybox.Application;
import Toybox.Lang;
using Toybox.System;
using Toybox.WatchUi;
using Toybox.BluetoothLowEnergy as Ble;

class BleDiscoverController extends WatchUi.BehaviorDelegate {
    hidden var _view;
    hidden var _model;

    // XXX TODO: hax
    var diodkiNumer as Number = 0;
    function getNextDiodkiNumer() {
        self.diodkiNumer = diodkiNumer + 1;
        if (self.diodkiNumer > 3) {
            self.diodkiNumer = 0;
        }

        return self.diodkiNumer;
    }

    function initialize(model) {
        BehaviorDelegate.initialize();
        _model = model;
    }

    function onStart() {
        System.println("BleDiscoverController on start");
        Ble.setDelegate(_model);
    }

    function onStop() {}


    // onSelect has too many details about model; they all should be hidden (probably in the model)
    function onSelect() {
        var showInitialMenu = _model.pairedDevice == null;
        System.println("onSelect showInitialMenu: " + showInitialMenu);
        
        var isScanning = _model.isScanning();
        if (showInitialMenu) {
            if (isScanning) {
                System.println("Disable scanning");
                Ble.setScanState(Ble.SCAN_STATE_OFF);
            } else {
                // start scanning
                System.println("Start scanning...");
                Ble.setScanState(Ble.SCAN_STATE_SCANNING);
            }
        } else {
            // do action
            System.println("Perfrom action on BLE device.");

            // -- XXX debug,
            System.println("Services list:");
            var uuids = self._model.serviceUUIDsAsArray();
            System.println(uuids);

            self._model.write([0x30 + self.getNextDiodkiNumer(), 0x00]b);
        }

        return true;
    }

    function onMenu() as Boolean {
        System.println("onMenu");
        WatchUi.requestUpdate();
        return true;
    }

    function getInitialView() {
        _view = new BleDiscoverView(_model);
        return [_view, self];
    }
}
