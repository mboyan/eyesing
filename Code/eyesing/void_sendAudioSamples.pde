void sendAudioSamples(PGraphics scannedGraphics, int scanPosXA, int scanPosXB, Buffer bufLeft, Buffer bufRight){
  scannedGraphics.loadPixels();
  for (int i = 0; i < height; i++){
    scSamplesLeft[i] = brightness(scannedGraphics.pixels[i*width + scanPosXA])/127. - 1.0;
    scSamplesRight[i] = brightness(scannedGraphics.pixels[i*width + scanPosXB])/127. - 1.0;
    //scSamplesLeft[i] = brightness(scannedGraphics.pixels[i*width + scanPosXA])/255.;
    //scSamplesRight[i] = brightness(scannedGraphics.pixels[i*width + scanPosXB])/255.;
  }
  bufLeft.setn(0, height, scSamplesLeft);
  bufRight.setn(0, height, scSamplesRight);
}

void sendLFOSamples(PGraphics scannedGraphics, int scanPosY, Buffer buffer){
  scannedGraphics.loadPixels();
  for (int i = 0; i < width; i++){
    scSamplesLFO[i] = brightness(scannedGraphics.pixels[scanPosY*width + i])/255.;
  }
  buffer.setn(0, height, scSamplesLFO);
}
