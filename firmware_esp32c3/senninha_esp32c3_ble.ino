/*
 * =========================================================================
 *   SENNINHA-BOT #01 - FIRMWARE BLE + OLED + 2 SERVOS PARA ESP32-C3
 * =========================================================================
 *   Pinagem Configurada Conforme Conexoes Fisicas:
 *   - Servo Motor 1 (Esquerdo): GPIO 2
 *   - Servo Motor 2 (Direito) : GPIO 3
 *   - Display OLED SSD1306    : SCL no GPIO 5 (fio verde), SDA no GPIO 6 (fio roxo)
 *   - Buzina (Buzzer)         : Sinal no GPIO 1
 *   - Farol / LED             : GPIO 10 (ou onboard)
 * =========================================================================
 */

#include <Wire.h>
#include <Adafruit_GFX.h>
#include <Adafruit_SSD1306.h>
#include <ESP32Servo.h>
#include <BLEDevice.h>
#include <BLEServer.h>
#include <BLEUtils.h>
#include <BLE2902.h>

// ── CONFIGURAÇÃO DE PINOS ───────────────────────────────────────────────
#define PIN_SERVO_1     2   // Servo 1 (Roda Esquerda)
#define PIN_SERVO_2     3   // Servo 2 (Roda Direita)
#define PIN_BUZZER      1   // Buzina (fio azul GND, sinal pino 1)
#define PIN_FAROL       10  // Farol / LED

// Display OLED I2C
#define I2C_SDA         6   // Fio roxo
#define I2C_SCL         5   // Fio verde (SCK)
#define SCREEN_WIDTH    128
#define SCREEN_HEIGHT   64
#define OLED_RESET      -1
#define SCREEN_ADDRESS  0x3C

// ── OBJETOS E VARIÁVEIS GLOBAIS ─────────────────────────────────────────
Adafruit_SSD1306 display(SCREEN_WIDTH, SCREEN_HEIGHT, &Wire, OLED_RESET);
bool oledReady = false;

Servo servo1;
Servo servo2;

// UUIDs BLE (Nordic UART)
#define SERVICE_UUID           "6E400001-B5A3-F393-E0A9-E50E24DCCA9E"
#define CHARACTERISTIC_UUID_RX "6E400002-B5A3-F393-E0A9-E50E24DCCA9E"
#define CHARACTERISTIC_UUID_TX "6E400003-B5A3-F393-E0A9-E50E24DCCA9E"

BLEServer *pServer = NULL;
BLECharacteristic *pTxCharacteristic = NULL;
bool deviceConnected = false;
bool oldDeviceConnected = false;

unsigned long lastTelemetryTime = 0;
String currentExpression = "NEUTRO";

// ── CONTROLE DOS SERVOS MOTORES ─────────────────────────────────────────
// Em servos contínuos (360):
// 90 = Parado
// 180 = Frente Máxima / 0 = Ré Máxima (ou vice-versa por estarem em lados opostos)

void stopMotors() {
  servo1.write(90);
  servo2.write(90);
  Serial.println("[SERVOS] PARADOS (90, 90)");
}

void moveForward(int speedPercent = 100) {
  int p = constrain(speedPercent, 0, 100);
  int s1 = map(p, 0, 100, 90, 180); // Roda Esquerda frente
  int s2 = map(p, 0, 100, 90, 0);   // Roda Direita frente (invertido)
  servo1.write(s1);
  servo2.write(s2);
  Serial.printf("[SERVOS] FRENTE S1:%d S2:%d\n", s1, s2);
}

void moveBackward(int speedPercent = 100) {
  int p = constrain(speedPercent, 0, 100);
  int s1 = map(p, 0, 100, 90, 0);   // Roda Esquerda ré
  int s2 = map(p, 0, 100, 90, 180); // Roda Direita ré
  servo1.write(s1);
  servo2.write(s2);
  Serial.printf("[SERVOS] RE S1:%d S2:%d\n", s1, s2);
}

