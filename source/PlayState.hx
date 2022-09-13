package;

import flixel.FlxCamera;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.FlxState;
import flixel.math.FlxRandom;
import flixel.util.FlxColor;
import openfl.display.Bitmap;
import openfl.display.BitmapData;
import openfl.display.DisplayObject;
import openfl.display.DisplayObjectContainer;
import openfl.display.Stage;

class PlayState extends FlxState
{
	// The second window size constants.
	final WIN_WIDTH = 800;
	final WIN_HEIGHT = 100;

	public var _window:FlxWindowPOC;

	public var _s1:FlxSprite; // Main window flixel test sprite
	public var _s2:FlxSprite; // Second window flixel test sprite

	var _ofCamera:FlxCamera; // Second camera that will be copied to the second window
	var _ofBitmap:Bitmap; // OpenFL test block
	var _ofSpeedX:Float; // OpenFL test block X speed
	var _ofSpeedY:Float; // OpenFL test block Y speed
	var _ofBgBitmap:Bitmap;

	var _rand:FlxRandom;

	// Use HaxeFlixel FlxCamera in second window or not
	final useWindowCamera:Bool = false;

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
		// _s1.cameras = [FlxG.camera];

		add(_s1);

		_s1.velocity.x = _rand.float(100, 200);
		_s1.velocity.y = _rand.float(100, 200);

		// Setup second camera which will be copied to the second window.
		_ofCamera = new FlxCamera(0, -2 * WIN_HEIGHT, WIN_WIDTH, WIN_HEIGHT);
		FlxG.cameras.add(_ofCamera, true);

		// Create the second window's test flixel sprite
		_s2 = new FlxSprite(0, 0);
		_s2.makeGraphic(20, 20, FlxColor.GREEN);
		_s2.cameras = [_ofCamera];
		add(_s2);
		_s2.velocity.x = _rand.float(100, 200);
		_s2.velocity.y = _rand.float(100, 200);
	}

	private function createWindow():Void
	{
		if (_window != null)
			return;

		_window = new FlxWindowPOC(20, 100, WIN_WIDTH, WIN_HEIGHT); // , false);

		// Return focus to main window so keypresses work
		FlxG.game.stage.window.focus();

		// Add Window to MovieClip, as FlxGame's Document is added to its MovieClip
		// This will cause the FlxWindowPOC create() function to be called to complete
		// window setup.
		cast(_window._win.stage.getChildByName("mc"), DisplayObjectContainer).addChild(_window);

		// Add base sprite the size of the window.
		// This BitmapData will be updated by drawing the ofCamera.canvas onto itself.
		// It is added to the display list of the second window.
		_ofBgBitmap = new Bitmap(new BitmapData(WIN_WIDTH, WIN_HEIGHT, false, FlxColor.PINK));
		_window.addChild(_ofBgBitmap);

		// add demo sprite
		var bmd = new BitmapData(50, 50, false, FlxColor.RED);
		_ofBitmap = new Bitmap(bmd);
		_window.addChild(_ofBitmap);
		_ofBitmap.x = 100;
		_ofSpeedX = 10;
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
			if (_s2.x > WIN_WIDTH || _s2.x < 0)
				_s2.velocity.x *= -1;
			if (_s2.y > WIN_HEIGHT || _s2.y < 0)
				_s2.velocity.y *= -1;
		}

		// Update the OpenFL block speed to make sure it stays within the window.
		if (_ofBitmap != null)
		{
			_ofBitmap.x += _ofSpeedX;
			_ofBitmap.y += _ofSpeedY;
			if (_ofBitmap.x > WIN_WIDTH || _ofBitmap.x < 0)
				_ofSpeedX *= -1;
			if (_ofBitmap.y > WIN_HEIGHT || _ofBitmap.y < 0)
				_ofSpeedY *= -1;
		}

		// Copy _ofCamera pixels to the _ofBgBitmap
		if (_ofBgBitmap != null && _ofCamera != null)
		{
			// This is the heart of the second window function. This
			// copies the rendered image BitmapData from the camera to
			// to the BitmapData which is on the second window.
			_ofBgBitmap.bitmapData.draw(_ofCamera.canvas);
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
