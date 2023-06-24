package map;

using util.Utils;

class GroundProperties {
	public var objType = 0;
	public var objId = "";
	public var noWalk = true;
	public var damage = 0;
	public var animate: AnimateProperties;
	public var blendPriority: Int = -1;
	public var speed: Float = 1.0;
	public var uOffset = 0.0;
	public var vOffset = 0.0;
	public var push = false;
	public var sink = false;
	public var sinking = false;
	public var lightColor = -1;
	public var lightIntensity = 0.1;
	public var lightRadius = 1.0;

	public function new(groundXml: Xml) {
		this.objType = groundXml.intAttribute("type");
		this.objId = groundXml.attribute("id");
		this.noWalk = groundXml.elementExists("NoWalk");
		this.damage = groundXml.intElement("Damage");
		this.push = groundXml.elementExists("Push");
		this.blendPriority = groundXml.intElement("BlendPriority");
		this.speed = groundXml.floatElement("Speed", 1.0);
		this.uOffset = groundXml.intElement("XOffset");
		this.vOffset = groundXml.intElement("YOffset");
		this.push = groundXml.elementExists("Push");
		this.sink = groundXml.elementExists("Sink");
		this.sinking = groundXml.elementExists("Sinking");
		this.lightColor = groundXml.intElement("LightColor", -1);
		this.lightIntensity = groundXml.floatElement("LightIntensity", 0.1);
		this.lightRadius = groundXml.floatElement("LightRadius", 1);

		if (groundXml.elementExists("Animate"))
			this.animate = new AnimateProperties(groundXml.elementsNamed("Animate").next());
		else
			this.animate = new AnimateProperties(Xml.parse(""));
	}
}
