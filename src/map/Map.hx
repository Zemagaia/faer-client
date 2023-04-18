package map;

import util.Utils.MathUtil;
import engine.TextureFactory;
import util.BinPacker.Rect;
import util.AnimatedChar;
import util.Utils.RenderUtils;
import objects.Player;
import cpp.Stdlib;
import lime.graphics.opengl.GL;
import lime.graphics.opengl.GLVertexArrayObject;
import cpp.RawPointer;
import haxe.ds.HashMap;
import lime.utils.Int32Array;
import util.ConditionEffect;
import objects.GameObject;
import openfl.display3D.Context3DCompareMode;
import haxe.io.Bytes;
import util.NativeTypes;
import haxe.Exception;
import engine.GLTextureData;
import haxe.ds.IntMap;
import haxe.ds.Vector;
import lime.graphics.opengl.GLBuffer;
import lime.graphics.opengl.GLFramebuffer;
import lime.graphics.opengl.GLProgram;
import lime.graphics.opengl.GLTexture;
import lime.utils.Float32Array;
import lime.utils.Int16Array;
import objects.BasicObject;
import objects.Projectile;
import openfl.display.Sprite;
import openfl.display3D.Context3D;
import util.MacroUtil;
import util.AssetLibrary;

using util.Utils.ArrayUtils;

class Map extends Sprite {
	private static inline var TILE_UPDATE_MS = 100; // tick rate
	private static inline var BUFFER_UPDATE_MS = 500;
	private static inline var MAX_VISIBLE_SQUARES = 729;

	public static var leftMaskU: Float32 = 0.0;
	public static var leftMaskV: Float32 = 0.0;
	public static var topMaskU: Float32 = 0.0;
	public static var topMaskV: Float32 = 0.0;
	public static var rightMaskU: Float32 = 0.0;
	public static var rightMaskV: Float32 = 0.0;
	public static var bottomMaskU: Float32 = 0.0;
	public static var bottomMaskV: Float32 = 0.0;

	public var mapWidth: UInt16 = 0;
	public var mapHeight: UInt16 = 0;
	public var mapName = "";
	public var back = 0;
	public var allowPlayerTeleport = false;
	public var showDisplays = false;
	public var mapOverlay: MapOverlay;
	public var squares: Vector<Square>;
	public var gameObjects: IntMap<GameObject>;
	public var gameObjectsLen: Int32 = 0;
	public var players: IntMap<Player>;
	public var playersLen: Int32 = 0;
	public var projectiles: IntMap<Projectile>;
	public var projectilesLen: Int32 = 0;
	public var enemies: Array<GameObject>;
	public var player: Player = null;
	public var quest: Quest = null;
	public var lastWidth: Int16 = -1;
	public var lastHeight: Int16 = -1;
	public var c3d: Context3D;
	public var lastTileUpdate: Int32 = -1;

	private var lastBufferUpdate: Int32 = -1;
	private var visSquares: Vector<Square>;
	private var visSquareLen: UInt16 = 0;

	public var defaultProgram: GLProgram;
	public var groundProgram: GLProgram;

	public var groundVAO: GLVertexArrayObject;
	public var groundVBO: GLBuffer;
	public var groundVBOLen: Int32 = 0;
	public var groundIBO: GLBuffer;
	public var groundIBOLen: Int32 = 0;
	public var objVAO: GLVertexArrayObject;
	public var objVBO: GLBuffer;
	public var objVBOLen: Int32 = 0;
	public var objIBO: GLBuffer;
	public var objIBOLen: Int32 = 0;
	public var vertexData: RawPointer<Float32>;
	public var vertexLen: UInt32 = 65536;
	public var indexData: RawPointer<UInt32>;
	public var indexLen: UInt32 = 65536;

	private var i: Int32 = 0;
	private var vIdx: Int32 = 0;
	private var iIdx: Int32 = 0;

	private var backBuffer: GLFramebuffer;
	private var frontBuffer: GLFramebuffer;
	private var backBufferTexture: GLTexture;
	private var frontBufferTexture: GLTexture;

	public function new() {
		super();

		this.mapOverlay = new MapOverlay();
		this.gameObjects = new IntMap<GameObject>();
		this.players = new IntMap<Player>();
		this.projectiles = new IntMap<Projectile>();
		this.enemies = [];
		this.quest = new Quest(this);
		this.visSquares = new Vector<Square>(MAX_VISIBLE_SQUARES);
	}

	@:nonVirtual public function setProps(width: Int, height: Int, name: String, back: Int, allowPlayerTeleport: Bool, showDisplays: Bool) {
		this.mapWidth = width;
		this.mapHeight = height;
		this.squares = new Vector<Square>(this.mapWidth * this.mapHeight);
		this.mapName = name;
		this.back = back;
		this.allowPlayerTeleport = allowPlayerTeleport;
		this.showDisplays = showDisplays;
	}

