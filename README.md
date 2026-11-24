# WonderTANG OPL4 + V9990 (experimental)

Integration of MoonTANG OPL4 sound and tnCartWonder/Tiny9990 graphics on a
WonderTANG 2.0b / 2.02b with Tang Nano 20K (GW2AR-LV18QN88C8/I7).

**Work in progress. Hardware compatibility is incomplete. This is not a stable release.**

- Tiny9990 graphics with command engine, DVI video through the HDMI connector.
- OPL4 FM + PCM, 2 MiB YRW801 wave ROM plus 2 MiB sample RAM.
- Mono audio through J3 / MSX SOUNDIN; no HDMI audio.
- No Nextor, memory mapper, SCC, OPLL or MSX-Audio in this build.
- Boot and storage provided by a separate cartridge, such as Pico+.

## Version 0.2.0 - tested "Versione 1"

This is the **flag-only** build tested by the project owner. Download
[`wonder_opl4_v9990_v0.2.0.fs`](firmware/wonder_opl4_v9990_v0.2.0.fs)
and verify [SHA256SUMS](firmware/SHA256SUMS).
It fixes the Tiny9990 command-completion flag; it retains the previous UMA
arbitration and does not add HDMI audio. The separate experimental build with
new arbitration (locally called "Versione 2") is **not included**.

See [release notes](docs/releases/v0.2.0.md) for programming and rollback,
and [hardware test records](docs/hardware-tests.md) for the scope of validation.

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

Version 0.2.0: Gowin 1.9.12, placement 2 / routing 0. The analyzed paths have
zero setup and hold violations, with **0.009 ns minimum setup slack**.
This very small margin and the inherited constraints do not establish full
hardware correctness. There has been no full event-driven RTL simulation.

Hardware reports from the project owner, Philips NMS8245, Pico+ and WonderTANG:

| Test on version 0.2.0 | Observation |
|---|---|
| Monkey Island 1, V9990/OPL4 conversion | Tester reports good V9990 graphics and OPL4 audio together. Previous firmware showed incorrect colors and graphics glitches with the same game. |
| Monkey Island 2, V9990/OPL4 conversion | Tester reports good V9990 graphics and OPL4 audio together. Exact conversion versions and test duration were not supplied. |
| BASIC FM / PCM / wave ROM / RAM tests | No completed results recorded. |
| Other V9990 programs and game completion | Not established by these two reports. |

These are user-reported observations, not independent or exhaustive validation.
The new-arbitration experiment remains separate and has no recorded MSX test.

### Historical observations on the earlier firmware

The following reports predate the completion-flag fix. They have not all been
retested on 0.2.0 and must not be read as current results for this release.

| Test | Observation |
|---|---|
| Pinball Fantasies demo, build b0129, dated 2026-10-10 | Reports OPL4 detected and V9990 not detected; stops. OPL4 detection does not prove audio or wave ROM playback. |
| Galaga V9990, photographed | Severe repeated blocks / corrupted image. |
| Wolf3D demo V9990, video supplied by tester | Reported to work on this firmware; exact program still unknown. |
| V9990 logo animation test, exact program unknown | Logos are drawn but do not move as expected. |
| OPL4 BASIC FM / PCM / wave ROM / RAM tests | **Pending**. |


## Build and test

Install Gowin FPGA Designer with a valid license. From the repository root:

```text
gw_sh build.tcl
```

The expected output is `impl/pnr/wonder_opl4_v9990_flagfix.fs`. Check the new timing and
resource reports for each build; do not reuse an old output after a failed build.

The tested prebuilt image is in `firmware/`, with its SHA-256 checksum.
For publication, the original `wonder_opl4_v9990_flagfix.fs` was renamed to
`wonder_opl4_v9990_v0.2.0.fs` without changing any bytes.
Detailed Italian instructions: [build and test](docs/build-and-test.it.md).
Reports are in `reports/`; BASIC checks are in `test-msx/`.
The Python tests in `tests/` check arithmetic equivalence of the FIFO and envelope
optimizations. The completion-flag test checks the actual source expression
against its truth table. These checks are not full RTL simulation or hardware validation.

**YRW801 ROM is not included.** The firmware expects a user-supplied 2,097,152-byte
image in SPI flash at byte offset `0x200000`. The FPGA bitstream starts at `0x000000`.
SDRAM addresses are managed by the FPGA and are not Programmer flash addresses.
The flash log must show the wave ROM starting at `0x200000`, not `0x020000`.

## Integration changes

- Version 0.2.0: P#6.CE uses `CE_save | STATUS.CE_intr`, separating command completion from P#5 command-busy status.

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
