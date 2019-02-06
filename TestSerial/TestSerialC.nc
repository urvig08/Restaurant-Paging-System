#include "Timer.h"
#include "TestSerial.h"
#include "BlinkToRadio.h"

module TestSerialC {
  uses {
    interface SplitControl as Control;
    interface Leds;
    interface Boot;
    interface Timer<TMilli> as Timer0;
    interface Packet;
    interface AMPacket;
    interface AMSend;
    interface SplitControl as AMControl;
   interface Receive;
  }

implementation {

  message_t packet;
  bool locked = FALSE;
  uint16_t counter = 0, value;
  bool busy = FALSE;
  message_t pkt;
  
//Call the start of the Radio and the UART upon boot up
  event void Boot.booted() {
    call AMControl.start();
    call Control.start();
  }
  
//Start the Radio
  event void AMControl.startDone(error_t err) {
  }  

//Start the UART
  event void Control.startDone(error_t err) {
  }

//The receive event that will get triggered whne its receives a message from the Base Station and turn on the LEDs that 
//correspond to the last three bits of the Node ID received from Base Station. 

  event message_t* Receive.receive(message_t* bufPtr, 
				   void* payload, uint8_t len) {

      test_serial_msg_t* rcm = (test_serial_msg_t*)payload;
      if (rcm->counter & 0x1) {
	call Leds.led0On();
      }
      else {
	call Leds.led0Off();
      }
      if (rcm->counter & 0x2) {
	call Leds.led1On();
      }
      else {
	call Leds.led1Off();
      }
      if (rcm->counter & 0x4) {
	call Leds.led2On();
      }
      else {
	call Leds.led2Off();
      }
      value = rcm->counter;
      call Timer0.startOneShot(1000);  //call the timer 0 to start the sending process

      return bufPtr;
  }

//Event that gets fired after 1 second and starts the sending process
event void Timer0.fired() { 
    BlinkToRadioMsg* btrpkt = (BlinkToRadioMsg*)(call Packet.getPayload(&pkt, sizeof (BlinkToRadioMsg)));
    btrpkt->nodeid = TOS_NODE_ID;
    btrpkt->counter1 = value;
    call AMSend.send(AM_BROADCAST_ADDR, &pkt, sizeof(BlinkToRadioMsg));
    } 


//After the data has been sent, all the LED's should turn OFF. 
  event void AMSend.sendDone(message_t* msg, error_t error) {
     
     call Leds.led0Off();
     call Leds.led1Off();
     call Leds.led2Off(); 

  }

//Stop the Radio
  event void AMControl.stopDone(error_t err) {
  }


//Stop the UART
  event void Control.stopDone(error_t err) {
  }


}




