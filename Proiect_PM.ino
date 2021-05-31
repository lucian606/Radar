#include <Servo.h>

Servo servo;
const int servoPin = 8; // Pin which controls the servomotor
static int motorAngle = 0; // The angle at which the motor starts
const int pingPin = 7;
const int echoPin = 6;
const int buzzerPin = 5;
int rotationDelay = 15; // The initial rotation delay of the motor

long microsecondsToCentimeters(long microseconds) {
   return microseconds / 29 / 2;
}

void soundAlarm() {
  tone(buzzerPin, 500);
  delay(100);
  noTone(buzzerPin);
}

void setup() {
  Serial.begin(9600);
  pinMode(pingPin, OUTPUT);
  pinMode(echoPin, INPUT);
  pinMode(buzzerPin, OUTPUT);
  servo.attach(servoPin); // Ataching the motor to its pin
  servo.write(motorAngle); // Setting its initial angle
}

void showDistance() {
   long duration, inches, cm;
   digitalWrite(pingPin, LOW);
   delayMicroseconds(2);
   digitalWrite(pingPin, HIGH);
   delayMicroseconds(10);
   digitalWrite(pingPin, LOW);
   duration = pulseIn(echoPin, HIGH);
   cm = microsecondsToCentimeters(duration);
   if (cm < 10 && cm > 0) {
    soundAlarm();
   }
   Serial.print(" | Distance: ");
   Serial.print(cm);
   Serial.println();
}


void loop() {
  // Rotating the motor
  for (motorAngle = 0; motorAngle < 180; motorAngle++) {
    servo.write(motorAngle);  
    Serial.print("Degree: ");
    Serial.print(motorAngle);
    showDistance();
    delay(rotationDelay);
  }

  delay(1000);
   
  for (motorAngle = 180; motorAngle >= 0; motorAngle--) {
    servo.write(motorAngle);
    Serial.print("Degree: ");
    Serial.print(motorAngle);
    showDistance();     
    delay(rotationDelay);
  }

  delay(2000);
}
