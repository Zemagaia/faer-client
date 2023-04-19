package objects;

import network.NetworkHandler;
import map.Camera;
import util.Utils;
import engine.TextureFactory;
import haxe.ds.IntMap;
import map.Map;
import objects.BasicObject;
import openfl.display.BitmapData;
import openfl.geom.Point;
import util.BloodComposition;
import util.Utils;
import util.NativeTypes;
import util.PointUtil;

class Projectile extends BasicObject {
	private static var objBullIdToObjId: IntMap<Int> = new IntMap<Int>();

	public var props: ObjectProperties;
	public var containerProps: ObjectProperties;
	public var projProps: ProjectileProperties;
	public var texture: BitmapData;
	public var bulletId = 0;
	public var ownerId = 0;
	public var containerType = 0;
	public var bulletType = 0;
	public var damagesEnemies = false;
	public var damagesPlayers = false;
	public var damage = 0;
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
	public var colors: Array<Int32>;
	public var multiHitDict: IntMap<Bool>;
	public var uValue: Float32 = 0.0;
	public var vValue: Float32 = 0.0;
	public var width: Float32 = 0.0;
	public var height: Float32 = 0.0;

	private var staticPoint: Point;
	public var size: Float32 = 1.0;

	public static inline function findObjId(ownerId: Int32, bulletId: Int32) {
		return objBullIdToObjId.get(bulletId << 24 | ownerId);
	}

	public static inline function getNewObjId(ownerId: Int32, bulletId: Int32) {
		var objId = BasicObject.getNextFakeObjectId();
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
		super();

		this.staticPoint = new Point();
	}

