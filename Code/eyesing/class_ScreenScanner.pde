class ScreenScanner{
  
  PVector pos, vec;
  //PVector penaltyVec;
  float winSize;
  float stepSize = 10.0;
  int seedX, seedY, seedZ;
  float orientX, orientY, orientZ;
  PImage scanSegment;
  float avgBrightness;
  boolean showLargeFrame;
  boolean showCross;
  boolean toggleRotate;
  
  ScreenScanner(float x, float y, float z, float size){
    pos = new PVector(x, y, z);
    winSize = size;
    seedX = int(random(255));
    seedY = int(random(255));
    seedZ = int(random(255));
    //noiseDetail(3);
    
    orientX = 1.0;
    orientY = 1.0;
    orientZ = 1.0;
    
    //penaltyVec = new PVector(0.0, 0.0);
    showLargeFrame = false;
    showCross = true;
    toggleRotate = true;
  }
  
  void updatePos(){
    
    // Compute random perturbation
    noiseSeed(seedX);
    float vecX = noise(pos.x*0.001 + frameCount*0.1, pos.y*0.001)*2 - 1;
    noiseSeed(seedY);
    float vecY = noise(pos.x*0.001 + frameCount*0.1, pos.y*0.001)*2 - 1;
    noiseSeed(seedZ);
    float vecZ = noise(pos.x*0.001 + frameCount*0.1, pos.y*0.001)*2 - 1;
    vec = new PVector(orientX*vecX, orientY*vecY, orientZ*vecZ*10);
    //vec.add(penaltyVec);
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
    if(pos.z < 0.5*winSize){
      pos.z = winSize - pos.z;
      orientZ = -orientZ;
    } else if (pos.z > width - 0.5*winSize) {
      pos.z = 2*width - winSize - pos.z;
      orientY = -orientZ;
    }
  }
  
  void show(){
    //stroke(255, 0, 0, 100);
    noFill();
    rectMode(CENTER);
    float gradient;
    if (toggleRotate) {
      pushMatrix();
      translate(pos.x, pos.y);
      rotate(QUARTER_PI);
      translate(-pos.x, -pos.y);
    }
    for (int i = 6; i >= 0; i--){
      gradient = 255*(6 - i)/6;
      stroke(0, gradient, gradient*0.5, gradient);
      strokeWeight(i*2 + 1);
      rect(pos.x, pos.y, winSize, winSize);
      
      if (showCross) {
        line(pos.x + 0.5*winSize, pos.y, 2*width, pos.y);
        line(pos.x - 0.5*winSize, pos.y, -width, pos.y);
        line(pos.x, pos.y + 0.5*winSize, pos.x, 2*height);
        line(pos.x, pos.y - 0.5*winSize, pos.x, -height);
      }
    }
    if (toggleRotate) {
      popMatrix();
    }
    
    if (showLargeFrame){
      rect(0.5*width, 0.5*height, height - 50, height - 50);
    }
  }
  
  float scan(){
    avgBrightness = 0.0;
    scanSegment = get(int(pos.x - 0.5*winSize), int(pos.y - 0.5*winSize), int(winSize), int(winSize));
    //scanSegment.loadPixels();
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
