package funkin.options.type;

/**
 * Option type that allows stepping through a number.
**/
class NumOption extends TextOption {
	public var changedCallback:Float->Void;

	public var min:Float;
	public var max:Float;
	public var step:Float;

	public var currentValue:Float;

	public var parent:Dynamic;
	public var optionName:String;

	var __number:Alphabet;

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

		if (Reflect.field(parent, optionName) != null) currentValue = Reflect.field(parent, optionName);
	
		__number = new Alphabet(0, 20, ': $currentValue', 'bold');
		super(text, desc);
		add(__number);
	}

	private function formatValue(value:Float):String {
		if (step >= 1.0) {
			return Std.string(Std.int(value));
		} else if (step >= 0.01) {
			return Std.string(Math.round(value * 100) / 100);
		} else if (step >= 0.001) {
			return Std.string(Math.round(value * 1000) / 1000);
		} else {
			return Std.string(Math.round(value * 10000) / 10000);
		}
	}
	
	override function changeSelection(change:Int):Void {
		if (locked) return;
		var next = FlxMath.bound(currentValue + change * step, min, max);
		if (Math.abs(next - currentValue) < (step * 0.001)) return;
        currentValue = next;
		__number.text = ': ${formatValue(currentValue)}';

		if (optionName != null && parent != null) Reflect.setField(parent, optionName, currentValue);
		if (changedCallback != null) changedCallback(currentValue);

		CoolUtil.playMenuSFX(SCROLL);
	}

	override function select() {}
}