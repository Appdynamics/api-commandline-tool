#!/bin/bash
#
# Export ALL Dashboards and Applications from a controller - backups!
#
# Put in crontab to run daily at midnight
#   Ex:
#   0       0        *       *       *       $HOME/bin/exportDashboardsApplications.sh >> /data/backups/exports/exportDashboardsApplications.out 2>&1
#
# Requirements: Download jq @ https://stedolan.github.io/jq/download/
#
# 20190125 - eli.rodriguez@appdynamics.com
#
# Each dashboard and application will be put in a subdirectory with the file name as its ID

#
# Put this script, act.sh and the jq in the your bin directory
#
cd $HOME/bin

#
# Location of the backup files
#
BACKUPDIR=/data/backups/exports

# Shouldn't need to update anything below this
DATE=`date +%Y%m%d`

# subdirectories where the dashboards and applications will be backed up to
BKUPDASHBOARDS=$BACKUPDIR/dashboards/$DATE
BKUPAPPS=$BACKUPDIR/applications/$DATE

# This will grab the dashboard id and names in an array.
DASHBOARDS=$(./act.sh dashboard list | ./jq -r 'to_entries[] | [.value.id, .value.name] | @tsv'| sed 's/ //g'| sed 's/\t/-/g')

# Only grab the appication ids
APPLICATIONIDS=$(./act.sh application list | grep "<id>" | sed "s# *<id>\([^<]*\)</id>#\1#g")

# Make the backup directories if they don't exist.
mkdir -p $BKUPDASHBOARDS $BKUPAPPS

#
# Tar and compress backup dir and delete if success
#
compress_then_delete_directory () {
	local dirToBackup=$1
	# Tar up the directory specified
	/bin/tar -czpf ${dirToBackup}.tar.gz -C ${dirToBackup%/*} $DATE
	status=$?
	# If tar was successful, delete original directory...we want to keep only the compressed tar files.
	if test $status -eq 0; then
		delete_directory $dirToBackup
	else
		echo Backup of $dirToBackup failed... status = $status
	fi
}

#
# Recursively delete directory specified
#
delete_directory () {
	local dirToDelete=$1
	# TODO: Put a check for path ending in today's date...and only then delete it...
	echo dirToDelete=$dirToDelete
	rm -rf $dirToDelete
}



echo START : $(date)
echo "Backing dashboards..."
for DASHBOARD in $DASHBOARDS
do
#	echo $DASHBOARD
	# Grab only the dashboard id from the name.  We don't need the rest, but we have it if we want it to name our files with the full names
	DASHBOARDID=$(echo ${DASHBOARD} | awk -F\- '{print $1}')
    $HOME/bin/act.sh dashboard export -i $DASHBOARDID > $BKUPDASHBOARDS/${DASHBOARDID}

done;

echo "Backing applications..."

for APPLICATIONID in $APPLICATIONIDS
do
#	echo $APPLICATIONID
    $HOME/bin/act.sh application export -a $APPLICATIONID > $BKUPAPPS/${APPLICATIONID}
done;

echo END: $(date)



compress_then_delete_directory $BKUPDASHBOARDS
compress_then_delete_directory $BKUPAPPS

