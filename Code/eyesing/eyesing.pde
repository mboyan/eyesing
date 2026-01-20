import ddf.minim.*;
import ddf.minim.analysis.*;
import processing.video.*;

PShader shader, noiseShader, glyphShaderTexCtrl, glyphShaderOverlay;
PGraphics spinGraphics, noiseGraphics, paramGraphicsA, paramGraphicsB, paramGraphicsC, glyphGraphicsTexCtrl, glyphGraphicsOverlay, noiseModGraphics;

//float[] hist;

// Scanner variables
ScreenScanner screenScanner;
boolean scanToggle, scannerCtrl, scannerAdapt;
float bSampleA, bSampleB;

// Texture parameter control
boolean lineTextureParamCtrl = true;
float sweepSpeedA, sweepSpeedB, sweepSpeedC, sweepSpeedD;
float sweepLineWA, sweepLineWB, sweepLineWC, sweepLineWD;
float lineXA, lineXB, lineXC, lineXD;
float modA, modB, modC, modD;

float penalty;

// Audio reactivity
Minim minim;
FFT fft;
AudioPlayer in;
boolean audioReact = false;
float[] bands;
int bandShiftIdx;
float[] lvlThresh = {2.0, 0.5, 0.25, 0.125}; // Calibrate before show???

// WPF glyph controls
boolean glyphOverlay = true;
float glyphSeedA, glyphSeedB;
float glyphRepeatX, glyphRepeatY;
int glyphTextureCtrlIdx = 0; // 0 for none, 1 for beta, 2 for field, 3 for interact

// Video reading
Movie video;
boolean videoTextureParamControl = true;

// Noise visualisation
boolean viewNoise = false;
float probModEdge1, probModEdge2;

void setup(){
  
  // Initialize minim and track
  minim = new Minim(this);
  in = minim.loadFile("sample_live_coding_jam.wav", 1024); // change to mic input when needed
  fft = new FFT(in.bufferSize(), in.sampleRate());
  bands = new float[4];
  bandShiftIdx = 0;
  
  // PGraphics objects
  spinGraphics = createGraphics(width, height, P2D);
  noiseGraphics = createGraphics(width, height, P2D);
  paramGraphicsA = createGraphics(width, height, P2D);
  paramGraphicsB = createGraphics(width, height, P2D);
  paramGraphicsC = createGraphics(width, height, P2D);
  glyphGraphicsTexCtrl = createGraphics(width, height, P2D);
  glyphGraphicsOverlay = createGraphics(width, height, P2D);
  noiseModGraphics = createGraphics(width, height, P2D);
  
  // Initialize noise shader
  noiseShader = loadShader("noise_shader.glsl");
  noiseShader.set("iResolution", float(width), float(height), 0.0);
  noiseShader.set("iTime", 0.0);
  
  // Initialize spin shader
  shader = loadShader("eyesing_shader.glsl");
  shader.set("iResolution", float(width), float(height), 0.0);
  shader.set("beta", 0.5);
  shader.set("field", 0.0);
  shader.set("interact", 0.25);
  shader.set("selDensity", exp(-0.1));
  
  //size(540, 540, P2D);
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
  screenScanner = new ScreenScanner(width*0.5, height*0.5, width*0.25, 100);
  scanToggle = true;
  scannerCtrl = true;
  scannerAdapt = true;
  
  // Line patterns for parameter control
  sweepSpeedA = -5;
  sweepSpeedB = -1;
  sweepSpeedC = -10;
  sweepSpeedD = 5;
  sweepLineWA = 100;
  sweepLineWB = 200;
  sweepLineWC = 50;
  sweepLineWD = 0;
  modA = 0;
  modB = 0;
  modC = 0;
  modD = 0;
  
  // Draw default parameter graphics
  paramGraphicsA.beginDraw();
  paramGraphicsA.background(127);
  paramGraphicsA.endDraw();
  
  paramGraphicsB.beginDraw();
  paramGraphicsB.background(127);
  paramGraphicsB.endDraw();
  
  paramGraphicsC.beginDraw();
  paramGraphicsC.background(127);
  paramGraphicsC.endDraw();
  
  // Initialize glyph shader
  glyphShaderTexCtrl = loadShader("glyph_shader.glsl");
  glyphShaderOverlay = loadShader("glyph_shader.glsl");
  glyphRepeatX = 1; //16
  glyphRepeatY = 1; //9
  glyphShaderTexCtrl.set("iResolution", float(width), float(height), 0.0);
  glyphShaderTexCtrl.set("iContrast", 0.5);
  glyphShaderOverlay.set("iResolution", float(width), float(height), 0.0);
  glyphShaderOverlay.set("iContrast", 1.0);
  
  // Video input
  //video = new Movie(this, "VCLP0150.avi");
  //video = new Movie(this, "DSC_1789.mp4");
  //video = new Movie(this, "grubbly.mp4");
  //video = new Movie(this, "IMG_0138.mov");
  video = new Movie(this, "GlitchmanWalking.mp4");
  video.loop();
  
  // Noise probability modulation
  probModEdge1 = 0.05;
  probModEdge2 = sqrt(2);
}


