import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:mqtt_client/mqtt_client.dart';
import 'package:mqtt_client/mqtt_server_client.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Master Monitor',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        useMaterial3: true,
      ),
      home: const SensorMonitorScreen(),
    );
  }
}

class SensorData {
  final double tilt;
  final double moisture;
  final double temperature;
  final double humidity;

  SensorData({
    required this.tilt,
    required this.moisture,
    required this.temperature,
    required this.humidity,
  });

  factory SensorData.fromJson(Map<String, dynamic> json) {
    return SensorData(
      tilt: (json['tilt'] as num).toDouble(),
      moisture: (json['moisture'] as num).toDouble(),
      temperature: (json['temperature'] as num).toDouble(),
      humidity: (json['humidity'] as num).toDouble(),
    );
  }

  factory SensorData.empty() {
    return SensorData(
      tilt: 0.0,
      moisture: 0.0,
      temperature: 0.0,
      humidity: 0.0,
    );
  }
}

class SensorMonitorScreen extends StatefulWidget {
  const SensorMonitorScreen({Key? key}) : super(key: key);

  @override
  State<SensorMonitorScreen> createState() => _SensorMonitorScreenState();
}

class _SensorMonitorScreenState extends State<SensorMonitorScreen> {
  MqttServerClient? client;
  SensorData sensorData = SensorData.empty();
  bool isConnected = false;
  String connectionStatus = 'Disconnected';
  String errorMessage = '';

  // Thresholds for alerts
  final double tiltThreshold = 15.0;
  final double moistureThreshold = 80.0;
  final double temperatureThreshold = 35.0;
  final double humidityThreshold = 90.0;

  @override
  void initState() {
    super.initState();
    _connectToMqtt();
  }

  @override
  void dispose() {
    _disconnectFromMqtt();
    super.dispose();
  }

  Future<void> _connectToMqtt() async {
    setState(() {
      connectionStatus = 'Connecting...';
      errorMessage = '';
    });

    // Create the client
    client = MqttServerClient('broker.hivemq.com', 'flutter_sensor_client');
    // Set callback handlers
    client!.logging(on: false);
    client!.keepAlivePeriod = 20;
    client!.onDisconnected = _onDisconnected;
    client!.onConnected = _onConnected;
    client!.onSubscribed = _onSubscribed;
    client!.pongCallback = _pong;

    // Set connection parameters
    final connMess = MqttConnectMessage()
        .withClientIdentifier('flutter_sensor_client')
        .withWillTopic('willtopic')
        .withWillMessage('Disconnected unexpectedly')
        .startClean()
        .withWillQos(MqttQos.atLeastOnce);
    client!.connectionMessage = connMess;

    // Connect to the broker
    try {
      await client!.connect();
    } catch (e) {
      setState(() {
        connectionStatus = 'Connection failed';
        errorMessage = e.toString();
      });
      return;
    }

    // Check connection status
    if (client!.connectionStatus!.state == MqttConnectionState.connected) {
      setState(() {
        isConnected = true;
        connectionStatus = 'Connected';
      });
    } else {
      setState(() {
        isConnected = false;
        connectionStatus = 'Connection failed - ${client!.connectionStatus!.state}';
        errorMessage = 'Connection error: ${client!.connectionStatus!.state}';
      });
      client!.disconnect();
      return;
    }

    // Subscribe to topic
    const topic = 'esp32/sensors';
    client!.subscribe(topic, MqttQos.atLeastOnce);
  }

  void _onConnected() {
    setState(() {
      isConnected = true;
      connectionStatus = 'Connected';
    });
  }

  void _onDisconnected() {
    setState(() {
      isConnected = false;
      connectionStatus = 'Disconnected';
    });
  }

  void _onSubscribed(String topic) {
    // Set up a listener for messages
    client!.updates!.listen((List<MqttReceivedMessage<MqttMessage>> messages) {
      for (final message in messages) {
        final MqttPublishMessage recMess = message.payload as MqttPublishMessage;
        final payload = MqttPublishPayload.bytesToStringAsString(recMess.payload.message);
        
        try {
          final jsonData = jsonDecode(payload);
          final newData = SensorData.fromJson(jsonData);
          
          setState(() {
            sensorData = newData;
          });
          
          // Check if any values exceed thresholds
          _checkThresholds(newData);
        } catch (e) {
          setState(() {
            errorMessage = 'Failed to parse sensor data: $e';
          });
        }
      }
    });
  }

