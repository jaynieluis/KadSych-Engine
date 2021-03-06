package options;

#if desktop
import Discord.DiscordClient;
#end
import flash.text.TextField;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.addons.display.FlxGridOverlay;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.math.FlxMath;
import flixel.text.FlxText;
import flixel.util.FlxColor;
import lime.utils.Assets;
import flixel.FlxSubState;
import flash.text.TextField;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.util.FlxSave;
import haxe.Json;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.util.FlxTimer;
import flixel.input.keyboard.FlxKey;
import flixel.graphics.FlxGraphic;
import Controls;

using StringTools;

class OptionsState extends MusicBeatState
{
	var options:Array<String> = ['Keybinds', 'Apperance', 'Gameplay', 'Misc'];
	private var grpOptions:FlxTypedGroup<Alphabet>;
	private static var curSelected:Int = 0;
	public static var menuBG:FlxSprite;
	static var goToPlayState:Bool = false;
    var blackBorder:FlxSprite;
	public static var versionShit:FlxText;

	function openSelectedSubstate(label:String) {
		switch(label) {
			case 'Keybinds':
				openSubState(new options.ControlsSubState());
			case 'Misc':
				openSubState(new options.GraphicsSettingsSubState());
			case 'Apperance':
				openSubState(new options.VisualsUISubState());
			case 'Gameplay':
				openSubState(new options.GameplaySettingsSubState());
		}
	}

	public function new(?goToPlayState:Bool)
	{
		super();
		if (goToPlayState != null)
			OptionsState.goToPlayState = goToPlayState;
	}

	var selectorLeft:Alphabet;
	var selectorRight:Alphabet;

	override function create() {
		#if desktop
		DiscordClient.changePresence("Options Menu", null);
		#end

		var bg:FlxSprite = new FlxSprite().loadGraphic(Paths.image('menuDesat'));
		bg.color = 0xFFea71fd;
		bg.updateHitbox();

		bg.screenCenter();
		bg.antialiasing = ClientPrefs.globalAntialiasing;
		add(bg);

		grpOptions = new FlxTypedGroup<Alphabet>();
		add(grpOptions);

		for (i in 0...options.length)
		{
			var optionText:Alphabet = new Alphabet(0, 70 * i, options[i], true, false);
			optionText.isMenuItem = true;
			optionText.x -= 100;
			/*optionText.forceX = 300;
			optionText.yMult = 90;*/
			optionText.xAdd = 0;
			optionText.targetY = i;
			grpOptions.add(optionText);
		}
		
		selectorLeft = new Alphabet(0, 0, '', true, false);
		add(selectorLeft);
		selectorRight = new Alphabet(0, 0, '', true, false);
		add(selectorRight);

		versionShit = new FlxText(5, FlxG.height + 40, 0, "KadSych Engine " + MainMenuState.kadSychEngineVersion, 12);
		versionShit.scrollFactor.set();
		versionShit.setFormat("VCR OSD Mono", 16, FlxColor.WHITE, LEFT, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		
		blackBorder = new FlxSprite(-30,FlxG.height + 40).makeGraphic((Std.int(versionShit.width + 900)),Std.int(versionShit.height + 600),FlxColor.BLACK);
		blackBorder.alpha = 0.5;

		add(blackBorder);

		add(versionShit);
		
		changeSelection();
		ClientPrefs.saveSettings();

		super.create();
	}

	override function closeSubState() {
		super.closeSubState();
		ClientPrefs.saveSettings();
	}

	override function update(elapsed:Float) {
		super.update(elapsed);

		if (controls.UI_UP_P) {
			changeSelection(-1);
		}
		if (controls.UI_DOWN_P) {
			changeSelection(1);
		}

		if (controls.BACK) {
			FlxG.sound.play(Paths.sound('cancelMenu'));
			if (goToPlayState) {
				StageData.loadDirectory(PlayState.SONG);
				goToPlayState = false;
				LoadingState.loadAndSwitchState(new PlayState(), true);
			} else {
				MusicBeatState.switchState(new MainMenuState());
			}
		}

		if (controls.ACCEPT) {
			openSelectedSubstate(options[curSelected]);
		}
	}
	
	function changeSelection(change:Int = 0) {
		curSelected += change;
		if (curSelected < 0)
			curSelected = options.length - 1;
		if (curSelected >= options.length)
			curSelected = 0;

		var bullShit:Int = 0;

		for (item in grpOptions.members) {
			item.targetY = bullShit - curSelected;
			bullShit++;

			item.alpha = 0.6;
			if (item.targetY == 0) {
				item.alpha = 1;
				selectorLeft.x = item.x - 63;
				selectorLeft.y = item.y;
				selectorRight.x = item.x + item.width + 15;
				selectorRight.y = item.y;
			}
		}
		FlxG.sound.play(Paths.sound('scrollMenu'));
	}
}