	@:nonVirtual public function initialize() {
		addChild(this.mapOverlay);

		this.vertexData = cast Stdlib.nativeMalloc(this.vertexLen * 4);
		this.indexData = cast Stdlib.nativeMalloc(this.indexLen * 4);

		var leftMaskRect = AssetLibrary.getRectFromSet("ground", 0x6b);
		leftMaskU = (leftMaskRect.x + Main.PADDING) / Main.ATLAS_WIDTH;
		leftMaskV = (leftMaskRect.y + Main.PADDING) / Main.ATLAS_HEIGHT;

		var topMaskRect = AssetLibrary.getRectFromSet("ground", 0x6c);
		topMaskU = (topMaskRect.x + Main.PADDING) / Main.ATLAS_WIDTH;
		topMaskV = (topMaskRect.y + Main.PADDING) / Main.ATLAS_HEIGHT;

		var rightMaskRect = AssetLibrary.getRectFromSet("ground", 0x6d);
		rightMaskU = (rightMaskRect.x + Main.PADDING) / Main.ATLAS_WIDTH;
		rightMaskV = (rightMaskRect.y + Main.PADDING) / Main.ATLAS_HEIGHT;

		var bottomMaskRect = AssetLibrary.getRectFromSet("ground", 0x6e);
		bottomMaskU = (bottomMaskRect.x + Main.PADDING) / Main.ATLAS_WIDTH;
		bottomMaskV = (bottomMaskRect.y + Main.PADDING) / Main.ATLAS_HEIGHT;

		this.defaultProgram = RenderUtils.compileShaders(MacroUtil.readFile("assets/shaders/base.vert"), MacroUtil.readFile("assets/shaders/base.frag"));
		this.groundProgram = RenderUtils.compileShaders(MacroUtil.readFile("assets/shaders/ground.vert"), MacroUtil.readFile("assets/shaders/ground.frag"));

		this.groundVAO = GL.createVertexArray();
		this.groundIBO = GL.createBuffer();
		this.groundVBO = GL.createBuffer();

		GL.bindBuffer(GL.ARRAY_BUFFER, this.groundVBO);
		GL.bufferData(GL.ARRAY_BUFFER, 0, new Float32Array([]), GL.DYNAMIC_DRAW);
		GL.enableVertexAttribArray(0);
		GL.vertexAttribPointer(0, 4, GL.FLOAT, false, 56, 0);
		GL.enableVertexAttribArray(1);
		GL.vertexAttribPointer(1, 2, GL.FLOAT, false, 56, 16);
		GL.enableVertexAttribArray(2);
		GL.vertexAttribPointer(2, 2, GL.FLOAT, false, 56, 24);
		GL.enableVertexAttribArray(3);
		GL.vertexAttribPointer(3, 2, GL.FLOAT, false, 56, 32);
		GL.enableVertexAttribArray(4);
		GL.vertexAttribPointer(4, 2, GL.FLOAT, false, 56, 40);
		GL.enableVertexAttribArray(5);
		GL.vertexAttribPointer(5, 2, GL.FLOAT, false, 56, 48);
		GL.bindBuffer(GL.ELEMENT_ARRAY_BUFFER, this.groundIBO);
		GL.bufferData(GL.ELEMENT_ARRAY_BUFFER, 0, new Int32Array([]), GL.DYNAMIC_DRAW);

		this.objVAO = GL.createVertexArray();
		this.objIBO = GL.createBuffer();
		this.objVBO = GL.createBuffer();

		GL.bindBuffer(GL.ARRAY_BUFFER, this.objVBO);
		GL.bufferData(GL.ARRAY_BUFFER, 0, new Float32Array([]), GL.DYNAMIC_DRAW);
		GL.enableVertexAttribArray(0);
		GL.vertexAttribPointer(0, 4, GL.FLOAT, false, 36, 0);
		GL.enableVertexAttribArray(1);
		GL.vertexAttribPointer(1, 2, GL.FLOAT, false, 36, 16);
		GL.enableVertexAttribArray(2);
		GL.vertexAttribPointer(2, 2, GL.FLOAT, false, 36, 24);
		GL.enableVertexAttribArray(3);
		GL.vertexAttribPointer(3, 1, GL.FLOAT, false, 36, 32);
		GL.bindBuffer(GL.ELEMENT_ARRAY_BUFFER, this.objIBO);
		GL.bufferData(GL.ELEMENT_ARRAY_BUFFER, 0, new Int32Array([]), GL.DYNAMIC_DRAW);
		GL.useProgram(this.defaultProgram);

		this.c3d = Main.primaryStage3D.context3D;
		this.c3d.configureBackBuffer(Main.stageWidth, Main.stageHeight, 0, true);

		this.lastWidth = Main.stageWidth;
		this.lastHeight = Main.stageHeight;
		this.x = Main.stageWidth >> 1;
		this.y = Main.stageHeight >> 1;
		RenderUtils.clipSpaceScaleX = 2 / Main.stageWidth;
		RenderUtils.clipSpaceScaleY = 2 / Main.stageHeight;
	}

	@:nonVirtual public function dispose() {
		Stdlib.nativeFree(cast this.vertexData);
		Stdlib.nativeFree(cast this.indexData);

		this.mapOverlay = null;
		this.squares = null;

		if (this.gameObjects != null)
			for (obj in this.gameObjects)
				obj.dispose();
		this.gameObjects = null;

		if (this.players != null)
			for (obj in this.players)
				obj.dispose();
		this.players = null;

		if (this.projectiles != null)
			for (obj in this.projectiles)
				obj.dispose();
		this.projectiles = null;

		this.player = null;
		this.quest = null;
		TextureFactory.disposeTextures();
	}

	@:nonVirtual public function update(time: Int32, dt: Int16) {
		for (obj in this.gameObjects)
			if (!obj.update(time, dt))
				this.removeGameObject(obj.objectId);

		for (obj in this.players)
			if (!obj.update(time, dt))
				this.removePlayer(obj.objectId);

		for (obj in this.projectiles)
			if (!obj.update(time, dt))
				this.removeProjectile(obj.objectId);
	}

	@:nonVirtual private inline function validPos(x: UInt16, y: UInt16) {
		return !(x < 0 || x >= this.mapWidth || y < 0 || y >= this.mapHeight);
	}

	@:nonVirtual public function setGroundTile(x: UInt16, y: UInt16, tileType: UInt16) {
		if (!validPos(x, y))
			return;

		var idx: Int32 = x + y * this.mapWidth;
		var square = this.squares[idx];
		if (square == null) {
			square = new Square(x + 0.5, y + 0.5);
			this.squares[idx] = square;
		}

		square.tileType = tileType;
		square.props = GroundLibrary.propsLibrary.get(square.tileType);
		var texData = GroundLibrary.typeToTextureData.get(square.tileType).getTextureData();
		square.baseU = texData.uValue;
		square.baseV = texData.vValue;
		square.sink = square.props != null && square.props.sink ? 0.6 : 0;

		if (validPos(x - 1, y)) {
			var leftSq = this.squares[x - 1 + y * this.mapWidth];
			if (leftSq != null) {
				if (leftSq.props.blendPriority > square.props.blendPriority) {
					square.leftBlendU = leftSq.baseU;
					square.leftBlendV = leftSq.baseV;
				} else if (leftSq.props.blendPriority < square.props.blendPriority) {
					leftSq.rightBlendU = square.baseU;
					leftSq.rightBlendV = square.baseV;
				} else {
					square.leftBlendU = square.leftBlendV = -1.0;
					leftSq.rightBlendU = leftSq.rightBlendV = -1.0;
				}
			}
		}

		if (validPos(x, y - 1)) {
			var topSq = this.squares[x + (y - 1) * this.mapWidth];
			if (topSq != null) {
				if (topSq.props.blendPriority > square.props.blendPriority) {
					square.topBlendU = topSq.baseU;
					square.topBlendV = topSq.baseV;
				} else if (topSq.props.blendPriority < square.props.blendPriority) {
					topSq.bottomBlendU = square.baseU;
					topSq.bottomBlendV = square.baseV;
				} else {
					square.topBlendU = square.topBlendV = -1.0;
					topSq.bottomBlendU = topSq.bottomBlendV = -1.0;
				}
			}
		}

		if (validPos(x + 1, y)) {
			var rightSq = this.squares[x + 1 + y * this.mapWidth];
			if (rightSq != null) {
				if (rightSq.props.blendPriority > square.props.blendPriority) {
					square.rightBlendU = rightSq.baseU;
					square.rightBlendV = rightSq.baseV;
				} else if (rightSq.props.blendPriority < square.props.blendPriority) {
					rightSq.leftBlendU = square.baseU;
					rightSq.leftBlendV = square.baseV;
				} else {
					square.rightBlendU = square.rightBlendV = -1.0;
					rightSq.leftBlendU = rightSq.leftBlendV = -1.0;
				}
			}
		}

		if (validPos(x, y + 1)) {
			var bottomSq = this.squares[x + (y + 1) * this.mapWidth];
			if (bottomSq != null) {
				if (bottomSq.props.blendPriority > square.props.blendPriority) {
					square.bottomBlendU = bottomSq.baseU;
					square.bottomBlendV = bottomSq.baseV;
				} else if (bottomSq.props.blendPriority < square.props.blendPriority) {
					bottomSq.topBlendU = square.baseU;
					bottomSq.topBlendV = square.baseV;
				} else {
					square.bottomBlendU = square.bottomBlendV = -1.0;
					bottomSq.topBlendU = bottomSq.topBlendV = -1.0;
				}
			};
		}
	}

