//light sensor 1 : used in packets
#define LIGHT_SENSOR_1 "ls1"

//light sensor 2 : used in packets
#define LIGHT_SENSOR_2 "ls2"

//light sensor tripped : packet type (incoming)
#define LIGHT_SENSOR_TRIP "lst"

//light sensor value updated : packet type (incoming)
#define LIGHT_SENSOR_UPDATE "lsu"

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
int tripThreshhold = 75;
int changeThreshhold = 100;

void setup()
{
	//todo: try larger values
	Serial.begin(57600);
}

void loop()
{

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
				tripThreshhold = packetData;

 Serial.println(tripThreshhold, DEC);
 Serial.print(0, BYTE);
				break;
			}
			case CHANGE_THRESHHOLD:
			{
  Serial.println(changeThreshhold, DEC);
 Serial.print(0, BYTE);
				changeThreshhold = packetData;
				break;
			}
			case ARDUINO_PING_INCOMING:
			{
				Serial.print(ARDUINO_PING_OUTGOING);
				Serial.print( 0, BYTE );
				break;
			}
		}
	}
}
