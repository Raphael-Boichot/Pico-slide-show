# Flex in the city with your Game Boy Camera images

This project is a simple design for a tiny digital frame that displays Game Boy Camera images - because what better use of modern electronics than reviving 128×112 pixel grayscale selfies from the nineties ? It’s compact, portable, easy to build, and powered by 500 mA.h lithium battery.

To my knowledge, this is also the smallest digital frame in the world.

It can take as input: images in any format (as long as it is 2 bpp, all lossless printing format from any printer emulator are supported and automatically cropped and resized), raw saves without need for any conversion or raw ROM dumps from flashable Game Boy Camera equipped with [Photo!](https://github.com/untoxa/gb-photo)

![](/Pictures/Showcase_2.jpg)
(Credit: Raphaël BOICHOT)

## Environment configuration

- Install the latest [Arduino IDE](https://www.arduino.cc/en/software);
- Install the [Earle F. Philhower Raspberry Pi Pico Arduino core for Arduino IDE](https://github.com/earlephilhower/arduino-pico) via the Arduino Board manager (see [installation guide](https://github[...]);
- Install the Bodmer [TFT_eSPI library](https://github.com/Bodmer/TFT_eSPI) via the Arduino library manager;
- Locate the TFT_eSPI library: **\Arduino\libraries\TFT_eSPI** folder in your Arduino libraries and copy the [configuration file](/Pico_slide_show/TFT_setup) for the TFT display in this folder;
- Edit the **User_Setup_Select.h** and modify line 29:
    **#include <Pico_slide_show_TFT_eSPI_setup.h> // Default setup is root library folder**
- Install [GNU Octave](https://www.octave.org/). It is a multi-OS computing language requiring no dependencies, used to convert save files.

## Image conversion and compiling

Images are directly embedded into the Pi Pico flash memory, encoded in Game Boy Tile Format. So the repository comes with an image converter as well as the code for the Pi Pico itself.

The Arduino IDE does not allow easily scripting the two tasks (image converting and Pi Pico SDK code compiling) like other dev platforms. It's possible but more complicated than just running the GNU Octave converter and the Arduino IDE compiler separately.

So, this is how to proceed:

- Drop Game Boy Camera saves into the **/saves** folder or Game Boy Camera images into the **/Images** folder or rom dumps from [Photo!](https://github.com/untoxa/gb-photo) into the **/Roms** folder. You can drop and show as many as 540 images in a single build (up to 540, extra images will be discarded with a warning). Any format coming from any known emulator existing on Earth is accepted as long as it is 4 colors (2bbp);
- Run **Make_header_from_saves.m** from GNU Octave. It converts binary Game Boy Camera saves and images to C-compatible data. You can also set the delay between images in ms from this script;
- Open **Pico_slide_show.ino** with the Arduino IDE;
- Compile your code with the RP2040 core (select the Raspberry Pi Pico board and compile at 50 MHz) and upload directly or drop the pre-compiled .uf2 to your board.

New palettes encoded in RGB565 can be very easily added.

The code and board design are so basic that they can probably be ported to an ESP32 mini without difficulty. The GNU Octave code may also be very easy to convert in Python with your prefered LLM.

## Parts needed to build the device

- The [custom PCB](/PCB), any thickness, any finish, any color. Order at [JLCPCB](https://jlcpcb.com/) with the gerber .zip;
- A [0.85 inch 128x128 TFT display](https://www.aliexpress.com/item/1005008822385316.html). It must be that exact same one (ST7735 controller).
- A [Waveshare RP2040 Zero (or copy)](https://www.aliexpress.com/item/1005003504006451.html), **with pin header** (or add some);
- A [DD05CVSA charge-discharge circuit](https://www.aliexpress.com/item/1005005061314325.html). This is a very reliable sub board, used on various projects.
- [Male pin headers](https://www.aliexpress.com/item/4000873858801.html) with 2.54 mm spacing, if necessary, whatever the pin lenght, you will trim them anyway.
- A [6x6 push button, 4 pins](https://www.aliexpress.com/item/1005003938244847.html), any height. It can be harvested from any dead electronics, so it is common.
- 2 [microswitches SS-12D00G](https://www.aliexpress.com/item/1005003938856402.html) to cut the main power.
- A [503035 500 mA.h Lipo Battery](https://www.aliexpress.com/item/1005006421563695.html). It is a quite common size on purpose.

PCB designs can be edited with [EasyEDA Standard Edition](https://easyeda.com). EU citizens are advised to order PCBs at [JLCPCB](https://jlcpcb.com/) to avoid additional prohibitive taxes with customs. 

![](/PCB/PCB.png)

## Assembly (read carefully before attempting anything)

- I recommend testing the RP2040 Zero before soldering it (just try to flash the code without any error message) as Aliexpress components can sometimes be defective out of the box.
- Trim the pins **BEFORE SOLDERING** as short as possible for each component in order to not punch the battery side or scratch yourself if you wear it as cool pendant.
- Populate the front side before, test and if everything is OK, populate the back side. Stuck the battery with small patches of double sided tape in order to ba able to remove it, just in case.
- If possible, try to remove as much flux residues as you can but beware to the TFT display, it is very sensitive to dipping into IPA.

![](/Pictures/Showcase_1.png)
(Credit: Raphaël BOICHOT)

## User Manual

- **For using:** rigth switch on **USE** position, whatever the position of left switch (ON/OFF).
- **For charging:** rigth switch on **CHAR.** (charge) position, left switch on **ON** position. Charge until green led on the charge module.
- **For changing palette:** push the **PALETTE** button.

## Troubleshooting

If you struggle compiling the code, just open an issue, send me your batch of images and I can do the compiling for you.

## Kind warning

The code and design are provided as-is. If you're not satisfied with the current hardware, the PCB layout in EasyEDA, the GNU Octave scripts, or the Arduino IDE setup - feel free to create your own; the license permits it! Do not hesitate to get in touch with me to compile your images if you struggle to configure the setup.
