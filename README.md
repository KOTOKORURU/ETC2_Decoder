# ETC2-Decoder
Platform : Xilinx Spartan6

system clock   : 50mhz

LCD work clock : 33mhz

This is ETC2 Decode RTL implementation(RGB Format).
This mode only support format like "VK_FORMAT_ETC2_R8G8B8_UNORM_BLOCK".

ETC2 is a kind of compressed gpu texture format which is popular on many mobile platforms.

More info : https://registry.khronos.org/DataFormat/specs/1.3/dataformat.1.3.html#ETC2.

Work Flow:
1. Fetch compressed image data
2. Decode image to RGBA8 Format.
3. Truncate RGBA8 -> RGB(16bit pix) then write it to RAM, because the LCD only support the 16bit color.
4. align the LCD VSYNC/HSYNC signal, Read the RAM Data and present the Image on LCD.


tb            -> Testbench file

rtl           -> LCD & ETC2 Decoder Verilog Implementation

ipcore_dir    -> PLL ip

rom           -> 1 ROM ip for src image, 1 RAM ip for dst image

elina.ktx     -> Source Compressed ETC2 Image.

elina.png     -> Image Decompressed from ETC2.

elina.coe     -> Source Compressed ETC2 Image file to init FPGA Rom.

tft_color.ucf -> Port Definition

Example:

![image](https://github.com/KOTOKORURU/ETC2-Decoder/blob/master/example.png)