	@:nonVirtual public function addGameObject(go: GameObject, posX: Float32, posY: Float32) {
		go.mapX = posX;
		go.mapY = posY;

		if (!go.addTo(this, go.mapX, go.mapY))
			return;

		this.gameObjects.set(go.objectId, go);
		if (go.props.isEnemy)
			this.enemies.push(go);
		this.gameObjectsLen++;
	}

	@:nonVirtual public function addPlayer(player: Player, posX: Float32, posY: Float32) {
		player.mapX = posX;
		player.mapY = posY;

		if (!player.addTo(this, player.mapX, player.mapY))
			return;

		this.players.set(player.objectId, player);
		this.playersLen++;
	}

	@:nonVirtual public function addProjectile(proj: Projectile, posX: Float32, posY: Float32) {
		proj.mapX = posX;
		proj.mapY = posY;

		if (!proj.addTo(this, proj.mapX, proj.mapY))
			return;

		this.projectiles.set(proj.objectId, proj);
		this.projectilesLen++;
	}

	@:nonVirtual public function removeObj(objectId: Int32) {
		if (this.gameObjects.exists(objectId))
			removeGameObject(objectId);
		else if (this.players.exists(objectId))
			removePlayer(objectId);
		else if (this.projectiles.exists(objectId))
			removeProjectile(objectId);
	}

	@:nonVirtual public function removeGameObject(objectId: Int32) {
		var go = this.gameObjects.get(objectId);
		if (go != null) {
			go.removeFromMap();
			this.gameObjects.remove(objectId);
			if (go.props.isEnemy)
				this.enemies.remove(go);
			this.gameObjectsLen--;
		}
	}

	@:nonVirtual public function removePlayer(objectId: Int32) {
		var player = this.players.get(objectId);
		if (player != null) {
			player.removeFromMap();
			this.players.remove(objectId);
			this.playersLen--;
		}
	}

	@:nonVirtual public function removeProjectile(objectId: Int32) {
		var proj = this.projectiles.get(objectId);
		if (proj != null) {
			proj.removeFromMap();
			this.projectiles.remove(objectId);
			this.projectilesLen--;
		}
	}

	@:nonVirtual public function lookupSquare(x: UInt16, y: UInt16) {
		return x < 0
			|| x >= this.mapWidth
			|| y < 0
			|| y >= this.mapHeight
			|| player != null
			&& (player.mapX < 0 || player.mapY < 0) ? null : this.squares[x + y * this.mapWidth];
	}

	@:nonVirtual public function forceLookupSquare(x: UInt16, y: UInt16) {
		if (x < 0 || x >= this.mapWidth || y < 0 || y >= this.mapHeight || player != null && (player.mapX < 0 || player.mapY < 0))
			return null;

		var idx = x + y * this.mapWidth;
		var square = this.squares[idx];
		if (square == null) {
			square = new Square(x + 0.5, y + 0.5);
			this.squares[idx] = square;
		}

		return square;
	}

