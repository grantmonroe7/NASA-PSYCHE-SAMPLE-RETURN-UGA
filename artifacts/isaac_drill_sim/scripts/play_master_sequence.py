#!/usr/bin/env python3
"""
Minimal skeleton for playing the autonomous master sequence inside Isaac Sim.

This script is intentionally lightweight.  It demonstrates the command flow
that mirrors 07_master_sequence.m.  Replace the print / sleep stubs with
real joint commands once the USD articulation is available.
"""

import time
import yaml
from pathlib import Path

CONFIG = Path(__file__).parent.parent / "configs" / "default_params.yaml"

def load_params():
    with open(CONFIG) as f:
        return yaml.safe_load(f)

def cold_start_jog(params, duration=90.0, duty=0.3):
    print(f"[ISAAC] Cold-start jog for {duration:.0f}s @ {duty*100:.0f}% duty")
    # TODO: command low effort on penetration joint
    time.sleep(1.0)  # placeholder

def clamp(action="close"):
    print(f"[ISAAC] Clamp → {action}")
    # TODO: set gripper effort / position
    time.sleep(0.5)

def run_mode(mode_name, params):
    mode = params["modes"][mode_name]
    print(f"[ISAAC] Running mode {mode_name}: {mode}")
    # TODO: apply torque / velocity profile for mode["duration_s"]
    time.sleep(1.0)

def extract(mode_name, params):
    print(f"[ISAAC] Extraction (reverse of {mode_name})")
    # TODO: reverse commands at reduced magnitude
    time.sleep(1.0)

def master_sequence(mode="LVHT", do_cold_start=True):
    params = load_params()
    print("========================================")
    print(f"  ISAAC MASTER SEQUENCE – mode = {mode}")
    print("========================================")

    if do_cold_start:
        cold_start_jog(params)

    clamp("close")
    run_mode(mode, params)
    extract(mode, params)
    clamp("open")

    print("[ISAAC] Sequence complete.")

if __name__ == "__main__":
    master_sequence("LVHT", do_cold_start=True)