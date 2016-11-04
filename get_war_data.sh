#!/bin/sh
URL=http://www.war-memorial.net/wars_all.asp
RE_WARS="/Mem. Note/,/^$/p"
RE_REFS="/References/,//p"
DATA="$(lynx -dump "${URL}" | sed -n "${RE_WARS};${RE_REFS}")"

cat << EOF
Wars since 1900
===============

EOF

WARS=$(echo "${DATA}" | sed -n "${RE_WARS}" | tac)
REFS=$(echo "${DATA}" | sed -n "${RE_REFS}")

echo "${WARS}" | while read -r WAR ; do
	REFNUM=$(echo "${WAR}" | sed -n 's/^\[\([0-9]\+\)\].*/\1/p')
	REF=$(echo "${REFS}" | sed -n "s/^ \+${REFNUM}\. //p")
	DATESORIG=$(echo "${WAR}" | sed -n 's/.*[^0-9]\([0-9]\{4\} - [0-9]\{4\}\).*/\1/p')
	BEG=$(echo "${WAR}" | sed -n 's/.*[^-0-9]\{2\}\([0-9]\{4\}\).*/\1/p')
	END=$(echo "${WAR}" | sed -n 's/.* - \([0-9]\{4\}\).*/\1/p')
	DATES="${BEG}"
	if [ "${END}" != "${BEG}" ]; then
		DATES="${DATES}-${END}"
	else
		DATES="~${DATES}"
	fi
	DEATHS=$(echo "${WAR}" | sed -n "s/.*${END}[^,0-9]\([,0-9]\+\) [0-9].*/\1/p")
	NAME=$(echo "${WAR}" | sed -n "s/.*\]\(.*\) ${DATESORIG}.*/\1/p")

	if [ -n "${NAME}" ]; then
		# shellcheck disable=SC2039
		echo "- ${DATES} [${NAME}](${REF}), ${DEATHS} people killed"
	fi
done | sort
