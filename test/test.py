from requests import *
from subprocess import call

def main():
    call("./install-auth.sh", shell=True)
    call("./build-run.sh", shell=True)



main()