	@:nonVirtual private final inline function drawSquares() {
		final xScaledCos: Float32 = Camera.xScaledCos;
		final yScaledCos: Float32 = Camera.yScaledCos;
		final xScaledSin: Float32 = Camera.xScaledSin;
		final yScaledSin: Float32 = Camera.yScaledSin;

		while (this.i < this.visSquareLen) {
			final square = this.visSquares[this.i];
			square.clipX = square.middleX * Camera.cos + square.middleY * Camera.sin + Camera.csX;
			square.clipY = square.middleX * -Camera.sin + square.middleY * Camera.cos + Camera.csY;

			final scaledClipX = square.clipX * RenderUtils.clipSpaceScaleX;
			final scaledClipY = square.clipY * RenderUtils.clipSpaceScaleY;

			this.vertexData[this.vIdx] = -xScaledCos - xScaledSin + scaledClipX;
			this.vertexData[this.vIdx + 1] = yScaledSin - yScaledCos + scaledClipY;
			this.vertexData[this.vIdx + 2] = 0;
			this.vertexData[this.vIdx + 3] = 0;

			this.vertexData[this.vIdx + 4] = square.leftBlendU;
			this.vertexData[this.vIdx + 5] = square.leftBlendV;
			this.vertexData[this.vIdx + 6] = square.topBlendU;
			this.vertexData[this.vIdx + 7] = square.topBlendV;

			this.vertexData[this.vIdx + 8] = square.rightBlendU;
			this.vertexData[this.vIdx + 9] = square.rightBlendV;
			this.vertexData[this.vIdx + 10] = square.bottomBlendU;
			this.vertexData[this.vIdx + 11] = square.bottomBlendV;

			this.vertexData[this.vIdx + 12] = square.baseU;
			this.vertexData[this.vIdx + 13] = square.baseV;

			this.vertexData[this.vIdx + 14] = xScaledCos - xScaledSin + scaledClipX;
			this.vertexData[this.vIdx + 15] = -yScaledSin - yScaledCos + scaledClipY;
			this.vertexData[this.vIdx + 16] = 8 / Main.ATLAS_WIDTH;
			this.vertexData[this.vIdx + 17] = 0;

			this.vertexData[this.vIdx + 18] = square.leftBlendU;
			this.vertexData[this.vIdx + 19] = square.leftBlendV;
			this.vertexData[this.vIdx + 20] = square.topBlendU;
			this.vertexData[this.vIdx + 21] = square.topBlendV;

			this.vertexData[this.vIdx + 22] = square.rightBlendU;
			this.vertexData[this.vIdx + 23] = square.rightBlendV;
			this.vertexData[this.vIdx + 24] = square.bottomBlendU;
			this.vertexData[this.vIdx + 25] = square.bottomBlendV;

			this.vertexData[this.vIdx + 26] = square.baseU;
			this.vertexData[this.vIdx + 27] = square.baseV;

			this.vertexData[this.vIdx + 28] = -xScaledCos + xScaledSin + scaledClipX;
			this.vertexData[this.vIdx + 29] = yScaledSin + yScaledCos + scaledClipY;
			this.vertexData[this.vIdx + 30] = 0;
			this.vertexData[this.vIdx + 31] = 8 / Main.ATLAS_WIDTH;

			this.vertexData[this.vIdx + 32] = square.leftBlendU;
			this.vertexData[this.vIdx + 33] = square.leftBlendV;
			this.vertexData[this.vIdx + 34] = square.topBlendU;
			this.vertexData[this.vIdx + 35] = square.topBlendV;

			this.vertexData[this.vIdx + 36] = square.rightBlendU;
			this.vertexData[this.vIdx + 37] = square.rightBlendV;
			this.vertexData[this.vIdx + 38] = square.bottomBlendU;
			this.vertexData[this.vIdx + 39] = square.bottomBlendV;

			this.vertexData[this.vIdx + 40] = square.baseU;
			this.vertexData[this.vIdx + 41] = square.baseV;

			this.vertexData[this.vIdx + 42] = xScaledCos + xScaledSin + scaledClipX;
			this.vertexData[this.vIdx + 43] = -yScaledSin + yScaledCos + scaledClipY;
			this.vertexData[this.vIdx + 44] = 8 / Main.ATLAS_WIDTH;
			this.vertexData[this.vIdx + 45] = 8 / Main.ATLAS_WIDTH;

			this.vertexData[this.vIdx + 46] = square.leftBlendU;
			this.vertexData[this.vIdx + 47] = square.leftBlendV;
			this.vertexData[this.vIdx + 48] = square.topBlendU;
			this.vertexData[this.vIdx + 49] = square.topBlendV;

			this.vertexData[this.vIdx + 50] = square.rightBlendU;
			this.vertexData[this.vIdx + 51] = square.rightBlendV;
			this.vertexData[this.vIdx + 52] = square.bottomBlendU;
			this.vertexData[this.vIdx + 53] = square.bottomBlendV;

			this.vertexData[this.vIdx + 54] = square.baseU;
			this.vertexData[this.vIdx + 55] = square.baseV;
			this.vIdx += 56;

			final i4: UInt32 = this.i * 4;
			this.indexData[this.iIdx] = i4;
			this.indexData[this.iIdx + 1] = 1 + i4;
			this.indexData[this.iIdx + 2] = 2 + i4;
			this.indexData[this.iIdx + 3] = 2 + i4;
			this.indexData[this.iIdx + 4] = 1 + i4;
			this.indexData[this.iIdx + 5] = 3 + i4;
			this.iIdx += 6;

			this.i++;
		}
	}

