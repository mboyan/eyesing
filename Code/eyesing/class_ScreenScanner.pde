class ScreenScanner{
  
  PVector pos, vec;
  float winSize;
  float stepSize = 1000.0;
  int seedX, seedY;
  float orientX, orientY;
  PImage scanSegment;
  float avgBrightness;
  
  ScreenScanner(float x, float y, float size){
    pos = new PVector(x, y);
    winSize = size;
    seedX = int(random(255));
    seedY = int(random(255));
    //noiseDetail(3);
    
    orientX = 1.0;
    orientY = 1.0;
  }
  
  void updatePos(){
    // Compute random perturbation
    noiseSeed(seedX);
    float vecX = noise(pos.x*0.001, pos.y*0.001)*2 - 1;
    noiseSeed(seedY);
    float vecY = noise(pos.x*0.001 + frameCount*0.1, pos.y*0.001)*2 - 1;
    vec = new PVector(orientX*vecX, orientY*vecY);
    vec.normalize();
    vec.mult(stepSize);
    
    // Perturb
    pos.add(vec);
    
    // Bounce off edges
    if(pos.x < 0.5*winSize){
      pos.x = winSize - pos.x;
      orientX = -orientX;
    } else if (pos.x > width - 0.5*winSize) {
      pos.x = 2*width - winSize - pos.x;
      orientX = -orientX;
    }
    if(pos.y < 0.5*winSize){
      pos.y = winSize - pos.y;
      orientY = -orientY;
    } else if (pos.y > height - 0.5*winSize) {
      pos.y = 2*height - winSize - pos.y;
      orientY = -orientY;
    }
  }
  
  void show(){
    stroke(255, 0, 0);
    strokeWeight(3);
    noFill();
    rectMode(CENTER);
    rect(pos.x, pos.y, winSize, winSize);
  }
  
  float scan(){
    avgBrightness = 0.0;
    scanSegment = get(int(pos.x - 0.5*width), int(pos.y - 0.5*height), int(pos.x + 0.5*width), int(pos.y + 0.5*height));
    scanSegment.loadPixels();
    for(int i = 0; i < scanSegment.width; i++){
      for(int j = 0; j < scanSegment.height; j++){
        avgBrightness += brightness(scanSegment.get(i, j));
      }
    }
    avgBrightness /= scanSegment.width * scanSegment.height;
    avgBrightness /= 256;
    return avgBrightness;
  }
}
