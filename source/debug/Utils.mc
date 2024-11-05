using Toybox.Time as Time;
using Toybox.Time.Gregorian as Greg;
using Toybox.Lang as Lang;
using Toybox.BluetoothLowEnergy as Ble;

class Log {
    private static var FORMAT_LOG_MESSAGE = "[$1$] {$2$} $3$: $4$";
    private static var FORMAT_TIMESTAMP = "$1$-$2$-$3$ $4$:$5$:$6$"; // YYYY-MM-DD HH:MM:SS

    private var mLogLevel = "I";
    private var mLogStream = Toybox.System;

    function initialize(logLevel, logStream) {
        mLogLevel = logLevel;
        mLogStream = logStream;
    }

    private function formLogMessage(tag, message) {
        // Get a timestamp from the system
        var currentTime = Greg.info(Time.now(), Time.FORMAT_SHORT);
        var timestamp = Lang.format(FORMAT_TIMESTAMP, [
            currentTime.year.format("%04u"),
            currentTime.month.format("%02u"),
            currentTime.day.format("%02u"),
            currentTime.hour.format("%02u"),
            currentTime.min.format("%02u"),
            currentTime.sec.format("%02u")
        ]);

        // Form the log message
        return Lang.format(FORMAT_LOG_MESSAGE, [timestamp, mLogLevel, tag, message]);
    }

    function log(message) {
        var tag = "";
        // Print the log message
        mLogStream.println(formLogMessage(tag, message));
    }
}

class PrettierInitializer {
    function bleDevice(obj) {
        return Lang.format("BleDev{$1$}", [obj.getUuid()]);
    }

    function bleService(obj) {
        return Lang.format("BLESrv{$1$}", [obj.getUuid()]);
    }

    function bleScanResult(obj) {
        var o = obj as Ble.ScanResult;
        var rawData = o.getRawData();
        var uuids = o.getServiceUuids();
        var a = Pretty.dumps(rawData);
        var b = Pretty.dumps(uuids);
        return Lang.format("BleScanResult{$1$, $2$, $3$}", [obj, a, b]);
    }

    function initialize() {
        Pretty.register_type(Ble.ScanResult, method(:bleScanResult));
        Pretty.register_type(Ble.Service, method(:bleService));
        Pretty.register_type(Ble.Device, method(:bleDevice));
    }
}

const Debug = new Log("D", Toybox.System);
const BLEPrietter = new PrettierInitializer();