	override public function addTo(map: Map, x: Float32, y: Float32) {
		this.startX = x;
		this.startY = y;
		if (!super.addTo(map, x, y))
			return false;

		if (!this.containerProps.flying && curSquare != null && curSquare.sink != 0) {
			if (curSquare.obj != null && curSquare.obj.props.protectFromSink)
				mapZ = 0.5;
			else
				mapZ = 0.1;
		} else {
			var player = map.players.get(this.ownerId);
			if (player?.sinkLevel > 0)
				mapZ = 0.5 - 0.4 * (player.sinkLevel / 1.8);
		}

		return true;
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
		var d = 0;
		var dead = false;
		var elapsed = time - this.startTime;
		if (elapsed > this.projProps.lifetime)
			return false;

		var p = this.positionAt(elapsed);
		if (!this.moveTo(p.x, p.y) || curSquare != null && curSquare.tileType == 255) {
			if (this.damagesPlayers)
				NetworkHandler.squareHit(time, this.bulletId, this.ownerId);
			//else if (curSquare != null && curSquare.obj != null)
				//map.addObj(new HitEffect(this.colors, 100, 3, this.angle, this.projProps.speed), p.x, p.y);

			return false;
		}

		if (curSquare?.obj != null
			&& (!curSquare.obj.props.isEnemy || !this.damagesEnemies)
			&& (curSquare.obj.props.enemyOccupySquare || curSquare.obj.props.occupySquare)) {
			if (this.damagesPlayers)
				NetworkHandler.otherHit(time, this.bulletId, this.ownerId, curSquare.obj.objectId);
			//else
				//map.addObj(new HitEffect(this.colors, 100, 3, this.angle, this.projProps.speed), p.x, p.y);

			return false;
		}

		var target = cast(this.getHit(p.x, p.y), GameObject);
		if (target != null) {
			player = map.player;
			isPlayer = player != null;
			isTargetAnEnemy = target.props.isEnemy;
			sendMessage = isPlayer && (this.damagesPlayers || isTargetAnEnemy && this.ownerId == player.objectId);
			if (sendMessage) {
				d = GameObject.damageWithDefense(this.damage, target.defense, this.projProps.armorPiercing, target.condition);
				if (target == player) {
					d = Std.int(d * player.hitMult);
					NetworkHandler.playerHit(this.bulletId, this.ownerId);
					target.damage(this.containerType, d, this.projProps.effects, false, this);
				} else if (target.props.isEnemy) {
					dead = target.hp <= d;
					NetworkHandler.enemyHit(time, this.bulletId, target.objectId, dead);
					target.damage(this.containerType, d, this.projProps.effects, dead, this);
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
		clear();
		this.containerType = containerType;
		this.bulletType = bulletType;
		this.ownerId = ownerId;
		this.bulletId = bulletId;
		this.bIdMod2Flip = (this.bulletId & 1) == 0 ? 1 : -1;
		this.bIdMod4Flip = (this.bulletId & 3) < 2 ? 1 : -1;
		this.phase = (this.bulletId & 1) == 0 ? 0 : MathUtil.PI;
		this.angle = angle % (MathUtil.PI * 2);
		this.sinAngle = MathUtil.sin(this.angle);
		this.cosAngle = MathUtil.cos(this.angle);
		this.startTime = startTime;
		objectId = getNewObjId(this.ownerId, this.bulletId);
		mapZ = 0.5;
		this.containerProps = ObjectLibrary.propsLibrary.get(this.containerType);
		this.projProps = this.containerProps.projectiles.get(bulletType);
		this.props = ObjectLibrary.getPropsFromId(this.projProps.objectId);
		var textureData: TextureData = ObjectLibrary.typeToTextureData.get(this.props.objType);
		this.texture = textureData.getTexture(objectId);
		this.uValue = textureData.uValue;
		this.vValue = textureData.vValue;
		this.width = textureData.width;
		this.height = textureData.height;
		this.colors = BloodComposition.getColors(this.texture);
		this.damagesPlayers = this.containerProps.isEnemy;
		this.damagesEnemies = !this.damagesPlayers;
		this.sound = this.containerProps.oldSound;
		this.multiHitDict = this.projProps.multiHit ? new IntMap<Bool>() : null;
		if (this.projProps.size >= 0)
			this.size = this.projProps.size / 100;
		else
			this.size = ObjectLibrary.getSizeFromType(this.containerType) / 100;
		this.damage = 0;
	}

	public function setDamage(damage: Int32) {
		this.damage = damage;
	}

	public function moveTo(x: Float32, y: Float32) {
		mapX = x;
		mapY = y;
		curSquare = map.lookupSquare(Std.int(x), Std.int(y));
		return curSquare != null;
	}

	public function getHit(pX: Float32, pY: Float32): GameObject {
		var distSqr = 0.0;
		var minDistSqr = MathUtil.FLOAT_MAX;
		var target: GameObject = null;

		if (damagesEnemies)
			for (go in map.enemies) {
				distSqr = PointUtil.distanceSquaredXY(go.mapX, go.mapY, pX, pY);
				if (distSqr < 0.25 && distSqr < minDistSqr && (!this.projProps.multiHit || !(this.multiHitDict.exists(go.objectId)))) {
					minDistSqr = distSqr;
					target = go;
				}
			}
		else if (damagesPlayers)
			for (player in map.players) {
				distSqr = PointUtil.distanceSquaredXY(player.mapX, player.mapY, pX, pY);
				if (distSqr < 0.25 && (!this.projProps.multiHit || !(this.multiHitDict.exists(player.objectId)))) {
					if (player.objectId == map.player.objectId)
						return player;

					if (distSqr < minDistSqr) {
						minDistSqr = distSqr;
						target = cast(player, GameObject);
					}
				}
			}

		return target;
	}

	private function positionAt(elapsed: Int32) {
		var periodFactor = 0.0;
		var amplitudeFactor = 0.0;
		var theta = 0.0;
		var t = 0.0;
		var x = 0.0;
		var y = 0.0;
		var halfway = 0.0;
		var deflection = 0.0;
		var p = new Point(this.startX, this.startY);
		var dist = 0.0, baseSpeed = this.projProps.speed;
		if (this.projProps.acceleration == 0 || elapsed < this.projProps.accelerationDelay)
			dist = elapsed * baseSpeed;
		else {
			var timeTillMaxSpeed = 0;
			var timeClamped = 0, clampedSpeed = 0.0;
			if (this.projProps.speedClamp != -1) {
				clampedSpeed = this.projProps.speedClamp / 10000.0;
				var speedNeeded = Math.abs(this.projProps.speedClamp - this.projProps.realSpeed);
				timeTillMaxSpeed = Std.int(speedNeeded / (Math.abs(this.projProps.acceleration) * 10000.0));
				timeTillMaxSpeed = Std.int(Math.min(elapsed - this.projProps.accelerationDelay, timeTillMaxSpeed));
				if (elapsed - this.projProps.accelerationDelay - timeTillMaxSpeed > 0)
					timeClamped = elapsed - this.projProps.accelerationDelay - timeTillMaxSpeed;
			} else
				timeTillMaxSpeed = this.projProps.lifetime - this.projProps.accelerationDelay;
			dist = this.projProps.accelerationDelay * baseSpeed
				+ timeTillMaxSpeed * baseSpeed
				+ (timeTillMaxSpeed * timeTillMaxSpeed / 2000.0) * (this.projProps.acceleration / 1000.0)
				+ timeClamped * clampedSpeed;
		}

		if (this.projProps.wavy) {
			periodFactor = 6 * MathUtil.PI;
			amplitudeFactor = MathUtil.PI / 64;
			theta = this.angle + amplitudeFactor * MathUtil.sin(this.phase + periodFactor * elapsed / 1000);
			p.x += dist * MathUtil.cos(theta);
			p.y += dist * MathUtil.sin(theta);
		} else if (this.projProps.parametric) {
			t = elapsed / this.projProps.lifetime * 2 * MathUtil.PI;
			x = MathUtil.sin(t) * this.bIdMod2Flip;
			y = MathUtil.sin(2 * t) * this.bIdMod4Flip;
			p.x += (x * this.cosAngle - y * this.sinAngle) * this.projProps.magnitude;
			p.y += (x * this.sinAngle + y * this.cosAngle) * this.projProps.magnitude;
		} else {
			if (this.projProps.boomerang) {
				// todo: make the halfway actually halfway for accel projs
				halfway = this.projProps.lifetime * (this.projProps.speed / 2);
				if (dist > halfway)
					dist = halfway - (dist - halfway);
			}
			p.x += dist * this.cosAngle;
			p.y += dist * this.sinAngle;
			if (this.projProps.amplitude != 0) {
				deflection = this.projProps.amplitude * MathUtil.sin(this.phase
					+ elapsed / this.projProps.lifetime * this.projProps.frequency * 2 * MathUtil.PI);
				p.x += deflection * MathUtil.cos(this.angle + MathUtil.PI / 2);
				p.y += deflection * MathUtil.sin(this.angle + MathUtil.PI / 2);
			}
		}

		return p;
	}

	public function getDirectionAngle(time: Int32) {
		var elapsed = time - this.startTime;
		var futurePos = this.positionAt(elapsed + 16);

		var xDelta = futurePos.x - mapX;
		var yDelta = futurePos.y - mapY;
		if (xDelta == 0 && yDelta == 0)
			return this.prevDirAngle;

		var angle = Math.atan2(yDelta, xDelta);
		this.prevDirAngle = angle;
		return angle;
	}
}
