#!/usr/bin/env shpec
# shellcheck disable=SC1091
source shpecs/shpec_helper.sh

describe "jsont"
  matches_expected "formed=2000 super_heroes.jsont | jq" <<-EOF
{
  "squadName": "Super hero squad",
  "active": true,
  "formed": 2000,
  "location": {
    "homeTown": "Metro City",
    "secretBase": "Super tower"
  },
  "members": []
}
EOF

  matches_expected "formed=2015 squadName='Junior Super Heroes' active=false super_heroes.jsont 'member age=30 gender=female' 'member age=31 name=Rubber\ Girl gender=female' | jq" <<-EOF
{
  "squadName": "Junior Super Heroes",
  "active": false,
  "formed": 2015,
  "location": {
    "homeTown": "Metro City",
    "secretBase": "Super tower"
  },
  "members": [
    {
      "name": "Molecule Man",
      "age": 30,
      "gender": "female",
      "secretIdentity": "Dan Jukes",
      "powers": [
        "Radiation resistance",
        "Turning tiny",
        "Radiation blast"
      ]
    },
    {
      "name": "Rubber Girl",
      "age": 31,
      "gender": "female",
      "secretIdentity": "Dan Jukes",
      "powers": [
        "Radiation resistance",
        "Turning tiny",
        "Radiation blast"
      ]
    }
  ]
}
EOF
end_
