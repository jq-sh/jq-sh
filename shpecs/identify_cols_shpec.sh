#!/usr/bin/env shpec
# shellcheck disable=SC1090,SC1091,SC2016
source "${BASH_SOURCE[0]%/*}/shpec_helper.sh"
export input_cmd input_file


describe "identify_cols"
  input_file='shpecs/support/super_heroes.json'

  describe 'processing `.jsonl` files'
    input_cmd='jq --compact-output ".members[]"'

    matches_expected 'identify_cols' \
<<-EOF
age	gender	name	powers	secret.identity
EOF
  end
end
