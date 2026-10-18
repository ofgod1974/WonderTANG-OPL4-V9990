# WonderTANG OPL4 + V9990 (experimental)

Integration of MoonTANG OPL4 sound and tnCartWonder/Tiny9990 graphics on a
WonderTANG 2.0b / 2.02b with Tang Nano 20K (GW2AR-LV18QN88C8/I7).

**Work in progress. Hardware compatibility is incomplete. This is not a stable release.**

- Tiny9990 graphics with command engine, DVI video through the HDMI connector.
- OPL4 FM + PCM, 2 MiB YRW801 wave ROM plus 2 MiB sample RAM.
- Mono audio through J3 / MSX SOUNDIN; no HDMI audio.
- No Nextor, memory mapper, SCC, OPLL or MSX-Audio in this build.
- Boot and storage provided by a separate cartridge, such as Pico+.

## Upstream projects

This integration derives from two separate projects. It is not an official release
of either project. Exact source revisions and firmware checksum are recorded in
[UPSTREAMS.json](UPSTREAMS.json).

| Source | Starting revision | Integrated code |
|---|---|---|
| [herraa1/tnCartWonder](https://github.com/herraa1/tnCartWonder), itself derived from [buppu3/tnCart](https://github.com/buppu3/tnCart) | `d3a54f1b0df9e56c0d27ce1d0460f79f593d5568` | `rtl/` |
| [Papipapito/MoonTANG](https://github.com/Papipapito/MoonTANG) | `b2770265d02cdf30c721a8ace12793e63ec6e776` | `moon/` |

The WonderTANG hardware project is [lfantoniosi/WonderTANG](https://github.com/lfantoniosi/WonderTANG).
Original per-file copyright and license notices are retained.

### Forks maintained in this account

| Upstream | Fork |
|---|---|
| [Papipapito/MoonTANG](https://github.com/Papipapito/MoonTANG) | [ofgod1974/MoonTANG](https://github.com/ofgod1974/MoonTANG) |
| [herraa1/tnCartWonder](https://github.com/herraa1/tnCartWonder) | [ofgod1974/tnCartWonder](https://github.com/ofgod1974/tnCartWonder) |

These are separate GitHub forks for tracking the upstream projects. This repository
remains the combined integration project. The integrated source revisions above
and in [UPSTREAMS.json](UPSTREAMS.json) remain pinned: creating the forks does not
update or replace the combined firmware.

## Credits and thanks

This integration builds on the work of the following authors and projects:

| Author / project | Contribution used here |
|---|---|
| **Papipapito (Albert)** — [MoonTANG](https://github.com/Papipapito/MoonTANG) / MSXimus | Standalone OPL4 integration, PCM glue, wave-memory interface, YRW801 loader, mixer, I2S hand-off and MSX test programs. MoonTANG credits **Claude (Anthropic)** as a pair-programming co-author of that upstream port. |
| **Shinobu Hashimoto (buppu3)** — [tnCart](https://github.com/buppu3/tnCart) | Tiny9990 graphics, command engine, MSX bus front-end, SDRAM/UMA controller and video infrastructure. |
| **Albert Herranz (herraa1)** — [tnCartWonder](https://github.com/herraa1/tnCartWonder) | WonderTANG port, wt200b board mapping and clocking, and I2S transmitter. |
| **Luis Felipe Antoniosi (lfantoniosi)** — [WonderTANG](https://github.com/lfantoniosi/WonderTANG) | Cartridge hardware and pinout; the original SPI flash reader underlying MoonTANG's flash interface. |
| **Greg Taylor (gtaylormb)** — [OPL3 FPGA](https://github.com/gtaylormb/opl3_fpga) | OPL3 FM core. Its upstream credits include Robson Cozendey, Steffen Ohrendorf, Nuke.YKT and carbon14/opl3 for algorithm and reverse-engineering origins. |
| **Jokin Miragaia (antxiko)** — mangOPL4 | Gowin adaptations and the OPL3/MoonSound cartridge wrapper inherited through MoonTANG. |
| **srg320** — [Arcade-PsikyoSH2_MiSTer](https://github.com/srg320/Arcade-PsikyoSH2_MiSTer) | YMF278B PCM/wavetable engine, derived from MAME's ymf278b implementation by **R. Belmont, Olivier Galibert and hap**. |
| **Dan Gisselquist** — Gisselquist Technology | Asynchronous FIFO used by the FM host interface. |
| **Gowin Semiconductor** and **Sipeed** | Gowin FPGA primitives and the vendor DVI_TX IP carried by tnCartWonder; Tang Nano 20K hardware and tool support. |

Original source notices and license texts are retained in the files and in
[LICENSES](LICENSES/). The integration changes are described below under
[Integration changes](#integration-changes); upstream work is attributed to its
original authors, and no upstream endorsement is implied.

For the inherited component history, see the [MoonTANG credits at our starting
revision](https://github.com/Papipapito/MoonTANG/blob/b2770265d02cdf30c721a8ace12793e63ec6e776/CREDITS.md)
and the preserved [third-party notices](LICENSES/MoonTANG-third-party.md).
Those notices also cover other MoonTANG builds: this combined build uses the
tnCart SDRAM/UMA controller and Gowin DVI_TX; the separate MoonTANG HDMI-audio,
MSX-Audio and alternate-board components are outside this build.


## Current validation and known problems

Build: Gowin 1.9.12, placement 2 / routing 0. Timing passes for analyzed paths,
with approximately **0.016 ns minimum setup slack**. This small margin and the
upstream-derived constraints do not establish full hardware correctness.

Hardware observations on a Philips NMS8245, Pico+ and WonderTANG in slot 2:

| Test | Observation |
|---|---|
| Pinball Fantasies demo, build b0129, dated 2026-10-10 | Reports OPL4 detected and V9990 not detected; stops. OPL4 detection does not prove audio or wave ROM playback. |
| Galaga V9990, photographed | Severe repeated blocks / corrupted image. |
| Wolf3D demo V9990, video supplied by tester | Reported to work on this firmware; exact program still unknown. |
| V9990 logo animation test, exact program unknown | Logos are drawn but do not move as expected. |
| OPL4 BASIC FM / PCM / wave ROM / RAM tests | **Pending**. |

These observations must not be interpreted as complete V9990 or OPL4 validation.
The cause of the failures is still unknown. Development is paused pending BASIC tests.

## Build and test

Install Gowin FPGA Designer with a valid license. From the repository root:

```text
gw_sh build.tcl
```

The expected output is `impl/pnr/wonder_opl4_v9990.fs`. Check the new timing and
resource reports for each build; do not reuse an old output after a failed build.

The tested build candidate is in `firmware/`, with its SHA-256 checksum.
Detailed Italian instructions: [build and test](docs/build-and-test.it.md).
Reports are in `reports/`; BASIC checks are in `test-msx/`.
The Python tests in `tests/` check arithmetic equivalence of the FIFO and envelope
optimizations. They are not a full RTL simulation or hardware validation.

**YRW801 ROM is not included.** The firmware expects a user-supplied 2,097,152-byte
image in SPI flash at byte offset `0x200000`. The FPGA bitstream starts at `0x000000`.
SDRAM addresses are managed by the FPGA and are not Programmer flash addresses.
The flash log must show the wave ROM starting at `0x200000`, not `0x020000`.

## Integration changes

- Shared tnCart UMA / SDRAM controller for video RAM and OPL4 wave memory.
- New wave-memory bridge with byte writes, aligned word reads, refresh and watchdog.
- Combined I/O bus, interrupt, wait, reset and clock wiring.
- OPL4 loader and mixer retained; private MoonTANG SDRAM controller replaced by shared access.
- Three synchronous OPL4 register banks mapped to BSRAM.
- FIFO pointers and shared read/write rotations reduce video logic usage.
- Envelope product replaced with equivalent shifts for table values 0, 1, 2, 4 and 8.

The delivered candidate uses a 54 MHz PCM engine with clock enable 392/625
(33.8688 MHz effective). Alternative clock / FSM experiments are not included.

## Licensing

Integration changes are provided under GPL-3.0-or-later; see [LICENSE](LICENSE).
Upstream components retain their original licenses (including LGPL and BSD).
See [third-party notices](LICENSES/MoonTANG-third-party.md),
[tnCartWonder license](LICENSES/tnCartWonder-BSD-3-Clause.txt) and source headers.
The third-party notice is retained from MoonTANG and also describes components
that are not part of this build. The original Yamaha sample ROM is not redistributed.
