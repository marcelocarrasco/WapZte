#!/bin/bash

scp ztearchive@10.105.146.8:/home/ztearchive/wapgw/*$(date --date=''yesterday'' +%Y%m%d)*.csv  calidad@10.92.56.198:/calidad/WapZte/wapgw
exit
