package objects;

import network.NetworkHandler;
import haxe.ds.IntMap;
import map.Map;
import openfl.display.BitmapData;
import objects.particles.HitEffect;
import util.BloodComposition;
import util.Utils;
import util.NativeTypes;
import util.PointUtil;

using util.Utils.ArrayUtils;

class Projectile extends GameObject {
	private static var objBullIdToObjId: IntMap<Int> = new IntMap<Int>();
	private static var nextFakeObjectId = 0;

	public var containerProps: ObjectProperties;
	public var projProps: ProjectileProperties;
	public var bulletId = 0;
	public var containerType = 0;
	public var bulletType = 0;
	public var damagesEnemies = false;
	public var damagesPlayers = false;
	public var physicalDamage = 0;
	public var magicDamage = 0;
	public var trueDamage = 0;
	public var sound = "";
	public var startX = 0.0;
	public var startY = 0.0;
	public var startTime = 0;
	public var angle = 0.0;
	public var sinAngle = 0.0;
	public var cosAngle = 0.0;
	public var prevDirAngle = 0.0;
	public var bIdMod2Flip = 0;
	public var bIdMod4Flip = 0;
	public var phase = 0.0;
	public var colors: Array<UInt>;
	public var multiHitDict: IntMap<Bool>;

	private var totalAngleChange: Float32 = 0.0;
	private var zeroVelDist: Float32 = -1.0;
	private var lastDeflect: Float32 = 0.0;
	private var heatSeekFired = false;
	private var currentX = -1.0;
	private var currentY = -1.0;

	public static inline function findObjId(ownerId: Int32, bulletId: Int32) {
		return objBullIdToObjId.get(bulletId << 24 | ownerId);
	}

	public static inline function getNewObjId(ownerId: Int32, bulletId: Int32) {
		var objId = 0x7F000000 | nextFakeObjectId++;
		objBullIdToObjId.set(bulletId << 24 | ownerId, objId);
		return objId;
	}

	public static inline function removeObjId(ownerId: Int32, bulletId: Int32) {
		objBullIdToObjId.remove(bulletId << 24 | ownerId);
	}

	public static inline function disposeBullId() {
		objBullIdToObjId.clear();
	}

	public function new() {
		super(null, "Projectile");
	}

	override public function addTo(map: Map, x: Float32, y: Float32) {
		this.startX = this.currentX = x;
		this.startY = this.currentY = y;
		return super.addTo(map, x, y);
	}

	override public function removeFromMap() {
		super.removeFromMap();
		removeObjId(this.ownerId, this.bulletId);
		Global.projPool.release(this);
		if (this.multiHitDict != null) {
			this.multiHitDict.clear();
			this.multiHitDict = null;
		}
	}

