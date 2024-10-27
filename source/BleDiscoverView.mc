using Toybox.Application;
using Toybox.Graphics;
import Toybox.Lang;
using Toybox.System;

using Toybox.WatchUi;
using Toybox.BluetoothLowEnergy as Ble;

class BleDiscoverView extends WatchUi.View {
    hidden var _xpos;
    hidden var _font;
    hidden var _ljust;
    hidden var _rjust;
    hidden var _cjust;
    hidden var _lineHeight;
    hidden var _viewHeight;
    hidden var _model;

    function initialize(model) {
        View.initialize();
        _model = model;
    }

    function onLayout(dc) {
        _xpos = dc.getWidth() / 3;

        _font = Graphics.FONT_XTINY;
        _ljust = Graphics.TEXT_JUSTIFY_LEFT;
        _rjust = Graphics.TEXT_JUSTIFY_RIGHT;
        _cjust = Graphics.TEXT_JUSTIFY_CENTER;

        _lineHeight = dc.getFontHeight(_font);
        _viewHeight = dc.getHeight();
    }

    function drawInitialMenu(dc, isScanning) {
        System.println("Initial menu.");
        var ypos = dc.getHeight() / 2 - (3 * _lineHeight) / 2;

        dc.drawText(dc.getWidth() / 2, ypos, _font, Lang.format("SELECT to $1$ scanning", [isScanning ? "STOP" : "START"]), _cjust);
        ypos += _lineHeight;
        dc.drawText(dc.getWidth() / 2, ypos, _font, "BACK to exit", _cjust);
    }

    function drawActionMenu(dc) {
        System.println("drawActionMenu");
        var ypos = dc.getHeight() / 2 - (3 * _lineHeight) / 2;

        dc.drawText(0, ypos, _font, _model._status, _ljust);
        ypos += _lineHeight;
        dc.drawText(0, ypos, _font, _model.pairedDevice, _ljust);

        var services = _model.pairedDevice.getServices();
        if (services != null) {
            dc.setColor(Graphics.COLOR_GREEN, Graphics.COLOR_BLACK);
            dc.fillCircle(dc.getWidth() / 2, 10, 10);
            dc.drawText(0, ypos, _font, "services:", _ljust);
            for (var result = services.next(); result != null; result = services.next()) {
                ypos += _lineHeight;
                dc.drawText(0, ypos, _font, result, _ljust);
            }
        } else {
            dc.setColor(Graphics.COLOR_RED, Graphics.COLOR_RED);
            dc.fillCircle(dc.getWidth() / 2, 10, 10);
            dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_BLACK);
        }
    }

    /**
     * States:
     *    IDLE - nothing is happening in the app
     *    SCANNING - looking for Bramator
     *    Connecting - BLE device found, trying to connect to it
     *    CONNECTED - BLE device connected, can perfrom actions on it (OPEN GATE, DISCONNECT)
     *
     */
    function onUpdate(dc) {
        dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_BLACK);
        dc.clear();
        
        var showInitialMenu = _model.pairedDevice == null;
        System.println("show initial: " + showInitialMenu);

        var isScanning = _model.isScanning();

        if (showInitialMenu) {
            drawInitialMenu(dc, isScanning);
        } else {
            drawActionMenu(dc);
        }

        var color;

        if (_model.pairedDevice != null) {
            color = Graphics.COLOR_GREEN;
        } else if (isScanning) {
            color = Graphics.COLOR_ORANGE;
        } else {
            color = Graphics.COLOR_RED;
        }

        dc.setColor(color, color);
        dc.fillCircle(dc.getWidth() - 20, dc.getHeight() / 2, 10);
    }
}