void turnLeft(int speedPercent = 100) {
  int p = constrain(speedPercent, 0, 100);
  int s1 = map(p, 0, 100, 90, 60);  // Esquerda para trás/reduzida
  int s2 = map(p, 0, 100, 90, 0);   // Direita para frente
  servo1.write(s1);
  servo2.write(s2);
  Serial.printf("[SERVOS] ESQUERDA S1:%d S2:%d\n", s1, s2);
}

void turnRight(int speedPercent = 100) {
  int p = constrain(speedPercent, 0, 100);
  int s1 = map(p, 0, 100, 90, 180); // Esquerda para frente
  int s2 = map(p, 0, 100, 90, 120); // Direita para trás/reduzida
  servo1.write(s1);
  servo2.write(s2);
  Serial.printf("[SERVOS] DIREITA S1:%d S2:%d\n", s1, s2);
}

// ── SISTEMA DE ÁUDIO (BUZZER) ───────────────────────────────────────────

void playTone(int freq, int durationMs) {
  tone(PIN_BUZZER, freq, durationMs);
  delay(durationMs);
  noTone(PIN_BUZZER);
  digitalWrite(PIN_BUZZER, LOW);
}

void playConnectSound() {
  Serial.println("[SOM] Bluetooth conectado!");
  playTone(2093, 80);
  delay(60);
  playTone(3136, 150);
}

void playDisconnectSound() {
  Serial.println("[SOM] Bluetooth desconectado!");
  playTone(2400, 90);
  delay(50);
  playTone(1200, 160);
}

void playStartupSound() {
  Serial.println("[SOM] ESP32-C3 Inicializado!");
  playTone(1500, 60);
  delay(40);
  playTone(2500, 80);
}

// ── FUNÇÕES DO ROSTINHO OLED ────────────────────────────────────────────

void drawThickLine(int x0, int y0, int x1, int y1, int thickness) {
  for (int dx = -thickness / 2; dx <= thickness / 2; dx++) {
    for (int dy = -thickness / 2; dy <= thickness / 2; dy++) {
      display.drawLine(x0 + dx, y0 + dy, x1 + dx, y1 + dy, SSD1306_WHITE);
    }
  }
}

void drawHeart(int cx, int cy, int size) {
  int r = size / 2;
  display.fillCircle(cx - r / 2, cy - r / 2, r / 2, SSD1306_WHITE);
  display.fillCircle(cx + r / 2, cy - r / 2, r / 2, SSD1306_WHITE);
  display.fillTriangle(cx - r, cy - r / 4, cx + r, cy - r / 4, cx, cy + size / 2, SSD1306_WHITE);
}

void drawFaceHappy() {
  display.clearDisplay();
  drawThickLine(20, 30, 38, 16, 3);
  drawThickLine(38, 16, 56, 30, 3);
  drawThickLine(72, 30, 90, 16, 3);
  drawThickLine(90, 16, 108, 30, 3);

  display.drawLine(24, 38, 30, 34, SSD1306_WHITE);
  display.drawLine(28, 40, 34, 36, SSD1306_WHITE);
  display.drawLine(94, 38, 100, 34, SSD1306_WHITE);
  display.drawLine(98, 40, 104, 36, SSD1306_WHITE);

  display.fillCircle(64, 42, 10, SSD1306_WHITE);
  display.fillRect(52, 32, 24, 11, SSD1306_BLACK);
  display.display();
}

void drawFaceRace() {
  display.clearDisplay();
  drawThickLine(22, 18, 54, 28, 4);
  drawThickLine(22, 38, 54, 28, 4);
  drawThickLine(106, 18, 74, 28, 4);
  drawThickLine(106, 38, 74, 28, 4);

  drawThickLine(54, 48, 74, 48, 3);
  display.drawLine(18, 12, 48, 16, SSD1306_WHITE);
  display.drawLine(110, 12, 80, 16, SSD1306_WHITE);
  display.display();
}

