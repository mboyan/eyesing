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
    if (chan == 6) {
      sweepLineWA = width * float(val) / 127.0;
      println(sweepLineWA);
    }
    else if (chan == 7) {
      sweepLineWB = width * float(val) / 127.0;
      println(sweepLineWB);
    }
    else if (chan == 8) {
      sweepLineWC = width * float(val) / 127.0;
    }
    else if (chan == 9) {
      sweepLineWD = width * float(val) / 127.0;
    }
  }
  else if (message.getStatus() == 144) // X1 message
  {
    if (chan == 8) {
      viewNoise = !viewNoise;
    }
    else if (chan == 10) {
      glyphOverlay = !glyphOverlay;
    }
  }
}
