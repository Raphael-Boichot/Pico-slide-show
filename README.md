# Flex with your Game Boy Camera images

This project is a simple foundation for a tiny digital frame that displays Game Boy Camera images - because what better use of modern electronics than reviving 128×112 pixel grayscale selfies from the ’90s? It’s compact, portable, and powered by a single CR2XXX lithium battery.

## Environment configuration

- Install the latest [Arduino IDE](https://www.arduino.cc/en/software)
- Install the [Earle F. Philhower Raspberry Pi Pico Arduino core for Arduino IDE](https://github.com/earlephilhower/arduino-pico) via the Arduino Board manager (see [installation guide](https://github[...])
- Install the Bodmer [TFT_eSPI library](https://github.com/Bodmer/TFT_eSPI) via the Arduino library manager;
- Locate the TFT_eSPI library: **\Arduino\libraries\TFT_eSPI** folder in your Arduino libraries and copy the [configuration file](/Pico_slide_show/TFT_setup) for the TFT display in this folder.
- Edit the **User_Setup_Select.h** and modify line 29:
    **#include <Pico_slide_show_TFT_eSPI_setup.h> // Default setup is root library folder**
- Install [GNU Octave](https://www.octave.org/). It is a multi-OS computing language requiring no dependencies, used to convert save files.

## Image conversion and compiling

The Arduino IDE does not allow directly scripting the two tasks (image converter and compiler) easily like other dev platforms. It's possible but more complicated than just running GNU Octave and the compiler separately.

So, this is how to proceed:

- Drop Game Boy Camera saves into the **/saves** folder or Game Boy Camera images into the **/Images** folder. You can drop and show as many as 540 images in a build (up to 540 images, extras will be discarded).
- Run **Make_header_from_saves.m** from GNU Octave. It converts binary Game Boy Camera saves and images to C-compatible data. You can also set the delay between images from this script;
- Open **Pico_slide_show.ino** with the Arduino IDE;
- Compile your code with the RP2040 core (select the Raspberry Pi Pico board and compile at 50 MHz) and upload directly or drop the pre-compiled .uf2 to your board.

## Parts needed to build the device

- The [custom PCB](/PCB), any thickness, any finish, any color. Order at [JLCPCB](https://jlcpcb.com/) with the gerber .zip;
- A [0.85 inch 128x128 TFT display](https://aliexpress.com/item/1005008822385316.html). It must be that exact same one (ST7735 controller).
- A [Waveshare RP2040 Zero (or copy)](https://www.aliexpress.com/item/1005003504006451.html), **with pin header** (or add some);
- A [6x6 push button](https://www.aliexpress.com/item/1005003938244847.html), any height; it can be harvested from any dead electronics, so it is common.
- 1 [microswitch SS-12D00G](https://www.aliexpress.com/item/1005003938856402.html) to cut the main power.
- A [CR2XXX battery holder](https://aliexpress.com/item/1005006357635710.html) to solder. Minimal recommended model is CR2032 (2 hours of continuous use). CR2450 should last much longer.

![](/PCB/Schematic.png)

PCB designs can be edited with [EasyEDA Standard Edition](https://easyeda.com). EU citizens are advised to order PCBs at [JLCPCB](https://jlcpcb.com/) to avoid additional prohibitive taxes with customs. CR2032 lithium batteries have a theoretical capacity of 210 mAh at 3V, the device consumes less than 10 mA at 5V, the voltage converter has it's own efficiency, so you can probably rely on a single battery for a bit less than two hours.

## User Manual in 4 steps

- Insert a CR2032 battery and power it on.
- Press the button to cycle through palettes.
- Strut through the city, proudly showing off your Pico Slide Show.
- Question your life choices as you ponder the environmental cost of single-use lithium batteries—for this beautifully pointless creation.

## Kind warning

The code and design are provided as-is. If you're not satisfied with the current hardware, the PCB layout in EasyEDA, the GNU Octave scripts, or the Arduino IDE setup - feel free to create your own; the license permits it!
