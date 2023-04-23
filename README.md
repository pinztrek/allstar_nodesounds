# allstar_nodesounds
## Script to populate custom callsign readout ulaws for the allstar node list

The standard allstarlink distribution has a little known provision to check a specific directory for a *12345.ulaw* file corresponding to a node and play it instead of the standard *"NODE 12345 Connected"*. This works well and really helps reduce confusion for users not familiar with allstar. I had been using customized node readouts for some time that I made manually, which worked find for frequent connections. Ex: Audio recording *KM4BA remote base"* connected was saved as 55871.ulaw.  But if an arbitrary station connected in ASL still just announced the node number as there was no customized file present. 

It occurred to me that we already had a file on the ASL system which had node/callsign combinations which was periodically updated. 

This script will parse the */var/log/asterisk/astdb.txt* list of nodes for US callsigns and create a custom ulaw sound file which reads out the node's callsign. 

Currently it does rudementary exclusion of non-callsign info, only allowing well formed callsigns including those with **/** or **hyphen** suffixes.

It will create ulaw files for any missing nodes in */var/lib/asterisk/sounds/rpt/nodenames* which is where allstar looks for customized names. 

Any existing nodes will be skipped, and new nodes will be created. 

## Options:
- **-v** enables verbose mode and lists files it skips
- **-d** enables debugging mode and shows more detail on the read strings
- **-s** creates no output unless an error occurs
- **-D** sets dryrun mode, no files will be created
- **-?** print usage


Defaults to the dirs and files used in the allstarlink distribution:
- Sounds in */var/lib/asterisk/sounds*
- Nodes sounds in subdir *rpt/nodename* under the sounds directory
- Node list file: */var/log/asterisk/astdb.txt*

## Typical installation:
>cd /usr/local/bin<br>
>wget https://github.com/pinztrek/allstar_nodesounds/raw/main/build_nodes.sh -O build_nodes.sh<br>
>chmod a+x build_nodes.sh

## Typical use case:
Run it daily by adding to the */etc/cron.daily/allstar-helpers* script:
> /usr/local/bin/build_nodes.sh >/tmp/build_nodes.run 2>/tmp/build_nodes.err

Either edit the file or **carefully** run:
> sudo echo '/usr/local/bin/build_nodes.sh >/tmp/build_nodes.run 2>/tmp/build_nodes.err' >> /etc/cron.daily/allstar-helpers 

Which should append the entry to your file. **(Note the above block is one long line with stdout and stderr redirected to files in /tmp)**
## Notes:
- Exclusions are handled brute force with daisy chained grep -v pipes. You can add additional ones as needed
- variable *callprefix* contains the first letters of US calls. This can be customized to include other countries, but be cautious that other letters can include words other than callsigns.
- variable *callmatch* contains regex to match a typical callsign, including most foreign ones. Debug mode will show if a callsign is valid or not. 
- The script does not enforce strict error checking on suffixes after a **/** or **-**. Nodes should not have extranious info in the 2nd field with the callsign, but if they did the string would be read out if the node was linked. 
- There are over 20k US callsigns, so you'll need ~650Mb free before running the script. With 32G micro sd cards so cheap now there's no reason to be tight on space anymore. There are not as many non-US callsigns, so I may add an option to include WW calls as well. But it's not been a need to date. 
