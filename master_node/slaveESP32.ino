/**
 * MPU6050 + DHT11 + Soil Moisture Sensor + LoRa Transmitter
 * Reads accelerometer, gyroscope, and temperature from MPU6050
 * Reads temperature and humidity from DHT11
 * Reads soil moisture level from analog sensor
 * Sends data via LoRa communication
 * 
 * Author: Lenin Valentine
 */

#include <Adafruit_MPU6050.h>
#include <Adafruit_Sensor.h>
#include <Wire.h>
#include <DHT11.h>
#include <SPI.h>
#include <LoRa.h>

// DHT11 & Soil Moisture Pins
#define DHT_PIN 14           // DHT11 sensor pin
#define SOIL_MOISTURE_PIN 34  // Soil Moisture Sensor connected to GPIO34

// LoRa Pins
#define PIN_LORA_COPI   23
#define PIN_LORA_CIPO   19
#define PIN_LORA_SCK    18
#define PIN_LORA_CS     5
#define PIN_LORA_RST    2
#define PIN_LORA_DIO0   4
#define LORA_FREQUENCY  433E6  // LoRa Frequency

// Sensor Objects
DHT11 dht11(DHT_PIN);
Adafruit_MPU6050 mpu;
int counter = 0;

void setup() {
    Serial.begin(115200);
    Wire.begin(21, 22);  // ESP32 I2C: SDA = GPIO21, SCL = GPIO22

    // Initialize MPU6050
    Serial.println("Initializing MPU6050...");
    if (!mpu.begin()) {
        Serial.println("Failed to find MPU6050");
        while (1);
    }
    Serial.println("MPU6050 Initialized!");

    mpu.setAccelerometerRange(MPU6050_RANGE_8_G);
    mpu.setGyroRange(MPU6050_RANGE_500_DEG);
    mpu.setFilterBandwidth(MPU6050_BAND_21_HZ);

    // Initialize LoRa
    Serial.println("Initializing LoRa...");
    LoRa.setPins(PIN_LORA_CS, PIN_LORA_RST, PIN_LORA_DIO0);
    LoRa.setSPIFrequency(20000000);
    LoRa.setTxPower(20);

    if (!LoRa.begin(LORA_FREQUENCY)) {
        Serial.println("Starting LoRa failed!");
        while (1);
    }
    Serial.println("LoRa Initialized!");
}

void loop() {
    // Read MPU6050 Data
    sensors_event_t a, g, temp;
    mpu.getEvent(&a, &g, &temp);

    // Read DHT11 Data
    int temperature = 0, humidity = 0;
    int result = dht11.readTemperatureHumidity(temperature, humidity);

    // Read Soil Moisture Sensor
    int soilMoistureValue = analogRead(SOIL_MOISTURE_PIN);

    // Print Data Locally
    Serial.println("\n--- Sensor Readings ---");
    
    if (result == 0) {
        Serial.print("DHT11 Temperature: ");
        Serial.print(temperature);
        Serial.println(" °C");

        Serial.print("DHT11 Humidity: ");
        Serial.print(humidity);
        Serial.println(" %");
    } else {
        Serial.println(DHT11::getErrorString(result));
    }

    Serial.print("MPU6050 Acceleration: X = ");
    Serial.print(a.acceleration.x);
    Serial.print(", Y = ");
    Serial.print(a.acceleration.y);
    Serial.print(", Z = ");
    Serial.println(a.acceleration.z);

    Serial.print("MPU6050 Gyro: X = ");
    Serial.print(g.gyro.x);
    Serial.print(", Y = ");
    Serial.print(g.gyro.y);
    Serial.print(", Z = ");
    Serial.println(g.gyro.z);

    Serial.print("MPU6050 Temperature: ");
    Serial.print(temp.temperature);
    Serial.println(" °C");

    Serial.print("Soil Moisture Level: ");
    Serial.println(soilMoistureValue);

    Serial.println("------------------------");

    // Send Data via LoRa
    LoRa.beginPacket();
    LoRa.print("Packet ");
    LoRa.print(counter);
    LoRa.print(" | Temp: ");
    LoRa.print(temperature);
    LoRa.print("C | Humidity: ");
    LoRa.print(humidity);
    LoRa.print("% | Soil: ");
    LoRa.print(soilMoistureValue);
    LoRa.print(" | MPU Temp: ");
    LoRa.print(temp.temperature);
    LoRa.println("C");
    LoRa.endPacket();

    Serial.print("LoRa Packet Sent: ");
    Serial.println(counter);
    
    counter++;
    delay(1000);  // 1 second delay
}
