import sys, os
sys.path.insert(0, os.path.abspath(os.path.join(os.path.dirname(__file__), "../application_example")))
import example

def test_add_one():
    assert example.add_one(2)==3
