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
- A [CR2XXX battery holder](https://aliexpress.com/item/1005006357635710.html) to solder (surface mount, no through-hole). Minimal recommended model is CR2032. There is enough clearance to solder bigger CR2XXX battery holder for longer use. CR2032 lithium batteries have a theoretical capacity of 220 mAh at 3V, the device consumes less than 10 mA at 5V, the voltage converter has it's own efficiency, so you can probably rely on a single battery for more than two hours.

![](/PCB/Schematic.png)

PCB designs can be edited with [EasyEDA Standard Edition](https://easyeda.com). EU citizens are advised to order PCBs at [JLCPCB](https://jlcpcb.com/) to avoid additional prohibitive taxes with customs. 

## Assembly (read carefully before attempting anything)

- I recommend testing the RP2040 Zero before soldering it (just try to flash the code without any error message) as Aliexpress components can sometimes be defective out of the box.
- The battery holder is surface mount but on the the back side comprising pins of through hole components: the good way to assemble the board is to **cut the pins** of the front side components as short as possible **before** soldering so that the solder joints are as flat as possible on the back side. Trimming them after soldering is not enough and you risk to cut traces by trimming too short.
- If possible, try to remove as much flux residues as you can but beware to the TFT display, it is very sensitive to dipping into IPA.

## User Manual in 4 steps

- Insert a CR2032 battery and power it on.
- Press the button to cycle through palettes.
- Strut through the city, proudly showing off your Pico Slide Show.
- Question your life choices as you ponder the environmental cost of single-use lithium batteries—for this beautifully pointless creation.

## Kind warning

The code and design are provided as-is. If you're not satisfied with the current hardware, the PCB layout in EasyEDA, the GNU Octave scripts, or the Arduino IDE setup - feel free to create your own; the license permits it!
