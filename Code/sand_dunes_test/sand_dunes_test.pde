PShader shadowShader, sandProjShader, sandDepositShader, noiseShader, avalancheShader, sandExchangeShader;
PGraphics shadowGraphics, noiseGraphicsSel, noiseGraphicsDeposit, sandProjGraphics, avalancheGraphics, blankGraphics;
PGraphics sandHeightRead, sandHeightWrite;
PGraphics avalancheRead, avalancheWrite;

float noiseTimeBias = 37318.3172;

PVector windDir;
float hopDist = 5.0;
int maxHops = 256;
int maxAvalancheSteps = 10;

PGraphics temp;

void setup(){
  size(500, 500, P2D);
  //fullScreen(P2D);
  pixelDensity(1);
  textureWrap(REPEAT);
  //frameRate(1);
  
  // Set wind direction
  windDir = new PVector(0.0, 0.0).normalize();
  
  // Blank graphics
  blankGraphics = createGraphics(width, height, P2D);
  blankGraphics.beginDraw();
  blankGraphics.fill(0);
  blankGraphics.rect(0, 0, width, height);
  blankGraphics.endDraw();
  
  sandProjShader = loadShader("sand_proj_shader.glsl");
  
  noiseShader = loadShader("noise_shader.glsl");
  noiseShader.set("iResolution", (float) width, (float) height, 0.0);
  noiseShader.set("iTime", 0.0);
  noiseShader.set("hardThreshTexture", blankGraphics);
  noiseShader.set("probModEdges", 0.05, sqrt(2));
  
  // Generate initial sand height
  sandHeightRead = createGraphics(width, height, P2D);
  sandHeightWrite = createGraphics(width, height, P2D);
  sandHeightRead.beginDraw();
  sandHeightRead.loadPixels();
  for(int i = 0; i < sandHeightRead.pixels.length; i++){
    //sandHeightRead.pixels[i] = random(1.0) > 0.9 ? color(random(255)) : color(0);
    sandHeightRead.pixels[i] = color(random(255));
  }
  sandHeightRead.updatePixels();
  sandHeightRead.ellipse(0.5*width, 0.5*height, 100, 100);
  sandHeightRead.endDraw();
  
  // Shadow shader parameters
  shadowShader = loadShader("shadow_check.glsl");
  shadowShader.set("iResolution", (float) width, (float) height, 0.0);
  shadowShader.set("heightTexture", sandHeightRead);
  shadowShader.set("windDir", windDir.x, windDir.y);
  shadowShader.set("hopDist", hopDist);
  
  // Compute inital shadow
  shadowGraphics = createGraphics(width, height, P2D);
  shadowGraphics.beginDraw();
  shadowGraphics.textureWrap(REPEAT);
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
  sandProjShader.set("iResolution", (float) width, (float) height, 0.0);
  sandProjShader.set("heightTexture", sandHeightRead);
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
  avalancheShader.set("heightTexture", sandHeightRead);
  avalancheShader.set("windDir", windDir.x, windDir.y);
  avalancheShader.set("hopDist", hopDist);
  avalancheShader.set("maxHops", (float) maxHops);
  //avalancheGraphics = createGraphics(width, height, P2D);
  avalancheRead = createGraphics(width, height, P2D);
  avalancheWrite = createGraphics(width, height, P2D);
  
  // Final sand exchange shader parameters
  sandExchangeShader = loadShader("sand_exchange.glsl");
  sandExchangeShader.set("iResolution", (float) width, (float) height, 0.0);
}