	@:nonVirtual private final inline function drawGameObject(time: Int32, obj: GameObject) {
		obj.calcScreenCoords();

		var texW = obj.width * Main.ATLAS_WIDTH,
			texH = obj.height * Main.ATLAS_HEIGHT;

		var rect: Rect = null;
		if (obj.animatedChar != null) {
			var action = AnimatedChar.STAND;
			var p: Float32 = 0.0;
			if (time < obj.attackStart + GameObject.ATTACK_PERIOD) {
				if (!obj.props.dontFaceAttacks)
					obj.facing = obj.attackAngle;

				p = (time - obj.attackStart) % GameObject.ATTACK_PERIOD / GameObject.ATTACK_PERIOD;
				action = AnimatedChar.ATTACK;
			} else if (obj.moveVec.x != 0 || obj.moveVec.y != 0) {
				var walkPer = Std.int(0.5 / obj.moveVec.length);
				walkPer += 400 - walkPer % 400;
				if (obj.moveVec.x > GameObject.ZERO_LIMIT
					|| obj.moveVec.x < GameObject.NEGATIVE_ZERO_LIMIT
					|| obj.moveVec.y > GameObject.ZERO_LIMIT
					|| obj.moveVec.y < GameObject.NEGATIVE_ZERO_LIMIT) {
					obj.facing = Math.atan2(obj.moveVec.y, obj.moveVec.x);
					action = AnimatedChar.WALK;
				} else
					action = AnimatedChar.STAND;

				p = time % walkPer / walkPer;
			}

			rect = obj.animatedChar.rectFromFacing(obj.facing, action, p);
		} else if (obj.animations != null)
			rect = obj.animations.getTexture(time);

		if (rect != null) {
			obj.uValue = rect.x / Main.ATLAS_WIDTH;
			obj.vValue = rect.y / Main.ATLAS_WIDTH;
			texW = rect.width;
			obj.width = texW / Main.ATLAS_WIDTH;
			texH = rect.height;
			obj.height = texH / Main.ATLAS_HEIGHT;
		}

		var sink: Float32 = 1.0;
		if (obj.curSquare != null && !(obj.flying || obj.curSquare.obj != null && obj.curSquare.obj.props.protectFromSink))
			sink += obj.curSquare.sink + obj.sinkLevel;

		var flashStrength: Float32 = 0.0;
		if (obj.flashPeriodMs > 0) {
			if (obj.flashRepeats != -1 && time > obj.flashStartTime + obj.flashPeriodMs * obj.flashRepeats)
				obj.flashRepeats = obj.flashStartTime = obj.flashPeriodMs = obj.flashColor = 0;
			else
				flashStrength = MathUtil.sin((time - obj.flashStartTime) % obj.flashPeriodMs / obj.flashPeriodMs * MathUtil.PI) * 0.5;
		}

		final size = Camera.SIZE_MULT * obj.size;
		final w = size * texW * RenderUtils.clipSpaceScaleX * 0.5;
		final hBase = size * texH;
		final h = hBase * RenderUtils.clipSpaceScaleY * 0.5 / sink;
		final yBase = (obj.screenY - (hBase / 2 - size * Main.PADDING)) * RenderUtils.clipSpaceScaleY;
		final xBase = obj.screenX * RenderUtils.clipSpaceScaleX;
		final texelW: Float32 = 2.0 / Main.ATLAS_WIDTH / size;
		final texelH: Float32 = 2.0 / Main.ATLAS_HEIGHT / size;

		this.vertexData[vIdx] = -w + xBase;
		this.vertexData[vIdx + 1] = -h + yBase;
		this.vertexData[vIdx + 2] = obj.uValue;
		this.vertexData[vIdx + 3] = obj.vValue;

		this.vertexData[vIdx + 4] = texelW;
		this.vertexData[vIdx + 5] = texelH;
		this.vertexData[vIdx + 6] = obj.glowColor;
		this.vertexData[vIdx + 7] = obj.flashColor;
		this.vertexData[vIdx + 8] = flashStrength;

		this.vertexData[vIdx + 9] = w + xBase;
		this.vertexData[vIdx + 10] = -h + yBase;
		this.vertexData[vIdx + 11] = obj.uValue + obj.width;
		this.vertexData[vIdx + 12] = obj.vValue;

		this.vertexData[vIdx + 13] = texelW;
		this.vertexData[vIdx + 14] = texelH;
		this.vertexData[vIdx + 15] = obj.glowColor;
		this.vertexData[vIdx + 16] = obj.flashColor;
		this.vertexData[vIdx + 17] = flashStrength;

		this.vertexData[vIdx + 18] = -w + xBase;
		this.vertexData[vIdx + 19] = h + yBase;
		this.vertexData[vIdx + 20] = obj.uValue;
		this.vertexData[vIdx + 21] = obj.vValue + obj.height / sink;

		this.vertexData[vIdx + 22] = texelW;
		this.vertexData[vIdx + 23] = texelH;
		this.vertexData[vIdx + 24] = obj.glowColor;
		this.vertexData[vIdx + 25] = obj.flashColor;
		this.vertexData[vIdx + 26] = flashStrength;

		this.vertexData[vIdx + 27] = w + xBase;
		this.vertexData[vIdx + 28] = h + yBase;
		this.vertexData[vIdx + 29] = obj.uValue + obj.width;
		this.vertexData[vIdx + 30] = obj.vValue + obj.height / sink;

		this.vertexData[vIdx + 31] = texelW;
		this.vertexData[vIdx + 32] = texelH;
		this.vertexData[vIdx + 33] = obj.glowColor;
		this.vertexData[vIdx + 34] = obj.flashColor;
		this.vertexData[vIdx + 35] = flashStrength;
		vIdx += 36;

		i++;
		final i4 = i * 4;
		this.indexData[iIdx] = i4;
		this.indexData[iIdx + 1] = 1 + i4;
		this.indexData[iIdx + 2] = 2 + i4;
		this.indexData[iIdx + 3] = 2 + i4;
		this.indexData[iIdx + 4] = 1 + i4;
		this.indexData[iIdx + 5] = 3 + i4;
		iIdx += 6;

		/*var yPos: Int32 = 10 + (sink != 0 ? 5 : 0);
			if (obj.props.showName) {
					if (obj.name != null && obj.name != "" && obj.nameTex == null) {
						obj.nameText = new SimpleText(16, 0xFFFFFF);
						obj.nameText.setBold(true);
						obj.nameText.text = obj.name;
						obj.nameText.updateMetrics();

						obj.nameTex = new BitmapData(Std.int(obj.nameText.width + 20), 64, true, 0);
						obj.nameTex.draw(obj.nameText, new Matrix(1, 0, 0, 1, 12, 0));
						obj.nameTex.applyFilter(obj.nameTex, obj.nameTex.rect, new Point(0, 0), new GlowFilter(0, 1, 3, 3, 2, 1));

					 	obj.nameBitmap = new Bitmap(obj.nameTex);
						obj.nameBitmap.cacheAsBitmap = true;
						addChild(obj.nameBitmap);
					}

					obj.nameBitmap.x = obj.screenX - texW * 2;
					obj.nameBitmap.y = obj.yBaseNoZ - texH;
				}

				if (obj.props == null || !obj.props.noMiniMap) {
					if (obj.hp > obj.maxHP)
						obj.maxHP = obj.hp;

					var hpPerc = obj.hp / obj.maxHP;
					if (hpPerc > 0 && hpPerc < 1.1) {
						if (obj.hpBar == null)
							obj.hpBar = new Bitmap();

						obj.hpBar.bitmapData = TextureRedrawer.redrawHPBar(0x111111, 0x280000, ColorUtils.greenToRed(Std.int(hpPerc * 100)), 50, 8, hpPerc);
						obj.hpBar.x = obj.screenX - texW * 2;
						obj.hpBar.y = obj.yBaseNoZ + texH / 2;
						if (!contains(obj.hpBar))
							addChild(obj.hpBar);
						yPos += 15;
					}
			}

			if (obj.condition > 0) {
				var icon: BitmapData = null;
				if (obj.icons == null)
					obj.icons = new Array<BitmapData>();

				obj.icons.splice(0, obj.icons.length);
				ConditionEffect.getConditionEffectIcons(obj.condition, obj.icons, Std.int(time / 500));
				var len: Int32 = obj.icons.length;
				var lenDiv2: Int32 = len >> 1;
				for (i in 0...len) {
					icon = obj.icons[i];
					var iconData = TextureFactory.make(icon);
						var iconW: Int32 = iconData.width;
						RenderUtils.baseRender(iconW, iconData.height, obj.screenX - iconW * lenDiv2 + i * iconW, obj.yBaseNoZ + obj.dh + yPos, obj.width,
							obj.height, obj.uValue, obj.vValue, 1);
				}
		}*/
	}

