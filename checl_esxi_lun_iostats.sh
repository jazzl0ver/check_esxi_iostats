#!/bin/bash

ESXHOST=$1
NAME=$2

[ -z $ESXHOST ] && echo "Usage: $(basename $0) ESX_Server_IP [Device_Name]" && exit

VCHOST=1.2.3.4
USER=user
PASS=pass

#-- list of metrics to show, counting from 0
FIELDS="0 3 4 5 6 7 8 9 10 13 23 29 30"

TMP1=$(mktemp -p /tmp $(basename $0).XXXXXXXXX)
TMP2=$(mktemp -p /tmp $(basename $0).XXXXXXXXX)
TMP3=$(mktemp -p /tmp $(basename $0).XXXXXXXXX)

#-- if device name is not specified, use the 1st "Local DELL Disk" occurence in the storage adapters devices list
[ -z "$NAME" ] && NAME=$(esxcli -s $VCHOST -h $ESXHOST -u $USER -p $PASS storage core device list | grep "Local DELL Disk" | cut -f2 -d\( | cut -f1 -d\) | tail -1)

echo $PASS | resxtop -c /usr/lib/nagios/plugins/esxtop.conf --server $VCHOST --vihost $ESXHOST --username $USER -b -d 2 -n 1 -s > $TMP1 2>/dev/null

FIELD_START=$(head -1 $TMP1 | sed -e 's/,/\n/g' | grep -n "$NAME" | head -1 | cut -f1 -d:)
[ -z "$FIELD_START" ] && echo "IOSTATS CRITICAL: Device name '$NAME' was not found" && exit

FIELD_STR=$FIELD_START
for i in $(echo $FIELDS); do
    FIELD_STR="$FIELD_STR,$(($FIELD_START+$i))"
done

cat $TMP1 | cut -f${FIELD_STR} -d, > $TMP2

HEAD=$(cat $TMP2 | head -1 | sed -e 's/,/\n/g' | cut -f5 -d\\ | sed -e 's/[\\"]//g' | sed -e 's/ /_/g')

echo -e $HEAD | sed -e 's/ /,/g' | sed 's|/|_per_|g' > $TMP3
cat $TMP2 | tail -1 | sed -e 's/[\\"]//g' >> $TMP3

cat $TMP3 | perl -e '
    $header = <>;  chop($header);
    $data = <>;  chop($data);
    @header = split(",", $header);
    @data = split(",", $data);
    $nagios_data1 = ""; $nagios_data2 = "";
    for ( $c = 0; $c <= $#header; $c++) {
        $nagios_data1 .= "$header[$c]=$data[$c]";
#       $nagios_data1 .= " ms" if ($header[$c] =~ /MilliSec/);
#       $nagios_data1 .= " mbps" if ($header[$c] =~ /MBytes/);
        $nagios_data1 .= " %" if ($header[$c] =~ /%/);
        $nagios_data1 .= ", " if ($c != $#header);
        $nagios_data2 .= " $header[$c]=$data[$c]";
#       $nagios_data2 .= "ms;;" if ($header[$c] =~ /MilliSec/);
#       $nagios_data2 .= "mbps;;" if ($header[$c] =~ /MBytes/);
        $nagios_data2 .= "%;;" if ($header[$c] =~ /%/);
    }
    print "IOSTATS OK : $nagios_data1 |$nagios_data2;;\n";
'

/bin/rm $TMP1 $TMP2 $TMP3
