#!/bin/bash
#delete folder after 20 day from last write a file
find ../file/* -type d -ctime +20 -exec rm -rf {} \;
