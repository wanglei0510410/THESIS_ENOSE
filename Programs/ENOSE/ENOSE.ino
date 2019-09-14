#include<SoftwareSerial.h>

SoftwareSerial RPi(2,3);

const int mq2Pin=A0;
const int mq135Pin=A1;
const int mq3Pin=A2;
const int mq8Pin=A3;
const int tgs882Pin=A4;
const int mq136Pin=A5;
const int mqxPin=A6;
const int tempPin=A7;

float mq2Value, mq135Value, mq3Value, mq8Value, tgs882Value;
float mqxPinValue, mq136Value, tempValue;

String toSend;

void setup() 
{
  pinMode(mq2Pin, INPUT);
  pinMode(mq135Pin, INPUT);
  pinMode(mq3Pin, INPUT);
  pinMode(mq8Pin, INPUT);
  pinMode(tgs882Pin, INPUT);
  pinMode(mq136Pin, INPUT);
  pinMode(mqxPin, INPUT);
  pinMode(tempPin, INPUT);

  Serial.begin(9600);
  RPi.begin(9600);
}

void loop() 
{
  readSensors();
  convertSensorsReadings();
  sendSensorsValues();

  delay(1000);
}

void readSensors()
{
  mq2Value=analogRead(mq2Pin);
  mq135Value=analogRead(mq135Pin);
  mq3Value=analogRead(mq3Pin);
  mq8Value=analogRead(mq8Pin);
  tgs882Value=analogRead(tgs882Pin);  
  mq136Value=analogRead(mq136Pin);
  mqxPinValue=analogRead(mqxPin);
  tempValue=analogRead(tempPin);
}

void convertSensorsReadings()
{
  // 1023 is 5V
  // readValue*(5/1023)
  mq2Value=mq2Value*(5.0/1023.0);
  mq135Value=mq135Value*(5.0/1023.0);
  mq3Value=mq3Value*(5.0/1023.0);
  mq8Value=mq8Value*(5.0/1023.0);
  tgs882Value=tgs882Value*(5.0/1023.0);
  mq136Value=mq136Value*(5.0/1023.0);
  mqxPinValue=mqxPinValue*(5.0/1023.0);
  
  float mv = (tempValue/1024.0)*5000.0; 
  float cel = mv/10;
  tempValue=cel;
}

void sendSensorsValues()
{
  toSend="";
  toSend+=String(mq2Value);
  toSend+=",";
  toSend+=String(mq135Value);
  toSend+=",";
  toSend+=String(mq3Value);
  toSend+=",";
  toSend+=String(mq8Value);
  toSend+=",";
  toSend+=String(tgs882Value);
  toSend+=",";
  toSend+=String(mq136Value);
  toSend+=",";
  toSend+=String(mqxPinValue);
  toSend+=",";
  toSend+=String(tempValue);

  Serial.println(toSend);
  RPi.println(toSend);
}

