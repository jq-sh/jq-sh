#!/usr/bin/env shpec
# shellcheck disable=SC1090,SC1091,SC2016
source "${BASH_SOURCE[0]%/*}/shpec_helper.sh"
export input_cmd input_file


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

    describe 'with no headers'
      matches_expected 'headers=false jsonl2tsv name age powers' \
<<-EOF
Molecule Man	29	["Radiation resistance","Turning tiny","Radiation blast"]
Madame Uppercut	39	["Million tonne punch","Damage resistance","Superhuman reflexes"]
Eternal Flame	1000000	["Immortality","Heat Immunity","Inferno","Teleportation","Interdimensional travel"]
EOF
    end

    describe 'truncation'
      matches_expected 'jsonl2tsv name age powers%30' \
<<-EOF
name	age	powers
Molecule Man	29	["Radiation resistance",...t"]
Madame Uppercut	39	["Million tonne punch","...s"]
Eternal Flame	1000000	["Immortality","Heat Imm...l"]
EOF

      describe 'with end_size'
        matches_expected 'jsonl2tsv name age powers%30,7' \
<<-EOF
name	age	powers
Molecule Man	29	["Radiation resistan...blast"]
Madame Uppercut	39	["Million tonne punc...lexes"]
Eternal Flame	1000000	["Immortality","Heat...ravel"]
EOF

      describe 'with alias'
        matches_expected 'jsonl2tsv name age powers%30,7:PoWeRZ' \
<<-EOF
name	age	:PoWeRZ
Molecule Man	29	["Radiation resistan...blast"]
Madame Uppercut	39	["Million tonne punc...lexes"]
Eternal Flame	1000000	["Immortality","Heat...ravel"]
EOF
      end
    end
  end
end
