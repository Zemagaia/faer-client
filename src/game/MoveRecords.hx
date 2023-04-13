package game;

import cpp.RawPointer;
import cpp.Stdlib;
import util.NativeTypes;

@:unreflective
@:structAccess
@:native("CMoveRecord")
extern class MoveRecord {
	public var time: Int32;
	public var x: Float32;
	public var y: Float32;

	@:native("CMoveRecord")
	public static function create(time: Int32, x: Float32, y: Float32): MoveRecord;
}

@:headerCode('
struct CMoveRecord {
   CMoveRecord(int inTime, float inX, float inY) : time(inTime), x(inX), y(inY) { }

   int time;
   float x;
   float y;
};')
class MoveRecords {
	public var lastClearTime: Int = -1;
	public var records: RawPointer<MoveRecord>;
	public var recordIdx: Int = 0;

	public function new() {
		this.records = cast Stdlib.nativeMalloc(Stdlib.sizeof(MoveRecord) * 10);
	}

	public inline function addRecord(time: Int, x: Float, y: Float) {
		if (this.lastClearTime < 0)
			return;

		var id: Int = this.getId(time);
		if (id < 1 || id > 10)
			return;

		if (this.recordIdx == 0) {
			this.records[this.recordIdx++] = MoveRecord.create(time, x, y);
			return;
		}

		var currRecord = this.records[this.recordIdx - 1];
		var currId: Int = this.getId(currRecord.time);
		if (id != currId) {
			this.records[this.recordIdx++] = MoveRecord.create(time, x, y);
			return;
		}

		var score: Int = this.getScore(id, time);
		var currScore: Int = this.getScore(id, currRecord.time);
		if (score < currScore) {
			currRecord.time = time;
			currRecord.x = x;
			currRecord.y = y;
		}
	}

	public function clear(time: Int32) {
		this.lastClearTime = time;
		this.recordIdx = 0;
	}

	private function getId(time: Int32) {
		return Std.int((time - this.lastClearTime + 50) / 100);
	}

	private function getScore(id: Int32, time: Int32) {
		return Std.int(Math.abs(time - this.lastClearTime - id * 100));
	}
}
