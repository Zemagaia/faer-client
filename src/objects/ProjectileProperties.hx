package objects;

import openfl.utils.ByteArray;
import util.Utils.MathUtil;
import util.NativeTypes;
import util.ConditionEffect;

using util.Utils.XmlUtil;

class ProjectileProperties {
	public var bulletType = 0;
	public var objectId = "";
	public var objType = 0;
	public var angleCorrection = 0.0;
	public var rotation = 0.0;
	public var lightColor = 0;
	public var lightIntensity = 0.0;
	public var lightRadius = 0.0;
	public var lifetime = 0;
	public var speed: Float32 = 0.0;
	public var realSpeed = 0;
	public var size = 0;
	public var physicalDamage = 0;
	public var magicDamage = 0;
	public var trueDamage = 0;
	public var effects: Array<Int32> = null;
	public var multiHit = false;
	public var armorPiercing = false;
	public var particleTrail = false;
	public var wavy = false;
	public var parametric = false;
	public var boomerang = false;
	public var amplitude: Float32 = 0.0;
	public var frequency: Float32 = 0.0;
	public var magnitude: Float32 = 0.0;
	public var acceleration: Float32 = 0.0;
	public var accelerationDelay = 0;
	public var speedClamp: Float32 = 0.0;
	public var angleChange: Float32 = 0.0;
	public var angleChangeDelay = 0;
	public var angleChangeEnd = 0;
	public var angleChangeAccel: Float32 = 0.0;
	public var angleChangeAccelDelay = 0;
	public var angleChangeClamp: Float32 = 0.0;
	public var zeroVelocityDelay = 0;
	public var heatSeekSpeed: Float32 = 0.0;
	public var heatSeekRadius: Float32 = 0.0;
	public var heatSeekDelay: Float32 = 0;

	public function new(projectileXml: Xml) {
		this.bulletType = projectileXml.intAttribute("id");
		this.objectId = projectileXml.element("ObjectId");
		this.objType = ObjectLibrary.idToType.get(this.objectId);
		var objectXml = ObjectLibrary.xmlLibrary.get(this.objType);
		if (objectXml != null) {
			this.angleCorrection = objectXml.floatElement("AngleCorrection") * (MathUtil.PI / 4);
			this.rotation = objectXml.floatElement("Rotation");
			this.lightColor = objectXml.intElement("LightColor", -1);
			this.lightIntensity = objectXml.floatElement("LightIntensity", 0.1);
			this.lightRadius = objectXml.floatElement("LightRadius", 1);
		}
		this.lifetime = projectileXml.intElement("LifetimeMS");
		this.realSpeed = projectileXml.intElement("Speed");
		this.speed = this.realSpeed / 10000.0;
		this.size = projectileXml.intElement("Size", -1);
		this.physicalDamage = projectileXml.intElement("Damage");
		this.magicDamage = projectileXml.intElement("MagicDamage");
		this.trueDamage = projectileXml.intElement("TrueDamage");

		for (condEffectXML in projectileXml.elementsNamed("ConditionEffect")) {
			if (this.effects == null)
				this.effects = new Array<Int32>();
			this.effects.push(ConditionEffect.getConditionEffectFromName(condEffectXML.firstChild().nodeValue));
		}

		this.multiHit = projectileXml.elementExists("MultiHit");
		this.armorPiercing = projectileXml.elementExists("ArmorPiercing");
		this.particleTrail = projectileXml.elementExists("ParticleTrail");
		this.wavy = projectileXml.elementExists("Wavy");
		this.parametric = projectileXml.elementExists("Parametric");
		this.boomerang = projectileXml.elementExists("Boomerang");
		this.amplitude = projectileXml.floatElement("Amplitude");
		this.frequency = projectileXml.floatElement("Frequency", 1);
		this.magnitude = projectileXml.floatElement("Magnitude", 3);
		this.acceleration = projectileXml.floatElement("Acceleration");
		this.accelerationDelay = projectileXml.intElement("AccelerationDelay");
		this.speedClamp = projectileXml.floatElement("SpeedClamp", -1);
		this.angleChange = projectileXml.floatElement("AngleChange") * MathUtil.TO_RAD;
		this.angleChangeDelay = projectileXml.intElement("AngleChangeDelay");
		this.angleChangeEnd = projectileXml.intElement("AngleChangeEnd", MathUtil.INT_MAX);
		this.angleChangeAccel = projectileXml.floatElement("AngleChangeAccel") * MathUtil.TO_RAD;
		this.angleChangeAccelDelay = projectileXml.intElement("AngleChangeAccelDelay");
		this.angleChangeClamp = projectileXml.floatElement("AngleChangeClamp") * MathUtil.TO_RAD;
		this.zeroVelocityDelay = projectileXml.intElement("ZeroVelocityDelay", -1);
		this.heatSeekSpeed = projectileXml.floatElement("HeatSeekSpeed") / 10000.0;
		this.heatSeekRadius = projectileXml.floatElement("HeatSeekRadius");
		this.heatSeekDelay = projectileXml.intElement("HeatSeekDelay");
	}
}
