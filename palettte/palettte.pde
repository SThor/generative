float diameter, margin;
color firstColor, secondColor, thirdColor;
float firstHue, secondHue, thirdHue;
float saturation, brightness;

JSONArray palettes;

color constrastColor(color c) {
	return brightness(c)>50 ? color(0) : color(100);
}

String colorString(color c) {
	return "("+round(hue(c))+","+round(saturation(c))+","+round(brightness(c))+")";
}

color colorFromJSON(JSONArray array) {
	return color(array.getFloat(0), array.getFloat(1), array.getFloat(2));
}

void setup () {
	// 3*diameter + 4*margin, diameter + 2*margin
	size(1050,1300, P2D);
	smooth(8);
	orientation(LANDSCAPE);
	background(255);
	colorMode(HSB,360,100,100);
	diameter = 200;
	margin = 50;

/*	firstColor = color(0,0,0);
	secondColor = color(0,0,0);
	thirdColor = color(0,0,0);*/


	palettes = new JSONArray();

	for(int i=0; i<=5; i++) {
		JSONArray palette = new JSONArray();
		for(int j=0; j<=4; j++) {
			JSONArray jsonColor = new JSONArray();
			jsonColor.append(random(360));
			jsonColor.append(random(100));
			jsonColor.append(random(100));
			palette.append(jsonColor);
		}
		palettes.append(palette);
	}

}

void draw () {
	background(360);
	noStroke();
/*
	if(keyPressed) {
		fill(0);
		text(colorString(firstColor),margin, margin-5);
		text(colorString(secondColor),2*margin+diameter, margin-5);
		text(colorString(thirdColor),3*margin+2*diameter, margin-5);
	}*/

	for(int i=0; i<palettes.size(); i++) {
		JSONArray palette = palettes.getJSONArray(i);
		for(int j=0; j<palette.size(); j++) {
			color realColor = colorFromJSON(palette.getJSONArray(j));
			fill(realColor);
			float x = j*(margin+diameter) - 0.5*diameter;
			float y = i*(margin+diameter) - 0.5*diameter;
			circle(x,y,diameter);

			if(keyPressed) {
				fill(0);
				text(colorString(realColor),x- 0.15*diameter,y- 0.5*diameter - 5);
			}
		}
	}
}

void mouseClicked() {
	float gaussianMult = 100;

	secondHue = random(360);
	firstHue = (secondHue + 120)%360;
	thirdHue = (secondHue - 120)%360;

	saturation = random(100);
	brightness = random(100);

	firstColor = color(firstHue, saturation, brightness);
	secondColor = color(secondHue, saturation, brightness);
	thirdColor = color(thirdHue, saturation, brightness);

}