PShader shadowShader, sandProjShader, sandDepositShader, noiseShader, avalancheShader, sandExchangeShader;
PGraphics noiseGraphicsSel, noiseGraphicsDeposit, noiseGraphicsAvalanche;
PGraphics shadowGraphics, sandProjGraphics, avalancheGraphics, blankGraphics;
PGraphics sandHeight;

float noiseTimeBiasA = 37318.3172;
float noiseTimeBiasB = 74123.9213;

PVector windDir;
float hopDist = 5.0;
int maxHops = 256;
int maxAvalancheSteps = 5;

PGraphics temp;

void setup(){
  size(500, 500, P2D);
  //fullScreen(P2D);
  pixelDensity(1);
  textureWrap(REPEAT);
  //frameRate(1);
  
  // Set wind direction
  windDir = new PVector(0.0, 1.0).normalize();
  
  // Blank graphics
  blankGraphics = createGraphics(width, height, P2D);
  renderGraphics(blankGraphics);
  
  sandProjShader = loadShader("sand_proj_shader.glsl");
  
  noiseShader = loadShader("noise_shader.glsl");
  noiseShader.set("iResolution", (float) width, (float) height, 0.0);
  noiseShader.set("iTime", 0.0);
  noiseShader.set("hardThreshTexture", blankGraphics);
  noiseShader.set("probModEdges", 0.05, sqrt(2));
  
  // Generate initial sand height
  sandHeight = createGraphics(width, height, P2D);
  sandHeight.beginDraw();
  sandHeight.loadPixels();
  for(int i = 0; i < sandHeight.pixels.length; i++){
    //sandHeight.pixels[i] = random(1.0) > 0.9 ? color(random(255)) : color(0);
    sandHeight.pixels[i] = color(random(50), 0, 0);
  }
  sandHeight.updatePixels();
  sandHeight.fill(color(50, 0, 0));
  sandHeight.ellipse(0.5*width, 0.5*height, 100, 100);
  sandHeight.endDraw();
  countPixelVals(sandHeight);
  
  // Shadow shader parameters
  shadowShader = loadShader("shadow_check.glsl");
  shadowShader.set("iResolution", (float) width, (float) height, 0.0);
  shadowShader.set("heightTexture", sandHeight);
  shadowShader.set("windDir", windDir.x, windDir.y);
  shadowShader.set("hopDist", hopDist);
  
  // Compute inital shadow
  shadowGraphics = createGraphics(width, height, P2D);
  renderGraphics(shadowGraphics, shadowShader);
  
  // Compute initial selection noise
  noiseGraphicsSel = createGraphics(width, height, P2D);
  renderGraphics(noiseGraphicsSel, noiseShader);
  
  // Compute initial deposition noise
  noiseShader.set("iTime", noiseTimeBiasA);
  noiseGraphicsDeposit = createGraphics(width, height, P2D);
  renderGraphics(noiseGraphicsDeposit, noiseShader);
  
  // Compute initial avalainche noise
  noiseShader.set("iTime", noiseTimeBiasB);
  noiseGraphicsAvalanche = createGraphics(width, height, P2D);
  renderGraphics(noiseGraphicsAvalanche, noiseShader);
  
  // Sand projection shader parameters
  sandProjShader.set("iResolution", (float) width, (float) height, 0.0);
  sandProjShader.set("heightTexture", sandHeight);
  sandProjShader.set("shadowTexture", shadowGraphics);
  sandProjShader.set("noiseTextureSel", noiseGraphicsSel);
  sandProjShader.set("noiseTextureDeposit", noiseGraphicsDeposit);
  sandProjShader.set("windDir", windDir.x, windDir.y);
  //sandProjShader.set("selDensity", exp(-0.01));
  sandProjShader.set("selDensity", 0.5);
  sandProjShader.set("hopDist", hopDist);
  sandProjShader.set("maxHops", (float) maxHops);
  
  // Initialise sand deposition graphics
  sandProjGraphics = createGraphics(width, height, P2D);
  
  // Avalanche shader parameters
  avalancheShader = loadShader("avalanche_shader.glsl");
  avalancheShader.set("iResolution", (float) width, (float) height, 0.0);
  avalancheShader.set("exchangeTexture", sandHeight);
  avalancheShader.set("windDir", windDir.x, windDir.y);
  avalancheShader.set("hopDist", hopDist);
  avalancheShader.set("maxHops", (float) maxHops);
  //avalancheGraphics = createGraphics(width, height, P2D);
  avalancheGraphics = createGraphics(width, height, P2D);
  //avalancheWrite = createGraphics(width, height, P2D);
  
  // Final sand exchange shader parameters
  sandExchangeShader = loadShader("sand_exchange.glsl");
  sandExchangeShader.set("iResolution", (float) width, (float) height, 0.0);
}

