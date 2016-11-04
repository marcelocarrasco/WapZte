#!/bin/bash
ps cax | grep wapzte.sh > /dev/null
if [ $? -eq 0 ]; then
  echo "Process is running."
else
  sh /calidad/WapZte/Scripts/scpWapZte.sh
  sh /calidad/WapZte/Scripts/cleanUpFiles.sh '/calidad/WapZte'
  sh /calidad/WapZte/Scripts/wapzte.sh
fi
exit
