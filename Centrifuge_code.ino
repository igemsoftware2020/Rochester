
#include <Keypad.h>
const int ROW_NUM = 4; //four rows
const int COLUMN_NUM = 4; //four columns

char keys[ROW_NUM][COLUMN_NUM] = {
  {'1','2','3', 'A'},
  {'4','5','6', 'B'},
  {'7','8','9', 'C'},
  {'*','0','#', 'D'}
};

byte pin_rows[ROW_NUM] = {9, 8, 7, 6}; //connect to the row pinouts of the keypad
byte pin_column[COLUMN_NUM] = {5, 4, 3, 2}; //connect to the column pinouts of the keypad

Keypad keypad = Keypad( makeKeymap(keys), pin_rows, pin_column, ROW_NUM, COLUMN_NUM );
#include<Servo.h>
Servo esc;
String inputString;
long inputInt;

#include <LiquidCrystal.h>
int rs=34;
int en=36;
int d4=38;
int d5=40;
int d6=42;
int d7=44;
LiquidCrystal lcd(rs,en,d4,d5,d6,d7);

void setup() {
  Serial.begin(9600);
  inputString.reserve(10); // maximum number of digit for a number is 10, change if needed
  esc.attach(23);
  esc.writeMicroseconds(1000);
  lcd.begin(16,2);
}

void loop() {
  
  char key = keypad.getKey();

  if (key) {
    Serial.println(key);

    if (key >= '0' && key <= '9') {     // only act on numeric keys
      inputString += key;               // append new character to input string
    } else if (key == '#') {
      if (inputString.length() > 0) {
        inputInt = inputString.toInt(); // YOU GOT AN INTEGER NUMBER
        inputString = "";               // clear input
        // DO YOUR WORK HERE
        Serial.println(inputInt);

        int val;
        
        val=map(inputInt, 0, 1023, 0, 7000);
        esc.writeMicroseconds(val);
        Serial.println(val);

        lcd.setCursor(0,0);
        lcd.print("Speed: ");
        lcd.setCursor(7,0);
        lcd.print(inputInt);
        lcd.print(" RPM");
        delay(10000);
        lcd.clear();
        

      }
    } else if (key == '*') {
      inputString = "";                 // clear input 
    }  
  }
  
  
  
}
