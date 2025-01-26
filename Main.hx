package;

import sys.io.File;
import haxe.Json;

class Main {
	static function main() {
		// INIT
		var args = Sys.args();
		var argsLen = args.length;

		// START
		var plotContent = File.getContent(args[0]);
		var plot = Json.parse(plotContent);

		var o = File.write(args[1]);

		var instructions = plot.contents.instructions;

		for (i in 0...instructions.length) {
			var instruction = instructions[i];
			var type:String = instruction.type;
			var parameters = instruction.parameters;

			switch (type) {
				case "textPlate":
					var text = parameters.text;
					var foundTransparency = false;
					var transparencyValue = 1.0;
					if (StringTools.contains(text, '/transparent')) {
						foundTransparency = true;
						var transparency = text.split(" ")[1];
						transparencyValue = Std.parseFloat(transparency);
						text = StringTools.trim(StringTools.replace(StringTools.trim(text), '/transparent $transparency ', ""));
					}
					var howManySeconds = StringTools.contains(text, '/settime') ? text.split(" ")[1] : "a couple";
					text = StringTools.trim(StringTools.replace(StringTools.trim(text), '/settime $howManySeconds', ""));
					var whatDoesItSay = "nothing";
					if (text != "") {
						whatDoesItSay = text;
					}
					o.writeString('(TEXTPLATE) $whatDoesItSay - ');
					if (howManySeconds != "a couple") o.writeString('It lasts $howManySeconds seconds. ');
					if (foundTransparency) o.writeString('The opacity is set to ${Math.floor(transparencyValue * 100)}%. ');
					o.writeString('The alignment is at ${parameters.alignment.toUpperCase()}.\n\n');
				case "effect":
					var info = parameters.effectsName[0]; //??????????????????????????????????????? what the fuck was plotagon smoking when they wrote this as an array
					switch (info.EffectName) {
						case "FadeInB":
							o.writeString("The Screen fades in black.");
						case "FadeOutB":
							o.writeString("The Screen fades out black. ");
						case "FadeInBl":
							o.writeString("The Screen fades in blur. ");
						case "FadeOutBl":
							o.writeString("The Screen fades out blur. ");
						case "FadeInW":
							o.writeString("The Screen fades in white. ");
						case "FadeOutW":
							o.writeString("The Screen fades out white. ");
						case "FadeInP":
							o.writeString("The Screen fades in pixels. ");
						case "FadeOutP":
							o.writeString("The Screen fades out pixels. ");
						case "SetFov":
							o.writeString('The field of view is changed to ${Math.floor((Math.max(Math.min(info.EffectValue, 1.5), 0.5)) * 100)}%. ');
					}
					o.writeString('\n\n');
				case "scene":
					o.writeString('(SCENE) ${parameters.scene.text} ');
					o.writeString('featuring ${parameters.actor1.text} ${parameters.location1.text}');
					if (parameters.actor2 != null) o.writeString(' and ${parameters.actor2.text} ${parameters.location2.text}.');
					if (parameters.camera != null) {
						var camera = parameters.camera;
						o.writeString(' The camera is at ${camera.type.name.toLowerCase()}.');
					}
					o.writeString('\n\n');
				case "dialogue":
					var text = (cast parameters.text).text;
					var character = parameters.character.text;
					var expression = parameters.expression.text;

					// This corrects the expression for the current dialogue line.
					switch (expression) {
						case "Rage":
							expression = "Raging";
						case "Look left":
							expression = "Looking left";
						case "Look down":
							expression = "Looking down";
						case "Look up":
							expression = "Looking up";
						case "Look right":
							expression = "Looking right";
						case "Rage contained":
							expression = "About to rage";
					}

					var howManySeconds = StringTools.contains(text, '/settime') ? 'for ${text.split(" ")[1]} seconds ' : "";
					text = StringTools.trim(StringTools.replace(StringTools.trim(text), '/settime ${text.split(" ")[1]}', ""));
					var whatDoesItSay = "(foreign)";

					if (text != "") {
						whatDoesItSay = text;
					}
					o.writeString('$character (${expression.toUpperCase()}): $whatDoesItSay');

					var whatElse = "dialogue";
					if (instructions[i+1].type == "scene") whatElse = "scene";
					o.writeString(' - The dialogue is played out ${howManySeconds}before heading to the next $whatElse.');
					o.writeString('\n\n');
				case "action":
					var character = parameters.character.text;
					var target = parameters.target.text;
					var action = parameters.action.text;
					o.writeString('$character $action $target!');
					o.writeString('\n\n');
				case "sound":
					var sound = parameters.sound.text;
					var whatSubject = parameters.sound.id == null ? "External sound" : "The sound";
					o.writeString('$whatSubject "$sound" is played.');

					o.writeString('\n\n');
				case "music":
					var music = parameters.music.text;
					var whatSubject = parameters.music.id == null ? "External music" : "The music";

					if (music == "Music Stops") o.writeString('The music stops.');
					else o.writeString('$whatSubject "$music" is now playing.');

					o.writeString('\n\n');
			}
		}
	}
}