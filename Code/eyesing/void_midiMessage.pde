void midiMessage(MidiMessage message) { // You can also use midiMessage(MidiMessage message, long timestamp, String bus_name)
  // Receive a MidiMessage
  // MidiMessage is an abstract class, the actual passed object will be either javax.sound.midi.MetaMessage, javax.sound.midi.ShortMessage, javax.sound.midi.SysexMessage.
  // Check it out here http://java.sun.com/j2se/1.5.0/docs/api/javax/sound/midi/package-summary.html
  println();
  println("MidiMessage Data:");
  println("--------");
  println("Status Byte/MIDI Command:"+message.getStatus());
  for (int i = 1;i < message.getMessage().length;i++) {
    println("Param "+(i+1)+": "+(int)(message.getMessage()[i] & 0xFF));
  }
  
  int chan = message.getMessage()[1];
  int val = message.getMessage()[2];
  
  if (message.getStatus() == 188) // F1 message
  {
    if (chan == 2) {
      sweepSpeedA = 0.1 * width * (float(val) / 127.0 - 0.5);
    }
    else if (chan == 3) {
      sweepSpeedB = 0.1 * width *(float(val) / 127.0 - 0.5);
    }
    else if (chan == 4) {
      sweepSpeedC = 0.1 * width * (float(val) / 127.0 - 0.5);
    }
    else if (chan == 5) {
      sweepSpeedD = 0.1 * width * (float(val) / 127.0 - 0.5);
    }
    else if (chan == 6) {
      sweepLineWA = map(val, 0, 127, 0, width);
    }
    else if (chan == 7) {
      sweepLineWB = map(val, 0, 127, 0, width);
    }
    else if (chan == 8) {
      sweepLineWC = map(val, 0, 127, 0, width);
    }
    else if (chan == 9) {
      sweepLineWD = map(val, 0, 127, 0, width);
    }
    else if (chan == 10 && val == 127) {
      modA = 255 - modA;
    }
    else if (chan == 11 && val == 127) {
      modB = 255 - modB;
    }
    else if (chan == 12 && val == 127) {
      modC = 255 - modC;
    }
    else if (chan == 13 && val == 127) {
      modD = 255 - modD;
    }
    else if (chan == 14 && val == 127) {
      video = new Movie(this, "VCLP0150.avi");
      video.loop();
    }
    else if (chan == 15 && val == 127) {
      video = new Movie(this, "DSC_1789.mp4");
      video.loop();
    }
    else if (chan == 16 && val == 127) {
      video = new Movie(this, "grubbly.mp4");
      video.loop();
    }
    else if (chan == 17 && val == 127) {
      video = new Movie(this, "IMG_0138.mov");
      video.loop();
    }
    else if (chan == 18 && val == 127) {
      video = new Movie(this, "GlitchmanWalking.mp4");
      video.loop();
    }
  }
  else if (message.getStatus() == 144) // X1 toggle message
  {
    if (chan == 8) {
      //viewNoise = !viewNoise;
      xyToggle = !xyToggle;
    }
    else if (chan == 9) {
      audioReact = !audioReact;
      println("audioReact: " + str(audioReact));
    }
    else if (chan == 10) {
      glyphOverlay = !glyphOverlay;
      println("glyphOverlay: " + str(glyphOverlay));
    }
    else if (chan == 11) {
      scanToggle = !scanToggle;
      println("scanToggle: " + str(scanToggle));
    }
    else if (chan == 12) {
      //lineTextureParamCtrl = !lineTextureParamCtrl;
      //println("lineTextureParamCtrl: " + str(lineTextureParamCtrl));
      videoTextureParamControl = !videoTextureParamControl;
      println("videoTextureParamControl: " + str(videoTextureParamControl));
    }
    else if (chan == 13) {
      scannerCtrl = !scannerCtrl;
      println("scannerCtrl: " + str(scannerCtrl));
    }
    else if (chan == 14) {
      videoInvert = !videoInvert;
      println("videoInvert: " + str(videoInvert));
    }
    else if (chan == 15) {
      scannerAdapt = !scannerAdapt;
      println("scannerAdapt: " + str(scannerAdapt));
    }
    else if (chan == 30) {
      glyphRepeatX = 1;
      glyphRepeatY = 1;
    }
    else if (chan == 31) {
      glyphTextureCtrlIdx = 0;
    }
    else if (chan == 32) {
      glyphRepeatX = 16;
      glyphRepeatY = 9;
    }
    else if (chan == 33) {
      glyphTextureCtrlIdx = 1;
    }
    else if (chan == 34) {
      glyphRepeatX = 32;
      glyphRepeatY = 18;
    }
    else if (chan == 35) {
      glyphTextureCtrlIdx = 2;
    }
    else if (chan == 36) {
      glyphRepeatX = 64;
      glyphRepeatY = 32;
    }
    else if (chan == 37) {
      glyphTextureCtrlIdx = 3;
    }
  }
  else if (message.getStatus() == 176) // X1 knob message
  {
    if (chan == 0) {
      noiseBlend = map(val, 0, 127, 0, 1);
    }
    else if (chan == 1) {
      lvlThresh[0] = map(val, 0, 127, 0, 5);
    }
    else if (chan == 2) {
      xyBlend = map(val, 0, 127, 0, 1);
    }
    else if (chan == 3) {
      lvlThresh[1] = map(val, 0, 127, 0, 5);
    }
    else if (chan == 4) {
      probModEdge1 = 2 * float(val) / 127.0;
      println(probModEdge1);
    }
    else if (chan == 5) {
      lvlThresh[2] = map(val, 0, 127, 0, 5);
    }
    else if (chan == 6) {
      probModEdge2 = 2 * float(val) / 127.0;
      println(probModEdge2);
    }
    else if (chan == 7) {
      lvlThresh[3] = map(val, 0, 127, 0, 5);
    }
    else if (chan == 16) {
      bandShiftIdx = (val == 127) ? (bandShiftIdx + 1)%4 : (4 + bandShiftIdx - 1) %4;
    }
  }
}
