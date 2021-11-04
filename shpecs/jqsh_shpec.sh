#!/usr/bin/env shpec
source shpecs/shpec_helper.sh

describe "sh"
  matches_expected 'key=animals a.sh ant bee cat' \
<<-EOF
{ "animals": ["ant", "bee", "cat"] }
EOF
end

describe "jq"
  matches_expected 'jq --null-input --from-file --arg key animals --argjson values \[\"ant\"\,\"bee\"\,\"cat\"\] shpecs/support/a.jq' \
<<-EOF
{
  "animals": [
    "ant",
    "bee",
    "cat"
  ]
}
EOF
end

describe "jqsh"
  matches_expected 'key=animals a.jqsh ant bee cat' \
<<-EOF
{
  "animals": [
    "ant",
    "bee",
    "cat"
  ]
}
EOF
end
