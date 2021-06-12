# https://github.com/thomasrussellmurphy/istyle-verilog-formatter

import subprocess
import os
from pyautogui import hotkey
import pyautogui
from time import sleep
from keyboard import add_hotkey

rep_name = 'sv-drsstc-controller'

path = f'C:\\Github\\{rep_name}'

save_hotkey = 'ctrl s'
comp_hotkey = 'ctrl d'

save_delay_ms = 100


def with_hk(str, type=0):
	if type == 0:
		return str.replace(' ', '+')
	return tuple(str.split(' '))


def format_and_run():
	subprocess.call('node ./utils/include_fix.js')
	subprocess.call(f'iStyle -T2 -a -o -n {path}\\modules\\*.sv')
	subprocess.call(f'iStyle -T2 -a -o -n {path}\\src\\*.sv')
	subprocess.call(f'iStyle -T2 -a -o -n {path}\\dist\\*.sv')
	subprocess.call(f'iStyle -T2 -a -o -n {path}\\*.sv')


def compile():
	sleep(2 * save_delay_ms / 1000)
	pyautogui.hotkey('ctrl', 'm')
	sleep(save_delay_ms / 1000)
	pyautogui.write('npm run sim')
	sleep(save_delay_ms / 2000)
	pyautogui.hotkey('enter')


# ctrl + S for formatting and save
add_hotkey(with_hk(save_hotkey), format_and_run)

# ctrl + D for compiling
add_hotkey(with_hk(comp_hotkey), compile)

input('press any key to exit\n')
