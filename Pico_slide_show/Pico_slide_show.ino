#include "config.h"
#include "graphical_data.h"
#include <TFT_eSPI.h>  // Hardware-specific library
#include <SPI.h>
TFT_eSPI tft = TFT_eSPI();            // Invoke custom library
TFT_eSprite img = TFT_eSprite(&tft);  // Create Sprite object "img" with pointer to "tft" object

void setup(void) {
  //Set up the display
  tft.init();
  tft.setTextSize(2);
  img.setColorDepth(BITS_PER_PIXEL);  // Set colour depth first
  tft.setRotation(3);
  tft.fillScreen(TFT_BLACK);
  img.createSprite(image_width, image_height);  // then create the giant sprite that will be an image of our video ram buffer
  img.fillScreen(TFT_RED);
  img.pushSprite(0, y_ori);  //dump image to display
  //Serial.begin(115200);
}  // setup()

/////////////Specific to TinyGB Printer//////////////

void loop()  //core 1 loop deals with images, written by Raphaël BOICHOT, november 2024
{
  image_random = getRandom(images);
  //Serial.println(image_random,DEC);
  graphical_DATA_offset = image_random * tile_packet_size;  //starting offset to get tile data

  for (int i = 0; i < tile_packet_size; i++) {
    tile_DATA_buffer[i] = graphical_DATA[i + graphical_DATA_offset];
  }
  max_tile_line = image_height / 8;
  max_tile_column = image_width / 8;
  IMAGE_bytes_counter = 0;
  pixel_line = 0;
  offset_x = 0;

  for (int tile_line = 0; tile_line < max_tile_line; tile_line++) {              //this part fills 8 lines of pixels
    IMAGE_bytes_counter = 16 * max_tile_column * tile_line;                      //a tile is 16 bytes, a line screen is 20 tiles (160 pixels width)
    for (int i = 0; i < 8; i++) {                                                // This part fills a line of pixels
      offset_x = pixel_line * image_width;                                       //x stands for the position in the image vector containing compressed data
      for (int tile_column = 0; tile_column < max_tile_column; tile_column++) {  //we progress along 20 column tiles
        local_byte_LSB = tile_DATA_buffer[IMAGE_bytes_counter];                  //here we get data for a line of 8 pixels (2 bytes)
        local_byte_MSB = tile_DATA_buffer[IMAGE_bytes_counter + 1];              //here we get data for a line of 8 pixels
        for (int posx = 0; posx < 8; posx++) {
          pixel_level = bitRead(local_byte_LSB, 7 - posx) + 2 * bitRead(local_byte_MSB, 7 - posx);  //here we get pixel value along 8 pixels horizontally
          pixel_DATA_buffer[offset_x + posx] = image_palette[pixel_level];   //here we store 4 2bbp pixels per byte for next step (2bpp indexed png upscaler)
        }                                                                    //this is a bit aggressive as pixel decoder and PNG compression is within the same line of code, but efficient
        IMAGE_bytes_counter = IMAGE_bytes_counter + 16;                      //jumps to the next tile in byte
        offset_x = offset_x + 8;                                             //jumps to the next tile in pixels
      }                                                                      //This part fills a line of pixels
      IMAGE_bytes_counter = IMAGE_bytes_counter - 16 * max_tile_column + 2;  //shifts to the next two bytes among 16 per tile, so the next line of pixels in a tile
      pixel_line = pixel_line + 1;                                           //jumps to the next line
    }                                                                        //This part fills 8 lines of pixels
  }                                                                          //this part fills the entire image

  for (int x = 0; x < image_width; x++) {
    for (int y = 0; y < image_height; y++) {
      img.drawPixel(x, y, lookup_TFT_RGB565[pixel_DATA_buffer[x + y * image_width]]);
    }
  }
  img.pushSprite(0, y_ori);  //dump image to display
  delay(slide_show_delay);
}  // loop1()
/////////////Specific to TinyGB Printer//////////////

int getRandom(int X) {
  if (X <= 0) {
    return 0;  // Return 0 if invalid input
  }
  return random(X);  // random(X) returns a value from 0 to X-1
}
