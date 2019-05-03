/*
 * --------------------------------------------------------------------------------------------------------------------
 * Example sketch/program showing how to read data from a PICC to serial.
 * --------------------------------------------------------------------------------------------------------------------
 * This is a MFRC522 library example; for further details and other examples see: https://github.com/miguelbalboa/rfid
 * 
 * Example sketch/program showing how to read data from a PICC (that is: a RFID Tag or Card) using a MFRC522 based RFID
 * Reader on the Arduino SPI interface.
 * 
 * When the Arduino and the MFRC522 module are connected (see the pin layout below), load this sketch into Arduino IDE
 * then verify/compile and upload it. To see the output: use Tools, Serial Monitor of the IDE (hit Ctrl+Shft+M). When
 * you present a PICC (that is: a RFID Tag or Card) at reading distance of the MFRC522 Reader/PCD, the serial output
 * will show the ID/UID, type and any data blocks it can read. Note: you may see "Timeout in communication" messages
 * when removing the PICC from reading distance too early.
 * 
 * If your reader supports it, this sketch/program will read all the PICCs presented (that is: multiple tag reading).
 * So if you stack two or more PICCs on top of each other and present them to the reader, it will first output all
 * details of the first and then the next PICC. Note that this may take some time as all data blocks are dumped, so
 * keep the PICCs at reading distance until complete.
 * 
 * @license Released into the public domain.
 * 
 * Typical pin layout used:
 * -----------------------------------------------------------------------------------------
 *             MFRC522      Arduino       Arduino   Arduino    Arduino          Arduino
 *             Reader/PCD   Uno/101       Mega      Nano v3    Leonardo/Micro   Pro Micro
 * Signal      Pin          Pin           Pin       Pin        Pin              Pin
 * -----------------------------------------------------------------------------------------
 * RST/Reset   RST          9             5         D9         RESET/ICSP-5     RST
 * SPI SS      SDA(SS)      10            53        D10        10               10
 * SPI MOSI    MOSI         11 / ICSP-4   51        D11        ICSP-4           16
 * SPI MISO    MISO         12 / ICSP-1   50        D12        ICSP-1           14
 * SPI SCK     SCK          13 / ICSP-3   52        D13        ICSP-3           15
 */

#include <SPI.h>
#include <MFRC522.h>
#include <Wire.h>

#define DISPLAY_ADDRESS 0x72
#define RST_PIN          9          // Configurable, see typical pin layout above
#define SS_PIN1          10         // Configurable, see typical pin layout above
#define SS_PIN2          5
MFRC522 mfrc522[2];
int analogPin0 = A0;
int val0 = 0;
int analogPin1 = A1;
int val1 = 0;
int chargePin = A2;
double charge = 0.0;
int stopVal1 = 190;
int stopVal0 = 70;
String cardID = String("");
unsigned long prev = 0;
void setup() {
  //pinMode(8,OUTPUT);
  Serial.begin(115200);   // Initialize serial communications with the PC
  while (!Serial);    // Do nothing if no serial port is opened (added for Arduinos based on ATMEGA32U4)
  SPI.begin();      // Init SPI bus
  delay(50);
  mfrc522[0].PCD_Init(SS_PIN1,RST_PIN);   // Init MFRC522
  //mfrc522[0].PCD_DumpVersionToSerial();  // Show details of PCD - MFRC522 Card Reader details
  mfrc522[1].PCD_Init(SS_PIN2, RST_PIN);
  //mfrc522[1].PCD_DumpVersionToSerial();
  //Serial.println(F("Scan PICC to see UID, SAK, type, and data blocks..."));
  Wire.begin();
  Wire.write('|');
  Wire.write('-');
  Wire.write('|');
  Wire.write("<control>p");
  Wire.endTransmission();
  charge = analogRead(chargePin);
  charge = charge * 5.0 / 1024.0;
}

