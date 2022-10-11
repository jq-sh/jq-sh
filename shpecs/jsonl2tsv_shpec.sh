#!/usr/bin/env shpec
# shellcheck disable=SC1090,SC1091,SC2016
source "${BASH_SOURCE[0]%/*}/shpec_helper.sh"
export input_cmd input_file

describe "jsonl2tsv"
  describe 'processing `.jsonl` files'
    input_cmd='jq --compact-output ".members[]"'
    input_file='shpecs/support/super_heroes.json'

    matches_expected 'jsonl2tsv name age powers' \
<<-EOF
Molecule Man	29	["Radiation resistance","Turning tiny","Radiation blast"]
Madame Uppercut	39	["Million tonne punch","Damage resistance","Superhuman reflexes"]
Eternal Flame	1000000	["Immortality","Heat Immunity","Inferno","Teleportation","Interdimensional travel"]
EOF
  end

  describe "handling false, null & missing fields"
    input() {
      echo '{"a": true, "b": false, "c": null}'
      echo '{"a": false}'
    }

    matches_expected 'jsonl2tsv a b c' \
<<-EOF
true	false	null
false	¿	¿
EOF
  end
end
