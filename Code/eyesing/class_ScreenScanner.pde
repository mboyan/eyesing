class ScreenScanner{
  
  PVector pos, vec, midPt;
  //PVector penaltyVec;
  float winSize;
  float stepSize = 10.0;
  int seedX, seedY, seedZ;
  PVector orientVec;
  PImage scanSegment;
  float avgBrightness;
  boolean showLargeFrame;
  
  PVector correction;
  
  ScreenScanner(float x, float y, float z, float size){
    pos = new PVector(x, y, z);
    winSize = size;
    seedX = int(random(255));
    seedY = int(random(255));
    seedZ = int(random(255));
    //noiseDetail(3);
    
    midPt = new PVector(0.5*width, 0.5*height, 0.5*height);
    
    //penaltyVec = new PVector(0.0, 0.0);
    showLargeFrame = false;
  }
  
  void updatePos(){
    
    // Compute random perturbation
    noiseSeed(seedX);
    float vecX = noise(pos.x*0.001 + frameCount*0.1, pos.y*0.001 + frameCount*0.1)*2 - 0.95;
    noiseSeed(seedY);
    float vecY = noise(pos.x*0.001 + frameCount*0.1, pos.y*0.001 + frameCount*0.1)*2 - 0.95;
    noiseSeed(seedZ);
    float vecZ = noise(pos.x*0.001 + frameCount*0.1, pos.y*0.001 + frameCount*0.1)*2 - 0.95;
    vec = new PVector(vecX, vecY, vecZ*10);
    //vec.add(penaltyVec);
    vec.normalize();
    vec.mult(stepSize);
    
    // Perturb
    pos.add(vec);
    
    // Bounce off edges
    if(pos.dist(midPt) > 0.3*height){
      correction = PVector.sub(midPt, pos).normalize().mult(stepSize);
      pos.add(correction);
      seedX = int(random(255));
      seedY = int(random(255));
      seedZ = int(random(255));
    }
    //if(pos.x < 0.5*winSize){
    //  pos.x = winSize - pos.x;
    //  orientX = -orientX;
    //} else if (pos.x > width - 0.5*winSize) {
    //  pos.x = 2*width - winSize - pos.x;
    //  orientX = -orientX;
    //}
    //if(pos.y < 0.5*winSize){
    //  pos.y = winSize - pos.y;
    //  orientY = -orientY;
    //} else if (pos.y > height - 0.5*winSize) {
    //  pos.y = 2*height - winSize - pos.y;
    //  orientY = -orientY;
    //}
    //if(pos.z < 0.5*winSize){
    //  pos.z = winSize - pos.z;
    //  orientZ = -orientZ;
    //} else if (pos.z > width - 0.5*winSize) {
    //  pos.z = 2*width - winSize - pos.z;
    //  orientY = -orientZ;
    //}
  }
  
  void show(){
    stroke(255, 0, 0);
    strokeWeight(3);
    noFill();
    rectMode(CENTER);
    rect(pos.x, pos.y, winSize, winSize);
    
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
