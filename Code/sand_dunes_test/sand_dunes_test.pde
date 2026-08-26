PShader sandProjShader, sandDepositShader, noiseShader;
PGraphics sandHeight, noiseGraphics, noiseModGraphics;

void setup(){
  size(500, 500, P2D);
  pixelDensity(1);
  
  noiseModGraphics = createGraphics(width, height, P2D);
  noiseModGraphics.beginDraw();
  noiseModGraphics.fill(0);
  noiseModGraphics.rect(0, 0, width, height);
  noiseModGraphics.endDraw();
  
  sandProjShader = loadShader("sand_proj_shader.glsl");
  noiseShader = loadShader("noise_shader.glsl");
  noiseShader.set("iResolution", float(width), float(height), 0.0);
  noiseShader.set("iTime", 0.0);
  noiseShader.set("hardThreshTexture", noiseModGraphics);
  noiseShader.set("probModEdges", 0.05, sqrt(2));
  
  // Generate initial input
  sandHeight = createGraphics(width, height, P2D);
  sandHeight.beginDraw();
  sandHeight.loadPixels();
  for(int i = 0; i < sandHeight.pixels.length; i++){
    sandHeight.pixels[i] = color(random(255));
  }
  sandHeight.updatePixels();
  sandHeight.ellipse(0.5*width, 0.5*height, 100, 100);
  sandHeight.endDraw();
  
  // Compute initial noise
  noiseGraphics = createGraphics(width, height, P2D);
  noiseGraphics.beginDraw();
  noiseGraphics.shader(noiseShader);
  noiseGraphics.fill(0);
  noiseGraphics.rect(0, 0, width, height);
  noiseGraphics.endDraw();
  
  sandProjShader.set("iResolution", float(width), float(height), 0.0);
  sandProjShader.set("heightTexture", sandHeight);
  sandProjShader.set("noiseTexture", noiseGraphics);
  sandProjShader.set("windDir", 1.0, 1.0);
  sandProjShader.set("selDensity", exp(-0.05));
  sandProjShader.set("hopDist", 5.0);
}

void draw(){
  shader(sandProjShader);
  rect(0, 0, width, height);
  //image(sandHeight, 0, 0);
  //image(noiseGraphics, 0, 0);
}
