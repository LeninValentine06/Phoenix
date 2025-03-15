# LoRa-Based Real-Time Landslide Detection System
   ![Slave Node PCB Design](https://github.com/LeninValentine06/Phoenix/blob/main/misc/Slave_Node.jpg)
## 1. Project Overview

### The Problem

Landslides are devastating natural disasters that claim thousands of lives annually worldwide. Traditional monitoring systems are often expensive, difficult to deploy in remote areas, and lack real-time alerting capabilities. Many vulnerable communities, especially in developing regions, lack access to early warning systems that could save lives.

### Our Solution

The LoRa-Based Real-Time Landslide Detection System provides an affordable, open-source solution for early detection and warning of potential landslide events. By combining low-power sensors, long-range wireless communication, and intelligent data processing, our system can:

- Detect early signs of land movement and soil condition changes
- Transmit data over long distances even in remote areas
- Provide immediate, multi-modal alerts to communities at risk
- Operate for extended periods on battery power

The system uses distributed ESP32-based sensor nodes placed in landslide-prone areas to continuously monitor ground movement, soil moisture, and environmental conditions. When potential landslide indicators are detected, the system triggers immediate alerts via multiple channels.

## 2. System Architecture

### Hardware Components

#### Sensor Node (ESP32)
- **Microcontroller**: ESP32-WROOM-32
- **Sensors**:
  - MPU6050 (3-axis accelerometer and gyroscope)
  - Capacitive soil moisture sensor
  - DHT22/AM2302 temperature and humidity sensor
- **Communication**: LoRa RA-02 module (433MHz)
- **Power**: 3.7V LiPo battery with solar charging capability

#### Master Node (ESP32)
- **Microcontroller**: ESP32-WROOM-32
- **Alert Mechanisms**:
  - 9V speaker/buzzer for audio alerts
  - 2.8" ILI9341 TFT display for visual alerts and status
  - Optional GSM module for SMS alerts
- **Communication**:
  - LoRa RA-02 module (433MHz)
  - WiFi/Bluetooth (for configuration and notifications)
- **Power**: 5V DC power supply with battery backup

### Data Flow Architecture

```
┌─────────────────┐     LoRa     ┌─────────────────┐     Alert     ┌─────────────────┐
│                 │  Wireless    │                 │   Triggers    │                 │
│   Sensor Node   │ ───────────► │   Master Node   │ ───────────► │  Alert Systems  │
│     (ESP32)     │    433MHz    │     (ESP32)     │               │   - Speaker     │
│                 │              │                 │               │   - Display     │
│                 │              │                 │               │   - Mobile      │
└─────────────────┘              └─────────────────┘               └─────────────────┘
        │                                 ▲
        │                                 │
        │         LoRa Wireless           │
        └─────────────────────────────────┘
                (Multiple Nodes)
```

1. **Data Collection**: The ESP32 sensor nodes continuously monitor accelerometer data (ground movement), soil moisture levels, and environmental conditions.
2. **Data Processing**: Initial data processing occurs on the sensor nodes to identify concerning patterns before transmission.
3. **Data Transmission**: Processed data is transmitted via LoRa to the master node.
4. **Alert Analysis**: The ESP32 master node analyzes data from multiple sensor nodes and determines if alert thresholds are exceeded.
5. **Alert Distribution**: When potential landslide conditions are detected, the master node activates local alerts and sends notifications to configured devices.

## 3. Features

### Real-time Environmental Monitoring
- Continuous accelerometer data collection at 50Hz sample rate
- Soil moisture monitoring with 5-minute intervals
- Temperature and humidity readings every 15 minutes
- Local data processing to detect movement patterns indicative of landslides

### Long-Range, Low-Power Communication
- LoRa communication with 3-10km range (depending on terrain) using 433MHz frequency
- Optimized data packets to minimize transmission power
- Node power management for extended battery life (3-6 months on a single charge with solar support)
- Reliable mesh networking capabilities between multiple sensor nodes

### Multi-Modal Alert System
- High-decibel audio alarm for immediate local warning
- Visual alerts and system status on TFT display
- Optional mobile alerts via SMS or app notifications
- Configurable alert thresholds based on local conditions

### System Scalability
- Support for up to 50 sensor nodes per master node
- Expandable with multiple master nodes for larger coverage areas
- Modular design allowing for additional sensor types
- Open API for integration with existing warning systems

## 4. Setup & Installation

### Prerequisites

#### Hardware Requirements
- ESP32 development boards (for both sensor and master nodes)
- MPU6050 accelerometer/gyroscope module
- Soil moisture sensor (capacitive recommended)
- DHT22/AM2302 temperature & humidity sensor
- LoRa RA-02 modules (433MHz)
- 2.8" ILI9341 TFT display
- 9V speaker/buzzer
- 3.7V LiPo batteries with solar charging modules
- Power supplies, jumper wires, and prototyping boards

#### Software Requirements
- Arduino IDE (for ESP32 programming)
- Required libraries (included in the repository):
  - RadioHead library for LoRa communication
  - Adafruit MPU6050 library
  - Adafruit DHT sensor library
  - Adafruit GFX & ILI9341 libraries

### Sensor Node Setup

1. **Hardware Assembly**

   Connect the components to the ESP32 according to this pinout:
   
   ```
   ESP32 (Sensor Node)   |     Component
   ------------------------------------
   GPIO21 (SDA)         ---    MPU6050 SDA
   GPIO22 (SCL)         ---    MPU6050 SCL
   GPIO36 (ADC0)        ---    Soil Moisture Sensor
   GPIO17               ---    DHT22 Data
   GPIO5 (SCK)          ---    RA-02 SCK
   GPIO23 (MOSI)        ---    RA-02 MOSI
   GPIO19 (MISO)        ---    RA-02 MISO
   GPIO18               ---    RA-02 CS
   GPIO14               ---    RA-02 RST
   GPIO26               ---    RA-02 DIO0
   5V                   ---    Battery + (via switch)
   GND                  ---    Common ground
   ```

2. **Software Installation**

   a. Setup Arduino IDE for ESP32:
   - Add ESP32 board support to Arduino IDE
   - Install required libraries through the Library Manager

   b. Upload the sensor node code:
   - Clone this repository: `git clone https://github.com/LeninValentine06/lora-landslide-detection.git`
   - Navigate to the `sensor_node` directory
   - Open the `sensor_node.ino` file
   - Select your ESP32 board model and port
   - Compile and upload the code

### Master Node Setup

1. **Hardware Assembly**

   Connect the components to the ESP32 according to this pinout:
   
   ```
   ESP32 (Master Node)   |     Component
   ------------------------------------
   GPIO5 (SCK)          ---    RA-02 SCK
   GPIO23 (MOSI)        ---    RA-02 MOSI
   GPIO19 (MISO)        ---    RA-02 MISO
   GPIO18               ---    RA-02 CS
   GPIO14               ---    RA-02 RST
   GPIO26               ---    RA-02 DIO0
   GPIO25               ---    Speaker +
   GPIO21 (SDA)         ---    Display SDA
   GPIO22 (SCL)         ---    Display SCL
   GPIO2                ---    Display DC
   GPIO4                ---    Display CS
   GPIO15               ---    Display RST
   5V                   ---    Power input
   GND                  ---    Common ground
   ```

2. **Software Installation**

   a. Setup Arduino IDE for ESP32:
   - Add ESP32 board support to Arduino IDE
   - Install required libraries through the Library Manager

   b. Upload the master node code:
   - Open the `/master_node/master_node.ino` file from the repository
   - Select your ESP32 board model and port
   - Compile and upload the code

### Optional Mobile Notification Setup

1. Install the companion mobile app (available in the `/mobile_app` directory)
2. Configure WiFi credentials in the master node code
3. Pair your smartphone with the master node using the app
4. Test the notification system by triggering a test alert

## 5. Usage Instructions

### Initial Configuration

1. Place sensor nodes in strategic locations based on landslide risk assessment
   - Ensure proper anchoring into stable ground
   - Position solar panels for optimal sunlight exposure
   - Maintain line-of-sight between nodes when possible

2. Power on the master node first, then the sensor nodes
   - The master node display will show initialization progress
   - Wait for "SYSTEM READY" message on the display

3. Configure alert thresholds using the master node interface:
   - Press the CONFIG button to enter setup mode
   - Adjust sensitivity, alert levels, and communication parameters
   - Save configuration when complete

### Normal Operation

Under normal conditions, the system will:
- Display current readings from all sensor nodes
- Show battery levels and signal strength
- Log data at regular intervals
- Perform automatic self-tests every 24 hours

The TFT display shows a grid of connected sensor nodes with their status. Green indicators show normal operation, yellow shows warning levels, and red indicates critical alerts.

### Alert Conditions

When potential landslide conditions are detected:

1. The master node will:
   - Activate the audio alarm
   - Display detailed alert information
   - Send notifications to paired mobile devices
   - Log the event with timestamp and sensor data

2. To acknowledge alerts:
   - Press the ACKNOWLEDGE button on the master node
   - The audio alarm will silence, but visual alerts remain
   - The system continues monitoring for worsening conditions

3. After the danger passes:
   - Press and hold RESET for 5 seconds
   - Confirm system reset when prompted
   - The system will return to normal monitoring mode

## 6. Contributing

Contributions to this project are welcome! Here's how you can help:

### Reporting Issues
- Use the GitHub issue tracker to report bugs
- Include detailed steps to reproduce the issue
- Attach logs or screenshots when available

### Pull Requests
1. Fork the repository
2. Create a new branch (`git checkout -b feature/your-feature-name`)
3. Make your changes
4. Run tests if available
5. Commit your changes (`git commit -m 'Add some feature'`)
6. Push to the branch (`git push origin feature/your-feature-name`)
7. Open a Pull Request

### Development Guidelines
- Follow existing code style and naming conventions
- Add comments to explain complex functionality
- Update documentation when making changes
- Add tests for new features when possible

## 7. License

This project is licensed under the Creative Commons Zero v1.0 Universal License - see the [LICENSE](LICENSE) file for details.

This means you can copy, modify, distribute and perform the work, even for commercial purposes, all without asking permission.

## 8. Acknowledgments

- Thanks to the organizers of the Social Impact Hackathon for their support
- Special thanks to the communities who provided testing grounds and feedback
- Gratitude to all contributors and team members who made this project possible
- This project builds upon research and designs from numerous open-source projects in the disaster prevention community

---

**Disclaimer**: This system is designed as an early warning tool but should not replace proper evacuation procedures or professional geological assessment. Always follow local authority guidance during emergency situations.
