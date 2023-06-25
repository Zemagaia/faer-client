package objects;

import map.Camera;
import util.Utils;
import haxe.ds.IntMap;

using util.Utils.XmlUtil;

class ObjectProperties {
	public var objType = 0;
	public var objId = "";
	public var displayId = "";
	public var isPlayer = false;
	public var isEnemy = false;
	public var drawOnGround = false;
	public var drawUnder = false;
	public var occupySquare = false;
	public var fullOccupy = false;
	public var enemyOccupySquare = false;
	public var staticObj = false;
	public var noMiniMap = false;
	public var protectFromGroundDamage = false;
	public var protectFromSink = false;
	public var baseZ = 0.0;
	public var flying = false;
	public var color = 0xFFFFFF;
	public var showName = false;
	public var dontFaceAttacks = false;
	public var bloodProb = 0.0;
	public var bloodColor = 0xFF0000;
	public var sounds: IntMap<String> = null;
	public var portrait: TextureData = null;
	public var minSize = 100;
	public var maxSize = 100;
	public var sizeStep = 5;
	public var whileMoving: WhileMovingProperties = null;
	public var oldSound = "";
	public var projectiles: IntMap<ProjectileProperties>;
	public var angleCorrection = 0.0;
	public var rotation = 0.0;
	public var floating = false;
	public var floatTime = 0;
	public var floatHeight = 0.0;
	public var floatSine = false;
	public var lightColor = -1;
	public var lightIntensity = 0.1;
	public var lightRadius = 1.0;
	public var sortPriority = 0.0;
	public var showEffects: Array<ShowEffectProperties> = null;

	public function new(objectXml: Xml) {
		var bulletType = 0;
		this.projectiles = new IntMap<ProjectileProperties>();
		if (objectXml == null)
			return;

		this.objType = objectXml.intAttribute("type");
		this.objId = objectXml.attribute("id");
		this.displayId = objectXml.element("DisplayId", this.objId);
		this.isPlayer = objectXml.elementExists("Player");
		this.isEnemy = objectXml.elementExists("Enemy");
		this.drawOnGround = objectXml.elementExists("DrawOnGround");
		if (this.drawOnGround || objectXml.elementExists("DrawUnder"))
			this.drawUnder = true;

		this.occupySquare = objectXml.elementExists("OccupySquare");
		this.fullOccupy = objectXml.elementExists("FullOccupy");
		this.enemyOccupySquare = objectXml.elementExists("EnemyOccupySquare");
		this.staticObj = objectXml.elementExists("Static");
		this.noMiniMap = objectXml.elementExists("NoMiniMap");
		this.protectFromGroundDamage = objectXml.elementExists("ProtectFromGroundDamage");
		this.protectFromSink = objectXml.elementExists("ProtectFromSink");
		this.flying = objectXml.elementExists("Flying");
		this.showName = objectXml.elementExists("ShowName");
		this.dontFaceAttacks = objectXml.elementExists("DontFaceAttacks");
		this.floating = objectXml.elementExists("Float");
		if (this.floating) {
			var floatXml = objectXml.elementsNamed("Float").next();
			this.floatSine = floatXml.attribute("sine") == "true";
			this.floatTime = floatXml.intAttribute("time", 500);
			this.floatHeight = floatXml.floatAttribute("height", 0.5);
		}

		this.baseZ = objectXml.floatElement("Z");
		this.color = objectXml.intElement("Color", 0xFFFFFF);
		this.lightColor = objectXml.intElement("LightColor", -1);
		this.lightIntensity = objectXml.floatElement("LightIntensity", 0.1);
		this.lightRadius = objectXml.floatElement("LightRadius", 1);
		this.sortPriority = objectXml.floatElement("SortPriority") * Camera.PX_PER_TILE;

		if (objectXml.elementExists("Size"))
			this.minSize = this.maxSize = objectXml.intElement("Size", 100);
		else {
			this.minSize = objectXml.intElement("MinSize", 100);
			this.maxSize = objectXml.intElement("MaxSize", 100);
			this.sizeStep = objectXml.intElement("SizeStep", 5);
		}

		this.oldSound = objectXml.element("OldSound", null);
		for (xml in objectXml.elementsNamed("Projectile")) {
			bulletType = xml.intAttribute("id");
			this.projectiles.set(bulletType, new ProjectileProperties(xml));
		}

		this.showEffects = new Array<ShowEffectProperties>();
		for (xml in objectXml.elementsNamed("ShowEffect"))
			this.showEffects.push(new ShowEffectProperties(xml));

		this.angleCorrection = objectXml.floatElement("AngleCorrection") * (MathUtil.PI / 4);
		this.rotation = objectXml.floatElement("Rotation");

		for (xml in objectXml.elementsNamed("BloodProb"))
			this.bloodProb = xml.intValue();

		for (xml in objectXml.elementsNamed("BloodColor"))
			this.bloodColor = xml.intValue();

		for (soundXML in objectXml.elementsNamed("Sound")) {
			if (this.sounds == null)
				this.sounds = new IntMap<String>();

			this.sounds.set(soundXML.intAttribute("id"), soundXML.value());
		}

		for (xml in objectXml.elementsNamed("Portrait"))
			this.portrait = new TextureData(xml);

		for (xml in objectXml.elementsNamed("WhileMoving"))
			this.whileMoving = new WhileMovingProperties(xml);
	}

	public function getSize() {
		if (this.minSize == this.maxSize)
			return Std.int(this.minSize * 1.25);

		var maxSteps: Int = Math.round((this.maxSize - this.minSize) / this.sizeStep);
		return Std.int((this.minSize + Math.round(Math.random() * maxSteps) * this.sizeStep) * 1.25);
	}
}

class ShowEffectProperties {
	public var effType = "";
	public var radius = 0;
	public var cooldown = 0;
	public var color = 0;

	public function new(showEffXML: Xml) {
		this.effType = showEffXML.value();
		this.radius = showEffXML.intAttribute("radius");
		this.cooldown = showEffXML.intAttribute("cooldown");
		this.color = showEffXML.intAttribute("color");
	}
}

class WhileMovingProperties {
	public var z = 0.0;
	public var flying = false;

	public function new(whileMovingXML: Xml) {
		this.z = whileMovingXML.floatElement("Z");
		this.flying = whileMovingXML.elementExists("Flying");
	}
}
