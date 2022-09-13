package;

import flixel.FlxG;
import flixel.util.FlxColor;
import openfl.display.Sprite;
import openfl.display.StageAlign;
import openfl.display.StageScaleMode;
import openfl.events.Event;

/**
 * FlxWindowPOC houses the lime.ui.window. To some extent this mimics the Sprites
 * used in FlxGame. This window has no camera but a camera is
 * created by the application and added to the stage of this window. Content is then
 * copied to this sprite. Future revisions will integrate these more.
 */
class FlxWindowPOC extends Sprite
{
	public var _win:lime.ui.Window;

	var _inputContainer:Sprite;

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

	/**
	 * Create is called once this FlxWindowPOC object is added to the stage. This
	 * is done by the application (PlayState) after this object is completed. This
	 * function then completes the setup. Some of this could likely be streamlined
	 * as it was originally done this way to setup a full camera and Sprite hierarchy.
	 * @param _ 
	 */
	function create(_):Void
	{
		if (stage == null)
		{
			return;
		}
		trace('create called stage=${stage}');
		_win.stage.name = '2ndStage';

		removeEventListener(Event.ADDED_TO_STAGE, create);

		// Set up the view window and double buffering
		// It is unclear if this is needed
		_win.stage.scaleMode = StageScaleMode.NO_SCALE;
		_win.stage.align = StageAlign.TOP_LEFT;
		_win.stage.frameRate = FlxG.drawFramerate;

		// Add the window openFL Sprite to the stage
		_inputContainer.name = 'ic';
		addChild(_inputContainer);
	}
}
