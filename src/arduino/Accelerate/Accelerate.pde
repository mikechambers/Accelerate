
#define LIGHT_SENSOR_1_PIN 0

//light sensor 1 : used in packets
#define LIGHT_SENSOR_1 "ls1"

//light sensor 2 : used in packets
#define LIGHT_SENSOR_2 "ls2"

//light sensor tripped : packet type (incoming)
#define LIGHT_SENSOR_TRIP "lst"

//light sensor value updated : packet type (incoming)
#define LIGHT_SENSOR_UPDATE "lsu"

#define DEBUG_OUTGOING "deb"

//light sensor trip threshold : packet type (outgoing)
//specifies percent change in light value to detect trip
#define TRIP_THRESHHOLD 1


#define ARDUINO_PING_INCOMING 3

#define ARDUINO_PING_OUTGOING "p"


//light sensor change threshold : packet type (outgoing)
//specifies how much light sensor value has to change before
//new value is sent from hardware
#define CHANGE_THRESHHOLD 2

//we figure out elapsed time in hardware so we dont have to worry
//about results being skewed by latency
//total elapsed time (in ms) between both lights tripping
//packet type (incoming)
#define ELAPSED_TIME "elt"

//string delimter used to seperate values in packet
#define PACKET_DELIMETER "\t"

#define PACKET_EOL "\n"


//union that we will use
//the construct the int
//from the individual bytes
//sent from Flash / ActionScript
//we reuse this for all conversions
union u_tag
{
    byte b[2];
    int ival;
} u;

int packetType = 0;
int packetData = 0;
int tripThreshold = 75;
int changeThreshold = 100;

int lastLightSensor1Value = 0;
int lightSensor1Value = 0;
float change = 0;

void setup()
{
	//todo: try larger values
	Serial.begin(9600);
}

void loop()
{
        lightSensor1Value = analogRead(LIGHT_SENSOR_1_PIN);
        
        /*
        Serial.print(lightSensor1Value, DEC);
        Serial.print(":");
        Serial.print(abs(lightSensor1Value - lastLightSensor1Value));
        Serial.print(0, BYTE);
        */
        
        if(abs(lastLightSensor1Value - lightSensor1Value) >= changeThreshold)
        {
          Serial.print(LIGHT_SENSOR_UPDATE);
          Serial.print(PACKET_DELIMETER);
          Serial.print(LIGHT_SENSOR_1);
          Serial.print(PACKET_DELIMETER);
          Serial.print(lightSensor1Value);
          Serial.print(PACKET_EOL);
          //Serial.print(0, BYTE);
        }
        
        change = (abs(lastLightSensor1Value - lightSensor1Value) / lightSensor1Value) * 100;
	lastLightSensor1Value = lightSensor1Value;

        if(change > changeThreshold)
	{
	  //_lightSensor_1_triggered = true;
	  //_startTimeStamp = new Date().getTime();
	  //interfaceKit.setOutputState(SENSOR_1_OUTPUT_INDEX, true);
          //trace("HIT");
	}        
  
        //incoming packets are currently all
        //3 bytes
        // byte 1 : packet type
        // byte 2 and 3 : data (short / int)
	if(Serial.available() > 2)
	{
		
		packetType = Serial.read();

                u.b[0] = Serial.read();
                u.b[1] = Serial.read();

                packetData = u.ival;
		
		//Serial.println("incoming");
		//Serial.print( 0, BYTE );		
		
		switch(packetType)
		{
			case TRIP_THRESHHOLD:
			{
			  tripThreshold = packetData;

Serial.print(DEBUG_OUTGOING);
Serial.print(PACKET_DELIMETER);
Serial.print("Trip Threshold : ");
Serial.print(tripThreshold, DEC);
Serial.print(PACKET_EOL);
//Serial.print(0, BYTE);
			  break;
			}
			case CHANGE_THRESHHOLD:
			{
			  changeThreshold = packetData;

Serial.print(DEBUG_OUTGOING);
Serial.print(PACKET_DELIMETER);
Serial.print("Change Threshold : ");
Serial.print(changeThreshold, DEC);
Serial.print(PACKET_EOL);
//Serial.print(0, BYTE);
			  break;
			}
			case ARDUINO_PING_INCOMING:
			{
			  Serial.print(ARDUINO_PING_OUTGOING);
                          Serial.print("\n");
			  //Serial.print( 0, BYTE );
			  break;
			}
                        default:
                        {
                          Serial.print(DEBUG_OUTGOING);
                          Serial.print(PACKET_DELIMETER);
                          Serial.print("Arduino : Packet Type not recognized : ");
                          Serial.print(packetType, DEC);
                          Serial.print(PACKET_EOL);
                          //Serial.print(0, BYTE);
                        }
		}
	}

        delay(10);
}
