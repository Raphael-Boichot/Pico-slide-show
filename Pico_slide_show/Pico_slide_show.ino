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
  image_random = random(images);
  //Serial.println(image_random,DEC);
  graphical_DATA_offset = image_random * tile_packet_size;  //starting offset to get tile data

  for (int i = 0; i < tile_packet_size; i++) {
    tile_DATA_buffer[i] = graphical_DATA[i + graphical_DATA_offset];
  }

  //this part of code takes 3584 bytes (16 bytes per tile) and turns it into a 128x112 image
  max_tile_line = image_height / 8;
  max_tile_column = image_width / 8;
  IMAGE_bytes_counter = 0;
  pixel_line = 0;
  offset_x = 0;

  for (int tile_line = 0; tile_line < max_tile_line; tile_line++) {
  IMAGE_bytes_counter = 16 * max_tile_column * tile_line;

  for (int i = 0; i < 8; i++) {
    offset_x = pixel_line * image_width;

    for (int tile_column = 0; tile_column < max_tile_column; tile_column++) {
      uint8_t local_byte_LSB = tile_DATA_buffer[IMAGE_bytes_counter];
      uint8_t local_byte_MSB = tile_DATA_buffer[IMAGE_bytes_counter + 1];

      for (int posx = 0; posx < 8; posx++) {
        uint8_t mask = 1 << (7 - posx);  // Create mask to isolate bit
        uint8_t bit_lsb = (local_byte_LSB & mask) ? 1 : 0;
        uint8_t bit_msb = (local_byte_MSB & mask) ? 1 : 0;
        uint8_t pixel_level = (bit_msb << 1) | bit_lsb;

        pixel_DATA_buffer[offset_x + posx] = image_palette[pixel_level];
      }

      IMAGE_bytes_counter += 16;  // Next tile in row
      offset_x += 8;
    }

    IMAGE_bytes_counter = IMAGE_bytes_counter - 16 * max_tile_column + 2;  // Next row in tiles
    pixel_line++;
  }
}

  for (int x = 0; x < image_width; x++) {
    for (int y = 0; y < image_height; y++) {
      img.drawPixel(x, y, lookup_TFT_RGB565[pixel_DATA_buffer[x + y * image_width]]);
    }
  }
  img.pushSprite(0, y_ori);  //dump image to display
  delay(slide_show_delay);
}