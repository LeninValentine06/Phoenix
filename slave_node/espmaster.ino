#include <SPI.h>
#include <LoRa.h>

#define PIN_LORA_CS 5
#define PIN_LORA_RST 2
#define PIN_LORA_DIO0 4
#define LORA_FREQUENCY 433E6

void setup() {
    Serial.begin(115200);
    Serial.println("LoRa Receiver Initializing...");

    LoRa.setPins(PIN_LORA_CS, PIN_LORA_RST, PIN_LORA_DIO0);
    LoRa.setSPIFrequency(1E6);  // Reduce SPI speed

    if (!LoRa.begin(LORA_FREQUENCY)) {
        Serial.println("LoRa Initialization Failed!");
        while (1);
    }

    Serial.println("LoRa Receiver Ready");
}

void loop() {
    int packetSize = LoRa.parsePacket();
    if (packetSize) {
        Serial.println(" Packet Detected!");

        String receivedData = "";
        while (LoRa.available()) {
            char c = (char)LoRa.read();
            receivedData += c;
        }

        Serial.print("Received Data: ");
        Serial.println(receivedData);
        Serial.print("RSSI: ");
        Serial.println(LoRa.packetRssi());

        Serial.println("----------------------");
    }
}