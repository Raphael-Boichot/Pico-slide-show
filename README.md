# Flex with your Game Boy Camera images
This project is a simple base for a digital frame showing Game Boy Camera images.

## Environment Configuration

- Install the last [Arduino IDE](https://www.arduino.cc/en/software)
- Install the [Earle F. Philhower Raspberry Pi Pico Arduino core for Arduino IDE](https://github.com/earlephilhower/arduino-pico) via the Arduino Board manager (see [installation guide](https://github.com/earlephilhower/arduino-pico#installing-via-arduino-boards-manager)).
- Install the the [Adafruit Neopixel for Arduino IDE](https://github.com/adafruit/Adafruit_NeoPixel);
- Install the Bodmer [TFT_eSPI library](https://github.com/Bodmer/TFT_eSPI) via the Arduino library manager.
- Locate the TFT_eSPI library: **\Arduino\libraries\TFT_eSPI** folder in your Arduino libraries
- copy the [configuration file](/Pico_slide_show/TFT_setup) for the TFT display in this folder.
- edit the User_Setup_Select.h and modify line 29:
    **#include <Pico_slide_show_TFT_eSPI_setup.h> // Default setup is root library folder**
- Install [GNU Octave](https://www.octave.org/). It is a multi-OS computing langage requiring no dependancies;
- drop Game Boy Camera saves into the **/saves** folder. You can drop and show as much as 18 saves in a row;
- run **Make_header_from_saves.m** from GNU Octave. It converts binary Game Boy Camera saves to C compatble data;
- open **Pico_slide_show.ino** from the Arduino IDE;
- Compile your code and drop the uf2 to you board.

PCB designs can be edited with [EasyEDA Standard Edition](https://easyeda.com). Eu citizens are advised to order PCBs at [JLCPCB](https://jlcpcb.com/) to avoid additional prohibitive taxes with customs (taxes paid at order). I've never had any quality issue with them. Just drop the gerber to their site and order with default parameters (the cheapest by default). Considering that you yet have very basic soldering hardware (and skill), each populated PCB should cost you about 5€ maximum.

**Parts needed:** 
- A [0.85 inches 128x128 TFT display](https://aliexpress.com/item/1005008822385316.html). It must be that exact same one (ST7735 controller).
- A [Waveshare RP2040 Zero (or copy)](https://www.aliexpress.com/item/1005003504006451.html), **with pin header** (or add some);
- The [custom PCB](/PCB), any thickness, any finish, any color. Order at [JLCPCB](https://jlcpcb.com/) with the gerber .zip;
- A [6x6 push button](https://www.aliexpress.com/item/1005003938244847.html)  whatever height, that can be harvested on any dead electronic suff so it is common.
- 1 [microswitch SS-12D00G](https://www.aliexpress.com/item/1005003938856402.html) to cut the main power and the display backlight which draws more current (30 mA) than the Pi Pico (25 mA) itself, for saving battery in case of long timelapses for example.

## Kind warning
The code and current design come as is. If you're not happy with the current hardware, the PCB EasyEDA design or the Arduino IDE, create your own, the licence allows it !