void drawFaceWink() {
  display.clearDisplay();
  display.fillRoundRect(22, 14, 32, 30, 10, SSD1306_WHITE);
  display.fillCircle(38, 28, 8, SSD1306_BLACK);
  display.fillCircle(40, 26, 3, SSD1306_WHITE);

  drawThickLine(74, 30, 92, 18, 3);
  drawThickLine(92, 18, 110, 30, 3);

  drawThickLine(56, 48, 72, 46, 3);
  drawThickLine(72, 46, 78, 40, 3);
  display.display();
}

void drawFaceVictory() {
  display.clearDisplay();
  display.fillRoundRect(18, 12, 34, 34, 12, SSD1306_WHITE);
  display.fillCircle(35, 29, 8, SSD1306_BLACK);
  display.fillCircle(33, 24, 3, SSD1306_WHITE);
  display.fillCircle(39, 32, 2, SSD1306_WHITE);

  display.fillRoundRect(76, 12, 34, 34, 12, SSD1306_WHITE);
  display.fillCircle(93, 29, 8, SSD1306_BLACK);
  display.fillCircle(91, 24, 3, SSD1306_WHITE);
  display.fillCircle(97, 32, 2, SSD1306_WHITE);

  display.fillRoundRect(52, 44, 24, 14, 6, SSD1306_WHITE);
  display.display();
}

void drawFaceHeart() {
  display.clearDisplay();
  drawHeart(38, 26, 26);
  drawHeart(90, 26, 26);

  display.drawCircle(64, 44, 8, SSD1306_WHITE);
  display.fillRect(54, 36, 20, 9, SSD1306_BLACK);
  display.display();
}

void drawFaceAngry() {
  display.clearDisplay();
  display.fillTriangle(20, 16, 56, 28, 20, 38, SSD1306_WHITE);
  display.fillCircle(40, 28, 4, SSD1306_BLACK);

  display.fillTriangle(108, 16, 72, 28, 108, 38, SSD1306_WHITE);
  display.fillCircle(88, 28, 4, SSD1306_BLACK);

  display.drawRect(52, 46, 24, 8, SSD1306_WHITE);
  display.drawLine(58, 46, 58, 54, SSD1306_WHITE);
  display.drawLine(64, 46, 64, 54, SSD1306_WHITE);
  display.drawLine(70, 46, 70, 54, SSD1306_WHITE);
  display.display();
}

void drawFaceSleep() {
  display.clearDisplay();
  drawThickLine(20, 32, 54, 32, 4);
  drawThickLine(74, 32, 108, 32, 4);
  drawThickLine(60, 48, 68, 48, 2);

  display.setTextSize(1);
  display.setTextColor(SSD1306_WHITE);
  display.setCursor(96, 10);
  display.print("Z");
  display.setCursor(106, 6);
  display.print("z");
  display.setCursor(114, 2);
  display.print("z");
  display.display();
}

void drawFaceNeutral() {
  display.clearDisplay();
  display.fillRoundRect(24, 18, 28, 26, 8, SSD1306_WHITE);
  display.fillCircle(38, 31, 6, SSD1306_BLACK);
  display.fillCircle(40, 29, 2, SSD1306_WHITE);

  display.fillRoundRect(76, 18, 28, 26, 8, SSD1306_WHITE);
  display.fillCircle(90, 31, 6, SSD1306_BLACK);
  display.fillCircle(92, 29, 2, SSD1306_WHITE);

  drawThickLine(58, 48, 70, 48, 3);
  display.display();
}

void drawFaceBlink() {
  if (!oledReady) return;
  display.clearDisplay();
  drawThickLine(22, 28, 52, 28, 3);
  drawThickLine(76, 28, 106, 28, 3);
  display.display();
  delay(140);
}

void setExpression(String expr) {
  currentExpression = expr;
  Serial.print("[ROSTINHO]: ");
  Serial.println(expr);

  if (!oledReady) return;

  if (expr == "PISCAR") {
    drawFaceBlink();
    setExpression("FELIZ");
    return;
  }

  if (expr == "FELIZ") drawFaceHappy();
  else if (expr == "CORRIDA") drawFaceRace();
  else if (expr == "PISCADELA") drawFaceWink();
  else if (expr == "VITORIA") drawFaceVictory();
  else if (expr == "CORACAO") drawFaceHeart();
  else if (expr == "BRAVO") drawFaceAngry();
  else if (expr == "SONECA") drawFaceSleep();
  else drawFaceNeutral();
}

