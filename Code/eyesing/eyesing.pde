PShader shader;
PShader noiseShader;
PGraphics noiseGraphics;

void setup(){

  noiseGraphics = createGraphics(width, height, P2D);
  
  noiseShader = loadShader("noise_shader.glsl");
  noiseShader.set("iResolution", float(width), float(height), 0.0);
  noiseShader.set("iTime", 0.0);
  //shader.set("iChannel0", noiseImg);
  
  shader = loadShader("eyesing_shader.glsl");
  shader.set("iResolution", float(width), float(height), 0.0);
  
  size(500, 500, P2D);
  //fullScreen(P2D);
  
  noiseGraphics.beginDraw();
  noiseGraphics.shader(noiseShader);
  noiseGraphics.fill(0);
  noiseGraphics.rect(0, 0, width, height);
  noiseGraphics.endDraw();
}


void draw(){
  
  // Update noise shader
  //noiseShader.set("iTime", float(frameCount));
  
  
  
  // Update processing shader
  //shader.set("iTime", float(frameCount));
  
  shader(shader);
  image(noiseGraphics, 0, 0);
  //fill(0);
  //rect(0, 0, width, height);
  
}
