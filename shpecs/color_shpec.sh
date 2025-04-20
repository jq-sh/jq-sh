#!/usr/bin/env shpec
# shellcheck disable=SC1091
source shpecs/shpec_helper.sh

describe "color"
  matches_expected 'color --help' <<-EOF
color (v2025.04.20)

## color

Its like grep but doesn't filter out lines & each search term gets its own color!

### EXAMPLES
* \`echo hello world             |                               color he                 wo         lo\`
* \`while date; do sleep 1; done |                               color '^[A-Z][a-z][a-z]'            ' [A-Z][a-z][a-z]'  ':[0-9][0-9]:' '[0-9]'{0..9}' '\`
* \`while date; do sleep 1; done |                               color '^[A-Z][a-z][a-z]' SKIP_GREEN ' [A-Z][a-z][a-z]'  ':[0-9][0-9]:' '[0-9]'{0..9}' '\`
* \`while date; do sleep 1; done |                      COLOR=42 color '^[A-Z][a-z][a-z]'            ' [A-Z][a-z][a-z]'  ':[0-9][0-9]:' '[0-9]'{0..9}' '\`
* \`while date; do sleep 1; done | COLOR_EFFECTS="3;4;" COLOR=42 color '^[A-Z][a-z][a-z]'            ' [A-Z][a-z][a-z]'  ':[0-9][0-9]:' '[0-9]'{0..9}' '\`
EOF

  matches_expected_with_colors 'echo hello world | color he wo lo'  <<-EOF
[1;31m[Khe[m[Kl[1;33m[Klo[m[K [1;32m[Kwo[m[Krld
EOF
end_
