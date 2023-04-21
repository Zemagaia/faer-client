package mapeditor;

import map.RegionLibrary;

class RegionChooser extends Chooser {
	public function new() {
		super(Layer.REGION);
		for (regionXML in RegionLibrary.xmlLibrary)
			addElement(new RegionElement(regionXML));
		for (regionXML in RegionLibrary.xmlLibrary)
			addElement(new RegionElement(regionXML));
		for (regionXML in RegionLibrary.xmlLibrary)
			addElement(new RegionElement(regionXML));
	}
}