void draw(){
  println(frameCount);
  // Update selection noise
  noiseShader.set("iTime", float(frameCount));
  noiseGraphicsSel.beginDraw();
  noiseGraphicsSel.shader(noiseShader);
  noiseGraphicsSel.fill(0);
  noiseGraphicsSel.rect(0, 0, width, height);
  noiseGraphicsSel.endDraw();
  
  // Update deposition noise
  noiseShader.set("iTime", float(frameCount) + noiseTimeBias);
  noiseGraphicsDeposit.beginDraw();
  noiseGraphicsDeposit.shader(noiseShader);
  noiseGraphicsDeposit.fill(0);
  noiseGraphicsDeposit.rect(0, 0, width, height);
  noiseGraphicsDeposit.endDraw();
  
  // Update shadow calculation
  shadowShader.set("heightTexture", sandHeightRead);
  shadowGraphics.beginDraw();
  shadowGraphics.textureWrap(REPEAT);
  shadowGraphics.shader(shadowShader);
  shadowGraphics.fill(0);
  shadowGraphics.rect(0, 0, width, height);
  shadowGraphics.endDraw();
  
  // Pass textures to sand projection shader
  sandProjShader.set("heightTexture", sandHeightRead);
  sandProjShader.set("shadowTexture", shadowGraphics);
  sandProjShader.set("noiseTextureSel", noiseGraphicsSel);
  sandProjShader.set("noiseTextureDeposit", noiseGraphicsDeposit);
  
  // Compute sand deposition
  sandProjGraphics.beginDraw();
  sandProjGraphics.textureWrap(REPEAT);
  sandProjGraphics.shader(sandProjShader);
  sandProjGraphics.fill(0);
  sandProjGraphics.rect(0, 0, width, height);
  sandProjGraphics.endDraw();
  
  // Compute avalanches
  avalancheShader.set("remoteDepositTexture", sandProjGraphics);
  avalancheShader.set("exchangeTexture", blankGraphics);
  for (int i = 0; i < maxAvalancheSteps; i++)
  {
    avalancheShader.set("heightTexture", sandHeightRead);
    
    //avalancheGraphics.beginDraw();
    //avalancheGraphics.textureWrap(REPEAT);
    //avalancheGraphics.shader(avalancheShader);
    //avalancheGraphics.fill(0);
    //avalancheGraphics.rect(0, 0, width, height);
    //avalancheGraphics.endDraw();
    
    //avalancheShader.set("remoteDepositTexture", blankGraphics);
    //avalancheShader.set("exchangeTexture", avalancheGraphics);
    
    //avalancheWrite.beginDraw();
    //avalancheWrite.textureWrap(REPEAT);
    //avalancheWrite.shader(avalancheShader);
    //avalancheWrite.fill(0);
    //avalancheWrite.rect(0, 0, width, height);
    //avalancheWrite.endDraw();
    avalancheRead.beginDraw();
    avalancheRead.textureWrap(REPEAT);
    avalancheRead.shader(avalancheShader);
    avalancheRead.fill(0);
    avalancheRead.rect(0, 0, width, height);
    avalancheRead.endDraw();
    
    //temp = avalancheRead;
    //avalancheRead = avalancheWrite;
    //avalancheWrite = temp;
    
    // Compute final sand exchange
    //sandExchangeShader.set("exchangeTexture", avalancheGraphics);
    //sandExchangeShader.set("exchangeTexture", avalancheRead);
    //sandHeightWrite.beginDraw();
    //sandHeightWrite.textureWrap(REPEAT);
    //sandHeightWrite.shader(sandExchangeShader);
    //sandHeightWrite.fill(0);
    //sandHeightWrite.rect(0, 0, width, height);
    //sandHeightWrite.endDraw();
    sandExchangeShader.set("exchangeTexture", avalancheRead);
    sandHeightRead.beginDraw();
    sandHeightRead.textureWrap(REPEAT);
    sandHeightRead.shader(sandExchangeShader);
    sandHeightRead.fill(0);
    sandHeightRead.rect(0, 0, width, height);
    sandHeightRead.endDraw();
    
    //temp = sandHeightRead;
    //sandHeightRead = sandHeightWrite;
    //sandHeightWrite = temp;
    
    avalancheShader.set("remoteDepositTexture", blankGraphics);
    avalancheShader.set("exchangeTexture", avalancheRead);
  }
  
  
  
  //shader(sandExchangeShader);
  //fill(0);
  //rect(0, 0, width, height);
  //ellipse(width*0.5, height*0.5, 10, 10);
  //image(sandProjGraphics, 0, 0);
  image(sandHeightRead, 0, 0);
}

void keyPressed(){
  saveFrame();
}
