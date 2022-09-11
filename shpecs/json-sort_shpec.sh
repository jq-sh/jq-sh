#!/usr/bin/env shpec
source "${BASH_SOURCE[0]%/*}/shpec_helper.sh"


describe "json-sort"
  input_file='shpecs/support/super_heroes.json'
  input_cmd='jq .members'

  matches_expected 'json-sort age' \
<<-EOF
{"name":"Molecule Man","age":29,"gender":"male","secret":{"identity":"Dan Jukes"},"powers":["Radiation resistance","Turning tiny","Radiation blast"]}
{"name":"Madame Uppercut","age":39,"gender":"female","secret":{"identity":"Jane Wilson"},"powers":["Million tonne punch","Damage resistance","Superhuman reflexes"]}
{"name":"Eternal Flame","age":1000000,"gender":"female","secret":{"identity":"Unknown"},"powers":["Immortality","Heat Immunity","Inferno","Teleportation","Interdimensional travel"]}
EOF

  matches_expected 'reverse=true json-sort age' \
<<-EOF
{"name":"Eternal Flame","age":1000000,"gender":"female","secret":{"identity":"Unknown"},"powers":["Immortality","Heat Immunity","Inferno","Teleportation","Interdimensional travel"]}
{"name":"Madame Uppercut","age":39,"gender":"female","secret":{"identity":"Jane Wilson"},"powers":["Million tonne punch","Damage resistance","Superhuman reflexes"]}
{"name":"Molecule Man","age":29,"gender":"male","secret":{"identity":"Dan Jukes"},"powers":["Radiation resistance","Turning tiny","Radiation blast"]}
EOF

  matches_expected 'json-sort gender age' \
<<-EOF
{"name":"Madame Uppercut","age":39,"gender":"female","secret":{"identity":"Jane Wilson"},"powers":["Million tonne punch","Damage resistance","Superhuman reflexes"]}
{"name":"Eternal Flame","age":1000000,"gender":"female","secret":{"identity":"Unknown"},"powers":["Immortality","Heat Immunity","Inferno","Teleportation","Interdimensional travel"]}
{"name":"Molecule Man","age":29,"gender":"male","secret":{"identity":"Dan Jukes"},"powers":["Radiation resistance","Turning tiny","Radiation blast"]}
EOF

  matches_expected 'sort_by_expression=".gender,.age" json-sort' \
<<-EOF
{"name":"Madame Uppercut","age":39,"gender":"female","secret":{"identity":"Jane Wilson"},"powers":["Million tonne punch","Damage resistance","Superhuman reflexes"]}
{"name":"Eternal Flame","age":1000000,"gender":"female","secret":{"identity":"Unknown"},"powers":["Immortality","Heat Immunity","Inferno","Teleportation","Interdimensional travel"]}
{"name":"Molecule Man","age":29,"gender":"male","secret":{"identity":"Dan Jukes"},"powers":["Radiation resistance","Turning tiny","Radiation blast"]}
EOF
end
