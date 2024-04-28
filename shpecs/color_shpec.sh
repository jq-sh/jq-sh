#!/usr/bin/env shpec
# shellcheck disable=SC1091
source shpecs/shpec_helper.sh

describe "color"
  matches_expected 'color --help' <<-EOF
color (v2024.04.29)

## color

Its like grep but doesn't filter out lines & each search term gets its own color!

### EXAMPLES
* \`echo -e "help hello worlod \nwhoa" |                         color 'whoa|wo'          ' he'      'lo '\`
* \`(set -- 'whoa|wo' ' he' 'lo '; IFS=\$'\n'; echo "\$*")> /tmp/patterns.txt ; echo -e "help hello worlod \nwhoa" | patterns_file=/tmp/patterns.txt color\` # read patterns in from a file
* \`while date; do sleep 1; done |                               color '^[A-Z][a-z][a-z]'            ' [A-Z][a-z][a-z]'  ':[0-9][0-9]:' '[0-9]'{0..9}' '\`
* \`while date; do sleep 1; done |                               color '^[A-Z][a-z][a-z]' SKIP_GREEN ' [A-Z][a-z][a-z]'  ':[0-9][0-9]:' '[0-9]'{0..9}' '\`
* \`while date; do sleep 1; done |                      COLOR=42 color '^[A-Z][a-z][a-z]'            ' [A-Z][a-z][a-z]'  ':[0-9][0-9]:' '[0-9]'{0..9}' '\`
* \`while date; do sleep 1; done | COLOR_EFFECTS="3;4;" COLOR=42 color '^[A-Z][a-z][a-z]'            ' [A-Z][a-z][a-z]'  ':[0-9][0-9]:' '[0-9]'{0..9}' '\`
EOF

  matches_expected_with_colors "echo help hello worlod whoa | color 'whoa|wo' ' he' 'lo '"  <<-EOF
help[1;32m[K he[m[Kl[1;33m[Klo [m[K[1;31m[Kwo[m[Krlod [1;31m[Kwhoa[m[K
EOF

  patterns_file="$(mktemp)"
  (set -- 'whoa|wo' ' he' 'lo '; IFS=$'\n'; echo "$*")> "$patterns_file"

  # shellcheck disable=SC2016
  matches_expected_with_colors 'echo help hello worlod whoa | patterns_file=$patterns_file color'  <<-EOF
help[1;32m[K he[m[Kl[1;33m[Klo [m[K[1;31m[Kwo[m[Krlod [1;31m[Kwhoa[m[K
EOF
end_
