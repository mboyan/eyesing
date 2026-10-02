import ddf.minim.*;
import ddf.minim.analysis.*;
import processing.video.*;
import themidibus.*;
import javax.sound.midi.MidiMessage;

PShader shader, noiseShader, glyphShaderTexCtrl, glyphShaderOverlay;
PShader sandProjShader, sandExchangeShader, shadowShader, sandConvertShader, avalancheShader;
PGraphics spinGraphics, noiseGraphics, paramGraphicsA, paramGraphicsB, paramGraphicsC, glyphGraphicsTexCtrl, glyphGraphicsOverlay, noiseModGraphics;
PGraphics blankGraphicsZero, blankGraphicsMid, sandExchangeGraphics, shadowGraphics, sandProjGraphics, avalancheGraphics;

float noiseTimeBiasA = 37318.3172;
float noiseTimeBiasB = 74123.9213;
float noiseTimeBiasC = 2133.31923;

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
boolean invertSpins = false;

float penalty;

// Audio reactivity
Minim minim;
FFT fft;
//AudioPlayer in;
AudioInput in;
boolean audioReact = true;
float[] bands;
int bandShiftIdx;
float[] lvlThresh = {2.0, 0.5, 0.25, 0.125};

// WPF glyph controls
boolean glyphOverlay = false;
float glyphSeedA, glyphSeedB;
float glyphRepeatX = 1;
float glyphRepeatY = 1;
int glyphTextureCtrlIdx = 2; // 0 for none, 1 for beta, 2 for field, 3 for interact

// Video reading
Movie video;
PImage inputImg; // for static image parameter control
boolean videoTextureParamControl = false;
boolean videoInvert = false;
String[] videoTitles = {"VCLP0150.avi", "DSC_1789.mp4", "grubbly.mp4", "IMG_0138.mov", "GlitchmanWalking.mp4", "IMG-3278.mov", "DSC_0216.mov"};

// Noise visualisation
float probModEdge1, probModEdge2;
float noiseBlend = 0.0;
boolean quantizeNoise = false;

// Ising vs XY-model
boolean xyToggle = false;
float xyBlend = 1.0;

// Sand dune model variables
boolean toggleSandDunes = false;
PVector windDir = new PVector(1.0, 0.0).normalize();
float hopDist = 15.0;
int maxHops = 17;
int maxAvalancheSteps = 2;
float grainSize = 1.0 / 32.0;
//float selDensity = 0.75;
boolean toggleSelDensMod = false;

// MIDI
MidiBus f1Bus, x1Bus;

