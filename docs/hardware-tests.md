# Hardware test record

## Version 0.2.0 (local alias: Versione 1)

Report received in the project conversation on 2026-11-07. Reporter: project
owner ofgod1974. Setup in the established test context: Philips NMS8245,
Pico+ boot/storage and WonderTANG 2.02b / Tang Nano 20K in slot 2.

| Software | Graphics | Audio | Scope |
|---|---|---|---|
| Monkey Island 1 V9990/OPL4 conversion | Reported good | OPL4 reported good | Simultaneous video/audio; exact build and duration unspecified |
| Monkey Island 2 V9990/OPL4 conversion | Reported good | OPL4 reported good | Simultaneous video/audio; exact build and duration unspecified |

The tester confirmed incorrect colors and graphics glitches with the same
game before the flag-only correction, and improvement with this image.
No full playthrough, complete mode/command coverage or BASIC test results
were reported. These are tester observations, not independently reproduced
measurements. Do not describe the firmware as fully compatible or stable.

## Separate experiment (local alias: Versione 2)

Adds new shared-memory arbitration. No hardware result is recorded and it
is not part of the v0.2.0 release. It must not inherit the positive reports
above merely because it includes the completion-flag change.
