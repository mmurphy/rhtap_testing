#!/usr/bin/env sh
#
export TMPFOLDER=$(mktemp -d -t view-XXXXXXXXXXXXXXXXXX)
export PARAMSFORMHTML=${TMPFOLDER}/paramsform.hbs
export PARAMSOPTIONSJS=${TMPFOLDER}/paramsoptions.hbs
export PARAMSSETOPTIONSJS=${TMPFOLDER}/paramssetoptions.hbs

cat ciew.handlebars | awk '/START PARAMETER DEFINITIONS/{flag=1;next} /END PARAMETER DEFINITIONS/{flag=0} flag' > ${TMPFOLDER}/param_definitions.txt

export STARTFORMMARKER='<!-- START GENERATED FORM INPUTS - Do Not Edit -->'
export ENDFORMMARKER='<!-- END GENERATED FORM INPUTS - Do Not Edit -->'

export STARTPARAMETERSMARKER='/* START GENERATED PARAMETER OPTIONS - Do Not Edit */'
export ENDPARAMETERSMARKER='/* END GENERATED PARAMETER OPTIONS - Do Not Edit */'
export STARTSETPARAMETERSMARKER='/* START GENERATED SET PARAMETER OPTIONS - Do Not Edit */'
export ENDSETPARAMETERSMARKER='/* END GENERATED SET PARAMETER OPTIONS - Do Not Edit */'

echo "${STARTFORMMARKER}" > ${PARAMSFORMHTML}
echo "${STARTPARAMETERSMARKER}" > ${PARAMSOPTIONSJS}
echo "${STARTSETPARAMETERSMARKER}" > ${PARAMSSETOPTIONSJS}

export IFS='='
cat ${TMPFOLDER}/param_definitions.txt | while read PROMPT PARAM TYPE REST
do
  echo "<div class=\"question ${REST}\">" >> ${PARAMSFORMHTML}
  echo "<label for=\"$PARAM\">$PROMPT</label><br/>" >> ${PARAMSFORMHTML}
  echo "<input type=\"$TYPE\" id=\"$PARAM\" value=\"$PROMPT\" class=\"${REST}\">" >> ${PARAMSFORMHTML}
  echo "</div>"  >> ${PARAMSFORMHTML}
  echo ""  >> ${PARAMSFORMHTML}
  if [ "$TYPE" == "checkbox" ]
  then
    echo "$PARAM: document.getElementById('$PARAM').checked," >> ${PARAMSOPTIONSJS}
    echo "document.getElementById('$PARAM').checked = options.$PARAM" >> ${PARAMSSETOPTIONSJS}
  else
    echo "$PARAM: document.getElementById('$PARAM').value," >> ${PARAMSOPTIONSJS}
    echo "document.getElementById('$PARAM').value = options.$PARAM" >> ${PARAMSSETOPTIONSJS}
  fi
done

echo "${ENDFORMMARKER}" >> ${PARAMSFORMHTML}
echo "${ENDPARAMETERSMARKER}" >> ${PARAMSOPTIONSJS}
echo "${ENDSETPARAMETERSMARKER}" >> ${PARAMSSETOPTIONSJS}

./node_modules/.bin/hbs "$PWD/index.html" --partial ${PARAMSFORMHTML} --partial ${PARAMSOPTIONSJS} --partial ${PARAMSSETOPTIONSJS} --output ./public
cp style.css public/
