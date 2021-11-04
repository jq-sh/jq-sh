#!/usr/bin/env shpec
source shpecs/shpec_helper.sh

describe "jsonl2tsv"
  input_file='shpecs/support/super_heroes.json'

  describe 'processing `.jsonl` files'
    input_cmd='jq --compact-output ".members[]"'

# TODO identify cols from first jsonl record
#    cmd='jsonl2tsv' \
#      matches_expected <<-EOF
#age	gender	name	powers	secretIdentity
#29	male	Molecule Man	["Radiation resistance","Turning tiny","Radiation blast"]	Dan Jukes
#39	female	Madame Uppercut	["Million tonne punch","Damage resistance","Superhuman reflexes"]	Jane Wilson
#1000000	female	Eternal Flame	["Immortality","Heat Immunity","Inferno","Teleportation","Interdimensional travel"]	Unknown
#EOF

    matches_expected 'jsonl2tsv name age powers' \
<<-EOF
name	age	powers
Molecule Man	29	["Radiation resistance","Turning tiny","Radiation blast"]
Madame Uppercut	39	["Million tonne punch","Damage resistance","Superhuman reflexes"]
Eternal Flame	1000000	["Immortality","Heat Immunity","Inferno","Teleportation","Interdimensional travel"]
EOF

    matches_expected 'headers=false jsonl2tsv name age powers' \
<<-EOF
Molecule Man	29	["Radiation resistance","Turning tiny","Radiation blast"]
Madame Uppercut	39	["Million tonne punch","Damage resistance","Superhuman reflexes"]
Eternal Flame	1000000	["Immortality","Heat Immunity","Inferno","Teleportation","Interdimensional travel"]
EOF
  end
end
