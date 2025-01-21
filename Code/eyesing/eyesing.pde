PShader shader;

void setup(){
  
  shader = loadShader("eyesing_shader.glsl");
  shader.set("iResolution", float(width), float(height), 0.0);
  
  //size(500, 500, P2D);
  fullScreen(P2D);
  
}


void draw(){
  
  shader.set("iTime", float(frameCount));
  
  shader(shader);
  fill(0);
  rect(0, 0, width, height);
  
}