	override public function update(time: Int32, dt: Int16) {
		var player: Player = null;
		var isPlayer = false;
		var isTargetAnEnemy = false;
		var sendMessage = false;
		var dead = false;
		var elapsed = time - this.startTime;
		if (elapsed > this.projProps.lifetime)
			return false;

		this.updatePosition(elapsed, dt);
		if (!this.moveTo(this.currentX, this.currentY) || curSquare != null && curSquare.tileType == 0xFF) {
			if (this.damagesPlayers)
				NetworkHandler.squareHit(time, this.bulletId, this.ownerId);
			else if (curSquare != null && curSquare.obj != null)
				map.addGameObject(new HitEffect(this.colors, 0.33, 3, this.angle, this.projProps.speed), this.currentX, this.currentY);

			return false;
		}

		if (curSquare?.obj != null
			&& (!curSquare.obj.props.isEnemy || !this.damagesEnemies)
			&& (curSquare.obj.props.enemyOccupySquare || curSquare.obj.props.occupySquare)) {
			if (this.damagesPlayers)
				NetworkHandler.otherHit(time, this.bulletId, this.ownerId, curSquare.obj.objectId);
			else
				map.addGameObject(new HitEffect(this.colors, 0.33, 3, this.angle, this.projProps.speed), this.currentX, this.currentY);

			return false;
		}

		var target = cast(this.getHit(), GameObject);
		if (target != null) {
			player = map.player;
			isPlayer = player != null;
			isTargetAnEnemy = target.props.isEnemy;
			sendMessage = isPlayer && (this.damagesPlayers || isTargetAnEnemy && this.ownerId == player.objectId);
			if (sendMessage) {
				var physDmg = GameObject.physicalDamage(this.physicalDamage, target.defense, target.condition);
				var magicDmg = GameObject.magicDamage(this.magicDamage, target.resistance, target.condition);
				var trueDmg = GameObject.trueDamage(this.trueDamage, target.condition);

				if (target == player) {
					NetworkHandler.playerHit(this.bulletId, this.ownerId);
					if (physDmg > 0)
						target.damage(this.containerType, Std.int(physDmg * player.hitMult), this.projProps.effects, false, this, 0xB02020);
					if (magicDmg > 0)
						target.damage(this.containerType, Std.int(magicDmg * player.hitMult), this.projProps.effects, false, this, 0x6E15AD);
					if (trueDmg > 0)
						target.damage(this.containerType, Std.int(trueDmg * player.hitMult), this.projProps.effects, false, this, 0xC2C2C2);
				} else if (target.props.isEnemy) {
					dead = target.hp <= (physDmg + magicDmg + trueDmg);
					NetworkHandler.enemyHit(time, this.bulletId, target.objectId, dead);
					if (physDmg > 0)
						target.damage(this.containerType, physDmg, this.projProps.effects, dead, this, 0xB02020);
					if (magicDmg > 0)
						target.damage(this.containerType, magicDmg, this.projProps.effects, dead, this, 0x6E15AD);
					if (trueDmg > 0)
						target.damage(this.containerType, trueDmg, this.projProps.effects, dead, this, 0xC2C2C2);
				} else if (!this.projProps.multiHit)
					NetworkHandler.otherHit(time, this.bulletId, this.ownerId, target.objectId);
			}

			if (this.projProps.multiHit)
				this.multiHitDict.set(target.objectId, true);
			else
				return false;
		}

		return true;
	}

	public function reset(containerType: Int32, bulletType: Int32, ownerId: Int32, bulletId: Int32, angle: Float32, startTime: Int32) {
		this.map = null;
		this.curSquare = null;
		this.objectId = -1;
		this.mapX = this.mapY = 0;
		this.containerType = containerType;
		this.bulletType = bulletType;
		this.ownerId = ownerId;
		this.bulletId = bulletId;
		this.bIdMod2Flip = (this.bulletId & 1) == 0 ? 1 : -1;
		this.bIdMod4Flip = (this.bulletId & 3) < 2 ? 1 : -1;
		this.phase = (this.bulletId & 1) == 0 ? 0 : MathUtil.PI;
		this.angle = angle % MathUtil.TAU;
		this.sinAngle = MathUtil.sin(this.angle);
		this.cosAngle = MathUtil.cos(this.angle);
		this.startTime = startTime;
		objectId = getNewObjId(this.ownerId, this.bulletId);
		this.containerProps = ObjectLibrary.propsLibrary.get(this.containerType);
		this.projProps = this.containerProps.projectiles.get(bulletType);
		this.props = ObjectLibrary.getPropsFromId(this.projProps.objectId);
		var textureData: TextureData = ObjectLibrary.typeToTextureData.get(this.props.objType);
		this.uValue = textureData.uValue;
		this.vValue = textureData.vValue;
		this.width = textureData.width;
		this.height = textureData.height;
		this.colors = BloodComposition.getColors(textureData.getTexture());
		this.damagesPlayers = this.containerProps.isEnemy;
		this.damagesEnemies = !this.damagesPlayers;
		this.sound = this.containerProps.oldSound;
		this.multiHitDict = this.projProps.multiHit ? new IntMap<Bool>() : null;
		if (this.projProps.size >= 0)
			this.size = this.projProps.size / 100;
		else
			this.size = ObjectLibrary.getSizeFromType(this.containerType) / 100;
		this.physicalDamage = this.magicDamage = this.trueDamage = 0;
		this.heatSeekFired = false;
		this.lastDeflect = 0.0;
		this.zeroVelDist = -1.0;
		this.totalAngleChange = 0.0;
	}

