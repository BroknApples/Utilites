# ============================================================================
# Copyright (c) 2026 Brokn_Apples
# All rights reserved.
#
# Description:
#     Bare-bones autoclicker python script
# Usage:
#     Run from command prompt: python auto_click.py
# ============================================================================


import threading
import random
from pynput.mouse import Button, Controller as MouseController
from pynput.keyboard import Listener, KeyCode, Key

# Initialize mouse controller
mouse = MouseController()

# Toggle combo: Shift + \
TOGGLE_KEY = Key.f6

# Auto-clicker state
clicking = False
shift_held = False

# Time between clicks
CLICK_MIN = 2.7
CLICK_MAX = 4.2

# Function to perform mouse clicking
def clicker():
	while True:
		if clicking:
			wait_time = random.uniform(CLICK_MIN, CLICK_MAX)
			threading.Event().wait(wait_time)
			mouse.click(Button.left, 1)
		else:
			threading.Event().wait(0.1)


# Keyboard press handler
def onPress(key):
	global clicking, shift_held

	if key in (Key.shift, Key.shift_l, Key.shift_r):
		shift_held = True

	elif shift_held and key == TOGGLE_KEY:
		if not clicking:
			mouse.click(Button.left, 1)  # initial click
		clicking = not clicking
		print(f"Autoclicker {'ON' if clicking else 'OFF'}")


# Keyboard release handler
def onRelease(key):
	global shift_held

	if key in (Key.shift, Key.shift_l, Key.shift_r):
		shift_held = False


if __name__ == "__main__":
	print("Running auto_click.py!")

	click_thread = threading.Thread(target=clicker, daemon=True)
	click_thread.start()

	with Listener(on_press=onPress, on_release=onRelease) as listener:
		listener.join()
