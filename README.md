# TwoWindows

This is demonstration of a multi-window prototype for HaxeFlixel which now works without leaking or crashing on HL and CPP on Windows.

This uses flixel, openfl and lime. Versions tested are:

haxelib list
flixel: [4.11.0]
lime: [8.0.0]
openfl: [9.2.0]

It uses the technique of rendering to a camera which is off-screen and then copying its canvas to a Bitmap on the second window.