#include "TestSerial.h"

configuration TestSerialAppC {}
implementation {
  components TestSerialC as App, LedsC, MainC;
  components SerialActiveMessageC as AM;
  components new AMSenderC(AM_BLINKTORADIO);
  components new AMReceiverC(AM_BLINKTORADIO);
  components new TimerMilliC() as Timer0;
  components ActiveMessageC;

  App.Boot -> MainC.Boot;
  App.Control -> AM;
  App.Receive -> AM.Receive[AM_TEST_SERIAL_MSG];
  App.AMSend -> AM.AMSend[AM_TEST_SERIAL_MSG];
  App.Leds -> LedsC;
  App.Timer0 -> Timer0;
  App.Packet -> AMSenderC;
  App.AMPacket -> AMSenderC;
  App.AMSend -> AMSenderC;
  App.AMControl -> ActiveMessageC;
}


