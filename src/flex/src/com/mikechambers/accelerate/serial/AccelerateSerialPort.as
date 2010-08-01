// AS3 version of the SerialPort class
// originally written by Massimo Banzi @ Tinker.it based on
// code by Beltran Berrocal @ Progetto2501.it
//
// Ported to AS3 by Tink (Stephen Downs)
//
// Version 0.3 11.01.2007
//

//Update by Mike Chambers (7/29/2010)
//to fix issue where not passing in arguments to connect would cause
//socket error #1023

package com.mikechambers.accelerate.serial
{
	import com.mikechambers.accelerate.events.AccelerateDataEvent;
	
	import flash.events.DataEvent;
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.events.IOErrorEvent;
	import flash.events.ProgressEvent;
	import flash.events.SecurityErrorEvent;
	import flash.events.TimerEvent;
	import flash.net.Socket;
	import flash.utils.Timer;
	
	public class AccelerateSerialPort extends EventDispatcher
	{
		
		//light sensor 1 : used in packets
		public static const LIGHT_SENSOR_1:String = "ls1";
		
		//light sensor 2 : used in packets
		public static const LIGHT_SENSOR_2:String = "ls2";
		
		//light sensor tripped : packet type (incoming)
		private static const LIGHT_SENSOR_TRIP:String = "lst";
		
		//light sensor value updated : packet type (incoming)
		private static const LIGHT_SENSOR_UPDATE:String = "lsu";
		
		//light sensor trip threshold : packet type (outgoing)
		//specifies percent change in light value to detect trip
		private static const TRIP_THRESHHOLD:uint = 1;
		
		//ping from arduino that to determine if it is connected
		private static const ARDUINO_PING_OUTGOING:int = 3;
		
		//ping from arduino that to determine if it is connected
		private static const ARDUINO_PING_INCOMING:String = "p";
		
		//light sensor change threshold : packet type (outgoing)
		//specifies how much light sensor value has to change before
		//new value is sent from hardware
		private static const CHANGE_THRESHHOLD:uint = 2;
		
		//we figure out elapsed time in hardware so we dont have to worry
		//about results being skewed by latency
		//total elapsed time (in ms) between both lights tripping
		//packet type (incoming)
		private static const ELAPSED_TIME:String = "elt";
		
		//string delimter used to seperate values in packet
		private static const PACKET_DELIMETER:String = "\t";
		
		private var _host		: String;
		private var _port		: uint;
		private var _socket		: Socket;
		
		
		public function AccelerateSerialPort( host:String = null, port:int = 0 )
		{
			super();
			
			this.host = host;
			this.port = port;
			
			_socket = new Socket();
			_socket.addEventListener( Event.CLOSE, onClose );
			_socket.addEventListener( Event.CONNECT, onConnect );
			_socket.addEventListener( IOErrorEvent.IO_ERROR, onIOErrorEvent );
			_socket.addEventListener( SecurityErrorEvent.SECURITY_ERROR, onSecurityError );
			_socket.addEventListener( ProgressEvent.SOCKET_DATA, onSocketData );
		}
		
		public function dealloc():void
		{
			_socket.close();
			_socket.removeEventListener( Event.CLOSE, onClose );
			_socket.removeEventListener( Event.CONNECT, onConnect );
			_socket.removeEventListener( IOErrorEvent.IO_ERROR, onIOErrorEvent );
			_socket.removeEventListener( SecurityErrorEvent.SECURITY_ERROR, onSecurityError );
			_socket.removeEventListener( ProgressEvent.SOCKET_DATA, onSocketData );
			
			_socket = null;
		}
		
		public function getSensorValue(sensor:String):Number
		{
			//todo: impliment
			return 0;
		}
		
		public function reset():void
		{
			//todo: impliment
		}
		
		public function set host(value:String):void
		{
			if(value)
			{
				_host = value;
			}
		}
		
		public function get host():String
		{
			return _host;
		}
		
		public function set port(value:uint):void
		{
			if(value)
			{
				_port = value;
			}
		}
		
		public function get port():uint
		{
			return _port;
		}
		
		public function get connected():Boolean
		{
			return _socket.connected;
		}
		
		public function close():void
		{
			_socket.close();
		}
		
		private var _changeThreshhold:uint;
		private var _changeThreshholdSent:Boolean = false;
		
		private var _tripThreshhold:uint;
		private var _tripThreshholdSent:Boolean = false;
		
		//specified in milliseconds
		public function set changeThreshhold(value:uint):void
		{
			_changeThreshhold = value;
			
			if(_socket.connected)
			{
				sendChangeThreshhold();
			}
		}
		
		private function sendChangeThreshhold():void
		{
			_socket.writeByte(CHANGE_THRESHHOLD);
			_socket.writeByte(_changeThreshhold);
			_socket.flush();
			
			//this.send(createPacket(CHANGE_THRESHHOLD, _changeThreshhold));
			_changeThreshholdSent = true;
		}
		
		private function sendTripThreshhold():void
		{
			_socket.writeByte(TRIP_THRESHHOLD);
			_socket.writeByte(_tripThreshhold);
			_socket.flush();
			
			//this.send(createPacket(CHANGE_THRESHHOLD, _changeThreshhold));
			_tripThreshholdSent = true;
		}
		
		private function sendPing():void
		{
			_socket.writeByte(ARDUINO_PING_OUTGOING);
			_socket.flush();
		}
		
		//change necessary to trigger light trip trigger
		//specified in percent (1 - 100)
		public function set tripThreshhold(value:uint):void
		{
			_tripThreshhold = value;
			
			if(_socket.connected)
			{
				sendTripThreshhold();
			}
		}		
		
		public function connect( host:String = null, port:int = 0 ):void
		{			
			stopReconnectTimer();
			
			this.host = host;
			this.port = port;			
			
			if((!_host) || (!_port))
			{
				throw new ArgumentError("Host and port must be specified.")
			}
			
			_socket.connect( _host, _port );
		}
		
		public function send( value:String ):void
		{			
			_socket.writeUTFBytes( value );
			_socket.flush();
		}
		
		
		private function onClose( event:Event ):void
		{
			trace( "onClose" );
			stopTimers();
			startReconnectTimer();
			arduinoConnected = false;
			dispatchEvent( event.clone() );
		}
		
		private var connectTimer:Timer;
		public static const PING_INTERVAL:uint = 3000;
		private var arduinoConnected:Boolean = false;
		
		private var arduinoPingTimer:Timer;
		
		private function onArduinoPingTimer(event:TimerEvent):void
		{
			arduinoPingTimer.stop();
			sendPing();
		}
		
		private function stopTimers():void
		{
			if(arduinoPingTimer)
			{
				arduinoPingTimer.stop();
			}
			
			if(connectTimer)
			{
				connectTimer.stop();
			}
		}
		
		private function startPingTimer():void
		{
			if(!arduinoPingTimer)
			{
				arduinoPingTimer = new Timer(PING_INTERVAL);
				arduinoPingTimer.addEventListener(TimerEvent.TIMER, onArduinoPingTimer);
			}
			
			arduinoPingTimer.start();
		}
		
		private var reconnectTimer:Timer;
		private static const RECONNECT_INTERVAL:uint = 5000;
		private function onReconnectTimer(event:TimerEvent):void
		{
			trace("onReconnectTimer");
			stopReconnectTimer();
			connect();
		}
		
		private function startReconnectTimer():void
		{
			if(!reconnectTimer)
			{
				reconnectTimer = new Timer(RECONNECT_INTERVAL);
				reconnectTimer.addEventListener(TimerEvent.TIMER, onReconnectTimer);
			}
			
			reconnectTimer.start();
		}
		
		private function stopReconnectTimer():void
		{
			if(reconnectTimer)
			{
				reconnectTimer.stop();
			}
		}
		
		private function onConnectTimer(event:TimerEvent):void
		{
			trace("onConnectDelayTimer");
			connectTimer.stop();
			
			sendPing();

			if(_tripThreshhold && (!_tripThreshholdSent))
			{
			//send packet
			sendTripThreshhold();
			}
			
			if(_changeThreshhold && (!_changeThreshholdSent))
			{
				//send packet
				//this.send(createPacket(CHANGE_THRESHHOLD, _changeThreshhold));
				sendChangeThreshhold();
			}
		}
		
		private function onConnect( event:Event ):void
		{
			trace( "onConnect" );
			
			if(reconnectTimer)
			{
				reconnectTimer.stop();
			}
			
			if(!connectTimer)
			{
				connectTimer = new Timer(PING_INTERVAL);
				connectTimer.addEventListener(TimerEvent.TIMER, onConnectTimer);
			}
			
			connectTimer.start();
			

			
			dispatchEvent( event.clone() );
		}
		
		private function createPacket(type:String, value:*):String
		{
			if(value == null)
			{
				return type;
			}
			
			//todo : do we need EOL / \n
			
			return type + PACKET_DELIMETER + String(value);
		}
		
		private function onIOErrorEvent( event:IOErrorEvent ):void
		{
			trace( "onIOErrorEvent" );
			dispatchEvent( event.clone() );
		}
		
		private function onSecurityError( event:SecurityErrorEvent ):void
		{
			trace( "onSecurityError" );
			dispatchEvent( event.clone() );
		}
		
		private function onSocketData( event:ProgressEvent ):void
		{
			var data:String = _socket.readUTFBytes( _socket.bytesAvailable );
			
			trace("onSocketData : " + data);
			
			//todo: Need to ensure we have received entire packet (ends in \n)
			//do we need to strip of the trailing \n?
			var packet:Array = data.split(PACKET_DELIMETER);
			
			var messageType:String = packet[0];
			
			//packet : eventType \t [sensor] \t additionalData
			
			var out:AccelerateDataEvent;
			switch(messageType)
			{
				case ARDUINO_PING_INCOMING:
				{	
					if(!arduinoConnected)
					{
						out = new AccelerateDataEvent(AccelerateDataEvent.ARDUINO_ATTACH);
						arduinoConnected = true;
					}
					
					startPingTimer();
					break;
				}
				case LIGHT_SENSOR_TRIP:
				{
					//packet: LIGHT_SENSOR_TRIP\tLIGHT_SENSOR_1
					
					out = new AccelerateDataEvent(AccelerateDataEvent.LIGHT_SENSOR_TRIP);
					
					//figure out which sensor was tripped, and make sure we
					//recognize the sensor
					switch(packet[1])
					{
						case LIGHT_SENSOR_1:
						{
							
							out.sensor = LIGHT_SENSOR_1;
							break;
						}
						case LIGHT_SENSOR_2:
						{
							out.sensor = LIGHT_SENSOR_2;
							break;
						}
						default:
						{
							trace("AccelerateSerialPort.onSocketData : Unrecognized sensor : " + packet[1] + " : " + data);
						}
					}
					
					break;
				}
				case LIGHT_SENSOR_UPDATE:
				{
					//packet: LIGHT_SENSOR_UPDATE\tLIGHT_SENSOR_1\tVALUE
					
					out = new AccelerateDataEvent(AccelerateDataEvent.LIGHT_SENSOR_UPDATE);
					
					//figure out which sensor was tripped, and make sure we
					//recognize the sensor
					switch(packet[1])
					{
						case LIGHT_SENSOR_1:
						{
							out.sensor = LIGHT_SENSOR_1;
							break;
						}
						case LIGHT_SENSOR_2:
						{
							out.sensor = LIGHT_SENSOR_2;
							break;
						}
						default:
						{
							trace("AccelerateSerialPort.onSocketData : Unrecognized sensor : " + packet[1] + " : " + data);
						}
					}
					
					out.value = packet[2];
					
					break;
				}
				case ELAPSED_TIME:
				{
					//packet: ELAPSED_TIME\tTOTAL_ELAPSED_TIME
					
					out = new AccelerateDataEvent(AccelerateDataEvent.TOTAL_TIME);
					out.totalElapsedTime = packet[1];
					break;
				}
				default :
				{
					trace("AccelerateSerialPort.onSocketData : Unrecognized packet : " + data);
					
					//dont recognize packet. return
					return;
				}
			}
			
			if(out)
			{
				dispatchEvent(out);
			}
		}
		
	}
}