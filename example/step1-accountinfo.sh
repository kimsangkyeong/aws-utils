#!/bin/sh

INPUT_PATH=/data/accountinfo/input
OUTPUT_PATH=/data/accountinfo/result
TRANSFER_PATH=/data/rating/input

echo "========"
date
echo "-pgm--" 
echo $0
id
echo "# ls -alF /"
ls -alF /
echo "# ls -alF /data"
ls -alF /data
echo "--------"
echo "environment - JOB_DATA : ${JOB_DATA}"
mkdir -p ${INPUT_PATH} 2> /dev/null
echo "start : $0 " > ${INPUT_PATH}/${JOB_DATA}_A
mkdir -p ${OUTPUT_PATH} 2> /dev/null
echo "$0 : success" > ${OUTPUT_PATH}/${JOB_DATA}_A.result
mkdir -p ${TRANSFER_PATH} 2> /dev/null
echo "$0 passes to rating "  > ${TRANSFER_PATH}/${JOB_DATA}_B
echo "--------"
echo "# ls -al ${INPUT_PATH}"
ls -al ${INPUT_PATH}
echo "# cat  ${INPUT_PATH}/${JOB_DATA}_A"
cat  ${INPUT_PATH}/${JOB_DATA}_A
echo "# ls -al ${OUTPUT_PATH}"
ls -al ${OUTPUT_PATH}
echo "# cat ${OUTPUT_PATH}/${JOB_DATA}_A.result"
cat ${OUTPUT_PATH}/${JOB_DATA}_A.result
echo "# ls -al ${TRANSFER_PATH}"
ls -al ${TRANSFER_PATH}
echo "# cat ${TRANSFER_PATH}/${JOB_DATA}_B "
cat ${TRANSFER_PATH}/${JOB_DATA}_B
echo "########"

