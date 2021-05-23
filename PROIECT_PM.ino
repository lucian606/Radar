#include <Servo.h>

Servo servo;
const int SERVO_PIN = 8; // Pin which controls the servomotor
static int motor_angle = 0; // The angle at which the motor starts
const int pingPin = 7;
const int echoPin = 6;
const int buzzerPin = 5;
int rotation_delay = 15; // The initial rotation delay of the motor

long microsecondsToCentimeters(long microseconds) {
   return microseconds / 29 / 2;
}

void soundAlarm() {
  tone(buzzerPin, 500);
  delay(100);
  noTone(buzzerPin);
}

void setup() {
  // put your setup code here, to run once:
  Serial.begin(9600);
  pinMode(pingPin, OUTPUT);
  pinMode(echoPin, INPUT);
  pinMode(buzzerPin, OUTPUT);
  servo.attach(SERVO_PIN); // Ataching the motor to its pin
  servo.write(motor_angle); // Setting its initial angle
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
   if (cm < 10 && cm > 0)
    soundAlarm();
   Serial.print(" | Distance: ");
   Serial.print(cm);
   Serial.println();
}


void loop() {
  // put your main code here, to run repeatedly:
  int inc_state; // The state of the button which increases the speed of the motor
  int dec_state; // The state of the button which decreases the speed of the motor
  // Rotating the motor
  for (motor_angle = 0; motor_angle < 180; motor_angle++) {
    servo.write(motor_angle);  
    Serial.print("Degree: ");
    Serial.print(motor_angle);
    showDistance();
    delay(rotation_delay);
  }

  delay(1000);
   
   for (motor_angle = 180; motor_angle >= 0; motor_angle--) {
    servo.write(motor_angle);
    Serial.print("Degree: ");
    Serial.print(motor_angle);
    showDistance();     
    delay(rotation_delay);
  }

  delay(2000);
}
