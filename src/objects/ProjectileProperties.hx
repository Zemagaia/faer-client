package objects;

import openfl.utils.ByteArray;
import util.Utils.MathUtil;
import util.NativeTypes;
import util.ConditionEffect;

using util.Utils.XmlUtil;

class ProjectileProperties {
	public var bulletType = 0;
	public var objectId = "";
	public var lifetime = 0;
	public var speed = 0.0;
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
	public var amplitude = 0.0;
	public var frequency = 0.0;
	public var magnitude = 0.0;
	public var acceleration = 0.0;
	public var accelerationDelay = 0;
	public var speedClamp = 0.0;
	public var angleChange = 0.0;
	public var angleChangeDelay = 0;
	public var angleChangeEnd = 0;
	public var zeroVelocityDelay = 0;
	public var heatSeekSpeed = 0.0;
	public var heatSeekRadius = 0.0;
	public var heatSeekDelay = 0;

	public function new(projectileXML: Xml) {
		this.bulletType = projectileXML.intAttribute("id");
		this.objectId = projectileXML.element("ObjectId");
		this.lifetime = projectileXML.intElement("LifetimeMS");
		this.realSpeed = projectileXML.intElement("Speed");
		this.speed = this.realSpeed / 10000.0;
		this.size = projectileXML.intElement("Size", -1);
		this.physicalDamage = projectileXML.intElement("Damage");
		this.magicDamage = projectileXML.intElement("MagicDamage");
		this.trueDamage = projectileXML.intElement("TrueDamage");

		for (condEffectXML in projectileXML.elementsNamed("ConditionEffect")) {
			if (this.effects == null)
				this.effects = new Array<Int32>();
			this.effects.push(ConditionEffect.getConditionEffectFromName(condEffectXML.firstChild().nodeValue));
		}

		this.multiHit = projectileXML.elementExists("MultiHit");
		this.armorPiercing = projectileXML.elementExists("ArmorPiercing");
		this.particleTrail = projectileXML.elementExists("ParticleTrail");
		this.wavy = projectileXML.elementExists("Wavy");
		this.parametric = projectileXML.elementExists("Parametric");
		this.boomerang = projectileXML.elementExists("Boomerang");
		this.amplitude = projectileXML.floatElement("Amplitude");
		this.frequency = projectileXML.floatElement("Frequency", 1);
		this.magnitude = projectileXML.floatElement("Magnitude", 3);
		this.acceleration = projectileXML.floatElement("Acceleration");
		this.accelerationDelay = projectileXML.intElement("AccelerationDelay");
		this.speedClamp = projectileXML.floatElement("SpeedClamp", -1);
		this.angleChange = projectileXML.floatElement("AngleChange") * MathUtil.TO_RAD;
		this.angleChangeDelay = projectileXML.intElement("AngleChangeDelay");
		this.angleChangeEnd = projectileXML.intElement("AngleChangeEnd", MathUtil.INT_MAX);
		this.zeroVelocityDelay = projectileXML.intElement("ZeroVelocityDelay", -1);
		this.heatSeekSpeed = projectileXML.floatElement("HeatSeekStrength");
		this.heatSeekRadius = projectileXML.floatElement("HeatSeekRadius");
		this.heatSeekDelay = projectileXML.intElement("HeatSeekDelay");
	}
}
