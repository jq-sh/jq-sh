#!/usr/bin/env shpec
# shellcheck disable=SC1091
source shpecs/shpec_helper.sh

describe "json-redact"
  input_file() { echo 'shpecs/support/super_heroes.json'; }

  matches_expected 'json-redact --help' <<-EOF
json-redact (v2023.08.29)

## json-redact

### EXAMPLES
* \`              json-redact created_at updated_at\` # redact created_at, updated_at with default MAX_LENGTH (3)
* \`MAX_LENGTH=-1 json-redact created_at updated_at\` # redact created_at, updated_at with no MAX_LENGTH
EOF

  matches_expected 'json-redact secretBase age identity' <<-EOF
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
      "secret": {
        "identity": "███"
      },
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
      "secret": {
        "identity": "███"
      },
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
      "secret": {
        "identity": "███"
      },
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

  matches_expected 'redacted_keys="secretBase identity" json-redact' <<-EOF
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
      "secret": {
        "identity": "███"
      },
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
      "secret": {
        "identity": "███"
      },
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
      "secret": {
        "identity": "███"
      },
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

  matches_expected 'MAX_LENGTH=1 json-redact secretBase identity' <<-EOF
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
      "secret": {
        "identity": "█"
      },
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
      "secret": {
        "identity": "█"
      },
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
      "secret": {
        "identity": "█"
      },
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

  matches_expected 'MAX_LENGTH=-1 json-redact secretBase identity' <<-EOF
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
      "secret": {
        "identity": "████████"
      },
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
      "secret": {
        "identity": "██████████"
      },
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
      "secret": {
        "identity": "██████"
      },
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

  matches_expected 'json-redact' <<-EOF
{
  "squadName": "Super hero squad",
  "active": true,
  "formed": 2016,
  "location": {
    "homeTown": "Metro City",
    "secretBase": "Super tower"
  },
  "members": [
    {
      "name": "Molecule Man",
      "age": 29,
      "gender": "male",
      "secret": {
        "identity": "Dan Jukes"
      },
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
      "secret": {
        "identity": "Jane Wilson"
      },
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
      "secret": {
        "identity": "Unknown"
      },
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
end_
