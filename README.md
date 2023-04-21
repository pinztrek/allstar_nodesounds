# allstar_nodesounds
Script to populate callsign ulaws for the node list

This script will parse the US callsigns in the /var/log/asterisk/astdb.txt list of nodes. 

Currently it does rudementary exclusion of non-callsign info, only allowing callsigns with / or hyphen.

It will create ulaw files for any missing nodes in /var/lib/asterisk/sounds/rpt/nodenames which is where allstar looks for customized names. 

Any existing nodes will be skipped. 

Options:
- -v enables verbose mode and lists files it skips
- -d enables debugging mode and shows more detail on the read strings
- -s creates no output unless an error occurs
- -? print usage