	public function setDamages(physicalDmg: Int32, magicDmg: Int32, trueDmg: Int32) {
		this.physicalDamage = physicalDmg;
		this.magicDamage = magicDmg;
		this.trueDamage = trueDmg;
	}

	public override function moveTo(x: Float32, y: Float32) {
		mapX = x;
		mapY = y;
		curSquare = map.lookupSquare(Std.int(x), Std.int(y));
		return curSquare != null;
	}

	public function getHit() {
		var distSqr = 0.0;
		var minDistSqr = MathUtil.FLOAT_MAX;
		var target: GameObject = null;

		var i = 0;
		while (i < map.gameObjectsLen) {
			var go = map.gameObjects.unsafeGet(i);
			if (!(damagesPlayers ? go.props.isPlayer : go.props.isEnemy)) {
				i++;
				continue;
			}

			distSqr = PointUtil.distanceSquaredXY(go.mapX, go.mapY, this.currentX, this.currentY);
			if (distSqr < 0.33 && (!this.projProps.multiHit || !(this.multiHitDict.exists(go.objectId)))) {
				if (distSqr < minDistSqr) {
					minDistSqr = distSqr;
					target = go;
				}
			}
			i++;
		}

		return target;
	}

	private function findHeatSeekingTarget(radiusSqr: Float) {
		var maxHp = MathUtil.FLOAT_MIN;
		var target: GameObject = null;

		var i = 0;
		while (i < map.gameObjectsLen) {
			var go = map.gameObjects.unsafeGet(i);

			if (!(damagesPlayers ? go.props.isPlayer : go.props.isEnemy)) {
				i++;
				continue;
			}

			if (go.maxHP > maxHp
				&& PointUtil.distanceSquaredXY(go.mapX, go.mapY, this.currentX, this.currentY) < radiusSqr
				&& (!this.projProps.multiHit || !(this.multiHitDict.exists(go.objectId)))) {
				maxHp = go.maxHP;
				target = go;
			}

			i++;
		}

		return target;
	}

