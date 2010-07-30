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
	import flash.net.Socket;
	
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
		private static const TRIP_THRESHHOLD:String = "tt";
		
		//ping from arduino that to determine if it is connected
		private static const ARDUINO_PING:String = "p";
		
		//light sensor change threshold : packet type (outgoing)
		//specifies how much light sensor value has to change before
		//new value is sent from hardware
		private static const CHANGE_THRESHHOLD:String = "ct";
		
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
				this.send(createPacket(CHANGE_THRESHHOLD, _changeThreshhold));
				_changeThreshholdSent = true;
			}
		}
		
		//change necessary to trigger light trip trigger
		//specified in percent (1 - 100)
		public function set tripThreshhold(value:uint):void
		{
			_tripThreshhold = value;
			
			if(_socket.connected)
			{
				this.send(createPacket(TRIP_THRESHHOLD, _tripThreshhold));
				_tripThreshholdSent = true;
			}
		}		
		
		public function connect( host:String = null, port:int = 0 ):void
		{			
			this.host = host;
			this.port = port;			
			
			if((!_host) || (!_port))
			{
				throw new ArgumentError("Host and port must be specified.")
			}
			
			_socket.connect( _host, _port );
			trace( "connecting" );
		}
		
		public function send( value:String ):void
		{			
			_socket.writeUTFBytes( value );
			_socket.flush();
		}
		
		
		private function onClose( event:Event ):void
		{
			trace( "onClose" );
			dispatchEvent( event.clone() );
		}
		
		private function onConnect( event:Event ):void
		{
			trace( "onConnect" );
			
			this.send(createPacket(ARDUINO_PING, null));
			
			if(_tripThreshhold && (!_tripThreshholdSent))
			{
				//send packet
				this.send(createPacket(TRIP_THRESHHOLD, _tripThreshhold));
			}
			
			if(_changeThreshhold && (!_changeThreshholdSent))
			{
				//send packet
				this.send(createPacket(CHANGE_THRESHHOLD, _changeThreshhold));
			}
			
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
			
			//todo: Need to ensure we have received entire packet (ends in \n)
			//do we need to strip of the trailing \n?
			var packet:Array = data.split(PACKET_DELIMETER);
			
			var messageType:String = packet[0];
			
			//packet : eventType \t [sensor] \t additionalData
			
			var out:AccelerateDataEvent;
			switch(messageType)
			{
				case ARDUINO_PING:
				{
					out = new AccelerateDataEvent(AccelerateDataEvent.ARDUINO_CONNECT);
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
			
			dispatchEvent(out);
		}
		
	}
}