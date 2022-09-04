package;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.FlxState;
import flixel.math.FlxRandom;
import flixel.util.FlxColor;
import openfl.display.DisplayObject;
import openfl.display.DisplayObjectContainer;
import openfl.display.Stage;

class PlayState extends FlxState
{
	public var _window:FlxWindowPOC;

	public var _s1:FlxSprite;
	public var _s2:FlxSprite;

	var _rand:FlxRandom;

	override public function create()
	{
		super.create();
		_rand = new FlxRandom();
		FlxG.camera.bgColor = FlxColor.CYAN;

		// Don't pause so that clicking on other tools
		// doesn't interfere with leak or stop
		FlxG.autoPause = false;

		// create sprites
		_s1 = new FlxSprite(0, 0);
		_s1.makeGraphic(20, 20, FlxColor.BLUE);
		_s1.cameras = [FlxG.camera];

		add(_s1);

		_s1.velocity.x = _rand.float(100, 200);
		_s1.velocity.y = _rand.float(100, 200);
		// createWindow(); - test create second window at startup
	}

	private function createWindow():Void
	{
		if (_window != null)
			return;

		_window = new FlxWindowPOC(20, 100, 800, 100);

		// Return focus to main window so keypresses work
		FlxG.game.stage.window.focus();

		// Add Window to MovieClip, as FlxGame's Document is added to its MovieClip
		cast(_window._win.stage.getChildByName("mc"), DisplayObjectContainer).addChild(_window);

		// Create a moving sprite
		// This will increase the leak rate but really you just need the camera to render its
		// background to get a leak.
		_s2 = new FlxSprite(100, 0);
		_s2.makeGraphic(20, 20, FlxColor.GREEN);
		_s2.cameras = [_window._camera];
		_s2.velocity.x = _rand.float(100, 200);
		_s2.velocity.y = _rand.float(100, 200);

		add(_s2);
	}

	override public function update(elapsed:Float)
	{
		super.update(elapsed);

		if (_window == null && FlxG.keys.justReleased.A)
		{
			createWindow();
		}

		// Dump recursive tree of Lime Modules and Openfl stage objects
		if (FlxG.keys.justReleased.D)
		{
			printModules(6);
		}

		// Make sure FlxSprites never leave the windows
		if (_s1.x > FlxG.width || _s1.x < 0)
			_s1.velocity.x *= -1;
		if (_s1.y > FlxG.height || _s1.y < 0)
			_s1.velocity.y *= -1;

		if (_s2 != null)
		{
			if (_s2.x > _window._win.width || _s2.x < 0)
				_s2.velocity.x *= -1;
			if (_s2.y > _window._win.height || _s2.y < 0)
				_s2.velocity.y *= -1;
		}
	}

	/// ----- Debug code below here, for dumping the DisplayObject hierarchy
	private function printModules(depth:Int = 10000):Void
	{
		var appModules = FlxG.game.stage.application.modules;
		trace('Modules and stage hierarchy');
		for (i => m in appModules)
		{
			var mS = '  Module[$i]=${m}';
			if (Std.isOfType(m, Stage))
			{
				var s = cast(m, Stage);
				trace('${mS}, color=${s.color}, ${s.name}');
				printStageHierarchy(s, depth - 1);
			}
			else
			{
				trace(${mS});
			}
		}
	}

	private function printStageHierarchy(s:Stage, depth:Int):Void
	{
		for (i in 0...s.numChildren)
		{
			var c = s.getChildAt(i);
			trace('  child[$i]=${c}, ${c.name}');
			if (Std.isOfType(c, DisplayObject))
			{
				if (depth > 0)
				{
					printChildren(cast(c, DisplayObject), 4, depth - 1);
				}
				else if (s.numChildren > 0)
				{
					trace('  ---- depth limit reached ----');
				}
			}
		}
	}

	@:access(openfl.display.DisplayObject.__children)
	private function printChildren(doc:DisplayObject, indent:Int, depth:Int):Void
	{
		if (doc.__children != null)
		{
			for (i => c in doc.__children)
			{
				var idt = [for (i in 0...indent) " "].join("");
				trace('${idt}child[$i]=${c}, ${c.name}');
				if (depth > 0)
					printChildren(c, indent + 2, depth - 1);
				else if (c.__children != null && c.__children.length > 0)
				{
					trace('${idt}---- depth limit reached ----');
				}
			}
		}
	}
}
