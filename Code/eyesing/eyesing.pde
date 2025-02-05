PShader shader, noiseShader;
PGraphics noiseGraphics;

void setup(){
  
  size(500, 500, P2D);
  //fullScreen(P2D);
  
  //noiseGraphics = createGraphics(width, height, P2D);
  
  noiseShader = loadShader("noise_shader.glsl");
  noiseShader.set("iResolution", float(width), float(height), 0.0);
  
  shader = loadShader("eyesing_shader.glsl");
  shader.set("iResolution", float(width), float(height), 0.0);
  //shader.set("iChannel0", noiseImg);
  
}


void draw(){
  
  // Update noise shader
  noiseShader.set("iTime", frameCount);
  
  //noiseGraphics.beginDraw();
  //noiseGraphics.shader(noiseShader);
  //noiseGraphics.rect(0, 0, width, height);
  //noiseGraphics.endDraw();
  
  // Update processing shader
  shader.set("iTime", float(frameCount));
  
  shader(shader);
  //image(noiseGraphics, 0, 0);
  fill(0);
  rect(0, 0, width, height);
  
}
