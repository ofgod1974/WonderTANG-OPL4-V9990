"""Check the actual combinational CE field against Yamaha V9990 P#6.

This is a truth-table test of the expression extracted from the RTL source,
not an event-driven simulation of the whole core.
P#5.CE means executing; P#6.CE means command completed (manual, p.76).
"""
from pathlib import Path
import re
import unittest

PORT = Path(__file__).resolve().parents[1]/'rtl/src/peripheral/video/tiny9990/t9990_port.sv'
EXPR = re.search(r'p6_cd_data\s*=\s*\{\s*5\s*\x27b00000\s*,([^,]+),',
                 PORT.read_text(encoding='utf-8-sig')).group(1).strip()

def evaluate(expr, saved, busy, event):
    values={'CE_save':saved,'STATUS.CE':busy,'STATUS.CE_intr':event}
    terms=[x.strip() for x in expr.split('|')]
    assert all(x in values for x in terms), terms
    result=0
    for x in terms: result |= values[x]
    return result

class CommandCompletionTests(unittest.TestCase):
    def test_all_busy_event_and_latch_combinations(self):
        for saved in (0,1):
            for busy in (0,1):
                for event in (0,1):
                    self.assertEqual(evaluate(EXPR,saved,busy,event),saved|event)

    def test_executing_is_not_completed(self):
        self.assertEqual(evaluate(EXPR,0,1,0),0)

    def test_latched_completion_survives_next_command(self):
        self.assertEqual(evaluate(EXPR,1,1,0),1)

    def test_original_expression_is_detected_as_wrong(self):
        self.assertNotEqual(evaluate('CE_save | STATUS.CE',0,1,0),0)
        self.assertNotEqual(evaluate('CE_save | STATUS.CE',0,0,1),1)

if __name__=='__main__': unittest.main(verbosity=2)
