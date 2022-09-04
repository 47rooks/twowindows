package;

import flixel.FlxCamera;
import flixel.FlxG;
import flixel.util.FlxColor;
import openfl.display.Sprite;
import openfl.display.StageAlign;
import openfl.display.StageScaleMode;
import openfl.events.Event;

/**
 * FlxWindowPOC mimics the ApplicationMain/FlxGame setup as regards the
 * Sprites and hierarchy. Sprites are labelled (name) for debugging
 * purposes to show the hierarchy. There is no DocumentClass but otherwise
 * the hierarchy is a good match. And there is no preloader.
 */
class FlxWindowPOC extends Sprite
{
	public var _win:lime.ui.Window;

	var _inputContainer:Sprite;

	public var _camera:FlxCamera;

	public function new(x:Int, y:Int, width:Int, height:Int)
	{
		super();

		_inputContainer = new Sprite();

		var attributes:lime.ui.WindowAttributes = {
			allowHighDPI: false,
			alwaysOnTop: false,
			borderless: false,
			// display: 0,
			element: null,
			frameRate: 60,
			#if !web
			fullscreen: false,
			#end
			height: height,
			hidden: #if munit true #else false #end,
			maximized: false,
			minimized: false,
			parameters: {},
			resizable: true,
			title: "Win2",
			width: width,
			x: null,
			y: null
		};

		attributes.context = {
			antialiasing: 0,
			background: 0,
			colorDepth: 32,
			depth: true,
			hardware: true,
			stencil: true,
			type: null,
			vsync: false
		};
		_win = FlxG.stage.application.createWindow(attributes);
		_win.stage.color = FlxColor.ORANGE;
		_win.x = x;
		_win.y = y;

		trace('new window stage=${_win.stage}');
		trace('adding DOC to stage');
		var mc = new openfl.display.MovieClip();
		mc.name = 'mc';
		_win.stage.addChildAt(mc, 0);
		trace('added DOC to stage');

		trace('registering added to stage listener');
		addEventListener(Event.ADDED_TO_STAGE, create);
		trace('registered added to stage listener');
	}

	@:access(flixel.FlxCamera._scrollRect)
	function create(_):Void
	{
		if (stage == null)
		{
			trace('stage is null');
			return;
		}
		trace('create called stage=${stage}');
		removeEventListener(Event.ADDED_TO_STAGE, create);

		// Set up the view window and double buffering
		stage.scaleMode = StageScaleMode.NO_SCALE;
		stage.align = StageAlign.TOP_LEFT;
		stage.frameRate = FlxG.drawFramerate;

		// Add the window openFL Sprite to the stage
		_inputContainer.name = 'ic';
		addChild(_inputContainer);

		// Create the camera and label all the Sprites for debug purposes
		_camera = new FlxCamera(0, 0, _win.width, _win.height);
		_camera.bgColor = FlxColor.PINK;
		_camera.flashSprite.name = 'camera_flashsprite';
		_camera._scrollRect.name = 'camera_scrollRect';
		_camera.canvas.name = 'camera_canvas';
		_camera.debugLayer.name = 'camera_debugLayer';

		// Add camera openFL Sprite to the stage at the same place in the display list
		// Not sure if this before or after the _inputContainer
		addChildAt(_camera.flashSprite, getChildIndex(_inputContainer));

		_win.stage.addEventListener(Event.ENTER_FRAME, onEnterFrame);
	}

	function onEnterFrame(_):Void
	{
		// trace('onEnterFrame');
		draw();
	}

	@:allow(flixel.FlxGame)
	@:access(flixel.FlxGame.draw)
	@:access(flixel.FlxCamera.clearDrawStack)
	@:access(flixel.FlxCamera.render)
	function draw():Void
	{
		// This is a hack to be able to call render. This would be done the other way around in a real
		// implementation where FlxCamera.render would have @:allow(FlxWindow)
		// Most of this function is a ripoff from FlxCameraFrontEnd. It should not be done this way.
		// But as a quick proof that you can even draw on another window it works.

		// These are current attempts to get the sprite move without leaving a trail behind.
		// This is basically pointless. It would be best to move to using a frontend I think.
		_camera.clearDrawStack();
		_camera.canvas.graphics.clear();
		_camera.flashSprite.graphics.clear();

		_camera.fill(_camera.bgColor.to24Bit(), _camera.useBgAlphaBlending, _camera.bgColor.alphaFloat);

		// This is a second call to draw but it doesn't itself cause the leak. You can still leak with
		// just the camera render. But having this here mimics the way the cameras work on the main
		// window.
		FlxG.state.draw();

		_camera.render();
	}
}
