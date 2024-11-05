//! Module for writing an object or object hierarchy as a pretty string.
//!
//! Simple module for pretty-printing MonkeyC objects. All native types
//! are handled by default. User-defined types can implement the special
//! __repr__ method to return a string representation.  If the behavior
//! for a type (native or user-defined) needs to be changed, a callback
//! can be registered to override. The most recently registered callback
//! will be used.
//!
//! @example
//!  function hexadecimal_number(obj) {
//!      return Lang.format("0x$1$", [ obj.format("%x") ]);
//!  }
//!
//!  function scientific_float(obj) {
//!      return obj.format("%e");
//!  }
//!
//!  function demo() {
//!      var d = { 1 => 3.14159 };
//!
//!      // prints "{ 1: 3.14159f }"
//!      Pretty.dump(d);
//!
//!      // override the behavior for Number
//!      Pretty.register_type(Lang.Number, method(:hexadecimal_number));
//!
//!      // override the behavior for Float
//!      Pretty.register_type(Lang.Float, method(:scientific_float));
//!
//!      // prints "{ 0x1: 3.141590e+00 }"
//!      Pretty.dump(d);
//!  }
module Pretty {
    using Toybox.Lang;
    using Toybox.System;
    using Toybox.BluetoothLowEnergy as Ble;

    //! Register a callback to pretty format an object of the given type.
    //!
    //! @param [type] The type of an object to use the given callback function for
    //! @param [callback] A Lang.Method that generates a string representation of a type
    function register_type(type, callback) {
        _type_map.add(new TypeMapEntry(type, callback));
    }

    //! Remove a callback registered to pretty format an object of the given type.
    //!
    //! Remove the most recently registered callback for the given type. Has no
    //! effect if no registered function is found. The default handlers for the
    //! built-in types cannot be removed, but they can be overridden by adding
    //! a new callback with `register_type`.
    //!
    //! @param [type] The type to deregister
    function deregister_type(type) {
        var n = _type_map.size();

        for (var i = n - 1; i >= 0; --i) {
            if (_type_map[i].type == type) {
                _type_map.remove(_type_map[i]);
                return;
            }
        }
    }

    //! Convert an object to a pretty string representation.
    //!
    //! Convert an object to a pretty string representation using
    //!   1) the most recent callback registered with `register_type`
    //!      that has not been removed with `deregister_type`
    //!   2) the default formatting for built-in types
    //!   3) the format provided by a class member function __repr__.
    //!
    //! @param [obj] The object to convert.
    //! @return String A pretty string representation of the object.
    //! @throws UnexpectedTypeException if an object type is not known.
    //!
    function dumps(obj) as Lang.String {
        return _dumps(obj, false);
    }

    function dumpsOrCrash(obj) as Lang.String {
        return _dumps(obj, true);
    }

    //
    // everything below this line is an implementation detail
    // do not access these things
    //

    var _type_map as Lang.Array<TypeMapEntry> = [];

    class TypeMapEntry {
        function initialize(type, callback) {
            self.type = type;
            self.callback = callback;
        }

        var type;
        var callback;
    }

    //
    // return a pretty representation of the given object
    //
    function _dumps(obj, exceptionOnUnknown as Lang.Boolean) {
        var n = _type_map.size();
        for (var i = n - 1; i >= 0; --i) {
            var entry = _type_map[i];
            if (obj instanceof entry.type) {
                return entry.callback.invoke(obj);
            }
        }

        // default behavior for built-in types
        if (obj instanceof Lang.Boolean) {
            return obj.toString();
        } else if (obj instanceof Lang.Char) {
            return Lang.format("'$1$'", [obj]);
        } else if (obj instanceof Lang.Double) {
            return Lang.format("$1$d", [obj.format("%g")]);
        } else if (obj instanceof Lang.Float) {
            return Lang.format("$1$f", [obj.format("%g")]);
        } else if (obj instanceof Lang.Long) {
            return Lang.format("$1$L", [obj]);
        } else if (obj instanceof Lang.Number) {
            return obj.toString();
        } else if (obj instanceof Lang.String) {
            return Lang.format("\"$1$\"", [obj]);
        } else if (obj instanceof Lang.Array) {
            n = obj.size();
            if (n == 0) {
                return "[]";
            }

            var r = "[ ";
            r += _dumps(obj[0], exceptionOnUnknown);

            for (var i = 1; i < n; ++i) {
                r += ", ";
                r += _dumps(obj[i], exceptionOnUnknown);
            }
            r += " ]";

            return r;
        } else if (obj instanceof Lang.Dictionary) {
            n = obj.size();
            if (n == 0) {
                return "{}";
            }

            var k = obj.keys();
            var v = obj.values();

            var r = "{ ";
            r += _dumps(k[0], exceptionOnUnknown);
            r += ": ";
            r += _dumps(v[0], exceptionOnUnknown);

            for (var i = 1; i < n; ++i) {
                r += ", ";
                r += _dumps(k[i], exceptionOnUnknown);
                r += ": ";
                r += _dumps(v[i], exceptionOnUnknown);
            }
            r += " }";

            return r;
        } else if (obj instanceof Lang.ByteArray) {
            return obj.toString();
        } else if (obj == null) {
            return "null";
        }

        // special behavior for user-defined types
        else if (obj has :__repr__) {
            return obj.__repr__();
        }
        // unknown type
        else {
            var message = Lang.format("Unknown type for '$1$'", [obj]);
            if (exceptionOnUnknown) {
                throw new Lang.UnexpectedTypeException(message, null, null);
            } else {
                return message;
            }
        }
    }
}