  void _pong() {
    // Handle ping response
  }

  void _disconnectFromMqtt() {
    if (client != null && client!.connectionStatus!.state == MqttConnectionState.connected) {
      client!.disconnect();
    }
  }

  void _checkThresholds(SensorData data) {
    if (data.tilt > tiltThreshold) {
      _showAlert('Tilt', data.tilt, tiltThreshold);
    }
    if (data.moisture > moistureThreshold) {
      _showAlert('Moisture', data.moisture, moistureThreshold);
    }
    if (data.temperature > temperatureThreshold) {
      _showAlert('Temperature', data.temperature, temperatureThreshold);
    }
    if (data.humidity > humidityThreshold) {
      _showAlert('Humidity', data.humidity, humidityThreshold);
    }
  }

  void _showAlert(String sensorType, double value, double threshold) {
    // Display in-app alert
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('$sensorType alert: ${value.toStringAsFixed(1)} exceeds threshold of $threshold'),
        backgroundColor: Colors.red,
        duration: const Duration(seconds: 5),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('ESP32 Sensor Monitor'),
        actions: [
          // Connection status indicator
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: isConnected 
              ? const Icon(Icons.wifi, color: Colors.green)
              : const Icon(Icons.wifi_off, color: Colors.red),
          )
        ],
      ),
      body: Column(
        children: [
          // Connection status
          Container(
            padding: const EdgeInsets.all(8.0),
            color: isConnected ? Colors.green.shade100 : Colors.red.shade100,
            child: Row(
              children: [
                Icon(
                  isConnected ? Icons.check_circle : Icons.error,
                  color: isConnected ? Colors.green : Colors.red,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    connectionStatus,
                    style: TextStyle(
                      color: isConnected ? Colors.green.shade800 : Colors.red.shade800,
                    ),
                  ),
                ),
                if (!isConnected)
                  ElevatedButton(
                    onPressed: _connectToMqtt,
                    child: const Text('Reconnect'),
                  ),
              ],
            ),
          ),
          
          // Error message (if any)
          if (errorMessage.isNotEmpty)
            Container(
              padding: const EdgeInsets.all(8.0),
              color: Colors.orange.shade100,
              child: Row(
                children: [
                  const Icon(Icons.warning, color: Colors.orange),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      errorMessage,
                      style: TextStyle(color: Colors.orange.shade800),
                    ),
                  ),
                ],
              ),
            ),
          
          // Sensor data
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: GridView.count(
                crossAxisCount: 2,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
                children: [
                  _buildSensorCard(
                    'Tilt',
                    sensorData.tilt,
                    '°',
                    Icons.rotate_right,
                    sensorData.tilt > tiltThreshold ? Colors.red : Colors.blue,
                  ),
                  _buildSensorCard(
                    'Soil Moisture',
                    sensorData.moisture,
                    '%',
                    Icons.water_drop,
                    sensorData.moisture > moistureThreshold ? Colors.red : Colors.blue,
                  ),
                  _buildSensorCard(
                    'Temperature',
                    sensorData.temperature,
                    '°C',
                    Icons.thermostat,
                    sensorData.temperature > temperatureThreshold ? Colors.red : Colors.orange,
                  ),
                  _buildSensorCard(
                    'Humidity',
                    sensorData.humidity,
                    '%',
                    Icons.water,
                    sensorData.humidity > humidityThreshold ? Colors.red : Colors.blue,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSensorCard(String title, double value, String unit, IconData icon, Color color) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: value > _getThresholdForSensor(title) ? Colors.red : Colors.transparent,
          width: 2,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 48, color: color),
            const SizedBox(height: 8),
            Text(
              title,
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.baseline,
              textBaseline: TextBaseline.alphabetic,
              children: [
                Text(
                  value.toStringAsFixed(1),
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    color: color,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  unit,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: color,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              'Threshold: ${_getThresholdForSensor(title)}$unit',
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ],
        ),
      ),
    );
  }

  double _getThresholdForSensor(String sensorType) {
    switch (sensorType) {
      case 'Tilt':
        return tiltThreshold;
      case 'Soil Moisture':
        return moistureThreshold;
      case 'Temperature':
        return temperatureThreshold;
      case 'Humidity':
        return humidityThreshold;
      default:
        return 0.0;
    }
  }
}