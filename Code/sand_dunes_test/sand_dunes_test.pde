PShader shadowShader, sandProjShader, sandDepositShader, noiseShader, avalancheShader;
PGraphics shadowGraphics, sandHeight, noiseGraphicsSel, noiseGraphicsDeposit, noiseModGraphics, sandDepositGraphics;

float noiseTimeBias = 37318.3172;

PVector windDir;
int maxHops = 10;

void setup(){
  size(500, 500, P2D);
  pixelDensity(1);
  //frameRate(1);
  
  // Set wind direction
  windDir = new PVector(1.0, 1.0);
  
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
  
  // Generate initial sand height
  sandHeight = createGraphics(width, height, P2D);
  sandHeight.beginDraw();
  sandHeight.loadPixels();
  for(int i = 0; i < sandHeight.pixels.length; i++){
    sandHeight.pixels[i] = color(random(255));
  }
  sandHeight.updatePixels();
  sandHeight.ellipse(0.5*width, 0.5*height, 100, 100);
  sandHeight.endDraw();
  
  // Shadow shader parameters
  shadowShader = loadShader("shadow_check.glsl");
  shadowShader.set("iResolution", float(width), float(height), 0.0);
  shadowShader.set("heightTexture", sandHeight);
  shadowShader.set("windDir", windDir.x, windDir.y);
  
  // Compute inital shadow
  shadowGraphics = createGraphics(width, height, P2D);
  shadowGraphics.beginDraw();
  shadowGraphics.shader(shadowShader);
  shadowGraphics.fill(0);
  shadowGraphics.rect(0, 0, width, height);
  shadowGraphics.endDraw();
  
  // Compute initial selection noise
  noiseGraphicsSel = createGraphics(width, height, P2D);
  noiseGraphicsSel.beginDraw();
  noiseGraphicsSel.shader(noiseShader);
  noiseGraphicsSel.fill(0);
  noiseGraphicsSel.rect(0, 0, width, height);
  noiseGraphicsSel.endDraw();
  
  // Compute initial deposition noise
  noiseShader.set("iTime", noiseTimeBias);
  noiseGraphicsDeposit = createGraphics(width, height, P2D);
  noiseGraphicsDeposit.beginDraw();
  noiseGraphicsDeposit.shader(noiseShader);
  noiseGraphicsDeposit.fill(0);
  noiseGraphicsDeposit.rect(0, 0, width, height);
  noiseGraphicsDeposit.endDraw();
  
  // Sand projection shader parameters
  sandProjShader.set("iResolution", float(width), float(height), 0.0);
  sandProjShader.set("heightTexture", sandHeight);
  sandProjShader.set("shadowTexture", shadowGraphics);
  sandProjShader.set("noiseTextureSel", noiseGraphicsSel);
  sandProjShader.set("noiseTextureDeposit", noiseGraphicsDeposit);
  sandProjShader.set("windDir", windDir.x, windDir.y);
  sandProjShader.set("selDensity", exp(-0.05));
  sandProjShader.set("hopDist", 5.0);
  sandProjShader.set("maxHops", (float) maxHops);
  
  // Initialise sand deposition graphics
  sandDepositGraphics = createGraphics(width, height, P2D);
  
  // Avalanche shader parameters
  avalancheShader = loadShader("avalanche_shader.glsl");
  avalancheShader.set("iResolution", float(width), float(height), 0.0);
  avalancheShader.set("heightTexture", sandHeight);
  avalancheShader.set("windDir", windDir.x, windDir.y);
  avalancheShader.set("hopDist", 5.0);
  avalancheShader.set("maxHops", (float) maxHops);
}

void draw(){
  println(frameCount);
  // Update selection noise
  //noiseShader.set("iTime", float(frameCount));
  //noiseGraphicsSel.beginDraw();
  //noiseGraphicsSel.shader(noiseShader);
  //noiseGraphicsSel.fill(0);
  //noiseGraphicsSel.rect(0, 0, width, height);
  //noiseGraphicsSel.endDraw();
  
  //// Update deposition noise
  //noiseShader.set("iTime", float(frameCount) + noiseTimeBias);
  //noiseGraphicsSel.beginDraw();
  //noiseGraphicsSel.shader(noiseShader);
  //noiseGraphicsSel.fill(0);
  //noiseGraphicsSel.rect(0, 0, width, height);
  //noiseGraphicsSel.endDraw();
  
  // Pass selection noise
  sandProjShader.set("noiseTextureSel", noiseGraphicsSel);
  sandProjShader.set("noiseTextureDeposit", noiseGraphicsDeposit);
  
  // Compute sand deposition
  sandDepositGraphics.beginDraw();
  sandDepositGraphics.shader(sandProjShader);
  sandDepositGraphics.fill(0);
  sandDepositGraphics.rect(0, 0, width, height);
  sandDepositGraphics.endDraw();
  
  shader(avalancheShader);
  rect(0, 0, width, height);
  //image(sandHeight, 0, 0);
  //image(noiseGraphicsSel, 0, 0);
}
