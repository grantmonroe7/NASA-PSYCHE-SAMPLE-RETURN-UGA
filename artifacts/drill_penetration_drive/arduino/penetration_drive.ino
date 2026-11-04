/*
 * penetration_drive.ino
 * Arduino firmware for the cable-reel penetration motor.
 * Compatible with Arduino Uno / Mega / Nano + motor driver
 * (L298N, BTS7960, or Maxon ESCON compatible driver).
 *
 * Interface:
 *   PWM pin  → motor driver speed
 *   DIR pin  → motor direction (up / down)
 *   Encoder A/B → position feedback (optional closed-loop)
 *   Serial 115200 → telemetry to MATLAB / host
 *
 * Command protocol (simple ASCII):
 *   "T <torque_cmd_0_to_1>\n"   → set normalized torque
 *   "P <position_m>\n"          → closed-loop position (if encoder present)
 *   "S\n"                       → stop
 */

#include <Encoder.h>          // install "Encoder" library by Paul Stoffregen

// Pin map (change to match your wiring)
const int PIN_PWM   = 9;
const int PIN_DIR   = 8;
const int PIN_ENC_A = 2;      // interrupt capable
const int PIN_ENC_B = 3;

// Mechanical constants (must match 00_parameters.m)
const float N_G     = 113.0f; // gearbox ratio
const float R_W     = 0.030f; // reel radius [m]
const float N_P     = 2.0f;   // movable-pulley advantage
const float COUNTS_PER_REV = 4096.0f * N_G;  // motor encoder * gearbox

Encoder myEnc(PIN_ENC_A, PIN_ENC_B);

float torqueCmd = 0.0f;       // normalized 0…1
long  lastCount = 0;
unsigned long lastTelem = 0;

void setup() {
  pinMode(PIN_PWM, OUTPUT);
  pinMode(PIN_DIR, OUTPUT);
  Serial.begin(115200);
  analogWrite(PIN_PWM, 0);
  digitalWrite(PIN_DIR, LOW);
  Serial.println(F("Penetration drive ready"));
}

void loop() {
  // ---- Serial command parser ----
  if (Serial.available()) {
    String line = Serial.readStringUntil('\n');
    line.trim();
    if (line.startsWith("T ")) {
      torqueCmd = constrain(line.substring(2).toFloat(), 0.0f, 1.0f);
    } else if (line.startsWith("S")) {
      torqueCmd = 0.0f;
    }
    // Position command can be added later with a simple P-controller
  }

  // ---- Motor command ----
  int pwm = (int)(torqueCmd * 255.0f);
  analogWrite(PIN_PWM, pwm);
  // Direction can be set by a second command or sign of torque

  // ---- Telemetry @ 50 Hz ----
  if (millis() - lastTelem > 20) {
    long count = myEnc.read();
    float revs = (float)count / COUNTS_PER_REV;
    float x_m  = revs * (2.0f * PI * R_W) / N_P;   // linear position
    float v_mps = 0.0f;                            // crude – improve with dt

    Serial.print("X ");
    Serial.print(x_m, 4);
    Serial.print(" T ");
    Serial.println(torqueCmd, 3);

    lastTelem = millis();
    lastCount = count;
  }
}