void loop() {
  // Reset the loop if no new card present on the sensor/reader. This saves the entire process when idle.
  
  //charge = (double)analogRead(chargePin);


  val0 = analogRead(analogPin0);  // read the input pin
  val1 = analogRead(analogPin1);
  checkA();
  checkB();
  delay(50);
  int r = analogRead(chargePin);
  //charge = analogRead(chargePin);
  charge = r * 3.8/1023.0;
  Wire.beginTransmission(DISPLAY_ADDRESS);

  Wire.write('|');
  Wire.write('-');
  Wire.print("Battery Percentage: ");
  Wire.println("");
  if(charge >= 3.8){
    Wire.print("100%");  
  }
  else if(charge < 3.8 && charge >= 3.7){
    Wire.print("90%");  
  }
  else if(charge < 3.7 && charge >= 3.6){
    Wire.print("80%");  
  }
  else if(charge < 3.6 && charge >= 3.58){
    Wire.print("70%");  
  }
  else if(charge < 3.58 && charge >= 3.55){
    Wire.print("60%");  
  }
  else if(charge < 3.55 && charge >= 3.52){
    Wire.print("50%");  
  }
  else if(charge < 3.52 && charge >= 3.51){
    Wire.print("40%");  
  }
  else if(charge < 3.51 && charge >= 3.48){
    Wire.print("30%");  
  }
  else if(charge < 3.48 && charge >= 3.4){
    Wire.print("20%");  
  }
  else if(charge < 3.4){
    Wire.println("10%"); 
    Wire.println("LOW BATTERY!"); 
  }
  Wire.endTransmission();
}

void checkA() {
  cardID = String("");
  MFRC522 mfrc522a = mfrc522[0];
  if ( ! mfrc522a.PICC_IsNewCardPresent() || val0 < stopVal0) {
    return;
  }

  // Select one of the cards
  if ( ! mfrc522a.PICC_ReadCardSerial() || val0 < stopVal0) {
    return;
  }

  // Dump debug info about the card; PICC_HaltA() is automatically called
  for(int i = 0 ; i < mfrc522a.uid.size; i++){
    //Serial.print(mfrc522a.uid.uidByte[i] < 0x10 ? " 0" : " ");
    //Serial.print(mfrc522a.uid.uidByte[i], HEX);
    cardID = cardID + mfrc522a.uid.uidByte[i] + " ";
  }
  //Serial.println(cardID);
  cardID = cardID + "1";
  Serial.println(cardID);
  mfrc522[0].PICC_HaltA();
  mfrc522[0].PCD_StopCrypto1();
}

void checkB() {
  cardID = String("");
  MFRC522 mfrc522b = mfrc522[1];
  if ( ! mfrc522b.PICC_IsNewCardPresent() || val1 < stopVal1) {
    return;
  }

  // Select one of the cards
  if ( ! mfrc522b.PICC_ReadCardSerial() || val1 < stopVal1) {
    return;
  }

  // Dump debug info about the card; PICC_HaltA() is automatically called
  for(int i = 0 ; i < mfrc522b.uid.size; i++){
    //Serial.print(mfrc522b.uid.uidByte[i] < 0x10 ? " 0" : " ");
    //Serial.print(mfrc522b.uid.uidByte[i], HEX);
    cardID = cardID + mfrc522b.uid.uidByte[i] + " ";
  }
  cardID = cardID + "2";
  Serial.println(cardID);
  mfrc522[1].PICC_HaltA();
  mfrc522[1].PCD_StopCrypto1();
}

void i2cSendValue(double charge){
  
  Wire.beginTransmission(DISPLAY_ADDRESS);

  Wire.write('|');
  Wire.write('-');
  Wire.print("Battery Percentage: ");
  Wire.println("");
  if(charge >= 3.8){
    Wire.print("100%");  
  }
  else if(charge < 3.8 && charge >= 3.7){
    Wire.print("90%");  
  }
  else if(charge < 3.7 && charge >= 3.6){
    Wire.print("80%");  
  }
  else if(charge < 3.6 && charge >= 3.58){
    Wire.print("70%");  
  }
  else if(charge < 3.58 && charge >= 3.55){
    Wire.print("60%");  
  }
  else if(charge < 3.55 && charge >= 3.52){
    Wire.print("50%");  
  }
  else if(charge < 3.52 && charge >= 3.51){
    Wire.print("40%");  
  }
  else if(charge < 3.51 && charge >= 3.48){
    Wire.print("30%");  
  }
  else if(charge < 3.48 && charge >= 3.4){
    Wire.print("20%");  
  }
  else if(charge < 3.4){
    Wire.println("10%"); 
    Wire.println("LOW BATTERY!"); 
  }
  Wire.endTransmission();
  
}