void draw(){
  
  // ===== Analyze sound =====
  if(frameCount > 30){
    in.play();
  }
  if(audioReact){
    fft.forward(in.left);
    
    // Get low freqs
    bands[bandShiftIdx] = 0;
    for(int i = 0; i < fft.specSize()*0.25; i++){
      bands[bandShiftIdx] += fft.getBand(i);
    }
    bands[bandShiftIdx] /= fft.specSize()*0.25;
    
    // Get mid A freqs
    bands[(bandShiftIdx+1)%4] = 0;
    for(int i = int(fft.specSize()*0.25); i < fft.specSize()*0.5; i++){
      bands[(bandShiftIdx+1)%4] += fft.getBand(i);
    }
    bands[(bandShiftIdx+1)%4] /= fft.specSize()*0.25;
    
    // Get mid B freqs
    bands[(bandShiftIdx+2)%4] = 0;
    for(int i = int(fft.specSize()*0.5); i < fft.specSize()*0.75; i++){
      bands[(bandShiftIdx+2)%4] += fft.getBand(i);
    }
    bands[(bandShiftIdx+2)%4] /= fft.specSize()*0.25;
    
    // Get high freqs
    bands[(bandShiftIdx+3)%4] = 0;
    for(int i = int(fft.specSize()*0.75); i < fft.specSize(); i++){
      bands[(bandShiftIdx+3)%4] += fft.getBand(i);
    }
    bands[(bandShiftIdx+3)%4] /= fft.specSize()*0.25;
  }
  
  // ===========================
  // PATTERN PRE-PROCESSING
  // ===========================
  
  // Draw parameter graphics
  if(lineTextureParamCtrl && !viewNoise){
    paramGraphicsA.beginDraw();
    paramGraphicsA.background(127);
    paramGraphicsA.stroke(modA);
    paramGraphicsA.strokeWeight(sweepLineWA);
    lineXA = (width + (frameCount*sweepSpeedA)%(width + sweepLineWA))%width - 0.5*sweepLineWA;
    paramGraphicsA.line(lineXA, 0, lineXA, height);
    paramGraphicsA.endDraw();
    
    paramGraphicsB.beginDraw();
    paramGraphicsB.background(127);
    paramGraphicsB.stroke(modB);
    paramGraphicsB.strokeWeight(sweepLineWB);
    lineXB = (width + (frameCount*sweepSpeedB)%(width + sweepLineWB))%width - 0.5*sweepLineWB;
    paramGraphicsB.line(lineXB, 0, lineXB, height);
    paramGraphicsB.endDraw();
    
    paramGraphicsC.beginDraw();
    paramGraphicsC.background(127);
    paramGraphicsC.stroke(modC);
    paramGraphicsC.strokeWeight(sweepLineWC);
    lineXC = (width + (frameCount*sweepSpeedC)%(width + sweepLineWC))%width - 0.5*sweepLineWC;
    paramGraphicsC.line(lineXC, 0, lineXC, height);
    paramGraphicsC.endDraw();
  }
  
  // Draw noise modulation graphics
  noiseModGraphics.beginDraw();
  if(sweepLineWD < width){
    noiseModGraphics.background(modD);
    noiseModGraphics.stroke(255 - modD);
    noiseModGraphics.strokeWeight(sweepLineWD);
    lineXD = (width + (frameCount*sweepSpeedD)%(width + sweepLineWD))%width - 0.5*sweepLineWD;
    noiseModGraphics.line(lineXD, 0, lineXD, height);
  } else {
    noiseModGraphics.background(255 - modD);
  }
  noiseModGraphics.endDraw();
  
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
  if (glyphTextureCtrlIdx > 0 || glyphOverlay){
    noiseSeed(13);
    glyphSeedA = 2.0*noise(frameCount*0.008);
    noiseSeed(24);
    glyphSeedB = 2.0*noise(frameCount*0.008);
    
    glyphShaderTexCtrl.set("iSeedA", glyphSeedA);
    glyphShaderTexCtrl.set("iSeedB", glyphSeedB);
    glyphShaderTexCtrl.set("iRepeat", glyphRepeatX, glyphRepeatY);
    glyphShaderOverlay.set("iSeedA", glyphSeedA);
    glyphShaderOverlay.set("iSeedB", glyphSeedB);
    glyphShaderOverlay.set("iRepeat", glyphRepeatX, glyphRepeatY);
    
    glyphGraphicsTexCtrl.beginDraw();
    glyphGraphicsTexCtrl.shader(glyphShaderTexCtrl);
    glyphGraphicsTexCtrl.fill(0);
    glyphGraphicsTexCtrl.rect(0, 0, width, height);
    glyphGraphicsTexCtrl.endDraw();
  }
  
  // Pass parameter textures
  if (!viewNoise) {
    if (videoTextureParamControl && video.available() == true){
      video.read();
      video.filter(INVERT);
      shader.set("paramTextureBeta", video);
      shader.set("paramTextureField", video);
      shader.set("paramTextureInteract", video);
    } else {
      if (glyphTextureCtrlIdx == 1){
        shader.set("paramTextureBeta", glyphGraphicsTexCtrl);
      } else {
        shader.set("paramTextureBeta", paramGraphicsA);
      }
      if (glyphTextureCtrlIdx == 2){
        shader.set("paramTextureField", glyphGraphicsTexCtrl);
      } else {
        shader.set("paramTextureField", paramGraphicsB);
      }
      if (glyphTextureCtrlIdx == 3){
        shader.set("paramTextureInteract", glyphGraphicsTexCtrl);
      } else {
        shader.set("paramTextureInteract", paramGraphicsC);
      }
    }
  }
  //shader.set("spinTexture", spinGraphics);
  
  // Update processing shader
  //shader.set("iTime", float(frameCount));
  
  //shader(shader);
  ////image(noiseGraphics, 0, 0);
  //fill(0);
  //rect(0, 0, width, height);
  
  // ===========================
  // MAIN PATTERN
  // ===========================
  
  // Draw spins
  if (viewNoise){
    image(noiseGraphics, 0, 0);
  } else {
    spinGraphics.beginDraw();
    spinGraphics.shader(shader);
    spinGraphics.fill(0);
    spinGraphics.rect(0, 0, width, height);
    spinGraphics.endDraw();
    image(spinGraphics, 0, 0);
  }
  
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
  
  // ===========================
  // PATTERN OVERLAY
  // ===========================
  
  // Glyph overlay
  if (glyphOverlay){
    glyphGraphicsOverlay.beginDraw();
    glyphGraphicsOverlay.shader(glyphShaderOverlay);
    glyphGraphicsOverlay.fill(0);
    glyphGraphicsOverlay.rect(0, 0, width, height);
    glyphGraphicsOverlay.endDraw();
    blendMode(MULTIPLY);
    image(glyphGraphicsOverlay, 0, 0);
    blendMode(BLEND);
  }
  
  //rectMode(CORNER);
  //shader(glyphShader);
  //fill(0);
  //rect(0, 0, width, height);
  
  // Crosshair
  if(scanToggle){
    
    bSampleA = screenScanner.scan();
    //fill(255, 0, 0);
    //textSize(50);
    //text(str(bSampleA), 50, 50);
    //text(str(screenScanner.pos.z), 50, 120);
    
    screenScanner.updatePos();
    
    // Flicker bands
    if(audioReact){
      fill(0);
      noStroke();
      rectMode(CORNER);
      if(bands[0] < lvlThresh[0]){
        rect(screenScanner.pos.x + screenScanner.winSize*0.5, screenScanner.pos.y, width, height);
        rect(screenScanner.pos.x, screenScanner.pos.y + screenScanner.winSize*0.5, width, height);
      }
      if(bands[1] < lvlThresh[1]){
        rect(screenScanner.pos.x + screenScanner.winSize*0.5, screenScanner.pos.y, width, -height);
        rect(screenScanner.pos.x, screenScanner.pos.y - screenScanner.winSize*0.5, width, -height);
      }
      if(bands[2] < lvlThresh[2]){
        rect(screenScanner.pos.x - screenScanner.winSize*0.5, screenScanner.pos.y, -width, height);
        rect(screenScanner.pos.x, screenScanner.pos.y + screenScanner.winSize*0.5, -width, height);
      }
      if(bands[3] < lvlThresh[3]){
        rect(screenScanner.pos.x - screenScanner.winSize*0.5, screenScanner.pos.y, -width, -height);
        rect(screenScanner.pos.x, screenScanner.pos.y - screenScanner.winSize*0.5, -width, -height);
      }
    }
    screenScanner.show();
    
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
  if(key == 'Q' || key == 'q'){
    // Flip parameter A modulation
    modA = (modA == 0) ? 255 : 0;
  }
  if(key == 'W' || key == 'w'){
    // Flip parameter B modulation
    modB = (modB == 0) ? 255 : 0;
  }
  if(key == 'E' || key == 'e'){
    // Flip parameter C modulation
    modC = (modC == 0) ? 255 : 0;
  }
  if(key == 'R' || key == 'r'){
    // Flip noise probability modulation
    modD = (modD == 0) ? 255 : 0;
  }
  if(key == 'S' || key == 's'){
    // Screenshot
    saveFrame("screenshot.tiff");
  }
  // Glyph repeats
  //if(key == '0'){
  //  glyphRepeatX = 1;
  //  glyphRepeatY = 1;
  //}
  //if(key == '1'){
  //  glyphRepeatX = 8;
  //  glyphRepeatY = 5;
  //}
  //if(key == '2'){
  //  glyphRepeatX = 16;
  //  glyphRepeatY = 10;
  //}
  //if(key == '3'){
  //  glyphRepeatX = 24;
  //  glyphRepeatY = 15;
  //}
  //if(key == '4'){
  //  glyphRepeatX = 32;
  //  glyphRepeatY = 20;
  //}
  //if(key == '5'){
  //  glyphRepeatX = 40;
  //  glyphRepeatY = 25;
  //}
  // FOR PROJECTOR RESOLUTION
  if(key == '0'){
    glyphRepeatX = 1;
    glyphRepeatY = 1;
  }
  if(key == '1'){
    glyphRepeatX = 16;
    glyphRepeatY = 9;
  }
  if(key == '2'){
    glyphRepeatX = 32;
    glyphRepeatY = 18;
  }
  if(key == '3'){
    glyphRepeatX = 64;
    glyphRepeatY = 32;
  }
}
