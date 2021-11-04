#!/usr/bin/env shpec
source shpecs/shpec_helper.sh


describe "json-redact"
  input_file='shpecs/support/super_heroes.json'
  input_cmd='cat'

  matches_expected 'json-redact secretBase age secretIdentity' \
<<-EOF
{
  "squadName": "Super hero squad",
  "active": true,
  "formed": 2016,
  "location": {
    "homeTown": "Metro City",
    "secretBase": "███"
  },
  "members": [
    {
      "name": "Molecule Man",
      "age": 0,
      "gender": "male",
      "secretIdentity": "███",
      "powers": [
        "Radiation resistance",
        "Turning tiny",
        "Radiation blast"
      ]
    },
    {
      "name": "Madame Uppercut",
      "age": 0,
      "gender": "female",
      "secretIdentity": "███",
      "powers": [
        "Million tonne punch",
        "Damage resistance",
        "Superhuman reflexes"
      ]
    },
    {
      "name": "Eternal Flame",
      "age": 0,
      "gender": "female",
      "secretIdentity": "███",
      "powers": [
        "Immortality",
        "Heat Immunity",
        "Inferno",
        "Teleportation",
        "Interdimensional travel"
      ]
    }
  ]
}
EOF

  matches_expected 'redacted_keys="secretBase secretIdentity" json-redact' \
<<-EOF
{
  "squadName": "Super hero squad",
  "active": true,
  "formed": 2016,
  "location": {
    "homeTown": "Metro City",
    "secretBase": "███"
  },
  "members": [
    {
      "name": "Molecule Man",
      "age": 29,
      "gender": "male",
      "secretIdentity": "███",
      "powers": [
        "Radiation resistance",
        "Turning tiny",
        "Radiation blast"
      ]
    },
    {
      "name": "Madame Uppercut",
      "age": 39,
      "gender": "female",
      "secretIdentity": "███",
      "powers": [
        "Million tonne punch",
        "Damage resistance",
        "Superhuman reflexes"
      ]
    },
    {
      "name": "Eternal Flame",
      "age": 1000000,
      "gender": "female",
      "secretIdentity": "███",
      "powers": [
        "Immortality",
        "Heat Immunity",
        "Inferno",
        "Teleportation",
        "Interdimensional travel"
      ]
    }
  ]
}
EOF

  matches_expected 'MAX_LENGTH=1 json-redact secretBase secretIdentity' \
<<-EOF
{
  "squadName": "Super hero squad",
  "active": true,
  "formed": 2016,
  "location": {
    "homeTown": "Metro City",
    "secretBase": "█"
  },
  "members": [
    {
      "name": "Molecule Man",
      "age": 29,
      "gender": "male",
      "secretIdentity": "█",
      "powers": [
        "Radiation resistance",
        "Turning tiny",
        "Radiation blast"
      ]
    },
    {
      "name": "Madame Uppercut",
      "age": 39,
      "gender": "female",
      "secretIdentity": "█",
      "powers": [
        "Million tonne punch",
        "Damage resistance",
        "Superhuman reflexes"
      ]
    },
    {
      "name": "Eternal Flame",
      "age": 1000000,
      "gender": "female",
      "secretIdentity": "█",
      "powers": [
        "Immortality",
        "Heat Immunity",
        "Inferno",
        "Teleportation",
        "Interdimensional travel"
      ]
    }
  ]
}
EOF

  matches_expected 'MAX_LENGTH=-1 json-redact secretBase secretIdentity' \
<<-EOF
{
  "squadName": "Super hero squad",
  "active": true,
  "formed": 2016,
  "location": {
    "homeTown": "Metro City",
    "secretBase": "██████████"
  },
  "members": [
    {
      "name": "Molecule Man",
      "age": 29,
      "gender": "male",
      "secretIdentity": "████████",
      "powers": [
        "Radiation resistance",
        "Turning tiny",
        "Radiation blast"
      ]
    },
    {
      "name": "Madame Uppercut",
      "age": 39,
      "gender": "female",
      "secretIdentity": "██████████",
      "powers": [
        "Million tonne punch",
        "Damage resistance",
        "Superhuman reflexes"
      ]
    },
    {
      "name": "Eternal Flame",
      "age": 1000000,
      "gender": "female",
      "secretIdentity": "██████",
      "powers": [
        "Immortality",
        "Heat Immunity",
        "Inferno",
        "Teleportation",
        "Interdimensional travel"
      ]
    }
  ]
}
EOF
end
