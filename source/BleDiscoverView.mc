using Toybox.Application;
using Toybox.BluetoothLowEnergy as Ble;
using Toybox.Graphics;
import Toybox.Lang;
using Toybox.System;
using Toybox.WatchUi;

class BleDiscoverView extends WatchUi.View {
    hidden var _centerX;
    hidden var _centerY;
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
        _centerX = dc.getWidth() / 2;
        _centerY = dc.getHeight() / 2;

        _font = Graphics.FONT_XTINY;
        _ljust = Graphics.TEXT_JUSTIFY_LEFT;
        _rjust = Graphics.TEXT_JUSTIFY_RIGHT;
        _cjust = Graphics.TEXT_JUSTIFY_CENTER;

        _lineHeight = dc.getFontHeight(_font);
        _viewHeight = dc.getHeight();
    }

    function showTextCentered(dc, ypos, text) {
        dc.drawText(_centerX, ypos, _font, text, _cjust);
    }
    function drawInitialMenu(dc, isScanning) {
        System.println("drawInitialMenu");
        var ypos = dc.getHeight() / 2 - (3 * _lineHeight) / 2;
        showTextCentered(dc, ypos, "SELECT to start scanning");
        ypos += _lineHeight;
        showTextCentered(dc, ypos, "BACK to exit");

        //dc, angle, radius
        drawInteractionHing(dc, Math.PI / 6, _centerX - 20);
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
        dc.drawText(_centerX, ypos, _font, self._model.app_state, _cjust);
    }

    function drawInteractionHing(dc, angle, radius) {
        var x = _centerX + radius * Math.cos(angle);
        var y = _centerY - radius * Math.sin(angle);

        dc.setColor(Graphics.COLOR_DK_GRAY, Graphics.COLOR_BLACK);
        dc.drawCircle(x, y, 10); // Draw the circle with radius 10

        dc.setColor(Graphics.COLOR_DK_GREEN, Graphics.COLOR_BLACK);
        // pi/6 - pi/18 do pi/6 + pi/18
        var degree = Math.toDegrees(angle);
        var d1 = degree - 8;
        var d2 = degree + 8;
        dc.setPenWidth(4);
        var zagiecie = 20;
        //Graphics.ARC_COUNTER_CLOCKWISE
        dc.drawArc(_centerX + zagiecie, _centerY - zagiecie, _centerX - zagiecie - 10, Graphics.ARC_COUNTER_CLOCKWISE, d1, d2);
    }
}
