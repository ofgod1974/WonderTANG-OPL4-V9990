# Esito integrazione OPL4 + V9990

Senza violazioni nei percorsi analizzati

Firmware sperimentale, non provato sull’hardware. Vincoli derivati da tnCart; i risultati non verificano tutti gli I/O esterni o la banda sotto carico combinato.

## Occupazione

```text


  --------------------------------------------------------------------------------
  Resources                   | Usage                               | Utilization
  --------------------------------------------------------------------------------
  Logic                       | 19225/20736                         |  93%
    --LUT,ALU,ROM16           | 18421(14880 LUT, 3541 ALU, 0 ROM16) | -
    --SSRAM(RAM16)            | 134                                 | -
  Register                    | 9469/15915                          |  60%
    --Logic Register as Latch | 0/15552                             |  0%
    --Logic Register as FF    | 9404/15552                          |  61%
    --I/O Register as Latch   | 0/363                               |  0%
    --I/O Register as FF      | 65/363                              |  18%
  CLS                         | 10160/10368                         |  98%
  I/O Port                    | 54/66                               |  82%
  I/O Buf                     | 48                                  | -
    --Input Buf               | 14                                  | -
    --Output Buf              | 26                                  | -
    --Inout Buf               | 8                                   | -
  IOLOGIC                     | 8/121                               | 7%
    --OSER10                  | 4
  BSRAM                       | 42/46                               | 92%
    --SPX9                    | 1
    --SDPB                    | 16
    --SDPX9B                  | 4
    --DPB                     | 15
    --pROM                    | 6
  DSP                         | 1/24                                | 5%
    --MULT18X18               | 2
  ================================================================================




```

## Violazioni

Nessuna nei domini analizzati.

SHA256 bitstream: `cacbd4000a5295e315dba0bff4b3e4c03c4886b5517fe7153bab1978ae32fbd1`
