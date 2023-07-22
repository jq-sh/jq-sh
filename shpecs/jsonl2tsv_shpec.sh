#!/usr/bin/env shpec
# shellcheck disable=SC1091,SC2016
source shpecs/shpec_helper.sh

describe "jsonl2tsv"
  describe 'processing `.jsonl` files'
    input_file() { echo 'shpecs/support/super_heroes.json'; }
    input_cmd()  { jq --compact-output '.members[]'; }

    matches_expected 'jsonl2tsv name age powers' <<-EOF
Molecule Man	29	["Radiation resistance","Turning tiny","Radiation blast"]
Madame Uppercut	39	["Million tonne punch","Damage resistance","Superhuman reflexes"]
Eternal Flame	1000000	["Immortality","Heat Immunity","Inferno","Teleportation","Interdimensional travel"]
EOF
  end_

  describe "handling false, null & missing fields"
    input() {
      echo '{"a": true, "b": false, "c": null}'
      echo '{"a": false}'
    }

    matches_expected 'jsonl2tsv a b c' <<-EOF
true	false	null
false	¿	¿
EOF
  end_
end_