void draw(){
  println(frameCount);
  // Update selection noise
  noiseShader.set("iTime", float(frameCount));
  renderGraphics(noiseGraphicsSel, noiseShader);
  
  // Update deposition noise
  noiseShader.set("iTime", float(frameCount) + noiseTimeBiasA);
  renderGraphics(noiseGraphicsDeposit, noiseShader);
  
  // Update shadow calculation
  shadowShader.set("heightTexture", sandHeight);
  renderGraphics(shadowGraphics, shadowShader);
  
  // Pass textures to sand projection shader
  sandProjShader.set("heightTexture", sandHeight);
  sandProjShader.set("shadowTexture", shadowGraphics);
  sandProjShader.set("noiseTextureSel", noiseGraphicsSel);
  sandProjShader.set("noiseTextureDeposit", noiseGraphicsDeposit);
  
  // Compute sand deposition
  renderGraphics(sandProjGraphics, sandProjShader);
  
  // Compute avalanches
  avalancheShader.set("remoteDepositTexture", sandProjGraphics);
  avalancheShader.set("exchangeTexture", sandHeight);
  for (int i = 0; i < maxAvalancheSteps; i++)
  {
    // Update avalanche noise
    noiseShader.set("iTime", float(frameCount * maxAvalancheSteps) + noiseTimeBiasB + i);
    renderGraphics(noiseGraphicsAvalanche, noiseShader);
    
    //avalancheShader.set("heightTexture", sandHeight);
    avalancheShader.set("noiseTexture", noiseGraphicsAvalanche);
    renderGraphics(avalancheGraphics, avalancheShader);
    
    avalancheShader.set("remoteDepositTexture", blankGraphics);
    avalancheShader.set("exchangeTexture", avalancheGraphics);
  }
  
  sandExchangeShader.set("exchangeTexture", avalancheGraphics);
  renderGraphics(sandHeight, sandExchangeShader);
  
  //shader(sandExchangeShader);
  //fill(0);
  //rect(0, 0, width, height);
  //ellipse(width*0.5, height*0.5, 10, 10);
  //image(avalancheGraphics, 0, 0);
  image(sandHeight, 0, 0);
  //countPixelVals(shadowGraphics);
}

// Renders blank graphics
void renderGraphics(PGraphics graphics){
  graphics.beginDraw();
  graphics.fill(0);
  graphics.rect(0, height, width, -height);
  graphics.endDraw();
}

// Renders graphics with a shader
void renderGraphics(PGraphics graphics, PShader shader){
  graphics.beginDraw();
  graphics.textureWrap(REPEAT);
  graphics.shader(shader);
  graphics.fill(0);
  graphics.rect(0, height, width, -height);
  graphics.endDraw();
}

void countPixelVals(PGraphics graphics){
  graphics.loadPixels();
  float brightnessSum = 0.0;
  for (int i = 0; i < graphics.pixels.length; i++){
    brightnessSum += brightness(graphics.pixels[i]);
  }
  println("Total brightness: " + str(brightnessSum / 255));
}

void keyPressed(){
  saveFrame();
}
