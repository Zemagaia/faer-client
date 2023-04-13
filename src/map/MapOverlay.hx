package map;

import haxe.ds.IntMap;
import haxe.ds.Vector;
import openfl.display.Sprite;

class MapOverlay extends Sprite {
	private var speechBalloons: IntMap<SpeechBalloon>;
	private var statusTexts: Vector<CharacterStatusText>;
	private var statusTextIdx = 0;

	public function new() {
		super();

		mouseEnabled = false;
		mouseChildren = false;

		this.speechBalloons = new IntMap<SpeechBalloon>();
		this.statusTexts = new Vector<CharacterStatusText>(64);
	}

	public function addSpeechBalloon(sb: SpeechBalloon) {
		var id: Int = sb.go.objectId;
		var currentBalloon: SpeechBalloon = this.speechBalloons.get(id);
		if (currentBalloon != null && contains(currentBalloon))
			removeChild(currentBalloon);

		this.speechBalloons.set(id, sb);
		addChild(sb);
	}

	public function addStatusText(text: CharacterStatusText) {
		this.statusTexts[statusTextIdx++ % 64] = text;
		addChild(text);
	}

	public #if !tracing inline #end function draw(time: Int) {
		for (text in this.statusTexts) {
			if (text == null || text.disposed)
				continue;

			if (!text.draw(time))
				text.dispose();
		}

		for (sb in this.speechBalloons)
			if (!sb.disposed && !sb.draw(time))
				sb.dispose();
	}
}
