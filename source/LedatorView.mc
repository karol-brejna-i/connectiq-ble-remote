using Toybox.Application;
using Toybox.BluetoothLowEnergy as Ble;
using Toybox.Graphics;
import Toybox.Lang;
using Toybox.System;
using Toybox.WatchUi;

class LedatorView extends WatchUi.View {
    hidden var _centerX as Number?;
    hidden var _centerY as Number?;
    hidden var _font as Number?;
    hidden var _lineHeight as Number?;

    hidden var _bleDelegate as BleDiscoverModel;

    function initialize(model) {
        View.initialize();
        _bleDelegate = model;
    }

    function onLayout(dc) {
        _centerX = dc.getWidth() / 2;
        _centerY = dc.getHeight() / 2;

        _font = Graphics.FONT_XTINY;
        _lineHeight = dc.getFontHeight(_font);
    }

    function showTextCentered(dc, ypos, text) {
        dc.drawText(_centerX, ypos, _font, text, Graphics.TEXT_JUSTIFY_CENTER);
    }

    function drawInitialMenu(dc) {
        Debug.log("View.drawInitialMenu");
        var ypos = _centerY - (2 * _lineHeight) / 2;
        showTextCentered(dc, ypos, "SELECT to start scanning");
        ypos += _lineHeight;
        showTextCentered(dc, ypos, "BACK to exit");

        drawInteractionHint(dc, Math.PI / 6, _centerX - 10);
    }

    function drawActionMenu(dc) {
        Debug.log("View.drawActionMenu");

        var ypos = dc.getHeight() / 2 - (3 * _lineHeight) / 2;
        showTextCentered(dc, ypos, "SELECT to issue action");
        ypos += _lineHeight;
        showTextCentered(dc, ypos, "BACK to exit");

        ypos += _lineHeight;
        showTextCentered(dc, ypos, self._bleDelegate.payloadIdx);

        drawInteractionHint(dc, Math.PI / 6, _centerX - 10);
    }

    function onUpdate(dc) {
        Debug.log("View.onUpdate: " + self._bleDelegate.app_state);
        dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_BLACK);
        dc.clear();

        var color;
        switch (self._bleDelegate.app_state) {
            case APP_STATE_IDLE: {
                drawInitialMenu(dc);
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
        dc.drawText(_centerX, ypos, _font, self._bleDelegate.app_state, Graphics.TEXT_JUSTIFY_CENTER);
    }

    function drawInteractionHint(dc, angle, radius) {
        var degree = Math.toDegrees(angle);
        var d1 = degree - 8;
        var d2 = degree + 8;
        dc.setColor(Graphics.COLOR_GREEN, Graphics.COLOR_BLACK);
        dc.setPenWidth(4);
        dc.drawArc(_centerX, _centerY, radius, Graphics.ARC_COUNTER_CLOCKWISE, d1, d2);
    }
}
