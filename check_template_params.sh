#!/usr/bin/env sh
#
export TMPFOLDER=$(mktemp -d -t view-XXXXXXXXXXXXXXXXXX)
cat ciew.handlebars | sed 's/{{/\n{{/g' | sed -r 's/^[-{]*\{\{(#if)? *([a-zA-Z0-9 ]+)\}\}.*$/param: \2/g'|grep 'param: '|sort |uniq |awk '{print $2}' > ${TMPFOLDER}/params_used_in_template.txt
cat ciew.handlebars | awk '/START PARAMETER DEFINITIONS/{flag=1;next} /END PARAMETER DEFINITIONS/{flag=0} flag' > ${TMPFOLDER}/param_definitions.txt
export IFS='='
cat ${TMPFOLDER}/param_definitions.txt | while read PROMPT PARAM TYPE REST
do
  echo "$PARAM" 
done | sort | uniq > ${TMPFOLDER}/parameters_defined.txt
export ERROR=0
echo "\nDefined but not used:"
grep -v -w -f ${TMPFOLDER}/params_used_in_template.txt ${TMPFOLDER}/parameters_defined.txt
if [ $? != 1 ]
then
  ERROR=1
fi
echo "\nUsed but not defined:"
grep -v -w -f ${TMPFOLDER}/parameters_defined.txt ${TMPFOLDER}/params_used_in_template.txt 
if [ $? != 1 ]
then
  ERROR=1
fi
exit $ERROR