void setup(){
  
  //size(540, 540, P2D);
  //size(800, 800, P2D);
  //size(1080, 1350, P2D); // 4:5 format
  size(1350, 1080, P2D); // 5:4 format
  //size(1600, 1600, P2D);
  //size(1920, 1080, P2D);
  //size(540, 810, P2D);
  //size(1080, 360, P2D);
  //size(1754, 1240, P2D); // A4 150dpi
  //fullScreen(P2D, 2);
  //fullScreen(P2D);
  pixelDensity(1); // For Processing 4.5.2
  textureWrap(REPEAT);
  
  // Initialize MIDI
  MidiBus.list(); // List all available Midi devices on STDOUT. This will show each device's index and name.
  f1Bus = new MidiBus();
  f1Bus.registerParent(this);
  f1Bus.addInput(1);
  x1Bus = new MidiBus();
  x1Bus.registerParent(this);
  x1Bus.addInput(2);
  
  // Initialize minim and track
  minim = new Minim(this);
  //in = minim.loadFile("260327_eyesing_demo_soundtrack.mp3", 1024); // change to mic input when needed
  in = minim.getLineIn(Minim.MONO, 512);
  //fft = new FFT(in.bufferSize(), in.sampleRate());
  //println(in.bufferSize());
  fft = new FFT(512, in.sampleRate());
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
  
  // Blank graphics
  blankGraphicsZero = createGraphics(width, height, P2D);
  renderGraphics(blankGraphicsZero, 0);
  blankGraphicsMid = createGraphics(width, height, P2D);
  renderGraphics(blankGraphicsMid, 127);
  
  // Initialize spin shader
  shader = loadShader("eyesing_shader.glsl");
  shader.set("iTime", 0.0);
  shader.set("iResolution", float(width), float(height), 0.0);
  shader.set("beta", 0.5);
  shader.set("field", 0.0);
  shader.set("interact", 0.25);
  shader.set("selDensity", exp(-0.1));
  shader.set("xyModelToggle", xyToggle);
  shader.set("xyBlend", xyBlend);
  shader.set("noiseBlend", noiseBlend);
  shader.set("invert", invertSpins);
  shader.set("quantNoise", quantizeNoise);
  
  // Initialize noise shader
  noiseShader = loadShader("noise_shader.glsl");
  noiseShader.set("iResolution", float(width), float(height), 0.0);
  noiseShader.set("iTime", 0.0);
  
  // Compute initial noise for spin texture
  //renderGraphics(noiseGraphics, noiseShader);
  
  // Pass initial spin state
  //shader.set("spinTexture", noiseGraphics);
  
  // Compute initial noise for sand selection
  //noiseShader.set("iTime", noiseTimeBiasA);
  //renderGraphics(noiseGraphics, noiseShader);
  
  // Sand projection shader parameters
  sandProjShader = loadShader("sand_proj_shader.glsl");
  sandProjShader.set("iResolution", (float) width, (float) height, 0.0);
  //sandProjShader.set("heightTexture", sandExchangeGraphics);
  //sandProjShader.set("shadowTexture", shadowGraphics);
  //sandProjShader.set("noiseTextureSel", noiseGraphics);
  sandProjShader.set("windDir", windDir.x, windDir.y);
  //sandProjShader.set("selDensity", selDensity);
  sandProjShader.set("hopDist", hopDist);
  sandProjShader.set("maxHops", (float) maxHops);
  
  // Compute initial noise for sand deposition
  noiseShader.set("iTime", noiseTimeBiasB);
  renderGraphics(noiseGraphics, noiseShader);
  sandProjShader.set("noiseTextureDeposit", noiseGraphics);
  
  //hist = new float[width];
  //for (int i = 0; i < hist.length; i++){
  //  hist[i] = 0;
  //}
  
  //frameRate(0.1);
  
  // Create and turn on scanner
  screenScanner = new ScreenScanner(width*0.5, height*0.5, width*0.25, 100);
  scanToggle = true;
  scannerCtrl = false;
  scannerAdapt = true;
  
  // Line patterns for parameter control
  sweepSpeedA = -5;
  sweepSpeedB = -1;
  sweepSpeedC = -10;
  sweepSpeedD = 5;
  sweepLineWA = 0;
  sweepLineWB = 0;
  sweepLineWC = 0;
  sweepLineWD = 0;
  modA = 0;
  modB = 0;
  modC = 0;
  modD = 0;
  
  // Draw default parameter graphics
  renderGraphics(paramGraphicsA, 127);
  renderGraphics(paramGraphicsB, 127);
  renderGraphics(paramGraphicsC, 127);
  
  // Initialize glyph shader
  glyphShaderTexCtrl = loadShader("glyph_shader.glsl");
  glyphShaderOverlay = loadShader("glyph_shader.glsl");
  glyphShaderTexCtrl.set("iResolution", float(width), float(height), 0.0);
  glyphShaderTexCtrl.set("iContrast", 0.5);
  glyphShaderOverlay.set("iResolution", float(width), float(height), 0.0);
  glyphShaderOverlay.set("iContrast", 1.0);
  
  // Video input
  //video = new Movie(this, "VCLP0150.avi");
  //video = new Movie(this, "DSC_1789.mp4");
  //video = new Movie(this, "grubbly.mp4");
  video = new Movie(this, "IMG_0138.mov");
  //video = new Movie(this, "GlitchmanWalking.mp4");
  //video = new Movie(this, "cymatique_edited.mp4");
  video.loop();
  
  inputImg = loadImage("rnkic_intro.jpg");
  //inputImg.filter(INVERT);
  
  // Noise probability modulation
  probModEdge1 = 0.05;
  probModEdge2 = sqrt(2);
  
  // Draw initial spin graphics
  //if (toggleSandDunes) renderGraphics(spinGraphics, shader);
  
  // Sand exchange and output shader parameters
  sandExchangeShader = loadShader("sand_exchange.glsl");
  sandExchangeShader.set("iResolution", (float) width, (float) height, 0.0);
  sandExchangeShader.set("grainSize", grainSize);
  sandConvertShader = loadShader("sand_convert_shader.glsl");
  sandConvertShader.set("iResolution", (float) width, (float) height, 0.0);
  sandConvertShader.set("invert", invertSpins);
  //sandConvertShader.set("heightTexture", spinGraphics);
  
  // Initialize sand exchange graphics
  sandExchangeGraphics = createGraphics(width, height, P2D);
  //renderGraphics(sandExchangeGraphics, sandConvertShader);
  
  // Initialise sand deposition graphics
  sandProjGraphics = createGraphics(width, height, P2D);
  
  // Shadow shader parameters
  shadowShader = loadShader("shadow_check.glsl");
  shadowShader.set("iResolution", (float) width, (float) height, 0.0);
  //shadowShader.set("heightTexture", sandExchangeGraphics);
  shadowShader.set("windDir", windDir.x, windDir.y);
  shadowShader.set("hopDist", hopDist);
  
  // Compute inital shadow
  shadowGraphics = createGraphics(width, height, P2D);
  //renderGraphics(shadowGraphics, shadowShader);
  
  // Avalanche shader parameters
  avalancheShader = loadShader("avalanche_shader.glsl");
  avalancheShader.set("iResolution", (float) width, (float) height, 0.0);
  //avalancheShader.set("exchangeTexture", sandExchangeGraphics);
  avalancheShader.set("windDir", windDir.x, windDir.y);
  avalancheShader.set("hopDist", hopDist);
  avalancheShader.set("maxHops", (float) maxHops);
  avalancheShader.set("grainSize", grainSize);
  avalancheGraphics = createGraphics(width, height, P2D);
}


