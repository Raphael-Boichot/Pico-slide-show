//Offset for the 240*240 ST7789 display
#define y_ori 8
#define TFT_BL 7
#define BTN_PUSH 13        // 8 in real, 13 just for testing with another board
#define LED_STATUS_PIN 16  // Internal LED is 16 on the RP2040zero
#define NUMPIXELS 1        // NeoPixel ring size (just internal LED here)
#define BITS_PER_PIXEL 16
#define image_width 128
#define image_height 112
#define tile_packet_size 16 * (image_width * image_height) / 64
byte tile_DATA_buffer[tile_packet_size];  //number of bytes in tile data, 1 tile is 16 bytes
byte pixel_DATA_buffer[image_width * image_height];
unsigned short int lookup_TFT_RGB565[4];  //Default palette
unsigned char palette_index = 0;
unsigned char palette_number = 4;
unsigned short int palette_storage[] = {
  //beware, palette is inverted compared to normal display in the Game Boy Format
  0xFFFF, 0x94B2, 0x31A6, 0x0000,  //default grayscale
  0xFFFF, 0x6FE5, 0x1BBA, 0x0000,  //GBC
  0x94C1, 0x4BE5, 0x2B08, 0x2080,  //DMG
  0xC614, 0x8C8D, 0x4A87, 0x1082   //GBP
};

//This array contains preformated pixels for 2bbp png mode, 4 pixels per bytes, assuming a 4x upscaling factor and so 4 consecutive pixels identical stored per bytes
//Game Boy data file are inverted contrary to modern display when recovered pixel by pixel: 3 is black and 0 is white
unsigned char local_byte_LSB = 0;        //storage byte for conversion
unsigned char local_byte_MSB = 0;        //storage byte for conversion
unsigned char pixel_level = 0;           //storage byte for conversion
unsigned int graphical_DATA_offset = 0;  //counter for data bytes
unsigned int image_random = 0;
unsigned int DATA_bytes_counter = 0;  //counter for data bytes
unsigned int pixel_line = 0;
unsigned int DATA_bytes_to_print = 0;  //counter for data bytes
unsigned int IMAGE_bytes_counter = 0;  //counter for data bytes
unsigned int offset_x = 0;             //local variable for decoder
unsigned int max_tile_line = 0;        //local variable for decoder
unsigned int max_tile_column = 0;      //local variable for decoder
unsigned int max_pixel_line = 0;       //local variable for decoder
unsigned long currentMillis = 0;
unsigned long previousMillis = 0;
const unsigned long debounceDelay = 200;  // 200 ms debounce time