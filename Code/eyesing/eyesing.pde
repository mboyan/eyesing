PShader shader, noiseShader;
PGraphics spinGraphics, noiseGraphics, paramGraphicsA, paramGraphicsB, paramGraphicsC;

float[] hist;

// Scanner variables
ScreenScanner screenScanner;
boolean scanToggle, scannerCtrl, scannerAdapt;
float bSampleA, bSampleB;

// Texture parameter control
boolean textureParamCtrl;
float sweepSpeedA, sweepSpeedB, sweepSpeedC;
float sweepLineWA, sweepLineWB, sweepLineWC;
float lineXA, lineXB, lineXC;
float modA, modB, modC;

float penalty;

void setup(){
  
  spinGraphics = createGraphics(width, height, P2D);
  noiseGraphics = createGraphics(width, height, P2D);
  paramGraphicsA = createGraphics(width, height, P2D);
  paramGraphicsB = createGraphics(width, height, P2D);
  paramGraphicsC = createGraphics(width, height, P2D);
  
  noiseShader = loadShader("noise_shader.glsl");
  noiseShader.set("iResolution", float(width), float(height), 0.0);
  noiseShader.set("iTime", 0.0);
  
  // Define shader and pass initial parameters
  shader = loadShader("eyesing_shader.glsl");
  shader.set("iResolution", float(width), float(height), 0.0);
  shader.set("beta", 0.5);
  shader.set("field", 0.0);
  shader.set("interact", 0.25);
  shader.set("selDensity", exp(-0.1));
  
  //size(500, 500, P2D);
  fullScreen(P2D);
  
  // Compute initial noise
  noiseGraphics.beginDraw();
  noiseGraphics.shader(noiseShader);
  noiseGraphics.fill(0);
  noiseGraphics.rect(0, 0, width, height);
  noiseGraphics.endDraw();
  
  // Pass initial spin state
  shader.set("spinTexture", noiseGraphics);
  
  hist = new float[width];
  for (int i = 0; i < hist.length; i++){
    hist[i] = 0;
  }
  
  //frameRate(1);
  
  // Create and turn on scanner
  screenScanner = new ScreenScanner(width*0.5, height*0.5, width*0.25, 100);
  scanToggle = true;
  scannerCtrl = true;
  scannerAdapt = true;
  
  // Toggle texture parameter control
  textureParamCtrl = true;
  sweepSpeedA = 5;
  sweepSpeedB = 1;
  sweepSpeedC = 10;
  sweepLineWA = 100;
  sweepLineWB = 200;
  sweepLineWC = 50;
  modA = 0;
  modB = 0;
  modC = 0;
  
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
}


void draw(){
  
  // Draw parameter graphics
  if(textureParamCtrl){
    paramGraphicsA.beginDraw();
    paramGraphicsA.background(127);
    paramGraphicsA.stroke(modA);
    paramGraphicsA.strokeWeight(sweepLineWA);
    lineXA = (frameCount*sweepSpeedA)%(width + sweepLineWA) - 0.5*sweepLineWA;
    paramGraphicsA.line(lineXA, 0, lineXA, height);
    paramGraphicsA.endDraw();
    
    paramGraphicsB.beginDraw();
    paramGraphicsB.background(127);
    paramGraphicsB.stroke(modB);
    paramGraphicsB.strokeWeight(sweepLineWB);
    lineXB = (frameCount*sweepSpeedB)%(width + sweepLineWB) - 0.5*sweepLineWB;
    paramGraphicsB.line(lineXB, 0, lineXB, height);
    paramGraphicsB.endDraw();
    
    paramGraphicsC.beginDraw();
    paramGraphicsC.background(127);
    paramGraphicsC.stroke(modC);
    paramGraphicsC.strokeWeight(sweepLineWC);
    lineXC = (frameCount*sweepSpeedC)%(width + sweepLineWC) - 0.5*sweepLineWC;
    paramGraphicsC.line(lineXC, 0, lineXC, height);
    paramGraphicsC.endDraw();
  }
  
  // Update noise shader
  noiseShader.set("iTime", float(frameCount));
  
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
  shader.set("paramTextureBeta", paramGraphicsA);
  shader.set("paramTextureField", paramGraphicsB);
  shader.set("paramTextureInteract", paramGraphicsC);
  //shader.set("spinTexture", spinGraphics);
  
  // Update processing shader
  //shader.set("iTime", float(frameCount));
  
  //shader(shader);
  ////image(noiseGraphics, 0, 0);
  //fill(0);
  //rect(0, 0, width, height);
  
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
  
  if(scanToggle){
    
    bSampleA = screenScanner.scan();
    fill(255, 0, 0);
    textSize(50);
    text(str(bSampleA), 50, 50);
    text(str(screenScanner.pos.z), 50, 120);
    
    screenScanner.updatePos();
    screenScanner.show();
    
    // Adapt scanner motion
    if(scannerAdapt){
      bSampleB = screenScanner.scan();
      //screenScanner.stepSize += 4*(pow(bSampleA - 0.5, 2) - pow(bSampleB - 0.5, 2));
      penalty = -4*pow(bSampleB - 0.5, 2);
      //screenScanner.penaltyVec = PVector.mult(screenScanner.vec, penalty*0.5);
      screenScanner.stepSize = 40.0*pow(bSampleA - bSampleB, 2.0) - 50.0 * penalty;
      //float corr = - 4*pow(bSampleA - 0.5, 2);
      //screenScanner.stepSize = exp(pow(bSampleA - 0.5, 2)) - exp(pow(bSampleA - 0.5, 2));
    }
    
    // Control parameters with scanner
    if(scannerCtrl){
      shader.set("beta", exp(map(screenScanner.pos.x, 0, width, -10.0, 10.0)));
      shader.set("field", map(screenScanner.pos.y, 0, height, -1.0, 1.0));
      shader.set("interact", map(screenScanner.pos.z, 0, width, -0.1, 1.0));
    }
  }
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
}
