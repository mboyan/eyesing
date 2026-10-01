// Renders blank graphics with a constant value
void renderGraphics(PGraphics graphics, int val){
  graphics.beginDraw();
  graphics.background(val);
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
