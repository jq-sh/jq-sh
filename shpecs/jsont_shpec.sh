#!/usr/bin/env shpec
source shpecs/shpec_helper.sh


describe "jsont"
  matches_expected "formed=2015 super_heroes.jsont 'age=30 member' | jq" \
<<-EOF
{
  "squadName": "Super hero squad",
  "active": true,
  "formed": 2015,
  "location": {
    "homeTown": "Metro City",
    "secretBase": "Super tower"
  },
  "members": [
    {
      "name": "Molecule Man",
      "age": 30,
      "gender": "male",
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
end
