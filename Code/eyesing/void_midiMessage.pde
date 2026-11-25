void noteOn(int channel, int number, int velocity, long timestamp, String busName) {
  println();
  println("Note On:");
  println("--------");
  println("Channel:"+channel);
  println("Pitch:"+number);
  println("Velocity:"+velocity);
  println("Timestamp:"+timestamp);
  println("Recieved on Bus:"+busName);
  
  if (busName == opzBusName) {
    scSynth.set("rateMidiNote", number);
    scSynth.set("gate", 1);
    //println("This came from OP-Z");
  } 
  else if (busName == x1BusName) { // X1 toggles
    if (number == 8) {
      xyToggle = !xyToggle;
      println("xyToggle: " + str(xyToggle));
    }
    else if (number == 9) {
      scanToggle = !scanToggle;
      println("scanToggle: " + str(scanToggle));
    }
    else if (number == 10) {
      glyphOverlay = !glyphOverlay;
      println("glyphOverlay: " + str(glyphOverlay));
    }
    else if (number == 11) {
      scannerCtrl = !scannerCtrl;
      println("scannerCtrl: " + str(scannerCtrl));
    }
    else if (number == 12) {
      //lineTextureParamCtrl = !lineTextureParamCtrl;
      //println("lineTextureParamCtrl: " + str(lineTextureParamCtrl));
      videoTextureParamControl = !videoTextureParamControl;
      println("videoTextureParamControl: " + str(videoTextureParamControl));
    }
    else if (number == 13) {
      scannerAdapt = !scannerAdapt;
      println("scannerAdapt: " + str(scannerAdapt));
    }
    else if (number == 14) {
      videoInvert = !videoInvert;
      println("videoInvert: " + str(videoInvert));
    }
    else if (number == 15) {
      invertSpins = !invertSpins;
      println("Spins inverted");
    }
    else if (number == 17){
      audioReact = !audioReact;
      println("audioReact: " + str(audioReact));
    }
    else if (number == 18){
      maxAvalancheSteps = max(maxAvalancheSteps - 1, 1);
      println("maxAvalancheSteps: " + str(maxAvalancheSteps));
    }
    else if (number == 19){
      maxAvalancheSteps = min(maxAvalancheSteps + 1, 10);
      println("maxAvalancheSteps: " + str(maxAvalancheSteps));
    }
    else if (number == 20){
      scanSpeedXA = max(scanSpeedXA - 1, -width);
      println("scanSpeedXA: " + str(scanSpeedXA));
    }
    else if (number == 21){
      scanSpeedXB = max(scanSpeedXB - 1, -width);
      println("scanSpeedXA: " + str(scanSpeedXB));
    }
    else if (number == 22){
      scanSpeedXA = min(scanSpeedXA + 1, width);
      println("scanSpeedXA: " + str(scanSpeedXA));
    }
    else if (number == 23){
      scanSpeedXB = min(scanSpeedXB + 1, width);
      println("scanSpeedXB: " + str(scanSpeedXB));
    }
    else if (number == 26){
      toggleSandDunes = !toggleSandDunes;
      println("toggleSandDunes: " + str(toggleSandDunes));
    }
    else if (number == 27){
      toggleSelDensMod = !toggleSelDensMod;
      println("toggleSelDensMod: " + str(toggleSelDensMod));
    }
    else if (number == 30) {
      glyphRepeatX = 1;
      glyphRepeatY = 1;
    }
    else if (number == 31) {
      glyphTextureCtrlIdx = 0;
    }
    else if (number == 32) {
      glyphRepeatX = 16;
      glyphRepeatY = 9;
    }
    else if (number == 33) {
      glyphTextureCtrlIdx = 1;
    }
    else if (number == 34) {
      glyphRepeatX = 32;
      glyphRepeatY = 18;
    }
    else if (number == 35) {
      glyphTextureCtrlIdx = 2;
    }
    else if (number == 36) {
      glyphRepeatX = 64;
      glyphRepeatY = 32;
    }
    else if (number == 37) {
      glyphTextureCtrlIdx = 3;
    }
    else if (number == 44) {
      toggleSlitScanX = !toggleSlitScanX;
      println("toggleSlitScanX: " + str(toggleSlitScanX));
    }
    else if (number == 45) {
      toggleSlitScanY = !toggleSlitScanY;
      println("toggleSlitScanY: " + str(toggleSlitScanY));
    }
  }
}

void noteOff(int channel, int pitch, int velocity, long timestamp, String busName) {
  if (busName == opzBusName) {
    //scSynth.set("rateMidiNote", pitch);
    scSynth.set("gate", 0);
  }
}

