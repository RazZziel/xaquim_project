//Definimos elementos de control para motores 1 e 2
#define M1_FRONT  7
#define M1_BACK   8
#define M2_FRONT  12
#define M2_BACK   13
#define M1_SPEED  10
#define M2_SPEED  11
#define LED_DBG1  2 /* Green */
#define LED_DBG2  3 /* Red */

#define SL1       0
#define SL2       1

#define M1        1
#define M2        2

#define SPEED_CRUISE   200
#define TURN_MAX       50
#define UMBRAL_NEGRO   800

#define is_outside(n)  (n > UMBRAL_NEGRO)

enum { TURN_RIGHT, TURN_LEFT, NO_TURN, TURN_RIGHT_BIT };


int sensor0, sensor1, turn_counter;
int signed turn = NO_TURN;
int faced = 0;

void motorSetup(){
  pinMode(M1_FRONT, OUTPUT);
  pinMode(M1_BACK,  OUTPUT);
  pinMode(M2_FRONT, OUTPUT);
  pinMode(M2_BACK,  OUTPUT);
  pinMode(LED_DBG1, OUTPUT);
  pinMode(LED_DBG2, OUTPUT);
}

//Establecemos movementos de 1 ou 2 motores
//Velocidades positivas cara adiante
//Velocidades negativas cara atrás
void motorControl(int motor, signed int speed){
  if (motor&M1){
    if(speed>0) {
      digitalWrite(M1_BACK,LOW);
      digitalWrite(M1_FRONT,HIGH);
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
      digitalWrite(M2_FRONT,HIGH);
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
  motorControl(M1|M2, 000);
  Serial.begin(9600);
}

void debug()
{
  //Serial.print("sensor0: "); Serial.print(sensor0); Serial.print("\n");
  //Serial.print("sensor1: "); Serial.print(sensor1); Serial.print("\n");
  Serial.print("fasced: "); Serial.print(faced); Serial.print("\n");
  //digitalWrite( LED_DBG1, (turn_counter == 0) ? HIGH : LOW );
  //digitalWrite( LED_DBG2, (turn_counter == TURN_MAX) ? HIGH : LOW );
  digitalWrite( LED_DBG1, is_outside(sensor0) ? HIGH : LOW );
  digitalWrite( LED_DBG2, is_outside(sensor1) ? HIGH : LOW );
}

//Establecemos un movemento ciclico
void loop(){
  //Moverse de fronte durante 2 segundos
  sensor0 = analogRead(SL1);
  sensor1 = analogRead(SL2);
  delay(10);
  
#if 0
  if ( (!is_outside(sensor0) && is_outside(sensor1)) || /* Inner edge */
       (turn_counter > TURN_MAX) )              /* Don't turn anymore */
  {
    turn = NO_TURN;
    turn_counter = 0;
  }
  else
  {          
    if ( is_outside(sensor0) )
      turn = TURN_LEFT;
    else /* In the middle or in the outer edge */
      turn = TURN_RIGHT;
    turn_counter++;
  }
#else
  if ( is_outside(sensor0) && is_outside(sensor1) )
  {
    turn = TURN_LEFT;
  }
  else if ( is_outside(sensor0) && !is_outside(sensor1) )
  {
    turn = TURN_LEFT;
  }
  else if ( !is_outside(sensor0) && is_outside(sensor1) )
  {
    turn = NO_TURN;
    faced = 1;
  }
  else /* if ( !is_outside(sensor0) && !is_outside(sensor1) ) */
  {
    if (faced == 0)
    {
      turn = TURN_RIGHT_BIT;
    }
    else
    {
      turn = TURN_RIGHT;
    }
  }
#endif

  switch(turn){
    case NO_TURN:
      motorControl(M1|M2, SPEED_CRUISE);
      break;
#if 0
    case TURN_RIGHT:
      motorControl(M1, SPEED_CRUISE);
      motorControl(M2, 0);
      break;
    case TURN_LEFT:
      motorControl(M1, 0);
      motorControl(M2, SPEED_CRUISE);
      break;
    case TURN_RIGHT_BIT:
      motorControl(M1, SPEED_CRUISE);
      motorControl(M2, SPEED_CRUISE*2/3);
      break;
#else
    case TURN_RIGHT:
      motorControl(M2, SPEED_CRUISE);
      motorControl(M1, 0);
      break;
    case TURN_LEFT:
      motorControl(M2, 0);
      motorControl(M1, SPEED_CRUISE);
      break;
    case TURN_RIGHT_BIT:
      motorControl(M2, SPEED_CRUISE);
      motorControl(M1, SPEED_CRUISE*2/3);
      break;  
#endif
  }
}