void draw(){
  
  //println(frameCount);
  
  // ===== Analyze sound =====
  //if(frameCount > 30){
  //  in.play();
  //}
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
    
  paramGraphicsA.beginDraw();
  if(sweepLineWA < width){
    paramGraphicsA.background(127);
    paramGraphicsA.stroke(modA);
    paramGraphicsA.strokeWeight(sweepLineWA);
    lineXA += sweepSpeedA + 0.5*sweepLineWA;
    lineXA = lineXA%(width + sweepLineWA);
    lineXA -= 0.5*sweepLineWA;
    paramGraphicsA.line(lineXA, 0, lineXA, height);
  } else {
    paramGraphicsA.background(modA);
  }
  paramGraphicsA.endDraw();
  
  paramGraphicsB.beginDraw();
  if(sweepLineWB < width){
    paramGraphicsB.background(127);
    paramGraphicsB.stroke(modB);
    paramGraphicsB.strokeWeight(sweepLineWB);
    lineXB += sweepSpeedB + 0.5*sweepLineWB;
    lineXB = lineXB%(width + sweepLineWB);
    lineXB -= 0.5*sweepLineWB;
    paramGraphicsB.line(lineXB, 0, lineXB, height);
  } else {
    paramGraphicsB.background(modB);
  }
  paramGraphicsB.endDraw();
  
  paramGraphicsC.beginDraw();
  if(sweepLineWC < width){
    paramGraphicsC.background(127);
    paramGraphicsC.stroke(modC);
    paramGraphicsC.strokeWeight(sweepLineWC);
    lineXC += sweepSpeedC + 0.5*sweepLineWC;
    lineXC = lineXC%(width + sweepLineWC);
    lineXC -= 0.5*sweepLineWC;
    paramGraphicsC.line(lineXC, 0, lineXC, height);
  } else {
    paramGraphicsC.background(modC);
  }
  paramGraphicsC.endDraw();
  //}
  
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
  
  // Update noise shader
  noiseShader.set("iTime", (float) frameCount);
  noiseShader.set("hardThreshTexture", noiseModGraphics);
  noiseShader.set("probModEdges", probModEdge1, probModEdge2);
  
  // Draw noise for selection probs
  renderGraphics(noiseGraphics, noiseShader);
  
  // Pass selection noise
  shader.set("noiseTexture1", noiseGraphics);
  
  // Update noise shader
  noiseShader.set("iTime", frameCount + noiseTimeBiasA);
  
  // Redraw noise for acceptance probs
  renderGraphics(noiseGraphics, noiseShader);
  
  // Pass acceptance test noise
  shader.set("noiseTexture2", noiseGraphics);
  
  // Compute glyph texture
  if (glyphTextureCtrlIdx > 0 || glyphOverlay || toggleSelDensMod){
    noiseSeed(13);
    glyphSeedA = 2.0*noise(frameCount*0.002);
    noiseSeed(24);
    glyphSeedB = 2.0*noise(frameCount*0.002);
    
    glyphShaderTexCtrl.set("iSeedA", glyphSeedA);
    glyphShaderTexCtrl.set("iSeedB", glyphSeedB);
    glyphShaderTexCtrl.set("iRepeat", glyphRepeatX, glyphRepeatY);
    glyphShaderOverlay.set("iSeedA", glyphSeedA);
    glyphShaderOverlay.set("iSeedB", glyphSeedB);
    glyphShaderOverlay.set("iRepeat", glyphRepeatX, glyphRepeatY);
    
    renderGraphics(glyphGraphicsTexCtrl, glyphShaderTexCtrl);
  }
  
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
  //shader.set("spinTexture", spinGraphics);
  
  // Update processing shader
  //shader.set("iTime", float(frameCount));
  
  //shader(shader);
  ////image(noiseGraphics, 0, 0);
  //fill(0);
  //rect(0, 0, width, height);
  
  renderGraphics(glyphGraphicsOverlay, glyphShaderOverlay);
  
  // ===========================
  // MAIN PATTERN
  // ===========================
  
  if (toggleSandDunes && frameCount > 1)
  {
    // Update selection noise
    noiseShader.set("iTime", (float) frameCount);
    renderGraphics(noiseGraphics, noiseShader);
    sandProjShader.set("noiseTextureSel", noiseGraphics);
    
    // Update deposition noise
    noiseShader.set("iTime", float(frameCount) + noiseTimeBiasA);
    renderGraphics(noiseGraphics, noiseShader);
    sandProjShader.set("noiseTextureDeposit", noiseGraphics);
    
    // Update shadow calculation
    shadowShader.set("heightTexture", sandExchangeGraphics);
    renderGraphics(shadowGraphics, shadowShader);
    
    // Pass textures to sand projection shader
    sandProjShader.set("heightTexture", sandExchangeGraphics);
    sandProjShader.set("shadowTexture", shadowGraphics);
    if (toggleSelDensMod) {
      sandProjShader.set("selDensityTexture", glyphGraphicsOverlay);
    } else {
      sandProjShader.set("selDensityTexture", blankGraphicsMid);
    }
    
    // Compute sand deposition
    renderGraphics(sandProjGraphics, sandProjShader);
    
    // Compute avalanches
    avalancheShader.set("remoteDepositTexture", sandProjGraphics);
    avalancheShader.set("exchangeTexture", sandExchangeGraphics);
    for (int i = 0; i < maxAvalancheSteps; i++)
    {
      // Update avalanche noise
      noiseShader.set("iTime", float(frameCount * maxAvalancheSteps) + noiseTimeBiasB + i);
      renderGraphics(noiseGraphics, noiseShader);
      //noiseGraphicsAvalanche.save("noiseGraphicsAvalanche_" + str(i) + "_" + nf(frameCount, 5) + ".tiff");
      
      avalancheShader.set("noiseTexture", noiseGraphics);
      renderGraphics(avalancheGraphics, avalancheShader);
      //avalancheGraphics.save("avalancheGraphics_" + str(i) + "_" + nf(frameCount, 5) + ".tiff");
      
      avalancheShader.set("remoteDepositTexture", blankGraphicsZero);
      avalancheShader.set("exchangeTexture", avalancheGraphics);
    }
    
    // Final sand exchange
    sandExchangeShader.set("exchangeTexture", avalancheGraphics);
    renderGraphics(sandExchangeGraphics, sandExchangeShader);
    
    sandConvertShader.set("heightTexture", sandExchangeGraphics);
    sandConvertShader.set("invert", invertSpins);
    renderGraphics(spinGraphics, sandConvertShader);
  }
  else
  {
    shader.set("xyModelToggle", xyToggle);
    shader.set("iTime", float(frameCount) + noiseTimeBiasB);
    shader.set("xyBlend", xyBlend);
    shader.set("noiseBlend", noiseBlend);
    shader.set("invert", invertSpins);
    shader.set("quantNoise", quantizeNoise);
    
    // Draw spins
    if (invertSpins){
      invertSpins = false;
    }
    renderGraphics(spinGraphics, shader);
    
    // Feed spin graphics to sand dune algo
    sandConvertShader.set("heightTexture", spinGraphics);
    renderGraphics(sandExchangeGraphics, sandConvertShader);
  }
  
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
  
  // ===========================
  // PATTERN OVERLAY
  // ===========================
  
  // Glyph overlay
  if (glyphOverlay){
    //renderGraphics(glyphGraphicsOverlay, glyphShaderOverlay);
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
      if (screenScanner.toggleRotate) {
        pushMatrix();
        translate(screenScanner.pos.x, screenScanner.pos.y);
        rotate(QUARTER_PI);
        translate(-screenScanner.pos.x, -screenScanner.pos.y);
      }
      fill(0);
      noStroke();
      rectMode(CORNER);
      if(bands[0] < lvlThresh[0]){
        rect(screenScanner.pos.x + screenScanner.winSize*0.5, screenScanner.pos.y, screenScanner.maskWidth, screenScanner.maskWidth + screenScanner.winSize*0.5);
        rect(screenScanner.pos.x, screenScanner.pos.y + screenScanner.winSize*0.5, screenScanner.maskWidth, screenScanner.maskWidth);
      }
      if(bands[1] < lvlThresh[1]){
        rect(screenScanner.pos.x + screenScanner.winSize*0.5, screenScanner.pos.y, screenScanner.maskWidth, -screenScanner.maskWidth - screenScanner.winSize*0.5);
        rect(screenScanner.pos.x, screenScanner.pos.y - screenScanner.winSize*0.5, screenScanner.maskWidth, -screenScanner.maskWidth);
      }
      if(bands[2] < lvlThresh[2]){
        rect(screenScanner.pos.x - screenScanner.winSize*0.5, screenScanner.pos.y, -screenScanner.maskWidth, screenScanner.maskWidth + screenScanner.winSize*0.5);
        rect(screenScanner.pos.x, screenScanner.pos.y + screenScanner.winSize*0.5, -screenScanner.maskWidth, screenScanner.maskWidth);
      }
      if(bands[3] < lvlThresh[3]){
        rect(screenScanner.pos.x - screenScanner.winSize*0.5, screenScanner.pos.y, -screenScanner.maskWidth, -screenScanner.maskWidth - screenScanner.winSize*0.5);
        rect(screenScanner.pos.x, screenScanner.pos.y - screenScanner.winSize*0.5, -screenScanner.maskWidth, -screenScanner.maskWidth);
      }
      if (screenScanner.toggleRotate) {
        popMatrix();
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
  if(key == 'T' || key == 't'){
    // Flip noise probability modulation
    xyToggle = !xyToggle;
  }
  if(key == 'Y' || key == 'y'){
    // Flip noise probability modulation
    invertSpins = !invertSpins;
     shader.set("spinTexture", spinGraphics);
  }
  if(key == 'U' || key == 'u'){
    // Toggle sand dune algorithm
    toggleSandDunes = !toggleSandDunes;
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
