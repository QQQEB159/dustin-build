package funkin.options.type;

class NumOption extends TextOption {
    public var changedCallback:Float->Void;

    public var min:Float;
    public var max:Float;
    public var step:Float;

    public var currentValue:Float;

    public var parent:Dynamic;
    public var optionName:String;

    var __number:Alphabet;

    var currentIndex:Int = 0;
    var decimals:Int = 0;

    override function set_text(v:String) {
        super.set_text(v);
        __number.x = __text.x + __text.width + 12;
        return v;
    }

    public function new(text:String, desc:String, min:Float, max:Float, step:Float = 1, ?optionName:String, ?changedCallback:Float->Void = null, ?parent:Dynamic) {
        this.changedCallback = changedCallback;
        this.min = min;
        this.max = max;
        this.step = step;
        this.optionName = optionName;
        this.parent = parent = parent != null ? parent : Options;

        decimals = getDecimalPlaces(step);

        var savedValue:Float = min;
        if (Reflect.field(parent, optionName) != null) {
            savedValue = Reflect.field(parent, optionName);
        }

        savedValue = Math.min(Math.max(savedValue, min), max);

        currentIndex = Math.round((savedValue - min) / step);
        currentValue = roundToPrecision(min + currentIndex * step, decimals);

        __number = new Alphabet(0, 20, ': ${formatValue(currentValue)}', 'bold');
        super(text, desc);
        add(__number);

        if (Reflect.field(parent, optionName) != null) {
            Reflect.setField(parent, optionName, currentValue);
        }
    }

    override function changeSelection(change:Int):Void {
        if (locked) return;

        var nextIndex = currentIndex + change;
        var maxIndex = Math.floor((max - min) / step + 0.0000001);

        if (nextIndex < 0 || nextIndex > maxIndex) return;

        currentIndex = nextIndex;
        currentValue = roundToPrecision(min + currentIndex * step, decimals);

        __number.text = ': ${formatValue(currentValue)}';

        Reflect.setField(parent, optionName, currentValue);
        if (changedCallback != null) changedCallback(currentValue);

        CoolUtil.playMenuSFX(SCROLL);
    }

    override function select() {}

    function getDecimalPlaces(value:Float):Int {
        var str = Std.string(value);
        var idx = str.indexOf('.');
        if (idx == -1) return 0;
        return str.length - idx - 1;
    }

    function roundToPrecision(value:Float, decimals:Int):Float {
        if (decimals <= 0) return Math.round(value);
        var mult = Math.pow(10, decimals);
        return Math.round(value * mult) / mult;
    }

    function formatValue(value:Float):String {
        if (decimals <= 0) return Std.string(Math.round(value));
        var rounded = roundToPrecision(value, decimals);
        var str = Std.string(rounded);
        var dotIndex = str.indexOf('.');
        if (dotIndex == -1) {
            str += ".";
            dotIndex = str.length - 1;
        }
        while (str.length - dotIndex - 1 < decimals) str += "0";
        return str;
    }
}