#!/usr/bin/env shpec
# shellcheck disable=SC1090,SC1091,SC2016
source "${BASH_SOURCE[0]%/*}/shpec_helper.sh"
export input_cmd input_file


describe "exclude_cols"
  input_file='shpecs/support/super_heroes.json'

  describe 'processing `.jsonl` files'
    input_cmd='jq --compact-output ".members[]"'

    matches_expected 'exclude_cols powers' \
<<-EOF
age	gender	name	secret.identity
EOF
  end
end
