using Toybox.Application;
using Toybox.Graphics;
import Toybox.Lang;
using Toybox.System;

using Toybox.WatchUi;
using Toybox.BluetoothLowEnergy as Ble;

class BleDiscoverView extends WatchUi.View {
    hidden var _xcenter;
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
        _xcenter = dc.getWidth() / 2;

        _font = Graphics.FONT_XTINY;
        _ljust = Graphics.TEXT_JUSTIFY_LEFT;
        _rjust = Graphics.TEXT_JUSTIFY_RIGHT;
        _cjust = Graphics.TEXT_JUSTIFY_CENTER;

        _lineHeight = dc.getFontHeight(_font);
        _viewHeight = dc.getHeight();
    }

    function showTextCentered(dc, ypos, text) {
        dc.drawText(_xcenter, ypos, _font, text, _cjust);
    }
    function drawInitialMenu(dc, isScanning) {
        System.println("drawInitialMenu");
        var ypos = dc.getHeight() / 2 - (3 * _lineHeight) / 2;
        showTextCentered(dc, ypos, "SELECT to start scanning");
        ypos += _lineHeight;
        showTextCentered(dc, ypos, "BACK to exit");
    }

    function drawActionMenu(dc) {
        System.println("drawActionMenu");

        var ypos = dc.getHeight() / 2 - (3 * _lineHeight) / 2;
        showTextCentered(dc, ypos, "SELECT to issue action");
        ypos += _lineHeight;
        showTextCentered(dc, ypos, "BACK to exit");
    }

    function onUpdate(dc) {
        System.println("onUpdate: " + self._model.app_state);
        dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_BLACK);
        dc.clear();

        var color;
        switch (self._model.app_state) {
            case APP_STATE_IDLE: {
                drawInitialMenu(dc, true);
                color = Graphics.COLOR_LT_GRAY;
                break;
            }
            case APP_STATE_CONNECTED: {
                drawActionMenu(dc);
                color = Graphics.COLOR_GREEN;
                break;
            }
            default: {
                color = Graphics.COLOR_ORANGE;
            }
        }

        // show app state
        var ypos = 40;
        dc.setColor(color, Graphics.COLOR_BLACK);
        dc.drawText(_xcenter, ypos, _font, self._model.app_state, _cjust);
    }
}
