#!/bin/sh

INPUT_PATH=/data/cdrpersistence/input
OUTPUT_PATH=/data/cdrpersistence/result

echo "========"
date
echo "-pgm--" 
echo $0
id
echo "# ls -alF /"
ls -alF /
echo "# ls -alF /data "
ls -alF /data
echo "--------"
echo "environment - JOB_DATA : ${JOB_DATA}"
echo "step3 end process : $0 " > ${INPUT_PATH}/${JOB_DATA}
mkdir -p ${OUTPUT_PATH} 2> /dev/null
echo "$0 : success" > ${OUTPUT_PATH}/${JOB_DATA}.result
echo "--------"
echo "# ls -al ${INPUT_PATH} "
ls -al ${INPUT_PATH}
echo "# cat  ${INPUT_PATH}/${JOB_DATA}"
cat  ${INPUT_PATH}/${JOB_DATA}
echo "# ls -al ${OUTPUT_PATH}"
ls -al ${OUTPUT_PATH}
echo "# cat ${OUTPUT_PATH}/${JOB_DATA}.result "
cat ${OUTPUT_PATH}/${JOB_DATA}.result
echo "########"

