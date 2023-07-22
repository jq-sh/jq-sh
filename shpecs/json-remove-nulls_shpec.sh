#!/usr/bin/env shpec
# shellcheck disable=SC1091
source shpecs/shpec_helper.sh


describe "json-remove-nulls"
  matches_expected 'json-remove-nulls --help' <<-EOF
json-remove-nulls (v2023.07.22)

## json-remove-nulls

### EXAMPLES
* \`json-remove-nulls\`
EOF

  input_file() { echo 'shpecs/support/super_heroes.json'; }
  input_cmd()  { jq '.members |= null'; }
  matches_expected 'json-remove-nulls' <<-EOF
{
  "squadName": "Super hero squad",
  "active": true,
  "formed": 2016,
  "location": {
    "homeTown": "Metro City",
    "secretBase": "Super tower"
  }
}
EOF
end_