	@:nonVirtual private final inline function drawPlayer(time: Int32, player: Player) {
		player.calcScreenCoords();

		var texW = player.width * Main.ATLAS_WIDTH,
			texH = player.height * Main.ATLAS_HEIGHT;

		var rect: Rect = null;
		if (player.animatedChar != null) {
			var action = AnimatedChar.STAND;
			var p: Float32 = 0.0;
			if (time < player.attackStart + GameObject.ATTACK_PERIOD) {
				if (!player.props.dontFaceAttacks)
					player.facing = player.attackAngle;

				p = (time - player.attackStart) % GameObject.ATTACK_PERIOD / GameObject.ATTACK_PERIOD;
				action = AnimatedChar.ATTACK;
			} else if (player.moveVec.x != 0 || player.moveVec.y != 0) {
				var walkPer = Std.int(0.5 / player.moveVec.length);
				walkPer += 400 - walkPer % 400;
				if (player.moveVec.x > GameObject.ZERO_LIMIT
					|| player.moveVec.x < GameObject.NEGATIVE_ZERO_LIMIT
					|| player.moveVec.y > GameObject.ZERO_LIMIT
					|| player.moveVec.y < GameObject.NEGATIVE_ZERO_LIMIT) {
					player.facing = Math.atan2(player.moveVec.y, player.moveVec.x);
					action = AnimatedChar.WALK;
				} else
					action = AnimatedChar.STAND;

				p = time % walkPer / walkPer;
			}

			rect = player.animatedChar.rectFromFacing(player.facing, action, p);
		} else if (player.animations != null)
			rect = player.animations.getTexture(time);

		if (rect != null) {
			player.uValue = rect.x / Main.ATLAS_WIDTH;
			player.vValue = rect.y / Main.ATLAS_WIDTH;
			texW = rect.width;
			player.width = texW / Main.ATLAS_WIDTH;
			texH = rect.height;
			player.height = texH / Main.ATLAS_HEIGHT;
		}

		var sink: Float32 = 1.0;
		if (player.curSquare != null && !(player.flying || player.curSquare.obj != null && player.curSquare.obj.props.protectFromSink))
			sink += player.curSquare.sink + player.sinkLevel;

		var flashStrength: Float32 = 0.0;
		if (player.flashPeriodMs > 0) {
			if (player.flashRepeats != -1 && time > player.flashStartTime + player.flashPeriodMs * player.flashRepeats)
				player.flashRepeats = player.flashStartTime = player.flashPeriodMs = player.flashColor = 0;
			else
				flashStrength = MathUtil.sin((time - player.flashStartTime) % player.flashPeriodMs / player.flashPeriodMs * MathUtil.PI) * 0.5;
		}

		final size = Camera.SIZE_MULT * player.size;
		final w = size * texW * RenderUtils.clipSpaceScaleX * 0.5;
		final hBase = size * texH;
		final h = hBase * RenderUtils.clipSpaceScaleY * 0.5 / sink;
		final yBase = (player.screenY - (hBase / 2 - size * Main.PADDING)) * RenderUtils.clipSpaceScaleY;
		final xBase = player.screenX * RenderUtils.clipSpaceScaleX;
		final texelW = 2 / Main.ATLAS_WIDTH / size;
		final texelH = 2 / Main.ATLAS_HEIGHT / size;

		this.vertexData[vIdx] = -w + xBase;
		this.vertexData[vIdx + 1] = -h + yBase;
		this.vertexData[vIdx + 2] = player.uValue;
		this.vertexData[vIdx + 3] = player.vValue;

		this.vertexData[vIdx + 4] = texelW;
		this.vertexData[vIdx + 5] = texelH;
		this.vertexData[vIdx + 6] = player.glowColor;
		this.vertexData[vIdx + 7] = player.flashColor;
		this.vertexData[vIdx + 8] = flashStrength;

		this.vertexData[vIdx + 9] = w + xBase;
		this.vertexData[vIdx + 10] = -h + yBase;
		this.vertexData[vIdx + 11] = player.uValue + player.width;
		this.vertexData[vIdx + 12] = player.vValue;

		this.vertexData[vIdx + 13] = texelW;
		this.vertexData[vIdx + 14] = texelH;
		this.vertexData[vIdx + 15] = player.glowColor;
		this.vertexData[vIdx + 16] = player.flashColor;
		this.vertexData[vIdx + 17] = flashStrength;

		this.vertexData[vIdx + 18] = -w + xBase;
		this.vertexData[vIdx + 19] = h + yBase;
		this.vertexData[vIdx + 20] = player.uValue;
		this.vertexData[vIdx + 21] = player.vValue + player.height / sink;

		this.vertexData[vIdx + 22] = texelW;
		this.vertexData[vIdx + 23] = texelH;
		this.vertexData[vIdx + 24] = player.glowColor;
		this.vertexData[vIdx + 25] = player.flashColor;
		this.vertexData[vIdx + 26] = flashStrength;

		this.vertexData[vIdx + 27] = w + xBase;
		this.vertexData[vIdx + 28] = h + yBase;
		this.vertexData[vIdx + 29] = player.uValue + player.width;
		this.vertexData[vIdx + 30] = player.vValue + player.height / sink;

		this.vertexData[vIdx + 31] = texelW;
		this.vertexData[vIdx + 32] = texelH;
		this.vertexData[vIdx + 33] = player.glowColor;
		this.vertexData[vIdx + 34] = player.flashColor;
		this.vertexData[vIdx + 35] = flashStrength;
		vIdx += 36;

		i++;
		final i4 = i * 4;
		this.indexData[iIdx] = i4;
		this.indexData[iIdx + 1] = 1 + i4;
		this.indexData[iIdx + 2] = 2 + i4;
		this.indexData[iIdx + 3] = 2 + i4;
		this.indexData[iIdx + 4] = 1 + i4;
		this.indexData[iIdx + 5] = 3 + i4;
		iIdx += 6;

		var yPos: Int32 = 10 + (sink != 0 ? 5 : 0);
		/*if (player.name != null && player.name != "" && player.nameTex == null) {
					player.nameText = new SimpleText(16, player.isFellowGuild ? Settings.FELLOW_GUILD_COLOR : Settings.DEFAULT_COLOR);
					player.nameText.setBold(true);
					player.nameText.text = player.name;
					player.nameText.updateMetrics();

					player.nameTex = new BitmapData(Std.int(player.nameText.width + 20), 64, true, 0);
					player.nameTex.draw(player.nameText, new Matrix(1, 0, 0, 1, 12, 0));
					player.nameTex.applyFilter(player.nameTex, player.nameTex.rect, new Point(0, 0), new GlowFilter(0, 1, 3, 3, 2, 1));

					player.nameBitmap = new Bitmap(player.nameTex);
					player.nameBitmap.cacheAsBitmap = true;
					addChild(player.nameBitmap);
				}

				player.nameBitmap.x = player.screenX - texW * 2;
				player.nameBitmap.y = player.yBaseNoZ - texH;

				if (player.props == null || !player.props.noMiniMap) {
					if (player.hp > player.maxHP)
						player.maxHP = player.hp;

					var hpPerc = player.hp / player.maxHP;
					if (hpPerc > 0 && hpPerc < 1.1) {
						if (player.hpBar == null)
							player.hpBar = new Bitmap();

						player.hpBar.bitmapData = TextureRedrawer.redrawHPBar(0x111111, 0x280000, ColorUtils.greenToRed(Std.int(hpPerc * 100)), 50, 8, hpPerc);
						player.hpBar.x = player.screenX - texW * 2;
						player.hpBar.y = player.yBaseNoZ + texH / 2;
						if (!contains(player.hpBar))
							addChild(player.hpBar);
						yPos += 15;
					}
			}

			if (player.condition > 0) {
				var icon: BitmapData = null;
				if (player.icons == null)
					player.icons = new Array<BitmapData>();

				player.icons.splice(0, player.icons.length);
				ConditionEffect.getConditionEffectIcons(player.condition, player.icons, Std.int(time / 500));
				var len: Int32 = player.icons.length;
				var lenDiv2: Int32 = len >> 1;
				for (i in 0...len) {
					icon = player.icons[i];
					var iconData = TextureFactory.make(icon);
						var iconW: Int32 = iconData.width;
						RenderUtils.baseRender(iconW, iconData.height, player.screenX - iconW * lenDiv2 + i * iconW, player.yBaseNoZ + player.dh + yPos, player.width,
							player.height, player.uValue, player.vValue, 1);
				}
		}*/
	}

