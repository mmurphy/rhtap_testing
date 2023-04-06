#!/usr/bin/env bash
npm install
sh ./check_template_params.sh
[ -x public ] || mkdir public
sh ./paramsform.html.sh
npm run generate

