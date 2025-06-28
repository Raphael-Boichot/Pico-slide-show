#include "config.h"
#include "graphical_data.h"
#include <TFT_eSPI.h>  // Hardware-specific library
#include <SPI.h>
#include <hardware/gpio.h>
#include <hardware/adc.h>
TFT_eSPI tft = TFT_eSPI();            // Invoke custom library
TFT_eSprite img = TFT_eSprite(&tft);  // Create Sprite object "img" with pointer to "tft" object

void setup(void) {
  //Set up the display
  tft.init();
  tft.setTextSize(1);
  img.setColorDepth(BITS_PER_PIXEL);  // Set colour depth first
  tft.setRotation(3);
  tft.fillScreen(TFT_BLACK);
  delay(100);           //suppresses display jittering at init
  gpio_init(BTN_PUSH);  // Configure BTN_PUSH as input
  gpio_set_dir(BTN_PUSH, GPIO_IN);
  gpio_init(TFT_BL);  // configure BL as output, allows deactivating it via software in the future
  gpio_set_dir(TFT_BL, GPIO_OUT);
  gpio_put(TFT_BL, 1);  //BL switches the display ON, do not forget it !
  if (gpio_get(BTN_PUSH)) {
    debug_mode = 1;
  }
  Booting_animation();                          //it's not an animation anymore
  img.createSprite(image_width, image_height);  // then create the giant sprite that will be an image of our video ram buffer
  seed_rng_from_adc();                          // Get entropy from ADC
}  // setup()

/////////////Specific to TinyGB Printer//////////////

void loop()  //core 1 loop deals with images, written by Raphaël BOICHOT, november 2024
{

  currentMillis = millis();

  if (first_image) {  //dumps rapidely the first image
    load_palette(palette_index);
    pick_new_image();
    dump_image_to_display(image_random);
    first_image = 0;
    previousMillis = currentMillis;
  }

  if (gpio_get(BTN_PUSH)) {
    palette_index++;
    if (palette_index >= palette_number) {
      palette_index = 0;
    }
    load_palette(palette_index);
    dump_image_to_display(image_random);
    delay(debounceDelay);
  }

  if (currentMillis - previousMillis >= slide_show_delay) {
    previousMillis = currentMillis;
    pick_new_image();
    dump_image_to_display(image_random);
  }
}

void dump_image_to_display(int image_random) {

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
    int tile_row_start = 16 * max_tile_column * tile_line;

    for (int i = 0; i < 8; i++) {  // each pixel row in tile
      offset_x = pixel_line * image_width;

      for (int tile_column = 0; tile_column < max_tile_column; tile_column++) {
        uint8_t local_byte_LSB = tile_DATA_buffer[tile_row_start + 16 * tile_column + 2 * i];
        uint8_t local_byte_MSB = tile_DATA_buffer[tile_row_start + 16 * tile_column + 2 * i + 1];

        uint8_t byte_lsb = local_byte_LSB;
        uint8_t byte_msb = local_byte_MSB;

        for (int posx = 0; posx < 8; posx++) {
          pixel_DATA_buffer[offset_x + posx] = ((byte_msb & 0x80) >> 6) | ((byte_lsb & 0x80) >> 7);
          byte_msb <<= 1;
          byte_lsb <<= 1;
        }

        offset_x += 8;
      }
      pixel_line++;
    }
  }

  for (int y = 0; y < image_height; y++) {
    int row_offset = y * image_width;
    for (int x = 0; x < image_width; x++) {
      img.drawPixel(x, y, lookup_TFT_RGB565[pixel_DATA_buffer[row_offset + x]]);
    }
  }

  if (debug_mode) {
    tft.fillRect(0, 0, 128, 8, TFT_BLACK);
    tft.fillRect(0, 120, 128, 8, TFT_BLACK);
    tft.setTextColor(TFT_GREEN);
    tft.setCursor(0, 0);
    tft.print("Image rank: ");
    tft.print(image_random, DEC);
    tft.print("/");
    tft.println(images, DEC);
    tft.setCursor(0, 120);
    tft.print("Image address: ");
    tft.println(graphical_DATA_offset, HEX);
  }

  img.pushSprite(0, y_ori);  //dump image to display
}

void load_palette(int indice) {
  for (int i = 0; i < 4; i++) {  //load palette
    lookup_TFT_RGB565[i] = palette_storage[i + indice * 4];
  }
}

void seed_rng_from_adc() {
  adc_init();
  adc_gpio_init(26);  // GPIO26 is ADC0; make sure nothing is connected
  adc_select_input(0);

  uint32_t seed = 0;
  for (int i = 0; i < 32; i++) {
    seed <<= 1;
    seed |= (adc_read() & 1);  // Use the least significant bit
    sleep_ms(1);               // Small delay to allow entropy change
  }
  srand(seed);
}

void pick_new_image() {
  static int last_image = -1;  // First time: no last image
  int new_image;

  do {
    new_image = random(images);
  } while (new_image == last_image);

  image_random = new_image;
  last_image = new_image;
}

void typewriterPrintWithCursor(const char* text, uint16_t x, uint16_t y, uint16_t color, uint16_t delayMs = 25) {
  tft.setCursor(x, y);
  tft.setTextColor(color);

  for (int i = 0; text[i] != '\0'; i++) {
    tft.print(text[i]);

    // Draw white cursor
    int cx = tft.getCursorX();
    int cy = tft.getCursorY();
    tft.fillRect(cx, cy, 6, 8, TFT_WHITE);  // cursor block
    delay(delayMs);

    // Erase cursor
    tft.fillRect(cx, cy, 6, 8, TFT_BLACK);
  }
}

void Booting_animation() {
  int y = 8 + TXT_SHIFT;

  // Lines of splash screen
  struct Line {
    const char* text;
    uint16_t color;
  } lines[] = {
    { "Pico Slide show", TFT_GREEN },
    { "Raphael BOICHOT-2025", TFT_WHITE },
    { "GPL-3.0 license", TFT_SKYBLUE },
    { "https://github.com/", TFT_CYAN },
    { "Raphael-Boichot/", TFT_CYAN },
    { "Pico-slide-show", TFT_CYAN },
    { "Version 1.0", TFT_VIOLET },
    { nullptr, TFT_MAGENTA },  // Dynamic image count
    { "Enjoy the device !", TFT_ORANGE },
  };

  for (int i = 0; i < sizeof(lines) / sizeof(lines[0]); ++i) {
    if (lines[i].text) {
      typewriterPrintWithCursor(lines[i].text, 0, y, lines[i].color);
    } else {
      char buffer[32];
      sprintf(buffer, "%d stored into ROM", images);
      typewriterPrintWithCursor(buffer, 0, y, lines[i].color);
    }
    y += 10;
    delay(100);
  }

  // Final flashing cursor at the end
  int fx = 0;
  int fy = y;
  for (int i = 0; i < 6; i++) {
    tft.fillRect(fx, fy, 6, 8, (i % 2 == 0) ? TFT_WHITE : TFT_BLACK);
    delay(300);
  }
}
