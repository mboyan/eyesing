import processing.video.*;

PShader shader, noiseShader, glyphShaderTexCtrlA, glyphShaderTexCtrlB, glyphShaderTexCtrlC, glyphShaderOverlay;
PGraphics spinGraphics, noiseGraphics, glyphGraphicsTexCtrlA, glyphGraphicsTexCtrlB, glyphGraphicsTexCtrlC, noiseModGraphics;

//float[] hist;

// Scanner variables
ScreenScanner screenScanner;
boolean scanToggle, scannerCtrl, scannerAdapt;
float bSampleA, bSampleB;

// Texture parameter control
float sweepSpeedA, sweepSpeedB, sweepSpeedC, sweepSpeedD;
float sweepLineWA, sweepLineWB, sweepLineWC, sweepLineWD;
float lineXA, lineXB, lineXC, lineXD;
float modA, modB, modC, modD;

float penalty;

// WPF glyph controls
float glyphSeedA, glyphSeedB;
float glyphTexCtrlA, glyphTexCtrlB, glyphTexCtrlC;

// Video reading
Movie video;
PImage inputImg; // for static image parameter control
boolean videoTextureParamControl = false;
boolean videoInvert = false;

// Noise visualisation
float probModEdge1, probModEdge2;
float noiseBlend = 0.0;

// Ising vs XY-model
float modelSelector = 0.0;
float modelSelectorPrev = modelSelector;
float xyBlend = 1.0;
float perturbMag = 0.1;

// Periodic parameter modulation
float baseSpeed = 0.5;
float modeChangeSpeed = 0.001 * baseSpeed;
float glyphModSpeedA = 0.000031 * baseSpeed;
float glyphModSpeedB = 0.0000531 * baseSpeed;
float glyphModSpeedC = 0.0000782 * baseSpeed;

void setup(){
  
  pixelDensity(1);
  
  // PGraphics objects
  spinGraphics = createGraphics(width, height, P2D);
  noiseGraphics = createGraphics(width, height, P2D);
  glyphGraphicsTexCtrlA = createGraphics(width, height, P2D);
  glyphGraphicsTexCtrlB = createGraphics(width, height, P2D);
  glyphGraphicsTexCtrlC = createGraphics(width, height, P2D);
  noiseModGraphics = createGraphics(width, height, P2D);
  
  // Initialize noise shader
  noiseShader = loadShader("noise_shader.glsl");
  noiseShader.set("iResolution", float(width), float(height), 0.0);
  noiseShader.set("iTime", 0.0);
  
  // Initialize spin shader
  shader = loadShader("eyesing_shader.glsl");
  shader.set("iTime", 0.0);
  shader.set("iResolution", float(width), float(height), 0.0);
  shader.set("beta", 0.5);
  shader.set("field", 0.0);
  shader.set("interact", 0.25);
  shader.set("selDensity", exp(-0.1));
  shader.set("modelSelector", modelSelector);
  shader.set("xyBlend", xyBlend);
  shader.set("noiseBlend", noiseBlend);
  shader.set("perturbMag", perturbMag);
  
  //size(540, 540, P2D);
  //size(800, 800, P2D);
  fullScreen(P2D);
  
  // Compute initial noise
  noiseGraphics.beginDraw();
  noiseGraphics.shader(noiseShader);
  noiseGraphics.fill(0);
  noiseGraphics.rect(0, 0, width, height);
  noiseGraphics.endDraw();
  
  // Pass initial spin state
  shader.set("spinTexture", noiseGraphics);
  
  //hist = new float[width];
  //for (int i = 0; i < hist.length; i++){
  //  hist[i] = 0;
  //}
  
  //frameRate(1);
  
  // Create and turn on scanner
  screenScanner = new ScreenScanner(width*0.5, height*0.5, width*0.25, 50);
  scanToggle = true;
  scannerCtrl = true;
  scannerAdapt = true;
  
  // Line patterns for parameter control
  sweepSpeedA = 1;
  sweepSpeedB = -10;
  sweepSpeedC = -5;
  sweepSpeedD = 1;
  sweepLineWA = 10;
  sweepLineWB = 20;
  sweepLineWC = 30;
  sweepLineWD = width;
  modA = 0;
  modB = 0;
  modC = 0;
  modD = 0;
  
  // Draw default parameter graphics
  noiseModGraphics.beginDraw();
  noiseModGraphics.background(255);
  noiseModGraphics.endDraw();
  
  // Initialize glyph shader
  glyphTexCtrlA = 0.0;
  glyphTexCtrlB = 0.0;
  glyphTexCtrlC = 0.0;
  glyphShaderTexCtrlA = loadShader("glyph_shader.glsl");
  //glyphShaderOverlay = loadShader("glyph_shader.glsl");
  glyphShaderTexCtrlA.set("iResolution", float(width), float(height), 0.0);
  glyphShaderTexCtrlA.set("iContrast", glyphTexCtrlA);
  glyphShaderTexCtrlA.set("iRepeat", 1.0, 1.0);
  //glyphShaderOverlay.set("iResolution", float(width), float(height), 0.0);
  //glyphShaderOverlay.set("iContrast", 1.0);
  glyphShaderTexCtrlB = loadShader("glyph_shader.glsl");
  glyphShaderTexCtrlB.set("iResolution", float(width), float(height), 0.0);
  glyphShaderTexCtrlB.set("iContrast", glyphTexCtrlB);
  glyphShaderTexCtrlB.set("iRepeat", 1.0, 1.0);
  glyphShaderTexCtrlC = loadShader("glyph_shader.glsl");
  glyphShaderTexCtrlC.set("iResolution", float(width), float(height), 0.0);
  glyphShaderTexCtrlC.set("iContrast", glyphTexCtrlC);
  glyphShaderTexCtrlC.set("iRepeat", 1.0, 1.0);
  
  // Noise probability modulation
  probModEdge1 = 0.3;
  probModEdge2 = sqrt(2)*0.4;
}