	@:nonVirtual private final inline function drawProjectile(time: Int32, proj: Projectile) {
		proj.calcScreenCoords();

		var texW = proj.width * Main.ATLAS_WIDTH,
			texH = proj.height * Main.ATLAS_HEIGHT;

		final size = Camera.SIZE_MULT * proj.size;
		final w = size * texW;
		final h = size * texH;
		final yBase = (proj.screenY - (h / 2 - size * Main.PADDING)) * RenderUtils.clipSpaceScaleY;
		final xBase = proj.screenX * RenderUtils.clipSpaceScaleX;
		final texelW = 2 / Main.ATLAS_WIDTH / size;
		final texelH = 2 / Main.ATLAS_HEIGHT / size;
		final rotation = proj.props.rotation;
		final angle = proj.getDirectionAngle(time) + proj.props.angleCorrection + (rotation == 0 ? 0 : time / rotation);
		final cosAngle = MathUtil.cos(angle);
		final sinAngle = MathUtil.sin(angle);
		final xScaledCos = cosAngle * w * RenderUtils.clipSpaceScaleX * 0.5;
		final xScaledSin = sinAngle * h * RenderUtils.clipSpaceScaleX * 0.5;
		final yScaledCos = cosAngle * w * RenderUtils.clipSpaceScaleY * 0.5;
		final yScaledSinInv = -sinAngle * h * RenderUtils.clipSpaceScaleY * 0.5;

		this.vertexData[vIdx] = -xScaledCos + xScaledSin + xBase;
		this.vertexData[vIdx + 1] = yScaledSinInv + -yScaledCos + yBase;
		this.vertexData[vIdx + 2] = proj.uValue;
		this.vertexData[vIdx + 3] = proj.vValue;

		this.vertexData[vIdx + 4] = texelW;
		this.vertexData[vIdx + 5] = texelH;
		this.vertexData[vIdx + 6] = 0;
		this.vertexData[vIdx + 7] = 0;
		this.vertexData[vIdx + 8] = 0;

		this.vertexData[vIdx + 9] = xScaledCos + xScaledSin + xBase;
		this.vertexData[vIdx + 10] = -(yScaledSinInv + yScaledCos) + yBase;
		this.vertexData[vIdx + 11] = proj.uValue + proj.width;
		this.vertexData[vIdx + 12] = proj.vValue;

		this.vertexData[vIdx + 13] = texelW;
		this.vertexData[vIdx + 14] = texelH;
		this.vertexData[vIdx + 15] = 0;
		this.vertexData[vIdx + 16] = 0;
		this.vertexData[vIdx + 17] = 0;

		this.vertexData[vIdx + 18] = -(xScaledCos + xScaledSin) + xBase;
		this.vertexData[vIdx + 19] = yScaledSinInv + yScaledCos + yBase;
		this.vertexData[vIdx + 20] = proj.uValue;
		this.vertexData[vIdx + 21] = proj.vValue + proj.height;

		this.vertexData[vIdx + 22] = texelW;
		this.vertexData[vIdx + 23] = texelH;
		this.vertexData[vIdx + 24] = 0;
		this.vertexData[vIdx + 25] = 0;
		this.vertexData[vIdx + 26] = 0;

		this.vertexData[vIdx + 27] = xScaledCos + -xScaledSin + xBase;
		this.vertexData[vIdx + 28] = -yScaledSinInv + yScaledCos + yBase;
		this.vertexData[vIdx + 29] = proj.uValue + proj.width;
		this.vertexData[vIdx + 30] = proj.vValue + proj.height;

		this.vertexData[vIdx + 31] = texelW;
		this.vertexData[vIdx + 32] = texelH;
		this.vertexData[vIdx + 33] = 0;
		this.vertexData[vIdx + 34] = 0;
		this.vertexData[vIdx + 35] = 0;
		vIdx += 36;

		i++;
		final i4 = i * 4;
		this.indexData[iIdx] = i4;
		this.indexData[iIdx + 1] = 1 + i4;
		this.indexData[iIdx + 2] = 2 + i4;
		this.indexData[iIdx + 3] = 2 + i4;
		this.indexData[iIdx + 4] = 1 + i4;
		this.indexData[iIdx + 5] = 3 + i4;
		iIdx += 6;
	}

