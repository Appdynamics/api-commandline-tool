# RECIPES

## Applications

### Batch create applications

```shell
#!/bin/bash
NAMES="AD-Test1 AD-Test2 AD-Test3"

for NAME in $NAMES
do
echo "CREATE ${NAME}"
../act.sh application create -n "${NAME}" -t "APM"
done;
```

### Delete all applications on one controller

```shell
#!/bin/bash
EXISTING_APPLICATION_IDS=`../act.sh application list | grep "<id>" | sed "s# *<id>\([^<]*\)</id>#\1#g"`

for APPLICATION in $EXISTING_APPLICATION_IDS
do
echo "DELETE ${APPLICATION}"
../act.sh application delete -a "${APPLICATION}"
done;
```

### Events

### Application Deployment

Integrate this command with your deployment process

```shell
#!/bin/bash
APPLICATION=$1
SUBJECT=$2
COMMENT=$3
../act.sh event create -s INFO -c "${COMMENT}" -e APPLICATION_DEPLOYMENT -a ${APPLICATION} -s "${SUBJECT}" -l INFO
```