void draw(){
  
  // ===== Time-dependent parameters =====
  modelSelector = cos(frameCount*modeChangeSpeed)*2 + 1.0;
  modelSelector = max(min(modelSelector, 1.0), 0.0);
  xyBlend = 1.0 - pow(max(cos(frameCount*modeChangeSpeed + QUARTER_PI), 0.0), 6);
  
  glyphTexCtrlA = sin(frameCount*glyphModSpeedA)*2.0 + 1.0;
  glyphTexCtrlB = sin(frameCount*glyphModSpeedB)*2.0 + 1.0;
  glyphTexCtrlC = sin(frameCount*glyphModSpeedC)*2.0 + 1.0;
  //println(glyphTexCtrlA);
   
  // ===== Assign patterns =====
  
  // Update noise shader
  noiseShader.set("iTime", float(frameCount));
  noiseShader.set("hardThreshTexture", noiseModGraphics);
  noiseShader.set("probModEdges", probModEdge1, probModEdge2);
  
  // Draw noise for selection probs
  noiseGraphics.beginDraw();
  noiseGraphics.shader(noiseShader);
  noiseGraphics.fill(0);
  noiseGraphics.rect(0, 0, width, height);
  noiseGraphics.endDraw();
  
  // Pass selection noise
  shader.set("noiseTexture1", noiseGraphics);
  
  // Update noise shader
  noiseShader.set("iTime", float(frameCount+100000));
  
  // Draw noise for acceptance probs
  noiseGraphics.beginDraw();
  noiseGraphics.shader(noiseShader);
  noiseGraphics.fill(0);
  noiseGraphics.rect(0, 0, width, height);
  noiseGraphics.endDraw();
  
  // Pass acceptance test noise
  shader.set("noiseTexture2", noiseGraphics);
  
  // Compute glyph texture
  //if (glyphTextureCtrlIdx > 0 || glyphOverlay){
  noiseSeed(13);
  glyphSeedA = 2.0*noise(frameCount*0.001);
  noiseSeed(24);
  glyphSeedB = 2.0*noise(frameCount*0.001);
  
  glyphShaderTexCtrlA.set("iSeedA", glyphSeedA);
  glyphShaderTexCtrlA.set("iSeedB", glyphSeedB);
  //glyphShaderOverlay.set("iSeedA", glyphSeedA);
  //glyphShaderOverlay.set("iSeedB", glyphSeedB);
  //glyphShaderOverlay.set("iRepeat", glyphRepeatX, glyphRepeatY);
  glyphShaderTexCtrlA.set("iContrast", glyphTexCtrlA);
  glyphGraphicsTexCtrlA.beginDraw();
  glyphGraphicsTexCtrlA.shader(glyphShaderTexCtrlA);
  glyphGraphicsTexCtrlA.fill(0);
  glyphGraphicsTexCtrlA.rect(0, 0, width, height);
  glyphGraphicsTexCtrlA.endDraw();
  
  glyphShaderTexCtrlB.set("iSeedA", glyphSeedA);
  glyphShaderTexCtrlB.set("iSeedB", glyphSeedB);
  glyphShaderTexCtrlB.set("iContrast", glyphTexCtrlB);
  glyphGraphicsTexCtrlB.beginDraw();
  glyphGraphicsTexCtrlB.shader(glyphShaderTexCtrlB);
  glyphGraphicsTexCtrlB.fill(0);
  glyphGraphicsTexCtrlB.rect(0, 0, width, height);
  glyphGraphicsTexCtrlB.endDraw();
  
  glyphShaderTexCtrlC.set("iSeedA", glyphSeedA);
  glyphShaderTexCtrlC.set("iSeedB", glyphSeedB);
  glyphShaderTexCtrlC.set("iContrast", glyphTexCtrlC);
  glyphGraphicsTexCtrlC.beginDraw();
  glyphGraphicsTexCtrlC.shader(glyphShaderTexCtrlC);
  glyphGraphicsTexCtrlC.fill(0);
  glyphGraphicsTexCtrlC.rect(0, 0, width, height);
  glyphGraphicsTexCtrlC.endDraw();
  //}
  
  // Pass parameter textures
  if (videoTextureParamControl && video.available() == true){
    video.read();
    if (videoInvert) {
      video.filter(INVERT);
    }
    shader.set("paramTextureBeta", video);
    shader.set("paramTextureField", video);
    shader.set("paramTextureInteract", video);
    //shader.set("paramTextureBeta", inputImg);
    //shader.set("paramTextureField", inputImg);
    //shader.set("paramTextureInteract", inputImg);
  } else {
    shader.set("paramTextureBeta", glyphGraphicsTexCtrlA);
    shader.set("paramTextureField", glyphGraphicsTexCtrlB);
    shader.set("paramTextureInteract", glyphGraphicsTexCtrlC);
  }
  
  // ===========================
  // MAIN PATTERN
  // ===========================
  
  shader.set("modelSelector", modelSelector);
  shader.set("iTime", float(frameCount+12345));
  shader.set("xyBlend", xyBlend);
  shader.set("noiseBlend", noiseBlend);
  shader.set("perturbMag", perturbMag);
  
  // Draw spins
  spinGraphics.beginDraw();
  spinGraphics.shader(shader);
  spinGraphics.fill(0);
  spinGraphics.rect(0, 0, width, height);
  spinGraphics.endDraw();
  image(spinGraphics, 0, 0);
  
  // Feed spin image back to shader
  shader.set("spinTexture", spinGraphics);
  
  // Plot histogram
  //loadPixels();
  //for (int i = 0; i < pixels.length; i++){
  //  float pixelVal = brightness(pixels[i]);
  //  int binIdx = int((width - 1) * pixelVal / 255.0);
  //  hist[binIdx] += 0.1;
  //}
  //stroke(255, 0, 0);
  //for (int i = 0; i < hist.length; i++){
  //  line(i, 0, i, hist[i]);
  //}
  //updatePixels();
  //for (int i = 0; i < hist.length; i++){
  //  hist[i] = 0;
  //}
  
  //if(frameCount < 30){
  //  saveFrame();
  //}
  
  
  // Scanner
  if(scanToggle){
    
    bSampleA = screenScanner.scan();
    
    screenScanner.updatePos();
    //screenScanner.show();
    
    // Adapt scanner motion
    if(scannerAdapt){
      bSampleB = screenScanner.scan();
      penalty = -4*pow(bSampleB - 0.5, 2);
      screenScanner.stepSize = 40.0*pow(bSampleA - bSampleB, 2.0) - 50.0 * penalty;
    }
    
    // Control parameters with scanner
    if(scannerCtrl){
      shader.set("beta", exp(map(screenScanner.pos.x, 0, width, -10.0, 10.0)));
      shader.set("field", map(screenScanner.pos.y, 0, height, -1.0, 1.0));
      shader.set("interact", map(screenScanner.pos.z, 0, width, -0.1, 1.0));
    }
  }
  
  // ===========================
  // NEXT ROUND PATTERN PRE-PROCESSING
  // ===========================
  
  // Draw noise modulation graphics
  noiseModGraphics.beginDraw();
  if(sweepLineWD < width){
    noiseModGraphics.background(modD);
    noiseModGraphics.stroke(255 - modD);
    noiseModGraphics.strokeWeight(sweepLineWD);
    lineXD += sweepSpeedD + 0.5*sweepLineWD;
    lineXD = lineXD%(width + sweepLineWD);
    lineXD -= 0.5*sweepLineWD;
    noiseModGraphics.line(lineXD, 0, lineXD, height);
  } else {
    noiseModGraphics.background(255 - modD);
  }
  noiseModGraphics.endDraw();
  
  //saveFrame();
}

void mouseDragged(){
  shader.set("beta", exp(map(mouseX, 0, width, -10.0, 10.0)));
  println("beta = " + str(exp(map(mouseX, 0, width, -10.0, 10.0))));
  //shader.set("beta", map(mouseX / float(width), 0.0, 1.0, 0.0, 10.0));
  //shader.set("field", mouseY / float(width));
  shader.set("field", map(mouseY, 0, height, -1.0, 1.0));
  println("field = " + str(map(mouseY, 0, height, -1.0, 1.0)));
  //shader.set("interact", map(mouseY, 0, height, -1.0, 1.0));
  //println("interact = " + str(map(mouseY, 0, height, -1.0, 1.0)));
}

void keyPressed(){
  if(key == 'S' || key == 's'){
    // Screenshot
    saveFrame("screenshot.tiff");
  }
}
