package util;

import util.BinPacker.Rect;
import openfl.display.BitmapData;

class MaskedImageSet {
	public final images: Array<MaskedImage>;
	public final imageRects: Array<Rect>;
	public final maskRects: Array<Rect>;

	public function new() {
		this.images = [];
		this.imageRects = [];
		this.maskRects = [];
	}

	public function addFromBitmapData(images: BitmapData, masks: BitmapData, width: Int, height: Int, ignoreAtlas: Bool = false) {
		var imagesSet = new ImageSet();
		imagesSet.addFromBitmapData(images, width, height, ignoreAtlas);
		var masksNull = masks == null;
		var masksSet: ImageSet = null;
		if (!masksNull) {
			masksSet = new ImageSet();
			masksSet.addFromBitmapData(masks, width, height, ignoreAtlas);
		}

		for (i in 0...imagesSet.images.length) {
			if (i == AnimatedChar.FRAMES_PER_DIR) {
				for (j in 0...AnimatedChar.FRAMES_PER_DIR) {
					this.images.push(new MaskedImage(BitmapUtil.mirror(imagesSet.images[j]), masksNull ? null : BitmapUtil.mirror(masksSet.images[j])));
					this.imageRects.push(imagesSet.rects[i + j]);
					this.maskRects.push(masksNull ? null : masksSet.rects[i + j]);
				}
			}

			this.images.push(new MaskedImage(imagesSet.images[i], masksNull ? null : masksSet.images[i]));
			this.imageRects.push(imagesSet.rects[i < 7 ? i : i + 7]);
			this.maskRects.push(masksNull ? null : masksSet.rects[i < 7 ? i : i + 7]);
		}
	}

	public function addFromMaskedImage(maskedImage: MaskedImage, width: Int, height: Int) {
		this.addFromBitmapData(maskedImage.image, maskedImage.mask, width, height);
	}
}