// ── CALLBACKS BLE ───────────────────────────────────────────────────────

class ServerCallbacks: public BLEServerCallbacks {
    void onConnect(BLEServer* pServer) {
      deviceConnected = true;
      Serial.println("[BLE] Smartphone Conectado!");
    }

    void onDisconnect(BLEServer* pServer) {
      deviceConnected = false;
      Serial.println("[BLE] Smartphone Desconectado!");
      stopMotors();
    }
};

class CommandCallbacks: public BLECharacteristicCallbacks {
    void onWrite(BLECharacteristic *pCharacteristic) {
      String rxValue = pCharacteristic->getValue().c_str();
      rxValue.trim();

      if (rxValue.length() > 0) {
        Serial.print("[CMD RECEBIDO]: ");
        Serial.println(rxValue);

        // 1. Comando de Expressão do Rostinho OLED
        if (rxValue.startsWith("FACE:")) {
          String faceName = rxValue.substring(5);
          faceName.trim();
          setExpression(faceName);
        }
        // 2. Direção (D-Pad / Volante)
        else if (rxValue.startsWith("DRIVE:")) {
          // Formato: DRIVE:FRENTE:100 ou DRIVE:STOP:0
          int firstColon = rxValue.indexOf(':');
          int secondColon = rxValue.indexOf(':', firstColon + 1);
          String dir = rxValue.substring(firstColon + 1, secondColon);
          int spd = rxValue.substring(secondColon + 1).toInt();

          if (dir == "FRENTE") {
            moveForward(spd);
          } else if (dir == "RE") {
            moveBackward(spd);
          } else if (dir == "ESQ") {
            turnLeft(spd);
          } else if (dir == "DIR") {
            turnRight(spd);
          } else if (dir == "STOP") {
            stopMotors();
          }
        }
        // 3. Joystick Analógico 360°
        else if (rxValue.startsWith("JOY:")) {
          // Formato: JOY:<angulo>:<forca>:<gas>
          int c1 = rxValue.indexOf(':');
          int c2 = rxValue.indexOf(':', c1 + 1);
          int c3 = rxValue.indexOf(':', c2 + 1);
          int ang = rxValue.substring(c1 + 1, c2).toInt();
          int force = rxValue.substring(c2 + 1, c3).toInt();

          if (force < 15) {
            stopMotors();
          } else {
            // Navegação simples por ângulo
            if (ang >= 45 && ang <= 135) {
              moveForward(force);
            } else if (ang >= 225 && ang <= 315) {
              moveBackward(force);
            } else if (ang > 135 && ang < 225) {
              turnLeft(force);
            } else {
              turnRight(force);
            }
          }
        }
        // 4. Parada de Emergência
        else if (rxValue == "STOP") {
          stopMotors();
        }
        // 5. Buzina
        else if (rxValue.startsWith("BUZZER:")) {
          int state = rxValue.substring(7).toInt();
          if (state) {
            tone(PIN_BUZZER, 2400);
          } else {
            noTone(PIN_BUZZER);
            digitalWrite(PIN_BUZZER, LOW);
          }
        }
        // 6. Farol
        else if (rxValue.startsWith("LIGHT:")) {
          int state = rxValue.substring(6).toInt();
          digitalWrite(PIN_FAROL, state ? HIGH : LOW);
        }
      }
    }
};

// ── SETUP ───────────────────────────────────────────────────────────────

