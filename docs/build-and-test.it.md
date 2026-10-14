# WonderTANG OPL4 + V9990 — integrazione sperimentale

Destinazione: WonderTANG 2.0b / 2.02b con Tang Nano 20K,
GW2AR-LV18QN88C8/I7. Non usare su PCB con piedinatura diversa.

## Funzioni

- Tiny9990 ai porti Z80 60h–6Fh, con motore dei comandi abilitato.
- OPL4: OPL3 FM a C4h–C7h, wavetable PCM a 7Eh–7Fh.
- Video DVI attraverso il connettore HDMI, usando il percorso tnCart.
- Audio OPL4 mono al DAC I2S della Tang e al MSX attraverso J3.
- Nessun Nextor, mapper, MegaROM, SCC, OPLL o MSX-Audio nel firmware.
- Avvio e caricamento programmi affidati alla Pico+ o a un'altra interfaccia.
- Audio HDMI non incluso in questa versione.

## Memoria

La flash conserva il firmware a 000000h e la ROM YRW801 a 200000h.
Non sono inclusi campioni Yamaha.

La SDRAM condivisa assegna 000000h–1FFFFFh ai campioni YRW801,
200000h–3FFFFFh alla RAM campioni e 780000h–7FFFFFh alla VRAM.
L'arbitro UMA di tnCart mantiene i tempi video; un nuovo client converte
le richieste OPL4 in scritture di byte e letture allineate di 16 bit.
Il client aggiunge richieste di refresh e un watchdog di transazione.

## Modifiche rispetto ai progetti originali

- `moontang_shared_core.sv`: sostituisce il controller SDRAM privato con
  una porta wave esterna, mantenendo il loader YRW801 e il mixer.
- `wave_uma_bridge.sv`: collega quella porta al controller UMA.
- `combined_top.sv`: integra entrambi i dispositivi I/O, condividendo bus,
  SDRAM, SPI flash, reset e clock. Non espone ROM nello slot MSX.
- Tre banchi sincroni OPL4 da 32x8 sono assegnati a BSRAM anziché registri.
- Gli indici della FIFO grafica sono rappresentati da due puntatori base
  invece di 32 registri contenenti indici consecutivi modulo 32.
- Lettura e scrittura FIFO usano rotazioni condivise dei dati e della maschera;
  sono mantenuti gli aggiornamenti per cella e il comportamento precedente
  delle scritture simultanee.
- Il PCM gira a 54 MHz con clock enable 392/625 per 33,8688 MHz medi.
- La lettura FIFO combina rotazione e spostamento in un solo indirizzo,
  mantenendo le parti dell'uscita non aggiornate come nel circuito originale.
- Il prodotto dell'inviluppo PCM usa spostamenti: la tabella originale
  restituisce esclusivamente 0, 1, 2, 4 oppure 8.

## Compilazione riproducibile

Aprire una console nella cartella dei sorgenti e lanciare:

```text
gw_sh build.tcl
```

L'output previsto è `impl/pnr/wonder_opl4_v9990.fs`.
La presenza del file non sostituisce la verifica dei report di sintesi e timing.
Non utilizzare output di una compilazione precedente dopo un errore.
Il file consegnato supera il timing dei percorsi analizzati, con un margine
minimo di setup di circa 0,016 ns. Il margine è stretto: la prova fisica,
in particolare con video e audio simultanei, resta necessaria.

## Prove sull'hardware

Questa integrazione non è stata provata su una WonderTANG fisica.
Prima prova del firmware in SRAM, senza rendere permanente il cambio.
Inserire la cartuccia a MSX spento, collegare USB e caricare il `.fs` in SRAM.
La SRAM è volatile: non togliere alimentazione alla Tang tra caricamento e prova.
Accendere quindi il MSX mantenendo l'alimentazione USB durante il primo test.
Non inserire o rimuovere la cartuccia a MSX acceso.
Preparare una copia del firmware funzionante precedente.
Se YRW801 è già nella flash a 200000h, non serve riscriverla per il test SRAM.
Se manca, usare la propria immagine YRW801 da 2.097.152 byte, come file `.bin`.
In Gowin Programmer scegliere External Flash Mode, operazione
`exFlash C Bin Erase,Program thru GAO-Bridge`, Generic Flash e Start Address
`0x200000`. Nella maschera con sette cifre esadecimali è `0x0200000`:
il valore numerico deve essere 2.097.152, non 131.072 e non 33.554.432.
Programmare la ROM prima di caricare il firmware combinato in SRAM,
perché l'operazione GAO-Bridge sostituisce temporaneamente il circuito FPGA.
La programmazione permanente del `.fs` può cancellare dati: verificare
nuovamente YRW801 dopo ogni scrittura della flash.

Usare il video del MSX per BASIC/DOS e la porta HDMI della Tang per V9990.
L'audio esce da SOUNDIN/J3, non dall'HDMI.

1. Boot del NMS8245 dalla Pico+ e verifica che non resti bloccato.
2. Attendere che termini la copia YRW801. Il segnale LED diventa stabile
   con clock MSX presente; lampeggio lento indica caricamento, raffiche
   indicano errore. La polarità del LED determina se lo stato stabile
   appare acceso o spento: verificare poi con i programmi di test.
3. Da BASIC eseguire `LOAD "MT1DET.ASC",R` per rilevamento OPL4.
4. `MT4YRW.ASC` per contenuto dei campioni e `MT5RAM.ASC` per RAM scrivibile.
5. `MT2FM.ASC` e `MT6PCM.ASC` per audio FM e PCM.
6. Riprovare la stessa versione di Galaga V9990 già funzionante sul firmware
   precedente. I difetti originali di Tiny9990 non sono corretti qui.
7. Provare software che usi simultaneamente V9990 e OPL4: test separati dei
   due dispositivi non verificano la banda della SDRAM sotto carico combinato.

## Provenienza e licenze

MoonTANG: Papipapito/MoonTANG, commit b2770265d02cdf30c721a8ace12793e63ec6e776.
tnCartWonder: herraa1/tnCartWonder, commit d3a54f1b0df9e56c0d27ce1d0460f79f593d5568.

Sono mantenuti gli avvisi per-file e le licenze originali GPL/LGPL/BSD.
I nuovi moduli e le modifiche sono forniti sotto GPL-3.0-or-later.
Consultare LICENSE-MoonTANG e THIRD_PARTY-MoonTANG.md.
I controlli dei puntatori verificano l'aritmetica modificata, non costituiscono
una simulazione RTL dell'intera scheda o una validazione sull'hardware.