	private function updatePosition(elapsed: Int32, dt: Int16, predict: Bool = false) {
		if (this.projProps.heatSeekRadius > 0 && elapsed >= this.projProps.heatSeekDelay && !this.heatSeekFired) {
			var target = this.findHeatSeekingTarget(this.projProps.heatSeekRadius * this.projProps.heatSeekRadius);
			if (target != null) {
				this.angle = Math.atan2(target.mapY - this.currentY, target.mapX - this.currentX) % MathUtil.TAU;
				this.cosAngle = MathUtil.cos(this.angle);
				this.sinAngle = MathUtil.sin(this.angle);
				this.heatSeekFired = true;
			}
		}

		var angleChange = 0.0;
		if (this.projProps.angleChange != 0 && elapsed < this.projProps.angleChangeEnd && elapsed >= this.projProps.angleChangeDelay)
			angleChange += dt / 1000.0 * this.projProps.angleChange;
		trace(angleChange, this.projProps.angleChange, this.projProps.angleChangeDelay, this.projProps.angleChangeEnd, elapsed, "2");

		if (this.projProps.angleChangeAccel != 0 && elapsed >= this.projProps.angleChangeAccelDelay)
			angleChange += dt / 1000.0 * this.projProps.angleChangeAccel * (elapsed - this.projProps.angleChangeAccelDelay) / 1000.0;
		trace(angleChange, this.projProps.angleChangeAccel, this.projProps.angleChangeAccelDelay, elapsed, "3");

		if (angleChange > 0.0) {
			var clampDt = this.projProps.angleChangeClamp - this.totalAngleChange;
			trace(angleChange, clampDt, "4");
			if (this.projProps.angleChangeClamp != 0) {
				var clampedChange = Math.min(angleChange, clampDt);
				trace(angleChange, clampDt, clampedChange, this.projProps.angleChangeClamp, this.totalAngleChange, "5");
				if (!predict)
					this.totalAngleChange += clampedChange;
				this.angle += clampedChange;
				this.cosAngle = MathUtil.cos(this.angle);
				this.sinAngle = MathUtil.sin(this.angle);
			} else if (clampDt == 0) {
				trace(angleChange, clampDt, this.totalAngleChange, "6");
				this.angle += angleChange;
				this.cosAngle = MathUtil.cos(this.angle);
				this.sinAngle = MathUtil.sin(this.angle);
			}
		}

		var dist = 0.0;
		var usesZeroVel = this.projProps.zeroVelocityDelay != -1;
		if (!usesZeroVel || this.projProps.zeroVelocityDelay > elapsed) {
			var baseSpeed = this.heatSeekFired ? this.projProps.heatSeekSpeed : this.projProps.speed;
			if (this.projProps.acceleration == 0 || elapsed < this.projProps.accelerationDelay)
				dist = dt * baseSpeed;
			else {
				var accelDist = dt * ((this.projProps.realSpeed
					+ this.projProps.acceleration * (elapsed - this.projProps.accelerationDelay) / 1000.0) / 10000.0);
				if (this.projProps.speedClamp != -1)
					dist = accelDist;
				else {
					var clampDist = dt * this.projProps.speedClamp / 10000.0;
					dist = this.projProps.acceleration > 0 ? Math.min(accelDist, clampDist) : Math.max(accelDist, clampDist);
				}
			}
		} else {
			if (this.zeroVelDist == -1.0)
				this.zeroVelDist = PointUtil.distanceXY(this.startX, this.startY, this.currentX, this.currentY);

			this.currentX = this.startX + this.zeroVelDist * this.cosAngle;
			this.currentY = this.startY + this.zeroVelDist * this.sinAngle;
			return;
		}
		

		if (this.heatSeekFired) {
			this.currentX += dist * this.cosAngle;
			this.currentY += dist * this.sinAngle;
		} else {
			if (this.projProps.wavy) {
				var periodFactor = 6 * MathUtil.PI;
				var amplitudeFactor = MathUtil.PI / 64;
				var theta = this.angle + amplitudeFactor * MathUtil.sin(this.phase + periodFactor * elapsed / 1000);
				this.currentX += dist * MathUtil.cos(theta);
				this.currentY += dist * MathUtil.sin(theta);
			} else if (this.projProps.parametric) {
				var t = elapsed / this.projProps.lifetime * 2 * MathUtil.PI;
				var x = MathUtil.sin(t) * this.bIdMod2Flip;
				var y = MathUtil.sin(2 * t) * this.bIdMod4Flip;
				this.currentX += (x * this.cosAngle - y * this.sinAngle) * this.projProps.magnitude;
				this.currentY += (x * this.sinAngle + y * this.cosAngle) * this.projProps.magnitude;
			} else {
				if (this.projProps.boomerang && elapsed > this.projProps.lifetime / 2)
					dist = -dist;

				this.currentX += dist * this.cosAngle;
				this.currentY += dist * this.sinAngle;
				if (this.projProps.amplitude != 0) {
					var deflectionTarget = this.projProps.amplitude * MathUtil.sin(this.phase
						+ elapsed / this.projProps.lifetime * this.projProps.frequency * 2 * MathUtil.PI);
					this.currentX += (deflectionTarget - this.lastDeflect) * MathUtil.cos(this.angle + MathUtil.PI / 2);
					this.currentY += (deflectionTarget - this.lastDeflect) * MathUtil.sin(this.angle + MathUtil.PI / 2);
					if (!predict)
						this.lastDeflect = deflectionTarget;
				}
			}
		}
	}

	public function getDirectionAngle(time: Int32) {
		var prevX = this.currentX;
		var prevY = this.currentY;
		var prevAngle = this.angle;

		this.updatePosition(time - this.startTime + 16, 16, true);

		var xDelta = this.currentX - prevX;
		var yDelta = this.currentY - prevY;
		this.currentX = prevX;
		this.currentY = prevY;
		this.angle = prevAngle;

		if (xDelta == 0 && yDelta == 0)
			return this.prevDirAngle;

		var angle = Math.atan2(yDelta, xDelta);
		this.prevDirAngle = angle;
		return angle;
	}
}