	@:nonVirtual public final function draw(time: Int32) {
		var camX = Camera.mapX, camY = Camera.mapY;
		if (time - this.lastTileUpdate > TILE_UPDATE_MS && camX >= 0 && camY >= 0) {
			var xMin = Std.int(camX - Camera.maxDist),
				xMax = Std.int(camX + Camera.maxDist);
			var yMin = Std.int(camY - Camera.maxDist),
				yMax = Std.int(camY + Camera.maxDist);

			var visIdx: UInt16 = 0;
			for (x in xMin...xMax)
				for (y in yMin...yMax) {
					var dx: Float32 = camX - x - 0.5;
					var dy: Float32 = camY - y - 0.5;
					if (dx * dx + dy * dy > Camera.maxDistSq)
						continue;

					var square = this.squares[x + y * mapWidth];
					if (square == null)
						continue;

					this.visSquares[visIdx++] = square;
					#if debug
					if (visIdx > MAX_VISIBLE_SQUARES)
						throw new Exception("Client sees more tiles than it should");
					#end
					square.lastVisible = time + TILE_UPDATE_MS;
				}

			this.visSquareLen = visIdx;
			this.lastTileUpdate = time;
		}

		if (time - this.lastBufferUpdate > BUFFER_UPDATE_MS) {
			if (Main.stageWidth != this.lastWidth || Main.stageHeight != this.lastHeight) {
				this.c3d.configureBackBuffer(Main.stageWidth, Main.stageHeight, 0, false);

				this.lastWidth = Main.stageWidth;
				this.lastHeight = Main.stageHeight;
				this.x = Main.stageWidth >> 1;
				this.y = Main.stageHeight >> 1;
				RenderUtils.clipSpaceScaleX = 2 / Main.stageWidth;
				RenderUtils.clipSpaceScaleY = 2 / Main.stageHeight;
			}

			this.lastBufferUpdate = time;
		}

		this.c3d.setDepthTest(true, Context3DCompareMode.LESS);
		this.c3d.clear();

		GL.activeTexture(GL.TEXTURE0);
		GL.bindTexture(GL.TEXTURE_2D, Main.atlas.texture);

		while (this.vertexLen < this.visSquareLen * 56) {
			this.vertexData = cast Stdlib.nativeRealloc(cast this.vertexData, this.vertexLen * 2);
			this.vertexLen *= 2;
		}

		while (this.indexLen < this.visSquareLen * 6) {
			this.indexData = cast Stdlib.nativeRealloc(cast this.indexData, this.indexLen * 2);
			this.indexLen *= 2;
		}

		this.i = this.vIdx = this.iIdx = 0;
		drawSquares();

		GL.useProgram(this.groundProgram);
		GL.uniform2f(cast 0, leftMaskU, leftMaskV);
		GL.uniform2f(cast 1, topMaskU, topMaskV);
		GL.uniform2f(cast 2, rightMaskU, rightMaskV);
		GL.uniform2f(cast 3, bottomMaskU, bottomMaskV);
		GL.bindVertexArray(this.groundVAO);

		GL.bindBuffer(GL.ARRAY_BUFFER, this.groundVBO);
		// think about 2x scaling factor... todo
		if (this.vIdx > this.groundVBOLen) {
			GL.bufferData(GL.ARRAY_BUFFER, this.vIdx * 4, untyped __cpp__('(uintptr_t){0}', this.vertexData), GL.DYNAMIC_DRAW);
			this.groundVBOLen = this.vIdx;
		} else
			GL.bufferSubData(GL.ARRAY_BUFFER, 0, this.vIdx * 4, untyped __cpp__('(uintptr_t){0}', this.vertexData));

		GL.enableVertexAttribArray(0);
		GL.vertexAttribPointer(0, 4, GL.FLOAT, false, 56, 0);
		GL.enableVertexAttribArray(1);
		GL.vertexAttribPointer(1, 2, GL.FLOAT, false, 56, 16);
		GL.enableVertexAttribArray(2);
		GL.vertexAttribPointer(2, 2, GL.FLOAT, false, 56, 24);
		GL.enableVertexAttribArray(3);
		GL.vertexAttribPointer(3, 2, GL.FLOAT, false, 56, 32);
		GL.enableVertexAttribArray(4);
		GL.vertexAttribPointer(4, 2, GL.FLOAT, false, 56, 40);
		GL.enableVertexAttribArray(5);
		GL.vertexAttribPointer(5, 2, GL.FLOAT, false, 56, 48);

		GL.bindBuffer(GL.ELEMENT_ARRAY_BUFFER, this.groundIBO);
		if (this.iIdx > this.groundIBOLen) {
			GL.bufferData(GL.ELEMENT_ARRAY_BUFFER, this.iIdx * 4, untyped __cpp__('(uintptr_t){0}', this.indexData), GL.DYNAMIC_DRAW);
			this.groundIBOLen = this.iIdx;
		} else
			GL.bufferSubData(GL.ELEMENT_ARRAY_BUFFER, 0, this.iIdx * 4, untyped __cpp__('(uintptr_t){0}', this.indexData));
		GL.drawElements(GL.TRIANGLES, this.iIdx, GL.UNSIGNED_INT, 0);

		if (this.gameObjectsLen == 0) {
			this.c3d.present();
			this.mapOverlay.draw(time);
			return;
		}

		while (this.vertexLen < (this.gameObjectsLen + this.playersLen + this.projectilesLen) * 36) {
			this.vertexData = cast Stdlib.nativeRealloc(cast this.vertexData, this.vertexLen * 2);
			this.vertexLen *= 2;
		}

		while (this.indexLen < (this.gameObjectsLen + this.playersLen + this.projectilesLen) * 6) {
			this.indexData = cast Stdlib.nativeRealloc(cast this.indexData, this.indexLen * 2);
			this.indexLen *= 2;
		}

		this.i = -1;
		this.vIdx = this.iIdx = 0;
		for (obj in this.gameObjects) {
			if (obj.curSquare?.lastVisible < time || obj.props.fullOccupy)
				continue;

			drawGameObject(time, obj);
		}

		for (player in this.players) {
			if (player.curSquare?.lastVisible < time)
				continue;

			drawPlayer(time, player);
		}

		for (proj in this.projectiles) {
			if (proj.curSquare?.lastVisible < time)
				continue;

			drawProjectile(time, proj);
		}

		GL.blendEquation(GL.FUNC_ADD);
		GL.enable(GL.BLEND);
		GL.blendFunc(GL.SRC_ALPHA, GL.ONE_MINUS_SRC_ALPHA);
		GL.useProgram(this.defaultProgram);
		GL.bindVertexArray(this.objVAO);

		GL.bindBuffer(GL.ARRAY_BUFFER, this.objVBO);
		if (this.vIdx > this.objVBOLen) {
			GL.bufferData(GL.ARRAY_BUFFER, this.vIdx * 4, untyped __cpp__('(uintptr_t){0}', this.vertexData), GL.DYNAMIC_DRAW);
			this.objVBOLen = this.vIdx;
		} else
			GL.bufferSubData(GL.ARRAY_BUFFER, 0, this.vIdx * 4, untyped __cpp__('(uintptr_t){0}', this.vertexData));

		GL.enableVertexAttribArray(0);
		GL.vertexAttribPointer(0, 4, GL.FLOAT, false, 36, 0);
		GL.enableVertexAttribArray(1);
		GL.vertexAttribPointer(1, 2, GL.FLOAT, false, 36, 16);
		GL.enableVertexAttribArray(2);
		GL.vertexAttribPointer(2, 2, GL.FLOAT, false, 36, 24);
		GL.enableVertexAttribArray(3);
		GL.vertexAttribPointer(3, 1, GL.FLOAT, false, 36, 32);

		GL.bindBuffer(GL.ELEMENT_ARRAY_BUFFER, this.objIBO);
		if (this.iIdx > this.objIBOLen) {
			GL.bufferData(GL.ELEMENT_ARRAY_BUFFER, this.iIdx * 4, untyped __cpp__('(uintptr_t){0}', this.indexData), GL.DYNAMIC_DRAW);
			this.objIBOLen = this.iIdx;
		} else
			GL.bufferSubData(GL.ELEMENT_ARRAY_BUFFER, 0, this.iIdx * 4, untyped __cpp__('(uintptr_t){0}', this.indexData));

		GL.drawElements(GL.TRIANGLES, iIdx, GL.UNSIGNED_INT, 0);

		// GL.bindFramebuffer(GL.FRAMEBUFFER, this.frontBuffer);
		this.c3d.present();

		this.mapOverlay.draw(time);
	}
}
