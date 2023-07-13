package objects;

import map.Camera;
import util.Utils;
import haxe.ds.IntMap;

using util.Utils.XmlUtil;

class ItemProperties {
	public var objType = 0;
	public var objId = "";
	public var displayId = "";
	public var projectiles: IntMap<ProjectileProperties>;

	public function new(objectXml: Xml) {
		var bulletType = 0;
		this.projectiles = new IntMap<ProjectileProperties>();
		if (objectXml == null)
			return;

		this.objType = objectXml.intAttribute("type");
		this.objId = objectXml.attribute("id");
		this.displayId = objectXml.element("DisplayId", this.objId);
		for (xml in objectXml.elementsNamed("Projectile")) {
			bulletType = xml.intAttribute("id");
			this.projectiles.set(bulletType, new ProjectileProperties(xml));
		}
	}
}
