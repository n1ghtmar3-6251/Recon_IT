#!/usr/bin/env python3

import requests
import argparse
import re
import os

def banner():
	os.system('echo "$(tput setaf 1)==================================================================================================  $(tput sgr 0)"')
	os.system('echo "$(tput setaf 1)||$(tput sgr 0)$(tput setaf 4)                     FFFFFFFFFF           BB              IIIIIII       $(tput sgr 0)                     $(tput setaf 1) ||$(tput sgr 0)"')
	os.system('echo "$(tput setaf 1)||$(tput sgr 0)$(tput setaf 4)                     F                    B  B               I          $(tput sgr 0)                     $(tput setaf 1) ||$(tput sgr 0)"')
	os.system('echo "$(tput setaf 1)||$(tput sgr 0)$(tput setaf 4)                     F                    B    B             I          $(tput sgr 0)                     $(tput setaf 1) ||$(tput sgr 0)"')
	os.system('echo "$(tput setaf 1)||$(tput sgr 0)$(tput setaf 4)                     F                    B  B               I          $(tput sgr 0)                     $(tput setaf 1) ||$(tput sgr 0)"')
	os.system('echo "$(tput setaf 1)||$(tput sgr 0)$(tput setaf 4)                     FFFFFFFFFF           BB                 I          $(tput sgr 0)                     $(tput setaf 1) ||$(tput sgr 0)"')
	os.system('echo "$(tput setaf 1)||$(tput sgr 0)$(tput setaf 4)                     F                    B  B               I          $(tput sgr 0)                     $(tput setaf 1) ||$(tput sgr 0)"')
	os.system('echo "$(tput setaf 1)||$(tput sgr 0)$(tput setaf 4)                     F                    B   B              I          $(tput sgr 0)                     $(tput setaf 1) ||$(tput sgr 0)"')
	os.system('echo "$(tput setaf 1)||$(tput sgr 0)$(tput setaf 4)                     F                    B  B               I      $(tput sgr 0)$(tput setaf 6)This is FBI$(tput sgr 0)              $(tput setaf 1) ||$(tput sgr 0)"')
	os.system('echo "$(tput setaf 1)||$(tput sgr 0)$(tput setaf 4)                     F                    BB              IIIIIII   $(tput sgr 0)$(tput setaf 6)Auntyr Chele Dorja Khol$(tput sgr 0)  $(tput setaf 1) ||$(tput sgr 0)"')
	os.system('echo "$(tput setaf 1)==================================================================================================$(tput sgr 0)"')
	os.system('echo "               $(tput setaf 6)|$(tput sgr 0)  Developed By      :   N1GHTMAR3                          $(tput setaf 6)|$(tput sgr 0)"')
	os.system('echo "               $(tput setaf 6)|$(tput sgr 0)  Github            :   https://github.com/n1ghtmar3-6251  $(tput setaf 6)|$(tput sgr 0)"')
	os.system('echo "               $(tput setaf 6)|$(tput sgr 0)  Telegram ID       :   https://t.me/n1ghtmar3_2421        $(tput setaf 6)|$(tput sgr 0)"')
	os.system('echo "               $(tput setaf 6)|$(tput sgr 0)  Discord Channel   :   https://discord.gg/4yFfKr2r        $(tput setaf 6)|$(tput sgr 0)"')
	os.system('echo "               $(tput setaf 6)|===========================================================|$(tput sgr 0)"')


def parse_args():
	parser = argparse.ArgumentParser(description="XSS Sanity check on custom parameter")
	parser.add_argument('-f','--file',type=str,dest="file",help="file location i.e.: /root/file_name.txt")
	return parser

def filename(f1):
	with open(f1) as f:
		global url
		url = f.readlines()

def xss():
	for i in range(len(url)):
		if "?" in url:
			req1 = requests.get(url[i].rstrip('\n') +"&balsal'\"><heda=gushti'\"><chudi")
			res1 = req1.text
			if "balsal" in res1:
				a = re.findall("balsal(.*)chudi",res1)[0]
				print(url[i].rstrip('\n')  + "  :   " + a)

		else:
			req2 = requests.get(url[i].rstrip('\n') +"?balsal'\"><heda=gushti'\"><chudi")
			res2 = req2.text
			if "balsal" in res2:
				a = re.findall("balsal(.*)chudi",res2)[0]
				print(url[i].rstrip('\n')  + "  :   " + a)


if __name__ == "__main__":
	banner()
	parser=parse_args()
	args=parser.parse_args()
	filename(args.file)
	xss()