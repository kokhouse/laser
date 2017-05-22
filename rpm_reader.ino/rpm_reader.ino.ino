/* 
 This was a small project to measure the rpm and stats of fidget spinners. Just input the radius of your fidget spinner below and that's it!
 This processing script reads the input buffer for readings of rpm from the hardware (Arduino). 
 You'll also need to create the hardware for it, there's an arduino file that can be uploaded to your Arduino.
 */

int interruptPin = 2;
volatile int counter = 0;
long start_time;
long end_time = 0;
long duration = 0;
#define spokes 3 * 2 + 1

void setup(){
  pinMode(interruptPin, INPUT_PULLUP);
  attachInterrupt(digitalPinToInterrupt(interruptPin), count, CHANGE);
  Serial.begin(9600);
  start_time = micros();
}

void loop(){
  // Interrupts handle everything.
}

// Every 7 changes is one revolution.
void count(){
  counter++;
  if (counter == spokes) {
    end_time = micros();
    duration = end_time - start_time;
    start_time = end_time;
    Serial.println(60000000/float(duration));
    counter = 1;
  }
 
}
