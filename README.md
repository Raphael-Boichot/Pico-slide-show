# Flex in the city with your Game Boy Camera images

This project is a simple design for a tiny digital frame that displays Game Boy Camera images - because what better use of modern electronics than reviving 128×112 pixel grayscale selfies from the nineties ? It’s compact, portable, easy to build, and powered by a single CR2XXX lithium battery.

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

- Drop Game Boy Camera saves into the **/saves** folder or Game Boy Camera images into the **/Images** folder or rom dumps from [Photo!](https://github.com/untoxa/gb-photo) into the **/Roms** folder. You can drop and show as many as 540 images in a single build (up to 540, extra images will be discarded with a warning). Any format coming from any known emulator existing on Earth is accepted as long as it is 4 colors (2bbp).
- Run **Make_header_from_saves.m** from GNU Octave. It converts binary Game Boy Camera saves and images to C-compatible data. You can also set the delay between images in ms from this script;
- Open **Pico_slide_show.ino** with the Arduino IDE;
- Compile your code with the RP2040 core (select the Raspberry Pi Pico board and compile at 50 MHz) and upload directly or drop the pre-compiled .uf2 to your board.

## Parts needed to build the device

- The [custom PCB](/PCB), any thickness, any finish, any color. Order at [JLCPCB](https://jlcpcb.com/) with the gerber .zip;
- A [0.85 inch 128x128 TFT display](https://www.aliexpress.com/item/1005008822385316.html). It must be that exact same one (ST7735 controller).
- A [Waveshare RP2040 Zero (or copy)](https://www.aliexpress.com/item/1005003504006451.html), **with pin header** (or add some);
- A [DD05CVSA charge-discharge circuit](https://www.aliexpress.com/item/1005005061314325.html).
- [Male pin headers](https://www.aliexpress.com/item/4000873858801.html) with 2.54 mm spacing, if necessary, whatever the pin lenght, you will trim them anyway.
- A [6x6 push button](https://www.aliexpress.com/item/1005003938244847.html), any height; it can be harvested from any dead electronics, so it is common.
- 2 [microswitches SS-12D00G](https://www.aliexpress.com/item/1005003938856402.html) to cut the main power.
- A [503035 500 mA.h Lipo Battery](https://www.aliexpress.com/item/1005006421563695.html).

PCB designs can be edited with [EasyEDA Standard Edition](https://easyeda.com). EU citizens are advised to order PCBs at [JLCPCB](https://jlcpcb.com/) to avoid additional prohibitive taxes with customs. 

## Assembly (read carefully before attempting anything)

- I recommend testing the RP2040 Zero before soldering it (just try to flash the code without any error message) as Aliexpress components can sometimes be defective out of the box.
- If possible, try to remove as much flux residues as you can but beware to the TFT display, it is very sensitive to dipping into IPA.

## User Manual in 4 steps

- Press the button to cycle through palettes. Pressing it while booting activates a debug mode that shows minimal informations.
- Strut through the city, proudly showing off your Pico Slide Show.

## Kind warning

The code and design are provided as-is. If you're not satisfied with the current hardware, the PCB layout in EasyEDA, the GNU Octave scripts, or the Arduino IDE setup - feel free to create your own; the license permits it!
