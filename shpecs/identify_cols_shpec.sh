#!/usr/bin/env shpec
# shellcheck disable=SC1091,SC2016
source shpecs/shpec_helper.sh

describe "identify_cols"
  input_file() { echo 'shpecs/support/super_heroes.json'; }

  describe 'processing `.jsonl` files'
    input_cmd() { jq --compact-output '.members[]'; }

    matches_expected 'identify_cols' <<-EOF
age	gender	name	powers	secret.identity
EOF
  end_
end_
