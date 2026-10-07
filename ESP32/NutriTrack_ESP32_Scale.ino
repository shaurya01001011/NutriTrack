#include <WiFi.h>
#include <WebServer.h>
#include <ESPmDNS.h>
#include "HX711.h"

// ---------- Wi-Fi configuration ----------
// Change these values if the Wi-Fi network changes.
// ESP32 supports 2.4 GHz only. On an iPhone hotspot enable "Maximize Compatibility".
const char* WIFI_SSID = "1234";
const char* WIFI_PASSWORD = "87654321";

// Optional fixed IP so the address never changes.
// Set USE_STATIC_IP to true and match the values to YOUR router
// (same first three numbers as your laptop's IP, unused last number).
#define USE_STATIC_IP false
IPAddress local_IP(192, 168, 1, 50);
IPAddress gateway(192, 168, 1, 1);
IPAddress subnet(255, 255, 255, 0);
IPAddress dns(8, 8, 8, 8);

// App can also reach the scale at http://nutritrack.local
const char* DEVICE_NAME = "nutritrack";

// ---------- HX711 ----------
#define HX711_DOUT 16
#define HX711_SCK 17

HX711 scale;
WebServer server(80);

const float CALIBRATION_FACTOR = 1278.0;

// ---------- CORS ----------
void addCorsHeaders() {
  server.sendHeader("Access-Control-Allow-Origin", "*");
  server.sendHeader("Access-Control-Allow-Methods", "GET, OPTIONS");
  server.sendHeader("Access-Control-Allow-Headers", "*");
  server.sendHeader("Access-Control-Allow-Private-Network", "true");
  server.sendHeader("Cache-Control", "no-store");
}

void handleOptions() {
  addCorsHeaders();
  server.send(204);
}

// ---------- Weight ----------
float readWeight() {
  // Don't wait forever for the HX711
  if (!scale.wait_ready_timeout(1000)) {
    Serial.println("HX711 timeout!");
    return -1;
  }

  float weight = scale.get_units(3);
  if (weight < 0) weight = 0;
  return weight;
}

// ---------- API ----------
void handleWeight() {
  float weight = readWeight();
  addCorsHeaders();

  String json;
  if (weight < 0) {
    json = "{\"weight\":null}";
  } else {
    json = "{\"weight\":" + String(weight, 1) + "}";
  }
  server.send(200, "application/json", json);
}

void handleRoot() {
  addCorsHeaders();
  String msg = "NutriTrack ESP32 Scale is running\nIP: " + WiFi.localIP().toString();
  server.send(200, "text/plain", msg);
}

void handleNotFound() {
  addCorsHeaders();
  server.send(404, "text/plain", "Not found");
}

// ---------- Wi-Fi ----------
const char* wifiStatusText(wl_status_t s) {
  switch (s) {
    case WL_NO_SSID_AVAIL:   return "SSID not found (wrong name or 5 GHz network)";
    case WL_CONNECT_FAILED:  return "Connect failed (wrong password?)";
    case WL_CONNECTION_LOST: return "Connection lost";
    case WL_DISCONNECTED:    return "Disconnected";
    case WL_IDLE_STATUS:     return "Idle";
    default:                 return "Other";
  }
}

bool connectWiFi() {
  WiFi.persistent(false);
  WiFi.mode(WIFI_STA);
  WiFi.setAutoReconnect(true);
  WiFi.disconnect(true);
  delay(500);

#if USE_STATIC_IP
  if (!WiFi.config(local_IP, gateway, subnet, dns)) {
    Serial.println("Static IP config failed, using DHCP");
  }
#endif

  WiFi.begin(WIFI_SSID, WIFI_PASSWORD);
  Serial.print("Connecting to Wi-Fi");

  unsigned long start = millis();
  while (WiFi.status() != WL_CONNECTED && millis() - start < 20000) {
    delay(500);
    Serial.print(".");
  }
  Serial.println();

  if (WiFi.status() == WL_CONNECTED) {
    Serial.println("Wi-Fi connected!");
    Serial.print("ESP32 IP Address: ");
    Serial.println(WiFi.localIP());
    return true;
  }

  Serial.print("Wi-Fi failed: ");
  Serial.println(wifiStatusText(WiFi.status()));
  return false;
}

void ensureWiFi() {
  static unsigned long lastCheck = 0;
  if (WiFi.status() == WL_CONNECTED) return;
  if (millis() - lastCheck < 10000) return;
  lastCheck = millis();
  Serial.println("Wi-Fi lost, reconnecting...");
  WiFi.disconnect();
  WiFi.begin(WIFI_SSID, WIFI_PASSWORD);
}

void setup() {
  Serial.begin(115200);
  delay(1000);

  Serial.println();
  Serial.println("NutriTrack Weight System");
  Serial.println("------------------------");

  // ---------- HX711 ----------
  scale.begin(HX711_DOUT, HX711_SCK);

  Serial.println("Taring... Remove all weight.");
  delay(3000);

  if (scale.wait_ready_timeout(3000)) {
    scale.set_scale(CALIBRATION_FACTOR);
    scale.tare();
    Serial.println("Tare complete!");
  } else {
    Serial.println("HX711 NOT DETECTED! Check wiring (DOUT=16, SCK=17, VCC, GND).");
  }

  // ---------- Wi-Fi (retry until connected) ----------
  while (!connectWiFi()) {
    Serial.println("Retrying in 3 seconds...");
    delay(3000);
  }

  // ---------- mDNS ----------
  if (MDNS.begin(DEVICE_NAME)) {
    MDNS.addService("http", "tcp", 80);
    Serial.print("mDNS ready: http://");
    Serial.print(DEVICE_NAME);
    Serial.println(".local");
  } else {
    Serial.println("mDNS failed, use the IP address instead.");
  }

  // ---------- Server ----------
  server.on("/", HTTP_GET, handleRoot);
  server.on("/weight", HTTP_GET, handleWeight);
  server.on("/", HTTP_OPTIONS, handleOptions);
  server.on("/weight", HTTP_OPTIONS, handleOptions);
  server.onNotFound(handleNotFound);

  server.begin();

  Serial.println("Web server started!");
  Serial.print("Test in browser: http://");
  Serial.print(WiFi.localIP());
  Serial.println("/weight");
}

void loop() {
  ensureWiFi();
  server.handleClient();

  // Print weight every second
  static unsigned long lastReading = 0;
  if (millis() - lastReading >= 1000) {
    lastReading = millis();
    float weight = readWeight();

    if (weight >= 0) {
      Serial.print("Weight: ");
      Serial.print(weight, 1);
      Serial.println(" g");
    }
  }
}