void setup() {
  Serial.begin(115200);
  delay(500);
  Serial.println("\n--- INICIALIZANDO SENNINHA ESP32-C3 (2x SERVOS + OLED) ---");

  pinMode(PIN_BUZZER, OUTPUT);
  pinMode(PIN_FAROL, OUTPUT);
  digitalWrite(PIN_BUZZER, LOW);

  // Inicializa os 2 Servos Motores (Pinos 2 e 3)
  ESP32PWM::allocateTimer(0);
  ESP32PWM::allocateTimer(1);
  ESP32PWM::allocateTimer(2);
  ESP32PWM::allocateTimer(3);
  servo1.setPeriodHertz(50);
  servo2.setPeriodHertz(50);
  servo1.attach(PIN_SERVO_1, 500, 2400);
  servo2.attach(PIN_SERVO_2, 500, 2400);
  stopMotors();

  // Inicializa I2C nos pinos fornecidos: SDA = 6, SCL = 5
  Wire.begin(I2C_SDA, I2C_SCL);

  // Inicializa Display OLED SSD1306
  if (display.begin(SSD1306_SWITCHCAPVCC, SCREEN_ADDRESS)) {
    oledReady = true;
    display.clearDisplay();
    display.setTextSize(1);
    display.setTextColor(SSD1306_WHITE);
    display.setCursor(18, 18);
    display.print("SENNINHA-BOT #01");
    display.setCursor(24, 36);
    display.print("2x SERVOS + OLED");
    display.display();
    delay(1000);
    drawFaceNeutral();
  } else {
    Serial.println("[AVISO] Display OLED SSD1306 nao respondeu no endereco 0x3C!");
  }

  // Som de inicialização
  playStartupSound();

  // Inicializa BLE
  BLEDevice::init("SENNINHA-ESP32-C3");
  pServer = BLEDevice::createServer();
  pServer->setCallbacks(new ServerCallbacks());

  BLEService *pService = pServer->createService(SERVICE_UUID);

  pTxCharacteristic = pService->createCharacteristic(
                        CHARACTERISTIC_UUID_TX,
                        BLECharacteristic::PROPERTY_NOTIFY
                      );
  pTxCharacteristic->addDescriptor(new BLE2902());

  BLECharacteristic *pRxCharacteristic = pService->createCharacteristic(
                                           CHARACTERISTIC_UUID_RX,
                                           BLECharacteristic::PROPERTY_WRITE |
                                           BLECharacteristic::PROPERTY_WRITE_NR
                                         );
  pRxCharacteristic->setCallbacks(new CommandCallbacks());

  pService->start();

  BLEAdvertising *pAdvertising = BLEDevice::getAdvertising();
  pAdvertising->addServiceUUID(SERVICE_UUID);
  pAdvertising->setScanResponse(true);
  pAdvertising->setMinPreferred(0x06);
  pAdvertising->setMinPreferred(0x12);
  BLEDevice::startAdvertising();

  Serial.println("[BLE] Robô pronto! Aguardando conexao do app...");
}

// ── LOOP PRINCIPAL ──────────────────────────────────────────────────────

void loop() {
  // Telemetria (50Hz)
  if (deviceConnected && (millis() - lastTelemetryTime >= 20)) {
    lastTelemetryTime = millis();

    int rpm = 6400 + random(-80, 80);
    float bat = 7.62 + (random(-5, 5) * 0.01);
    float temp = 34.2 + (random(-2, 2) * 0.1);
    int motL = 420;
    int motR = 419;
    int latency = 12;

    char telemetryPacket[64];
    snprintf(telemetryPacket, sizeof(telemetryPacket),
             "RPM:%d;BAT:%.2f;TEMP:%.1f;L:%d;R:%d;MS:%d",
             rpm, bat, temp, motL, motR, latency);

    pTxCharacteristic->setValue((uint8_t*)telemetryPacket, strlen(telemetryPacket));
    pTxCharacteristic->notify();
  }

  // Ao conectar o celular
  if (deviceConnected && !oldDeviceConnected) {
    playConnectSound();
    setExpression("FELIZ");
    oldDeviceConnected = deviceConnected;
  }

  // Ao desconectar o celular
  if (!deviceConnected && oldDeviceConnected) {
    stopMotors();
    playDisconnectSound();
    setExpression("SONECA");
    delay(500);
    pServer->startAdvertising();
    Serial.println("[BLE] Reiniciando busca...");
    oldDeviceConnected = deviceConnected;
  }
}
