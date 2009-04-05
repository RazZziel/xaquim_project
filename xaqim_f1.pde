//Definimos elementos de control para motores 1 e 2
#define M1_FRONT 7
#define M1_BACK 8
#define M2_FRONT 12
#define M2_BACK 13
#define M1_SPEED 10
#define M2_SPEED 11

#define SL1 0
#define SL2 1

#define M1 1
#define M2 2

#define UMBRAL_NEGRO 800
#define is_outside(n) (n > UMBRAL_NEGRO)

void motorSetup(){
  pinMode(M1_FRONT, OUTPUT);
  pinMode(M1_BACK, OUTPUT);
  pinMode(M2_FRONT, OUTPUT);
  pinMode(M2_BACK, OUTPUT);
}

//Establecemos movementos de 1 ou 2 motores
//Velocidades positivas cara adiante
//Velocidades negativas cara atrás
void motorControl(int motor, signed int speed){
  if (motor&M1){
    if(speed>0) {
      digitalWrite(M1_BACK,LOW);
      digitalWrite(M1_FRONT, HIGH);
    } else if (speed<0){
      digitalWrite(M1_BACK,HIGH);
      digitalWrite(M1_FRONT,LOW);
      speed=-speed;
    }
    analogWrite(M1_SPEED,speed);
  }
  if (motor&M2){
    if(speed>0) {
      digitalWrite(M2_BACK,LOW);
      digitalWrite(M2_FRONT, HIGH);
    } else if (speed<0){
      digitalWrite(M2_BACK,HIGH);
      digitalWrite(M2_FRONT,LOW);
      speed=-speed;
    }
    analogWrite(M2_SPEED,speed);
  }
}

void setup(){
  motorSetup();
  //Detener el motor
  motorControl(M1|M2,000);
  Serial.begin(9600);
}

int sensor0, sensor1, estado;
int signed turn = 0; // 1 = right; 0 = no ; -1 = left

//Establecemos un movemento ciclico
void loop(){
  //Moverse de fronte durante 2 segundos
  sensor0 = analogRead(SL1);
  sensor1 = analogRead(SL2);
  Serial.print("sensor0: ");
  Serial.print(sensor0);
  Serial.print("\n");
  Serial.print("sensor1: ");
  Serial.print(sensor1);
  Serial.print("\n");
  delay(10);
  if (is_outside(sensor0) && is_outside(sensor1))
  {
    if (turn == 0)
      turn = 1;
  }
  else if ( !is_outside(sensor0) )
  {
    turn = 1;
  }
  else if ( is_outside(sensor1) )
  {
    turn = -1;
  }
  else
  {
    turn = 0;
  }
  
  switch(turn){
    case 0:
      motorControl(M1|M2, 200);
      break;
    case 1:
      motorControl(M1, 200);
      motorControl(M2, 0);
      break;
    case -1:
      motorControl(M2, 200);
      motorControl(M1, 0);
      break;
      
  }
    
}
