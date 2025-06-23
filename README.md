# Flex with your Game Boy Camera images

This project is a simple base for a tiny digital frame showing Game Boy Camera images. It is small and portable, powered by a single CR2032 lithium battery.

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
- Compile your code with the RP2040 core (select the Raspberry Pi Pico board and compile at 50 MHz) and upload or drop the pre-compiled .uf2 to your board.

## Parts needed to build the device

- A [0.85 inch 128x128 TFT display](https://aliexpress.com/item/1005008822385316.html). It must be that exact same one (ST7735 controller).
- A [Waveshare RP2040 Zero (or copy)](https://www.aliexpress.com/item/1005003504006451.html), **with pin header** (or add some);
- The [custom PCB](/PCB), any thickness, any finish, any color. Order at [JLCPCB](https://jlcpcb.com/) with the gerber .zip;
- A [6x6 push button](https://www.aliexpress.com/item/1005003938244847.html), any height; it can be harvested from any dead electronics, so it is common.
- 1 [microswitch SS-12D00G](https://www.aliexpress.com/item/1005003938856402.html) to cut the main power.
- A [CR2032 battery holder](https://aliexpress.com/item/1005006357635710.html) to solder. The battery should last about 5 hours of continuous display.

PCB designs can be edited with [EasyEDA Standard Edition](https://easyeda.com). EU citizens are advised to order PCBs at [JLCPCB](https://jlcpcb.com/) to avoid additional prohibitive taxes with customs.

## User Manual in 4 steps

- Put a CR2032 battery and switch the power on.
- Push the button to change the palette.
- Flex in the city with your Pico Slide Show.
- Regret using disposable lithium batteries for such a futile use.

## Kind warning

The code and current design come as is. If you're not happy with the current hardware, the PCB EasyEDA design, GNU Octave scripting, or the Arduino IDE, create your own—the license allows it!
