from random import Random
rng=Random(20261014)
for base in range(32):
    for trial in range(2048):
        data=rng.getrandbits(32)
        mask=rng.getrandbits(16)
        rotated=((data<<64)|data)>>(64-2*base)
        rotated_mask=((mask<<32)|mask)>>(32-base)
        for cell in range(32):
            index=(cell-base)&31
            assert ((rotated_mask>>cell)&1)==(bool(mask&(1<<index)) if index<16 else False)
            if index<16:
                assert ((rotated>>(2*cell))&3)==((data>>(2*index))&3)
        memory=rng.getrandbits(64)
        for shift in range(16):
            origin=(base-shift)&31
            output=((memory<<64)|memory)>>(2*origin)
            for lane in range(shift,16):
                assert ((output>>(2*lane))&3)==((memory>>(2*((base+lane-shift)&31)))&3)
print('PASS: shared read/write rotations, masks, wraparound; 65536 data cases')

