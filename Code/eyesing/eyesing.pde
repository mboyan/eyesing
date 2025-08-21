PShader shader;
PShader noiseShader;
PGraphics spinGraphics, noiseGraphics;

float[] hist;

void setup(){
  
  spinGraphics = createGraphics(width, height, P2D);
  noiseGraphics = createGraphics(width, height, P2D);
  
  noiseShader = loadShader("noise_shader.glsl");
  noiseShader.set("iResolution", float(width), float(height), 0.0);
  noiseShader.set("iTime", 0.0);
  
  shader = loadShader("eyesing_shader.glsl");
  shader.set("iResolution", float(width), float(height), 0.0);
  
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
  
  // Pass initial parameters
  shader.set("beta", 0.5);
  shader.set("field", 0.0);
  shader.set("interact", 0.25);
  shader.set("selDensity", exp(-0.1));
  
  hist = new float[width];
  for (int i = 0; i < hist.length; i++){
    hist[i] = 0;
  }
  
  //frameRate(1);
  
  // Draw spins
  //spinGraphics.beginDraw();
  //spinGraphics.shader(shader);
  //spinGraphics.fill(0);
  //spinGraphics.rect(0, 0, width, height);
  //spinGraphics.endDraw();
  //image(spinGraphics, 0, 0);
}


void draw(){
  
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
  
  text(str(frameCount), 50, 50);
}

void mouseDragged(){
  shader.set("beta", exp(map(mouseX, 0, width, -10.0, 10.0)));
  println("beta = " + str(exp(map(mouseX, 0, width, -10.0, 10.0))));
  //shader.set("beta", map(mouseX / float(width), 0.0, 1.0, 0.0, 10.0));
  //shader.set("field", mouseY / float(width));
  shader.set("field", map(mouseY, 0, height, -1.0, 1.0));
  println("field = " + str(map(mouseY, 0, height, -1.0, 1.0)));
}

//void keyPressed(){
//  saveFrame();
//}
