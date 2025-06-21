#include "config.h"
#include "graphical_data.h"
#include <TFT_eSPI.h>  // Hardware-specific library
#include <SPI.h>
#include <hardware/gpio.h>
#include <Adafruit_NeoPixel.h>
TFT_eSPI tft = TFT_eSPI();            // Invoke custom library
TFT_eSprite img = TFT_eSprite(&tft);  // Create Sprite object "img" with pointer to "tft" object

void setup(void) {
  //Set up the display
  Adafruit_NeoPixel pixels(NUMPIXELS, LED_STATUS_PIN, NEO_RGB);
  uint8_t intensity = 60;                                 //WS2812 intensity 255 is a death ray, 10 to 15 is normal
  uint32_t WS2812_Color = pixels.Color(0, intensity, 0);  //RGB triplet, default is green
  pixels.setPixelColor(0, WS2812_Color);
  pixels.show();  // Send the updated pixel colors to the hardware.
  delay(1000);
  pixels.clear();  // Set all pixel colors to 'off'
  pixels.show();   // Send the updated pixel colors to the hardware.
  //Set up the display
  tft.init();
  tft.setTextSize(2);
  img.setColorDepth(BITS_PER_PIXEL);  // Set colour depth first
  tft.setRotation(2);
  tft.fillScreen(TFT_BLACK);
  img.createSprite(image_width, image_height);  // then create the giant sprite that will be an image of our video ram buffer
  img.fillScreen(TFT_RED);
  img.pushSprite(0, y_ori);  //dump image to display
  //Serial.begin(115200);
  gpio_init(BTN_PUSH);  // Configure BTN_PUSH as input
  gpio_set_dir(BTN_PUSH, GPIO_IN);
  gpio_init(TFT_BL);  // configure BL as output, allows deactivating it via software in the future
  gpio_set_dir(TFT_BL, GPIO_OUT);
  gpio_put(TFT_BL, 1);
  image_random = random(images);
  load_palette(palette_index);
}  // setup()

/////////////Specific to TinyGB Printer//////////////

void loop()  //core 1 loop deals with images, written by Raphaël BOICHOT, november 2024
{
  if (gpio_get(BTN_PUSH)) {
    palette_index++;
    if (palette_index >= palette_number) {
      palette_index = 0;
    }
    load_palette(palette_index);
    dump_image_to_display(image_random);
    delay(debounceDelay);
  }
  currentMillis = millis();
  if (currentMillis - previousMillis >= slide_show_delay) {
    previousMillis = currentMillis;
    image_random = random(images);
    dump_image_to_display(image_random);
  }
}

void dump_image_to_display(int image_random) {
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
          pixel_DATA_buffer[offset_x + posx] = (bit_msb << 1) | bit_lsb;//storing pixel level 0(white)..3(dark)
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
}

void load_palette(int indice) {
  for (int i = 0; i < 4; i++) {  //load palette
    lookup_TFT_RGB565[i] = palette_storage[i + indice * 4];
  }
}