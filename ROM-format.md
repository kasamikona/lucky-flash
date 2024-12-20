# Cartridge ROM format
Data is stored big-endian, unused data filled with FF. The format as it is currently understood is as follows.  

Structure of a standard 8Mbit cart:
|Offset|Contents|
|--|--|
|`00000`|Magic header `EZ-TOY ROM CART(nul)`, required for cart to be recognized.|
|`00010`|32 bytes cart name padded with spaces, not required.|
|`00030`|Up to 50x 8-byte entries, song numbers.|
|`001C0`|Up to 100x 8-byte entries, song address/length.|
|`004E0`|Start of standard MIDI file data, no separation or alignment required.|
|`FFFE6`|18 bytes version & timestamp, not required.|
|`FFFF8`|4 bytes checksum or unique ID, not required.|
|`FFFFC`|2 bytes unknown value, not required.|
|`FFFFE`|2 bytes unknown value, not required.|

For cart name, original carts use RK number, e.g. `RK109`.  

The song number table contains values `00FFFFFFFFFFFFFF`, `01FFFFFFFFFFFFFF` etc.
The value of the first byte doesn't seem to matter, as long as it isn't `FF`.
When an entry starting with `FF` is hit, that marks the end of the list and defines the number of songs.
It's possible that this was intended for some kind of sequencing.  

The address/length table contains interleaved 32-bit address and 32-bit length of each song's MIDI data.
Addresses and lengths are in bytes, and addresses are absolute i.e. relative to the start of ROM.  

For version and timestamp:
- The first 3 bytes are version, e.g. `100` = version 1.00
- The next 9 bytes are the year, 3-letter month and day, e.g. `2003JUL31`
- The next 6 bytes are the creation timestamp HHMMSS, e.g. `161025`

The checksum algorithm and the range of source data is not currently known,
but it is not checked by the guitar so this is not critical.  

The last two values have unknown meaning. The following pairs have been seen:
- `9DFF FEFF`
- `8DFF F5FF`
- `73FF A8FF`
- `60FF 0AFF`
These also don't seem to have any significant effect and may be source file metadata.  

## MIDI data
MIDI data is in Yamaha XG format. Channels 1-3 and 7-16 are usable, while 4-6 are ignored/muted.
*I have not found any way to enable channels 4-6 so far, maybe they are reserved for the guitar strings.*  

Song intros use custom "one, two, three, four" samples in bank 123, program 118, notes 61, 63, 66, 68. Normally played on channel 11.  

Chord data is sysex events in Yamaha chord control format, i.e.  
`(F0) 43 7E 02 WW XX YY ZZ (F7)`  
where WW is chord root, XX is chord type, YY is bass note and ZZ is bass type.  

From various Yamaha manuals, the chord/note format appears to be as follows,
though this is not verified and it's unknown what parts of this data are actually used.

```
WW, YY:
 000xxxx bbb      xxx0001  C
 001xxxx bb       xxx0010  D
 010xxxx b        xxx0011  E
 011xxxx natural  xxx0100  F
 100xxxx #        xxx0101  G
 101xxxx ##       xxx0110  A
 110xxxx ###      xxx0111  B
 1111111 no bass note (bass only)
 other values reserved

XX, ZZ:
 0000000 Maj
 0000001 Maj6
 0000010 Maj7
 0000011 Maj7(#11)
 0000100 Maj(9)
 0000101 Maj7(9)
 0000110 Maj6(9)
 0000111 aug
 0001000 min
 0001001 min6
 0001010 min7
 0001011 min7b5
 0001100 min(9)
 0001101 min7(9)
 0001110 min7(11)
 0001111 minMaj7
 0010000 minMaj7(9)
 0010001 dim
 0010010 dim7
 0010011 7th
 0010100 7sus4
 0010101 7b5
 0010110 7(9)
 0010111 7(#11)
 0011000 7(13)
 0011001 7(b9)
 0011010 7(b13)
 0011011 7(#9)
 0011100 Maj7aug
 0011101 7aug
 0011110 1+8
 0011111 1+5
 0100000 sus4
 0100001 1+2+5
 0100010 chord cancel
 1111111 no bass note (bass only)
 other values reserved
```
