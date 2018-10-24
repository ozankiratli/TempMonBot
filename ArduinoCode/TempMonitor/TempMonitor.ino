//#include <dht.h>
#include<DHT.h>
#include <TimeLib.h>
#include <UIPEthernet.h> // Used for Ethernet

//#define DHTTYPE DHT11   // DHT 11 
#define DHTTYPE DHT22     // DHT 22  (AM2302)
//#define DHTTYPE DHT21     // DHT 21 (AM2301)

#define DHT_PIN       3     // Pin for DHT11 Temperature Humidity sensor 

DHT dht(DHT_PIN, DHTTYPE); 

#define R_int         2     // Refresh interval (IN SECONDS at least 25535 - otherwise dht fails)
#define S_int         30    // Sensor data record interval (IN SECONDS)
#define W_int         30    // Writing average and refreshing (IN MINUTES)

// Ethernet IP, default gateway and MAC addresses
// IP and MAC should be different for each unit
static byte mac[] = { 0xE4,0x69,0xF9,0x2D,0x30,0x01 };
IPAddress ip(192, 168, 69 , 101);

//IPAddress dnServer(192,222,69,1);
//IPAddress gateway(192,222,69,1);
//IPAddress subnet(255,255,255,0);             
EthernetServer server(80);

IPAddress timeServer(192, 168, 69, 1);

//const int timeZone = 1;     // Central European Time
const int timeZone = -5;  // Eastern Standard Time (USA)
//const int timeZone = -4;  // Eastern Daylight Time (USA)
//const int timeZone = -8;  // Pacific Standard Time (USA)
//const int timeZone = -7;  // Pacific Daylight Time (USA)

unsigned int localPort = 8888;  // local port to listen for UDP packets


//dht DHT;
EthernetUDP Udp;

float t=0;
float total_temp=0.0;  
float avg_temp=0.0;
float h=0.0;
float total_hum=0.0;
float avg_hum=0.0;
int dhtct=0;



int sm =0;
int smct=0;


void setup() {
  Ethernet.begin(mac,ip);
  server.begin();
  Udp.begin(localPort);
  setSyncProvider(getNtpTime);
  setSyncInterval(3600);
  dht.begin();
}


time_t prevDisplay = 0; // when the digital clock was displayed

void loop() {         

  if (timeStatus() != timeNotSet) {
    if (now() != prevDisplay) {
      prevDisplay=now();
      //Serial.println(now());

      if((second()%R_int)==0){
        //DHT.read21(DHT_PIN);      
        //t=DHT.temperature;
        //h=DHT.humidity;
        t=dht.readTemperature();
        h=dht.readHumidity();
      }
      if((second()%(S_int))==0){
        if(t>-100 && h>-1){
          total_temp+=t;
          total_hum+=h;
          dhtct++;
          }  
          smct++;
        }

      if((minute()%(W_int))==0 && (second()%60)==0){
        
        avg_temp=total_temp/(float)dhtct;
        avg_hum=total_hum/(float)dhtct;
               
        total_temp=0;
        total_hum=0;
        dhtct=0;
        }
     }
  }

  
// listen for incoming clients
  EthernetClient client = server.available();

  if (client) 
  {  
    boolean currentLineIsBlank = true;

    while (client.connected()) 
    {
      if (client.available()) 
      {
        char c = client.read();

        // if you've gotten to the end of the line (received a newline
        // character) and the line is blank, the http request has ended,
        // so you can send a reply
        if (c == '\n' && currentLineIsBlank) 
        {
            client.println("<html>");
            client.print("<body> Date (MDY): ");
            client.print(year());
            client.print("/");
            client.print(month());
            client.print("/");
            client.print(day());
            client.println(" </body>");
            client.println("<p />");
            client.print("<body> Time: ");
            client.print(hour());
            client.print(":");
            client.print(minute());
            client.print(":");
            client.print(second());
            client.println(" </body>");
            client.println("<p />");
            client.print("<body> Real Time Temp: ");
            client.print(t);
            client.println(" &#176;C </body>");
            client.println("<p />");
            client.print("<body> Avg. Temp: ");
            client.print(avg_temp);
            client.println(" &#176;C </body>");
            client.println("<p />");
            client.print("<body> Real Time Hum: ");
            client.print(h);
            client.println(" %\t </body>");
            client.println("<p />");
            client.print("<body> Avg. Hum: ");
            client.print(avg_hum);
            client.println(" %\t </body>");
            client.println("<p />");
            client.println("</html>");
          break;
        }

        if (c == '\n') {
          // you're starting a new line
          currentLineIsBlank = true;
        }
        else if (c != '\r') 
        {
          // you've gotten a character on the current line
          currentLineIsBlank = false;
        }
      } 
    }
    // give the web browser time to receive the data
    delay(10);
    // close the connection:
    client.stop();
  
  }
}

const int NTP_PACKET_SIZE = 48; // NTP time is in the first 48 bytes of message
byte packetBuffer[NTP_PACKET_SIZE]; //buffer to hold incoming & outgoing packets

time_t getNtpTime()
{
  while (Udp.parsePacket() > 0) ; // discard any previously received packets
  
  sendNTPpacket(timeServer);
  uint32_t beginWait = millis();
  while (millis() - beginWait < 1500) {
    int size = Udp.parsePacket();
    if (size >= NTP_PACKET_SIZE) {
      //Serial.println("Receive NTP Response");
      Udp.read(packetBuffer, NTP_PACKET_SIZE);  // read packet into the buffer
      unsigned long secsSince1900;
      // convert four bytes starting at location 40 to a long integer
      secsSince1900 =  (unsigned long)packetBuffer[40] << 24;
      secsSince1900 |= (unsigned long)packetBuffer[41] << 16;
      secsSince1900 |= (unsigned long)packetBuffer[42] << 8;
      secsSince1900 |= (unsigned long)packetBuffer[43];
      return secsSince1900 - 2208988800UL + timeZone * SECS_PER_HOUR;
    }
  }
  
  return 0; // return 0 if unable to get the time
}

// send an NTP request to the time server at the given address
void sendNTPpacket(IPAddress &address)
{
  // set all bytes in the buffer to 0
  memset(packetBuffer, 0, NTP_PACKET_SIZE);
  // Initialize values needed to form NTP request
  // (see URL above for details on the packets)
  packetBuffer[0] = 0b11100011;   // LI, Version, Mode
  packetBuffer[1] = 0;     // Stratum, or type of clock
  packetBuffer[2] = 6;     // Polling Interval
  packetBuffer[3] = 0xEC;  // Peer Clock Precision
  // 8 bytes of zero for Root Delay & Root Dispersion
  packetBuffer[12]  = 49;
  packetBuffer[13]  = 0x4E;
  packetBuffer[14]  = 49;
  packetBuffer[15]  = 52;
  // all NTP fields have been given values, now
  // you can send a packet requesting a timestamp:                 
  Udp.beginPacket(address, 123); //NTP requests are to port 123
  Udp.write(packetBuffer, NTP_PACKET_SIZE);
  Udp.endPacket();
}

