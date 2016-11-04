#!/bin/bash
<<COMMENT
Copia los archivos de una fecha determinada
Usage: scpWapZteDate.sh 'YYYYMMDD'
COMMENT
scp ztearchive@10.105.146.8:/home/ztearchive/wapgw/*$1*.csv  calidad@10.92.56.198:/calidad/WapZte/wapgw
exit
