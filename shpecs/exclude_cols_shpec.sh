#!/usr/bin/env shpec
# shellcheck disable=SC1091,SC2016
source shpecs/shpec_helper.sh

describe "exclude_cols"
  input_file() { echo 'shpecs/support/super_heroes.json'; }

  describe 'processing `.jsonl` files'
    input_cmd() { jq --compact-output '.members[]'; }

    matches_expected 'exclude_cols powers' <<-EOF
age	gender	name	secret.identity
EOF
  end_
end_
