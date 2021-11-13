#!/usr/bin/env shpec
source shpecs/shpec_helper.sh


describe "json-remove-nulls"
  input_file='shpecs/support/super_heroes.json'
  input_cmd='jq ".members |= null"'

  matches_expected 'json-remove-nulls' \
<<-EOF
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
end