void controllerChange(int channel, int number, int val, long timestamp, String busName) {
  println();
  println("Controller Change:");
  println("--------");
  println("Channel:"+channel);
  println("Number:"+number);
  println("Value:"+val);
  println("Timestamp:"+timestamp);
  println("Recieved on Bus:"+busName);
  //if (busName == x1BusName) {
  //  println("This came from X1");
  //} else if (busName == f1BusName) {
  //  println("This came from F1");
  //}
  
  if (busName == f1BusName) // F1 message
  {
    if (number == 2) {
      sweepSpeedA = 0.1 * width * (float(val) / 127.0 - 0.5);
      println("sweepSpeedA: " + str(sweepSpeedA));
    }
    else if (number == 3) {
      sweepSpeedB = 0.1 * width *(float(val) / 127.0 - 0.5);
      println("sweepSpeedB: " + str(sweepSpeedB));
    }
    else if (number == 4) {
      sweepSpeedC = 0.1 * width * (float(val) / 127.0 - 0.5);
      println("sweepSpeedC: " + str(sweepSpeedC));
    }
    else if (number == 5) {
      sweepSpeedD = 0.1 * width * (float(val) / 127.0 - 0.5);
      println("sweepSpeedD: " + str(sweepSpeedD));
    }
    else if (number == 6) {
      sweepLineWA = map(val, 0, 127, 0, width);
      println("sweepLineWA: " + str(sweepLineWA));
    }
    else if (number == 7) {
      sweepLineWB = map(val, 0, 127, 0, width);
      println("sweepLineWB: " + str(sweepLineWB));
    }
    else if (number == 8) {
      sweepLineWC = map(val, 0, 127, 0, width);
      println("sweepLineWC: " + str(sweepLineWC));
    }
    else if (number == 9) {
      sweepLineWD = map(val, 0, 127, 0, width);
      println("sweepLineWD: " + str(sweepLineWD));
    }
    else if (number >= 10 && number <=16 && val == 127) {
      video.stop();
      video.dispose();
      video = new Movie(this, videoTitles[number - 10]);
      video.loop();
    }
    else if (number == 17 && val == 127){
      quantizeNoise = !quantizeNoise;
      println("quantizeNoise: " + str(quantizeNoise));
    }
    else if (number == 18 && val == 127){
      screenScanner.showCross = !screenScanner.showCross;
      println("showCross: " + str(screenScanner.showCross));
    }
    else if (number == 37 && val == 127) {
      modA = 255 - modA;
    }
    else if (number == 38 && val == 127) {
      modB = 255 - modB;
    }
    else if (number == 39 && val == 127) {
      modC = 255 - modC;
    }
    else if (number == 40 && val == 127) {
      modD = 255 - modD;
    }
    else if (number == 41) {
      screenScanner.maskWidthFactor = val / 127.0;
    }
    else if (number == 42 && val == 127) {
      screenScanner.toggleRotate = !screenScanner.toggleRotate;
      println("toggleRotate: " + str(screenScanner.toggleRotate));
    }
  }
  else if (busName == x1BusName) // X1 knob message
  {
    if (number == 0) {
      noiseBlend = map(val, 0, 127, 0, 1);
    }
    else if (number == 1) {
      lvlThresh[bandShiftIdx] = map(val, 0, 127, 0, 5);
    }
    else if (number == 2) {
      //xyBlend = map(val, 0, 127, 0, 1);
      shader.set("beta", exp(map(val, 0, 127, -10.0, 10.0)));
    }
    else if (number == 3) {
      lvlThresh[1] = map(val, 0, 127, 0, 5);
    }
    else if (number == 4) {
      probModEdge1 = 2 * float(val) / 127.0;
      println(probModEdge1);
    }
    else if (number == 5) {
      lvlThresh[2] = map(val, 0, 127, 0, 5);
    }
    else if (number == 6) {
      probModEdge2 = 2 * float(val) / 127.0;
      println(probModEdge2);
    }
    else if (number == 7) {
      lvlThresh[3] = map(val, 0, 127, 0, 5);
    }
    else if (number == 16) {
      bandShiftIdx = (val == 127) ? (bandShiftIdx + 1)%4 : (4 + bandShiftIdx - 1)%4;
    }
    else if (number == 24) {
      windDirAngleIdx += (val == 127) ? -1 : 1;
      windDir = new PVector(cos(TWO_PI*windDirAngleIdx/360.0), sin(TWO_PI*windDirAngleIdx/360.0));
      println("windDirAngleIdx: " + str(windDirAngleIdx));
    }
    else if (number == 25) {
      hopDist += (val == 127) ? -1.0 : 1.0;
      hopDist = min(max(hopDist, 1.0), width*0.5);
      println("hopDist: " + str(hopDist));
    }
    else if (number == 29) {
      scanSpeedY = (int) map(val, 0, 127, -63, 63);
      println("scanSpeedY: " + str(scanSpeedY));
    }
  }
  else if (busName == opzBusName) // OP-Z synth control
  {
    //println();
    //println("Controller Change:");
    //println("--------");
    //println("Channel:"+channel);
    //println("Number:"+number);
    //println("Value:"+val);
    //println("Timestamp:"+timestamp);
    //println("Recieved on Bus:"+busName);
    //if (busName == x1BusName) {
    //  println("This came from X1");
    //} else if (busName == f1BusName) {
    //  println("This came from F1");
    //}
    if (number == 5) {
      scSynth.set("atk", map(val, 0, 127, 0, 2.0));
      println();
    }
    else if (number == 6) {
      scSynth.set("dec", map(val, 0, 127, 0, 2.0));
    }
    else if (number == 7) {
      scSynth.set("susLvl", map(val, 0, 127, 0, 1.0));
    }
    else if (number == 8) {
      scSynth.set("rel", map(val, 0, 127, 0, 2.0));
    }
    else if (number == 9) {
      scSynth.set("ampLFO", map(val, 0, 127, 0, 1.0));
      println(map(val, 0, 127, 0, 1.0));
    }
    else if (number == 10) {
      scSynth.set("rateLFO", map(val, 0, 127, 1/2048, 0.25));
      println(map(val, 0, 127, 1./2048., 0.25));
    }
  }
}
