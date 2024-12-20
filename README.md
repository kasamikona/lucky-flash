# Lucky Guitar Flashcart
A custom flashcart for the Lucky Group electronic guitar toy (らっき組 ギター) RK-001, made by People Co., Ltd.  

## What's it for?
The guitar toy, which I will call the Lucky Guitar from here onwards, has multiple play modes.
One of these modes uses ROM cartridges containing songs which you can play along with.
The songs are stored as MIDI files containing chord information.  

There were 14 main cartridges made, focusing on certain genres or artists,
and an additional "demo" cartridge containing a compilation of songs from the others.
The Lucky Guitar came with 2 or 3 random cartridges in the box, though additional ones could be purchased.
As it was a relatively obscure device, the cartridges are quite rare and it is very hard to collect them all.  

To allow the Lucky Guitar to be enjoyed to its fullest, I have developed a flash cart based heavily on the original cartridge design.
It supports playing ROM dumps of existing cartridges, as well as custom ROMs made from your own suitable MIDI files.
The latest version supports up to 8 different ROMs on one cartridge, with DIP switches to select them.  

Due to their small size, the flash carts contain no active logic and must be programmed externally.
Currently this is done through a custom adapter stackup for the TL866 (aka "MiniPro") Universal Programmer.
The stackup consists of a SN001-1 aka TSOP48 V3 base board from XinGong Tech, and the custom cartridge interface from here.
This adapter stack also allows dumping ROMs from the original cartridges after some modifications.  

## Contents
The main files you will want for making and using the flash cart are:
- **CartFlashMulti**: the latest multi-bank flash cart with DIP switches, intended for use with the custom shell. Gerber files coming soon.
- **LuckyCartInterface-TL866**: flash programmer interface for the TL866 and SN001-1. Gerber files coming soon.
- **CartShell.scad**: custom cart shell for the multi-bank flash cart, designed for SLA 3D printing. Render the main and cover parts separately. STL files coming soon.
- **CartParts.kicad_sym / CartParts.pretty**: custom KiCad parts shared between all PCBs.

The repo contains these additional files:
- **CartReplica**: a copy of the original cart PCB for research and analysis.
- **CartFlashSingle**: a flash cart based on the original carts, with minimal changes to support externally programming a flash chip. This can fit in an original shell.
- **DIP48-SN001**: a helper board that theoretically allows the cart interface to be used on other programming devices with 48-pin sockets.
