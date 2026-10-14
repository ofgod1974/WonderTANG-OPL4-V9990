"""Exhaustive arithmetic equivalence check for the FIFO pointer optimization.
This checks the changed address arithmetic, not RTL simulation or hardware.
"""
from random import Random

for vol in range(1024):
    for inc,shift in ((0,0),(1,0),(2,1),(4,2),(8,3)):
        original=((~vol)*inc)&2047
        optimized=(((~vol)&2047)<<shift)&2047 if inc else 0
        assert original==optimized
for base in range(32):
    for shift in range(16):
        for lane in range(shift,16):
            assert (base+lane-shift)%32 == ((base-shift)%32+lane)%32
print('PASS: 5120 envelope products and all merged FIFO read addresses')

checks = 0
for base in range(32):
    for mode in range(4):
        for count in range(32):
            step = (count << mode) & 31
            old = [((base+i)+step)&31 for i in range(16)]
            new_base = (base+step)&31
            assert old == [(new_base+i)&31 for i in range(16)]
            checks += 1

rng = Random(2350)
old_w = old_r = list(range(16))
w = r = 0
for cycle in range(100000):
    clear = rng.randrange(100) == 0
    w_enable, r_enable = rng.randrange(2), rng.randrange(2)
    ws = rng.randrange(32)
    rs = (rng.randrange(32) << rng.randrange(4)) & 31
    if clear:
        old_w, old_r = list(range(16)), list(range(16))
        w = r = 0
    else:
        if w_enable:
            old_w = [(x+ws)&31 for x in old_w]
            w = (w+ws)&31
        if r_enable:
            old_r = [(x+rs)&31 for x in old_r]
            r = (r+rs)&31
    assert old_w == [(w+i)&31 for i in range(16)]
    assert old_r == [(r+i)&31 for i in range(16)]
print(f'PASS: {checks} exhaustive cases and 100000 sequential pointer events')

def original_write(memory, base, mask, data):
    result = memory.copy()
    for i in range(16):
        if mask & (1 << i):
            result[(base+i)&31] = data[i]
    return result

def cell_write(memory, base, mask, data):
    result = memory.copy()
    for j in range(32):
        i = (j-base)&31
        if i < 16 and mask & (1 << i):
            result[j] = data[i]
    return result

# Each write-enable bit is independent: exhaust every base, enable position
# and input value, including address wraparound and the no/all-enable cases.
for base in range(32):
    for mask in [0,65535]+[1<<i for i in range(16)]:
        for value in range(4):
            data = [(value+i)&3 for i in range(16)]
            mem = [i&3 for i in range(32)]
            assert original_write(mem,base,mask,data) == cell_write(mem,base,mask,data)
mem = [0]*32
for _ in range(10000):
    base, mask = rng.randrange(32), rng.randrange(65536)
    data = [rng.randrange(4) for _ in range(16)]
    a = original_write(mem,base,mask,data)
    b = cell_write(mem,base,mask,data)
    assert a == b
    mem = a
print('PASS: per-cell FIFO writes, wraparound, masks, and 10000 random transactions')
