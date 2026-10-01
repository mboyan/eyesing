PShader shadowShader, sandProjShader, sandDepositShader, noiseShader, avalancheShader, sandExchangeShader, sandOutputShader;
PGraphics noiseGraphicsSel, noiseGraphicsDeposit, noiseGraphicsAvalanche;
PGraphics shadowGraphics, sandProjGraphics, avalancheGraphics, blankGraphics, sandExchangeGraphics;
PGraphics sandHeight;

float noiseTimeBiasA = 37318.3172;
float noiseTimeBiasB = 74123.9213;

PVector windDir;
float hopDist = 15.0;
int maxHops = 17;
int maxAvalancheSteps = 2;
float grainSize = 1.0 / 32.0;
float selDensity = 0.75;

void setup(){
  size(1920, 1080, P2D);
  //size(800, 800, P2D);
  //fullScreen(P2D);
  pixelDensity(1);
  textureWrap(REPEAT);
  //frameRate(1);
  
  // Set wind direction
  windDir = new PVector(1.0, 1.0).normalize();
  
  // Blank graphics
  blankGraphics = createGraphics(width, height, P2D);
  renderGraphics(blankGraphics);
  
  noiseShader = loadShader("noise_shader.glsl");
  noiseShader.set("iResolution", (float) width, (float) height, 0.0);
  noiseShader.set("iTime", 0.0);
  noiseShader.set("hardThreshTexture", blankGraphics);
  noiseShader.set("probModEdges", 0.05, sqrt(2));
  
  // Generate initial sand height
  sandExchangeGraphics = createGraphics(width, height, P2D);
  sandExchangeGraphics.beginDraw();
  sandExchangeGraphics.loadPixels();
  for(int i = 0; i < sandExchangeGraphics.pixels.length; i++){
    //sandExchangeGraphics.pixels[i] = random(1.0) > 0.9 ? color(random(255)) : color(0);
    sandExchangeGraphics.pixels[i] = color(random(120), 0, 0);
    //sandExchangeGraphics.pixels[i] = color(round(random(5.0)) * 255 * 1.0 / 16.0, 0, 0);
  }
  sandExchangeGraphics.updatePixels();
  sandExchangeGraphics.fill(color(255, 0, 0));
  sandExchangeGraphics.ellipse(0.5*width, 0.5*height, 0.2*height, 0.2*height);
  sandExchangeGraphics.endDraw();
  //countPixelVals(sandExchangeGraphics);
  sandHeight = createGraphics(width, height, P2D);
  
  // Shadow shader parameters
  shadowShader = loadShader("shadow_check.glsl");
  shadowShader.set("iResolution", (float) width, (float) height, 0.0);
  shadowShader.set("heightTexture", sandExchangeGraphics);
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
  sandProjShader = loadShader("sand_proj_shader.glsl");
  sandProjShader.set("iResolution", (float) width, (float) height, 0.0);
  sandProjShader.set("heightTexture", sandExchangeGraphics);
  sandProjShader.set("shadowTexture", shadowGraphics);
  sandProjShader.set("noiseTextureSel", noiseGraphicsSel);
  sandProjShader.set("noiseTextureDeposit", noiseGraphicsDeposit);
  sandProjShader.set("windDir", windDir.x, windDir.y);
  //sandProjShader.set("selDensity", exp(-0.01));
  sandProjShader.set("selDensity", selDensity);
  sandProjShader.set("hopDist", hopDist);
  sandProjShader.set("maxHops", (float) maxHops);
  
  // Initialise sand deposition graphics
  sandProjGraphics = createGraphics(width, height, P2D);
  
  // Avalanche shader parameters
  avalancheShader = loadShader("avalanche_shader.glsl");
  avalancheShader.set("iResolution", (float) width, (float) height, 0.0);
  avalancheShader.set("exchangeTexture", sandExchangeGraphics);
  avalancheShader.set("windDir", windDir.x, windDir.y);
  avalancheShader.set("hopDist", hopDist);
  avalancheShader.set("maxHops", (float) maxHops);
  avalancheShader.set("grainSize", grainSize);
  avalancheGraphics = createGraphics(width, height, P2D);
  
  // Final sand exchange shader parameters
  sandExchangeShader = loadShader("sand_exchange.glsl");
  sandExchangeShader.set("iResolution", (float) width, (float) height, 0.0);
  sandExchangeShader.set("grainSize", grainSize);
  sandOutputShader = loadShader("sand_output_shader.glsl");
  sandOutputShader.set("iResolution", (float) width, (float) height, 0.0);
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
  shadowShader.set("heightTexture", sandExchangeGraphics);
  renderGraphics(shadowGraphics, shadowShader);
  //shadowGraphics.save("shadowGraphics_" + nf(frameCount, 5) + ".tiff");
  
  // Pass textures to sand projection shader
  sandProjShader.set("heightTexture", sandExchangeGraphics);
  sandProjShader.set("shadowTexture", shadowGraphics);
  sandProjShader.set("noiseTextureSel", noiseGraphicsSel);
  sandProjShader.set("noiseTextureDeposit", noiseGraphicsDeposit);
  
  // Compute sand deposition
  renderGraphics(sandProjGraphics, sandProjShader);
  //sandProjGraphics.save("sandProjGraphics_" + nf(frameCount, 5) + ".tiff");
  
  // Compute avalanches
  avalancheShader.set("remoteDepositTexture", sandProjGraphics);
  avalancheShader.set("exchangeTexture", sandExchangeGraphics);
  for (int i = 0; i < maxAvalancheSteps; i++)
  {
    // Update avalanche noise
    noiseShader.set("iTime", float(frameCount * maxAvalancheSteps) + noiseTimeBiasB + i);
    renderGraphics(noiseGraphicsAvalanche, noiseShader);
    //noiseGraphicsAvalanche.save("noiseGraphicsAvalanche_" + str(i) + "_" + nf(frameCount, 5) + ".tiff");
    
    avalancheShader.set("noiseTexture", noiseGraphicsAvalanche);
    renderGraphics(avalancheGraphics, avalancheShader);
    //avalancheGraphics.save("avalancheGraphics_" + str(i) + "_" + nf(frameCount, 5) + ".tiff");
    
    avalancheShader.set("remoteDepositTexture", blankGraphics);
    avalancheShader.set("exchangeTexture", avalancheGraphics);
  }
  
  sandExchangeShader.set("exchangeTexture", avalancheGraphics);
  renderGraphics(sandExchangeGraphics, sandExchangeShader);
  //sandExchangeGraphics.save("sandExchangeGraphics_" + nf(frameCount, 5) + ".tiff");
  
  //shader(sandExchangeShader);
  //fill(0);
  //rect(0, 0, width, height);
  //ellipse(width*0.5, height*0.5, 10, 10);
  //image(avalancheGraphics, 0, 0);
  
  sandOutputShader.set("heightTexture", sandExchangeGraphics);
  renderGraphics(sandHeight, sandOutputShader);
  image(sandHeight, 0, 0);
  //countPixelVals(sandHeight);
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
