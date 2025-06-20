# Pico camera slide show
A base for a digital frame showing Game Boy Camera images

## How ?
PCB designs can be edited with [EasyEDA Standard Edition](https://easyeda.com). Schematics follows the associated projects, so refer to them and to the PCB source files to get the pinout. All these boards must be used with a **GB/GBC compatible link cable**. **GBA only (purple cables) are not pinout compatible** with the proposed socket (even if they fit as the only sockets available online in 2024 are the GBA compatible version). These boards have been tested IRL with GB/GBA/GBC/GB Boy Colour (as long as the cable is GB/GBC compatible).

Eu citizens are advised to order PCBs at [JLCPCB](https://jlcpcb.com/) to avoid additional prohibitive taxes with customs (taxes paid at order). I've never had any quality issue with them. Just drop the gerber to their site and order with default parameters (the cheapest by default). Considering that you yet have very basic soldering hardware (and skill), each populated PCB should cost you about 10€ maximum. You will save a multimeter too as it will work first try.

**Parts needed:** 
- A [0.85 inches 128x128 TFT display](https://aliexpress.com/item/1005008822385316.html). It must be that exact same one (ST7735 controller).
- A [Waveshare RP2040 Zero (or copy)](https://www.aliexpress.com/item/1005003504006451.html), **with pin header** (or add some);
- The [custom PCB](/PCB), any thickness, any finish, any color. Order at [JLCPCB](https://jlcpcb.com/) with the gerber .zip;
- A [6x6 push button](https://www.aliexpress.com/item/1005003938244847.html)  whatever height, that can be harvested on any dead electronic suff so it is common.
- 1 [microswitch SS-12D00G](https://www.aliexpress.com/item/1005003938856402.html) to cut the main power and the display backlight which draws more current (30 mA) than the Pi Pico (25 mA) itself, for saving battery in case of long timelapses for example.
