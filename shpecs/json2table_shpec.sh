#!/usr/bin/env shpec
# shellcheck disable=SC1091,SC2016
source shpecs/shpec_helper.sh


describe "json2table"
  input_file() { echo 'shpecs/support/super_heroes.json'; }

  describe 'processing `.jsonl` files'
    # shellcheck disable=SC2317
    input_cmd() { jq --compact-output '.members[]'; }

    describe 'cols'
      describe 'all'
        matches_expected 'json2table' <<-EOF
┌───────┬──────┬───────────────┬───────────────────────────────────────────────────────────────────────────────────┬───────────────┐
│age    │gender│name           │powers                                                                             │secret.identity│
├───────┼──────┼───────────────┼───────────────────────────────────────────────────────────────────────────────────┼───────────────┤
│29     │male  │Molecule Man   │["Radiation resistance","Turning tiny","Radiation blast"]                          │Dan Jukes      │
│39     │female│Madame Uppercut│["Million tonne punch","Damage resistance","Superhuman reflexes"]                  │Jane Wilson    │
│1000000│female│Eternal Flame  │["Immortality","Heat Immunity","Inferno","Teleportation","Interdimensional travel"]│Unknown        │
└───────┴──────┴───────────────┴───────────────────────────────────────────────────────────────────────────────────┴───────────────┘
EOF
      end_

      describe 'cols from arguments'
        matches_expected 'json2table age name secret.identity' <<-EOF
┌───────┬───────────────┬───────────────┐
│age    │name           │secret.identity│
├───────┼───────────────┼───────────────┤
│29     │Molecule Man   │Dan Jukes      │
│39     │Madame Uppercut│Jane Wilson    │
│1000000│Eternal Flame  │Unknown        │
└───────┴───────────────┴───────────────┘
EOF
      end_

      describe 'cols from an env var'
        matches_expected 'cols="age name secret.identity" json2table' <<-EOF
┌───────┬───────────────┬───────────────┐
│age    │name           │secret.identity│
├───────┼───────────────┼───────────────┤
│29     │Molecule Man   │Dan Jukes      │
│39     │Madame Uppercut│Jane Wilson    │
│1000000│Eternal Flame  │Unknown        │
└───────┴───────────────┴───────────────┘
EOF
      end_

      describe 'using an alias'
        matches_expected 'json2table age name secret.identity:shh_name' <<-EOF
┌───────┬───────────────┬───────────┐
│age    │name           │:shh_name  │
├───────┼───────────────┼───────────┤
│29     │Molecule Man   │Dan Jukes  │
│39     │Madame Uppercut│Jane Wilson│
│1000000│Eternal Flame  │Unknown    │
└───────┴───────────────┴───────────┘
EOF
      end_

      describe 'using truncation'
        matches_expected 'json2table name powers%30' <<-EOF
┌───────────────┬──────────────────────────────┐
│name           │powers                        │
├───────────────┼──────────────────────────────┤
│Molecule Man   │["Radiation resistance","..."]│
│Madame Uppercut│["Million tonne punch","D..."]│
│Eternal Flame  │["Immortality","Heat Immu..."]│
└───────────────┴──────────────────────────────┘
EOF

        matches_expected 'json2table name powers%30,10' <<-EOF
┌───────────────┬──────────────────────────────┐
│name           │powers                        │
├───────────────┼──────────────────────────────┤
│Molecule Man   │["Radiation resis...on blast"]│
│Madame Uppercut│["Million tonne p...reflexes"]│
│Eternal Flame  │["Immortality","H...l travel"]│
└───────────────┴──────────────────────────────┘
EOF
      end_

      describe 'using max_width'
        matches_expected 'max_width=80 json2table' <<-EOF
┌───────┬──────┬───────────────┬──────────────────────────────┬───────────────┐
│age    │gender│name           │powers                        │secret.identity│
├───────┼──────┼───────────────┼──────────────────────────────┼───────────────┤
│29     │male  │Molecule Man   │["Radiation resistance","..."]│Dan Jukes      │
│39     │female│Madame Uppercut│["Million tonne punch","D..."]│Jane Wilson    │
│1000000│female│Eternal Flame  │["Immortality","Heat Immu..."]│Unknown        │
└───────┴──────┴───────────────┴──────────────────────────────┴───────────────┘
EOF
        describe 'and truncation'
          matches_expected 'max_width=80 json2table age gender name%10 powers secret.identity' <<-EOF
┌───────┬──────┬──────────┬───────────────────────────────────┬───────────────┐
│age    │gender│name      │powers                             │secret.identity│
├───────┼──────┼──────────┼───────────────────────────────────┼───────────────┤
│29     │male  │Molec...an│["Radiation resistance","Turni..."]│Dan Jukes      │
│39     │female│Madam...ut│["Million tonne punch","Damage..."]│Jane Wilson    │
│1000000│female│Etern...me│["Immortality","Heat Immunity"..."]│Unknown        │
└───────┴──────┴──────────┴───────────────────────────────────┴───────────────┘
EOF
        end_

        describe 'of 0 (ie. no truncation despite not having enough COLUMNS)'
          COLUMNS=60 matches_expected 'max_width=0 json2table age gender name powers secret.identity' <<-EOF
┌───────┬──────┬───────────────┬───────────────────────────────────────────────────────────────────────────────────┬───────────────┐
│age    │gender│name           │powers                                                                             │secret.identity│
├───────┼──────┼───────────────┼───────────────────────────────────────────────────────────────────────────────────┼───────────────┤
│29     │male  │Molecule Man   │["Radiation resistance","Turning tiny","Radiation blast"]                          │Dan Jukes      │
│39     │female│Madame Uppercut│["Million tonne punch","Damage resistance","Superhuman reflexes"]                  │Jane Wilson    │
│1000000│female│Eternal Flame  │["Immortality","Heat Immunity","Inferno","Teleportation","Interdimensional travel"]│Unknown        │
└───────┴──────┴───────────────┴───────────────────────────────────────────────────────────────────────────────────┴───────────────┘
EOF
        end_
      end_
    end_

    describe 'filters'
      describe 'none'
        matches_expected 'json2table name gender age' <<-EOF
┌───────────────┬──────┬───────┐
│name           │gender│age    │
├───────────────┼──────┼───────┤
│Molecule Man   │male  │29     │
│Madame Uppercut│female│39     │
│Eternal Flame  │female│1000000│
└───────────────┴──────┴───────┘
EOF
      end_

      describe 'sorting'
        describe 'ascending'
          matches_expected 'sort_by="age" json2table name gender age' <<-EOF
┌───────────────┬──────┬───────┐
│name           │gender│age    │
├───────────────┼──────┼───────┤
│Molecule Man   │male  │29     │
│Madame Uppercut│female│39     │
│Eternal Flame  │female│1000000│
└───────────────┴──────┴───────┘
EOF
          matches_expected 'sort_by="<age" json2table name gender age' <<-EOF
┌───────────────┬──────┬───────┐
│name           │gender│age    │
├───────────────┼──────┼───────┤
│Molecule Man   │male  │29     │
│Madame Uppercut│female│39     │
│Eternal Flame  │female│1000000│
└───────────────┴──────┴───────┘
EOF
        end_

        describe 'descending'
          matches_expected 'sort_by=">age" json2table name gender age' <<-EOF
┌───────────────┬──────┬───────┐
│name           │gender│age    │
├───────────────┼──────┼───────┤
│Eternal Flame  │female│1000000│
│Madame Uppercut│female│39     │
│Molecule Man   │male  │29     │
└───────────────┴──────┴───────┘
EOF
        end_

        describe 'sort muiltiple columns'
          matches_expected 'sort_by="gender >age" json2table name gender age' <<-EOF
┌───────────────┬──────┬───────┐
│name           │gender│age    │
├───────────────┼──────┼───────┤
│Eternal Flame  │female│1000000│
│Madame Uppercut│female│39     │
│Molecule Man   │male  │29     │
└───────────────┴──────┴───────┘
EOF
        end_

        describe '(sort by gender even though its not in the `cols` list)'
          matches_expected 'super_hero_member_sort_by="gender age" super_hero_member.table' <<-EOF
Super Heroes
┌───────────────┬───────────────┬───────────────────────────────────────────────────────────────────────────┬───────┐
│name           │:secretIdentity│powers                                                                     │age    │
├───────────────┼───────────────┼───────────────────────────────────────────────────────────────────────────┼───────┤
│Madame Uppercut│Jane Wilson    │Million tonne punch, Damage resistance, Superhuman reflexes                │39     │
│Eternal Flame  │Unknown        │Immortality, Heat Immunity, Inferno, Teleportation, Interdimensional travel│1000000│
│Molecule Man   │Dan Jukes      │Radiation resistance, Turning tiny, Radiation blast                        │29     │
└───────────────┴───────────────┴───────────────────────────────────────────────────────────────────────────┴───────┘
EOF
        end_
      end_

      describe 'filtering'
        describe 'single filter'
          matches_expected 'sort_by="gender=female" json2table' <<-EOF
┌───────┬──────┬───────────────┬───────────────────────────────────────────────────────────────────────────────────┬───────────────┐
│age    │gender│name           │powers                                                                             │secret.identity│
├───────┼──────┼───────────────┼───────────────────────────────────────────────────────────────────────────────────┼───────────────┤
│39     │female│Madame Uppercut│["Million tonne punch","Damage resistance","Superhuman reflexes"]                  │Jane Wilson    │
│1000000│female│Eternal Flame  │["Immortality","Heat Immunity","Inferno","Teleportation","Interdimensional travel"]│Unknown        │
└───────┴──────┴───────────────┴───────────────────────────────────────────────────────────────────────────────────┴───────────────┘
EOF
        end_

        describe 'regex filter'
          matches_expected 'sort_by=">name=/(Ma.*?m|man)/ix" json2table' <<-EOF
┌───┬──────┬───────────────┬─────────────────────────────────────────────────────────────────┬───────────────┐
│age│gender│name           │powers                                                           │secret.identity│
├───┼──────┼───────────────┼─────────────────────────────────────────────────────────────────┼───────────────┤
│29 │male  │Molecule Man   │["Radiation resistance","Turning tiny","Radiation blast"]        │Dan Jukes      │
│39 │female│Madame Uppercut│["Million tonne punch","Damage resistance","Superhuman reflexes"]│Jane Wilson    │
└───┴──────┴───────────────┴─────────────────────────────────────────────────────────────────┴───────────────┘
EOF
          describe 'with whitespace'
            matches_expected 'sort_by="name=\"/(Ma.*?m   |   man) # this regex also has ix flags to ignore case, comments & whitespace/ix\"" json2table' <<-EOF
┌───┬──────┬───────────────┬─────────────────────────────────────────────────────────────────┬───────────────┐
│age│gender│name           │powers                                                           │secret.identity│
├───┼──────┼───────────────┼─────────────────────────────────────────────────────────────────┼───────────────┤
│39 │female│Madame Uppercut│["Million tonne punch","Damage resistance","Superhuman reflexes"]│Jane Wilson    │
│29 │male  │Molecule Man   │["Radiation resistance","Turning tiny","Radiation blast"]        │Dan Jukes      │
└───┴──────┴───────────────┴─────────────────────────────────────────────────────────────────┴───────────────┘
EOF
        end_

        describe 'multiple filters'
          matches_expected 'sort_by="age=39 gender=female" json2table' <<-EOF
┌───┬──────┬───────────────┬─────────────────────────────────────────────────────────────────┬───────────────┐
│age│gender│name           │powers                                                           │secret.identity│
├───┼──────┼───────────────┼─────────────────────────────────────────────────────────────────┼───────────────┤
│39 │female│Madame Uppercut│["Million tonne punch","Damage resistance","Superhuman reflexes"]│Jane Wilson    │
└───┴──────┴───────────────┴─────────────────────────────────────────────────────────────────┴───────────────┘
EOF
        end_

        describe 'multiple filters on multiple lines'
          export age=39 gender=female; sort_by=$(set | grep -E '^(age|gender)')
          matches_expected "sort_by='$sort_by' json2table" <<-EOF
┌───┬──────┬───────────────┬─────────────────────────────────────────────────────────────────┬───────────────┐
│age│gender│name           │powers                                                           │secret.identity│
├───┼──────┼───────────────┼─────────────────────────────────────────────────────────────────┼───────────────┤
│39 │female│Madame Uppercut│["Million tonne punch","Damage resistance","Superhuman reflexes"]│Jane Wilson    │
└───┴──────┴───────────────┴─────────────────────────────────────────────────────────────────┴───────────────┘
EOF
        end_

        describe 'extended flitering'
          expected=$(cat <<EOF
┌───────────────┬──────┬───┐
│name           │gender│age│
├───────────────┼──────┼───┤
│Madame Uppercut│female│39 │
│Molecule Man   │male  │29 │
└───────────────┴──────┴───┘
EOF
          )
          describe 'args'
            matches_expected 'json2table name                    gender  ">age<=39"' <<< "$expected"
            matches_expected 'json2table "name=/e[ ] (u|m)/ix"   gender  ">age"    ' <<< "$expected"
          end_
          describe 'cols'
            matches_expected 'sort_by=">age" cols=" name                gender  age<=39" json2table' <<< "$expected"
            matches_expected '               cols=" name                gender >age<=39" json2table' <<< "$expected"
            matches_expected '               cols="<name=/^m/i          gender  age"     json2table' <<< "$expected"
            matches_expected '               cols="<name=/e (u|m)/i     gender  age"     json2table' <<< "$expected"
            matches_expected '               cols="<name=/e[ ] (u|m)/ix gender  age"     json2table' <<< "$expected"
          end_
          describe 'sort_by'
            matches_expected 'sort_by="        >age<=39" json2table  name                 gender   age'      <<< "$expected"
            matches_expected 'sort_by="        >age"     json2table  name                 gender  "age<=39"' <<< "$expected"
            matches_expected 'sort_by="<gender <age"     json2table  name                 gender  "age<=39"' <<< "$expected"
            matches_expected 'sort_by="gender age"       json2table  name                 gender  "age<=39"' <<< "$expected"
            matches_expected 'sort_by="gender age"       json2table "name=/e[ ] (u|m)/ix" gender   age'      <<< "$expected"
          end_
        end_

        describe 'comparisons'
          matches_expected 'sort_by="age<100" json2table name gender age' <<-EOF
┌───────────────┬──────┬───┐
│name           │gender│age│
├───────────────┼──────┼───┤
│Molecule Man   │male  │29 │
│Madame Uppercut│female│39 │
└───────────────┴──────┴───┘
EOF
          matches_expected 'sort_by="age<=39" json2table name gender age' <<-EOF
┌───────────────┬──────┬───┐
│name           │gender│age│
├───────────────┼──────┼───┤
│Molecule Man   │male  │29 │
│Madame Uppercut│female│39 │
└───────────────┴──────┴───┘
EOF
          matches_expected 'sort_by="age==39" json2table name gender age' <<-EOF
┌───────────────┬──────┬───┐
│name           │gender│age│
├───────────────┼──────┼───┤
│Madame Uppercut│female│39 │
└───────────────┴──────┴───┘
EOF
          matches_expected 'sort_by="age>=39" json2table name gender age' <<-EOF
┌───────────────┬──────┬───────┐
│name           │gender│age    │
├───────────────┼──────┼───────┤
│Madame Uppercut│female│39     │
│Eternal Flame  │female│1000000│
└───────────────┴──────┴───────┘
EOF
          matches_expected 'sort_by="age>39" json2table name gender age' <<-EOF
┌─────────────┬──────┬───────┐
│name         │gender│age    │
├─────────────┼──────┼───────┤
│Eternal Flame│female│1000000│
└─────────────┴──────┴───────┘
EOF
          matches_expected 'sort_by="age!39" json2table name gender age' <<-EOF
┌─────────────┬──────┬───────┐
│name         │gender│age    │
├─────────────┼──────┼───────┤
│Molecule Man │male  │29     │
│Eternal Flame│female│1000000│
└─────────────┴──────┴───────┘
EOF
          matches_expected 'sort_by="age!=39" json2table name gender age' <<-EOF
┌─────────────┬──────┬───────┐
│name         │gender│age    │
├─────────────┼──────┼───────┤
│Molecule Man │male  │29     │
│Eternal Flame│female│1000000│
└─────────────┴──────┴───────┘
EOF
          matches_expected 'sort_by="age<>39" json2table name gender age' <<-EOF
┌─────────────┬──────┬───────┐
│name         │gender│age    │
├─────────────┼──────┼───────┤
│Molecule Man │male  │29     │
│Eternal Flame│female│1000000│
└─────────────┴──────┴───────┘
EOF
        end_
      end_
    end_

    describe 'multi-line data'
      # shellcheck disable=SC2317
      input_cmd() { jq --compact-output '.members[] | .powers |= join("\n")'; }
      matches_expected 'json2table name powers' <<-EOF
┌───────────────┬───────────────────────────────────────────────────────────────────────────┐
│name           │powers                                                                     │
├───────────────┼───────────────────────────────────────────────────────────────────────────┤
│Molecule Man   │Radiation resistance\nTurning tiny\nRadiation blast                        │
│Madame Uppercut│Million tonne punch\nDamage resistance\nSuperhuman reflexes                │
│Eternal Flame  │Immortality\nHeat Immunity\nInferno\nTeleportation\nInterdimensional travel│
└───────────────┴───────────────────────────────────────────────────────────────────────────┘
EOF
    end_

    describe 'sort_by'
      matches_expected 'sort_by="gender age" json2table name gender age' <<-EOF
┌───────────────┬──────┬───────┐
│name           │gender│age    │
├───────────────┼──────┼───────┤
│Madame Uppercut│female│39     │
│Eternal Flame  │female│1000000│
│Molecule Man   │male  │29     │
└───────────────┴──────┴───────┘
EOF
    end_

    describe 'larger json'
      # shellcheck disable=SC2317
      input_cmd() { cat; }

      describe 'with `resource` var'
        matches_expected 'resource=location json2table' <<-EOF
┌──────────┬───────────┐
│homeTown  │secretBase │
├──────────┼───────────┤
│Metro City│Super tower│
└──────────┴───────────┘
EOF

        matches_expected 'resource=location json2table secretBase homeTown' <<-EOF
┌───────────┬──────────┐
│secretBase │homeTown  │
├───────────┼──────────┤
│Super tower│Metro City│
└───────────┴──────────┘
EOF
      end_

      describe 'with `resources` var'
        matches_expected 'resources=members json2table' <<-EOF
members
┌───────┬──────┬───────────────┬───────────────────────────────────────────────────────────────────────────────────┬───────────────┐
│age    │gender│name           │powers                                                                             │secret.identity│
├───────┼──────┼───────────────┼───────────────────────────────────────────────────────────────────────────────────┼───────────────┤
│29     │male  │Molecule Man   │["Radiation resistance","Turning tiny","Radiation blast"]                          │Dan Jukes      │
│39     │female│Madame Uppercut│["Million tonne punch","Damage resistance","Superhuman reflexes"]                  │Jane Wilson    │
│1000000│female│Eternal Flame  │["Immortality","Heat Immunity","Inferno","Teleportation","Interdimensional travel"]│Unknown        │
└───────┴──────┴───────────────┴───────────────────────────────────────────────────────────────────────────────────┴───────────────┘
EOF

        describe 'and multiple `resources`'
          matches_expected 'resources="location members" json2table' <<-EOF
location
┌──────────┬───────────┐
│homeTown  │secretBase │
├──────────┼───────────┤
│Metro City│Super tower│
└──────────┴───────────┘
members
┌───────┬──────┬───────────────┬───────────────────────────────────────────────────────────────────────────────────┬───────────────┐
│age    │gender│name           │powers                                                                             │secret.identity│
├───────┼──────┼───────────────┼───────────────────────────────────────────────────────────────────────────────────┼───────────────┤
│29     │male  │Molecule Man   │["Radiation resistance","Turning tiny","Radiation blast"]                          │Dan Jukes      │
│39     │female│Madame Uppercut│["Million tonne punch","Damage resistance","Superhuman reflexes"]                  │Jane Wilson    │
│1000000│female│Eternal Flame  │["Immortality","Heat Immunity","Inferno","Teleportation","Interdimensional travel"]│Unknown        │
└───────┴──────┴───────────────┴───────────────────────────────────────────────────────────────────────────────────┴───────────────┘
EOF
        end_
      end_
    end_

    describe 'symlink: member.table -> json2table'
      # shellcheck disable=SC2317
      input_cmd() { cat; }

      matches_expected 'member.table' <<-EOF
┌───────┬──────┬───────────────┬───────────────────────────────────────────────────────────────────────────────────┬───────────────┐
│age    │gender│name           │powers                                                                             │secret.identity│
├───────┼──────┼───────────────┼───────────────────────────────────────────────────────────────────────────────────┼───────────────┤
│29     │male  │Molecule Man   │["Radiation resistance","Turning tiny","Radiation blast"]                          │Dan Jukes      │
│39     │female│Madame Uppercut│["Million tonne punch","Damage resistance","Superhuman reflexes"]                  │Jane Wilson    │
│1000000│female│Eternal Flame  │["Immortality","Heat Immunity","Inferno","Teleportation","Interdimensional travel"]│Unknown        │
└───────┴──────┴───────────────┴───────────────────────────────────────────────────────────────────────────────────┴───────────────┘
EOF

      matches_expected 'member.table name secret.identity:secretIdentity' <<-EOF
┌───────────────┬───────────────┐
│name           │:secretIdentity│
├───────────────┼───────────────┤
│Molecule Man   │Dan Jukes      │
│Madame Uppercut│Jane Wilson    │
│Eternal Flame  │Unknown        │
└───────────────┴───────────────┘
EOF
    end_

    describe 'script: super_hero_member.table'
      # shellcheck disable=SC2317
      input_cmd() { jq --compact-output '.members[]'; }

      describe 'cols'
        # from `cols` defined in super_hero_member.table
        matches_expected 'super_hero_member.table' <<-EOF
Super Heroes
┌───────────────┬───────────────┬───────────────────────────────────────────────────────────────────────────┬───────┐
│name           │:secretIdentity│powers                                                                     │age    │
├───────────────┼───────────────┼───────────────────────────────────────────────────────────────────────────┼───────┤
│Eternal Flame  │Unknown        │Immortality, Heat Immunity, Inferno, Teleportation, Interdimensional travel│1000000│
│Madame Uppercut│Jane Wilson    │Million tonne punch, Damage resistance, Superhuman reflexes                │39     │
│Molecule Man   │Dan Jukes      │Radiation resistance, Turning tiny, Radiation blast                        │29     │
└───────────────┴───────────────┴───────────────────────────────────────────────────────────────────────────┴───────┘
EOF

        matches_expected 'cols="name secret.identity:secretIdentity" super_hero_member.table' <<-EOF
Super Heroes
┌───────────────┬───────────────┐
│name           │:secretIdentity│
├───────────────┼───────────────┤
│Eternal Flame  │Unknown        │
│Madame Uppercut│Jane Wilson    │
│Molecule Man   │Dan Jukes      │
└───────────────┴───────────────┘
EOF

        matches_expected 'super_hero_member_cols="name age" super_hero_member.table' <<-EOF
Super Heroes
┌───────────────┬───────┐
│name           │age    │
├───────────────┼───────┤
│Eternal Flame  │1000000│
│Madame Uppercut│39     │
│Molecule Man   │29     │
└───────────────┴───────┘
EOF

        matches_expected 'super_hero_member_cols="name missing_key age" super_hero_member.table' <<-EOF
Super Heroes
┌───────────────┬───────────┬───────┐
│name           │missing_key│age    │
├───────────────┼───────────┼───────┤
│Eternal Flame  │¿          │1000000│
│Madame Uppercut│¿          │39     │
│Molecule Man   │¿          │29     │
└───────────────┴───────────┴───────┘
EOF

        matches_expected 'super_hero_member.table age name' <<-EOF
Super Heroes
┌───────┬───────────────┐
│age    │name           │
├───────┼───────────────┤
│1000000│Eternal Flame  │
│39     │Madame Uppercut│
│29     │Molecule Man   │
└───────┴───────────────┘
EOF
      end_

      describe 'title'
        # from `title` defined in super_hero_member.table
        matches_expected 'super_hero_member.table' <<-EOF
Super Heroes
┌───────────────┬───────────────┬───────────────────────────────────────────────────────────────────────────┬───────┐
│name           │:secretIdentity│powers                                                                     │age    │
├───────────────┼───────────────┼───────────────────────────────────────────────────────────────────────────┼───────┤
│Eternal Flame  │Unknown        │Immortality, Heat Immunity, Inferno, Teleportation, Interdimensional travel│1000000│
│Madame Uppercut│Jane Wilson    │Million tonne punch, Damage resistance, Superhuman reflexes                │39     │
│Molecule Man   │Dan Jukes      │Radiation resistance, Turning tiny, Radiation blast                        │29     │
└───────────────┴───────────────┴───────────────────────────────────────────────────────────────────────────┴───────┘
EOF

        matches_expected 'title="Heroes that are super" super_hero_member.table' <<-EOF
Heroes that are super
┌───────────────┬───────────────┬───────────────────────────────────────────────────────────────────────────┬───────┐
│name           │:secretIdentity│powers                                                                     │age    │
├───────────────┼───────────────┼───────────────────────────────────────────────────────────────────────────┼───────┤
│Eternal Flame  │Unknown        │Immortality, Heat Immunity, Inferno, Teleportation, Interdimensional travel│1000000│
│Madame Uppercut│Jane Wilson    │Million tonne punch, Damage resistance, Superhuman reflexes                │39     │
│Molecule Man   │Dan Jukes      │Radiation resistance, Turning tiny, Radiation blast                        │29     │
└───────────────┴───────────────┴───────────────────────────────────────────────────────────────────────────┴───────┘
EOF
      end_

      describe 'sort_by'
        # from `sort_by` defined in super_hero_member.table
        matches_expected 'super_hero_member.table' <<-EOF
Super Heroes
┌───────────────┬───────────────┬───────────────────────────────────────────────────────────────────────────┬───────┐
│name           │:secretIdentity│powers                                                                     │age    │
├───────────────┼───────────────┼───────────────────────────────────────────────────────────────────────────┼───────┤
│Eternal Flame  │Unknown        │Immortality, Heat Immunity, Inferno, Teleportation, Interdimensional travel│1000000│
│Madame Uppercut│Jane Wilson    │Million tonne punch, Damage resistance, Superhuman reflexes                │39     │
│Molecule Man   │Dan Jukes      │Radiation resistance, Turning tiny, Radiation blast                        │29     │
└───────────────┴───────────────┴───────────────────────────────────────────────────────────────────────────┴───────┘
EOF

        matches_expected 'sort_by="age" super_hero_member.table' <<-EOF
Super Heroes
┌───────────────┬───────────────┬───────────────────────────────────────────────────────────────────────────┬───────┐
│name           │:secretIdentity│powers                                                                     │age    │
├───────────────┼───────────────┼───────────────────────────────────────────────────────────────────────────┼───────┤
│Molecule Man   │Dan Jukes      │Radiation resistance, Turning tiny, Radiation blast                        │29     │
│Madame Uppercut│Jane Wilson    │Million tonne punch, Damage resistance, Superhuman reflexes                │39     │
│Eternal Flame  │Unknown        │Immortality, Heat Immunity, Inferno, Teleportation, Interdimensional travel│1000000│
└───────────────┴───────────────┴───────────────────────────────────────────────────────────────────────────┴───────┘
EOF

        describe '(sorting by gender even though its not in the `cols` list)'
          matches_expected 'super_hero_member_sort_by="gender age" super_hero_member.table' <<-EOF
Super Heroes
┌───────────────┬───────────────┬───────────────────────────────────────────────────────────────────────────┬───────┐
│name           │:secretIdentity│powers                                                                     │age    │
├───────────────┼───────────────┼───────────────────────────────────────────────────────────────────────────┼───────┤
│Madame Uppercut│Jane Wilson    │Million tonne punch, Damage resistance, Superhuman reflexes                │39     │
│Eternal Flame  │Unknown        │Immortality, Heat Immunity, Inferno, Teleportation, Interdimensional travel│1000000│
│Molecule Man   │Dan Jukes      │Radiation resistance, Turning tiny, Radiation blast                        │29     │
└───────────────┴───────────────┴───────────────────────────────────────────────────────────────────────────┴───────┘
EOF
        end_
      end_
    end_

    describe 'conf files'
      # shellcheck disable=SC2317
      input_cmd() { jq --compact-output '.members[]'; }

      describe 'specific conf'
        matches_expected 'conf=shpecs/support/specific.conf super_hero_member.table' <<-EOF
Super Specific Heroes
┌───────────────────────────────────────────────────────────────────────────┬───┬──────┐
│powers                                                                     │foo│gender│
├───────────────────────────────────────────────────────────────────────────┼───┼──────┤
│Million tonne punch, Damage resistance, Superhuman reflexes                │¿  │female│
│Immortality, Heat Immunity, Inferno, Teleportation, Interdimensional travel│¿  │female│
│Radiation resistance, Turning tiny, Radiation blast                        │¿  │male  │
└───────────────────────────────────────────────────────────────────────────┴───┴──────┘
EOF

        matches_expected 'conf=shpecs/support/specific-add.conf super_hero_member.table' <<-EOF
Super Heroes
┌───────────────┬───────────────┬───────────────────────────────────────────────────────────────────────────┬───────┬───┬──────┐
│name           │:secretIdentity│powers                                                                     │age    │foo│gender│
├───────────────┼───────────────┼───────────────────────────────────────────────────────────────────────────┼───────┼───┼──────┤
│Eternal Flame  │Unknown        │Immortality, Heat Immunity, Inferno, Teleportation, Interdimensional travel│1000000│¿  │female│
│Madame Uppercut│Jane Wilson    │Million tonne punch, Damage resistance, Superhuman reflexes                │39     │¿  │female│
│Molecule Man   │Dan Jukes      │Radiation resistance, Turning tiny, Radiation blast                        │29     │¿  │male  │
└───────────────┴───────────────┴───────────────────────────────────────────────────────────────────────────┴───────┴───┴──────┘
EOF

        describe 'from ~/.json2table/${resource}.conf (Nb. use conf=~)'
          TILDA=shpecs/support matches_expected 'conf=$TILDA super_hero_member.table' <<-EOF
Super Heroes
┌───────────────┬───────────────┬───────────────────────────────────────────────────────────────────────────┬───────┬───┬──────┐
│name           │:secretIdentity│powers                                                                     │age    │bar│gender│
├───────────────┼───────────────┼───────────────────────────────────────────────────────────────────────────┼───────┼───┼──────┤
│Madame Uppercut│Jane Wilson    │Million tonne punch, Damage resistance, Superhuman reflexes                │39     │¿  │female│
│Eternal Flame  │Unknown        │Immortality, Heat Immunity, Inferno, Teleportation, Interdimensional travel│1000000│¿  │female│
│Molecule Man   │Dan Jukes      │Radiation resistance, Turning tiny, Radiation blast                        │29     │¿  │male  │
└───────────────┴───────────────┴───────────────────────────────────────────────────────────────────────────┴───────┴───┴──────┘
EOF
        end_
      end_

      describe 'shared conf'
        matches_expected 'conf=shpecs/support/shared.conf super_hero_member.table' <<-EOF
Super Heroes
┌───────────────────────────────────────────────────────────────────────────┬───┬──────┐
│powers                                                                     │bar│gender│
├───────────────────────────────────────────────────────────────────────────┼───┼──────┤
│Million tonne punch, Damage resistance, Superhuman reflexes                │¿  │female│
│Immortality, Heat Immunity, Inferno, Teleportation, Interdimensional travel│¿  │female│
│Radiation resistance, Turning tiny, Radiation blast                        │¿  │male  │
└───────────────────────────────────────────────────────────────────────────┴───┴──────┘
EOF

        matches_expected 'conf=shpecs/support/shared-add.conf super_hero_member.table' <<-EOF
Super Shared Heroes
┌───────────────┬───────────────┬───────────────────────────────────────────────────────────────────────────┬───────┬───┬──────┐
│name           │:secretIdentity│powers                                                                     │age    │bar│gender│
├───────────────┼───────────────┼───────────────────────────────────────────────────────────────────────────┼───────┼───┼──────┤
│Madame Uppercut│Jane Wilson    │Million tonne punch, Damage resistance, Superhuman reflexes                │39     │¿  │female│
│Eternal Flame  │Unknown        │Immortality, Heat Immunity, Inferno, Teleportation, Interdimensional travel│1000000│¿  │female│
│Molecule Man   │Dan Jukes      │Radiation resistance, Turning tiny, Radiation blast                        │29     │¿  │male  │
└───────────────┴───────────────┴───────────────────────────────────────────────────────────────────────────┴───────┴───┴──────┘
EOF
      end_
    end_

    describe 'color_terms'
      input_cmd() { jq --compact-output '.members[]'; }

      matches_expected_with_colors 'color_terms="$(cat shpecs/support/color_terms-full.txt)" super_hero_member.table' <<-EOF
[1mSuper Heroes[0m
┌───────────────┬───────────────┬───────────────────────────────────────────────────────────────────────────┬───────┐
│[1mname           [0m│[1m:secretIdentity[0m│[1mpowers                                                                     [0m│[1mage    [0m│
├───────────────┼───────────────┼───────────────────────────────────────────────────────────────────────────┼───────┤
│Eternal Flame  │Unknown        │Immortality, Heat Immunity, Inferno, Teleportation, Interdimensional travel│1000000│
│Madame Uppercut│[1;36m[KJane Wilson[m[K    │Million tonne punch, Damage resistance, Superhuman reflexes                │39     │
│Molecule Man   │Dan Jukes      │Radiation resistance, [1;35m[KTurning tiny[m[K, Radiation [1;34m[Kblast[m[K                        │29     │
└───────────────┴───────────────┴───────────────────────────────────────────────────────────────────────────┴───────┘
EOF

      matches_expected_with_colors 'color_terms="$(cat shpecs/support/color_terms-partial.txt)" super_hero_member.table' <<-EOF
[1mSuper Heroes[0m
┌───────────────┬───────────────┬───────────────────────────────────────────────────────────────────────────┬───────┐
│[1mname           [0m│[1m:secretIdentity[0m│[1mpowers                                                                     [0m│[1mage    [0m│
├───────────────┼───────────────┼───────────────────────────────────────────────────────────────────────────┼───────┤
│Eternal Flame  │Unknown        │Immortality, Heat Immunity, Inferno, Teleportation, Interdimensional travel│1000000│
│Madame Uppercut│[1;36m[KJane Wilson[m[K    │Million tonne punch, Damage resistance, Superhuman reflexes                │39     │
│Molecule Man   │Dan Jukes      │Radiation resistance, Turning tiny, Radiation [1;34m[Kblast[m[K                        │29     │
└───────────────┴───────────────┴───────────────────────────────────────────────────────────────────────────┴───────┘
EOF

      matches_expected_with_colors 'super_hero_member_color_terms="$(cat shpecs/support/color_terms-full.txt)" super_hero_member.table' <<-EOF
[1mSuper Heroes[0m
┌───────────────┬───────────────┬───────────────────────────────────────────────────────────────────────────┬───────┐
│[1mname           [0m│[1m:secretIdentity[0m│[1mpowers                                                                     [0m│[1mage    [0m│
├───────────────┼───────────────┼───────────────────────────────────────────────────────────────────────────┼───────┤
│Eternal Flame  │Unknown        │Immortality, Heat Immunity, Inferno, Teleportation, Interdimensional travel│1000000│
│Madame Uppercut│[1;36m[KJane Wilson[m[K    │Million tonne punch, Damage resistance, Superhuman reflexes                │39     │
│Molecule Man   │Dan Jukes      │Radiation resistance, [1;35m[KTurning tiny[m[K, Radiation [1;34m[Kblast[m[K                        │29     │
└───────────────┴───────────────┴───────────────────────────────────────────────────────────────────────────┴───────┘
EOF

      matches_expected_with_colors 'super_hero_member_color_terms="$(cat shpecs/support/color_terms-partial.txt)" super_hero_member.table' <<-EOF
[1mSuper Heroes[0m
┌───────────────┬───────────────┬───────────────────────────────────────────────────────────────────────────┬───────┐
│[1mname           [0m│[1m:secretIdentity[0m│[1mpowers                                                                     [0m│[1mage    [0m│
├───────────────┼───────────────┼───────────────────────────────────────────────────────────────────────────┼───────┤
│Eternal Flame  │Unknown        │Immortality, Heat Immunity, Inferno, Teleportation, Interdimensional travel│1000000│
│Madame Uppercut│[1;36m[KJane Wilson[m[K    │Million tonne punch, Damage resistance, Superhuman reflexes                │39     │
│Molecule Man   │Dan Jukes      │Radiation resistance, Turning tiny, Radiation [1;34m[Kblast[m[K                        │29     │
└───────────────┴───────────────┴───────────────────────────────────────────────────────────────────────────┴───────┘
EOF

      matches_expected_with_colors 'conf=shpecs/support/specific.conf super_hero_member.table' <<-EOF
[1mSuper Specific Heroes[0m
┌───────────────────────────────────────────────────────────────────────────┬───┬──────┐
│[1mpowers                                                                     [0m│[1mfoo[0m│[1mgender[0m│
├───────────────────────────────────────────────────────────────────────────┼───┼──────┤
│Million tonne punch, [1;34m[KDamage resistance[m[K, [1;35m[KSuperhuman[m[K reflexes                │[1;41m[K¿[m[K  │female│
│Immortality, [1;41m[KHeat[m[K [1;42m[KImmunity[m[K, Inferno, Teleportation, Interdimensional travel│[1;41m[K¿[m[K  │female│
│Radiation resistance, Turning tiny, Radiation blast                        │[1;41m[K¿[m[K  │male  │
└───────────────────────────────────────────────────────────────────────────┴───┴──────┘
EOF

      matches_expected_with_colors 'conf=shpecs/support/shared.conf super_hero_member.table' <<-EOF
[1mSuper Heroes[0m
┌───────────────────────────────────────────────────────────────────────────┬───┬──────┐
│[1mpowers                                                                     [0m│[1mbar[0m│[1mgender[0m│
├───────────────────────────────────────────────────────────────────────────┼───┼──────┤
│Million tonne punch, [1;42m[KDamage resistance[m[K, [1;36m[KSuperhuman[m[K reflexes                │[1;41m[K¿[m[K  │female│
│Immortality, [1;34m[KHeat[m[K [1;35m[KImmunity[m[K, Inferno, Teleportation, Interdimensional travel│[1;41m[K¿[m[K  │female│
│Radiation resistance, Turning tiny, Radiation blast                        │[1;41m[K¿[m[K  │male  │
└───────────────────────────────────────────────────────────────────────────┴───┴──────┘
EOF
    end_

    describe 'color_terms_add'
      input_cmd() { jq --compact-output '.members[]'; }

      matches_expected_with_colors 'conf=shpecs/support/specific-add.conf super_hero_member.table' <<-EOF
[1mSuper Heroes[0m
┌───────────────┬───────────────┬───────────────────────────────────────────────────────────────────────────┬───────┬───┬──────┐
│[1mname           [0m│[1m:secretIdentity[0m│[1mpowers                                                                     [0m│[1mage    [0m│[1mfoo[0m│[1mgender[0m│
├───────────────┼───────────────┼───────────────────────────────────────────────────────────────────────────┼───────┼───┼──────┤
│[1;34m[KEternal[m[K Flame  │Unknown        │Immortality, Heat Immunity, Inferno, Teleportation, [1;45m[KInterdimensional travel[m[K│1000000│[1;41m[K¿[m[K  │[1;44m[Kfemale[m[K│
│[1;36m[KMadame[m[K [1;41m[KUppercut[m[K│Jane Wilson    │Million tonne punch, Damage resistance, Superhuman reflexes                │39     │[1;41m[K¿[m[K  │[1;44m[Kfemale[m[K│
│Molecule [1;43m[KMan[m[K   │[1;42m[KDan Jukes[m[K      │Radiation resistance, Turning tiny, Radiation blast                        │29     │[1;41m[K¿[m[K  │[1;43m[Kmale[m[K  │
└───────────────┴───────────────┴───────────────────────────────────────────────────────────────────────────┴───────┴───┴──────┘
EOF

      matches_expected_with_colors 'conf=shpecs/support/shared-add.conf super_hero_member.table' <<-EOF
[1mSuper Shared Heroes[0m
┌───────────────┬───────────────┬───────────────────────────────────────────────────────────────────────────┬───────┬───┬──────┐
│[1mname           [0m│[1m:secretIdentity[0m│[1mpowers                                                                     [0m│[1mage    [0m│[1mbar[0m│[1mgender[0m│
├───────────────┼───────────────┼───────────────────────────────────────────────────────────────────────────┼───────┼───┼──────┤
│[1;36m[KMadame[m[K [1;41m[KUppercut[m[K│Jane Wilson    │Million tonne punch, Damage resistance, Superhuman reflexes                │39     │[1;41m[K¿[m[K  │[1;43m[Kfemale[m[K│
│[1;34m[KEternal[m[K Flame  │Unknown        │Immortality, Heat Immunity, Inferno, Teleportation, [1;45m[KInterdimensional travel[m[K│1000000│[1;41m[K¿[m[K  │[1;43m[Kfemale[m[K│
│Molecule [1;44m[KMan[m[K   │[1;42m[KDan Jukes[m[K      │Radiation resistance, Turning tiny, Radiation blast                        │29     │[1;41m[K¿[m[K  │[1;44m[Kmale[m[K  │
└───────────────┴───────────────┴───────────────────────────────────────────────────────────────────────────┴───────┴───┴──────┘
EOF

      matches_expected_with_colors 'color_terms_add="$(cat shpecs/support/color_terms-full.txt)" super_hero_member.table' <<-EOF
[1mSuper Heroes[0m
┌───────────────┬───────────────┬───────────────────────────────────────────────────────────────────────────┬───────┐
│[1mname           [0m│[1m:secretIdentity[0m│[1mpowers                                                                     [0m│[1mage    [0m│
├───────────────┼───────────────┼───────────────────────────────────────────────────────────────────────────┼───────┤
│[1;34m[KEternal[m[K Flame  │Unknown        │Immortality, Heat Immunity, Inferno, Teleportation, Interdimensional travel│1000000│
│[1;36m[KMadame[m[K [1;41m[KUppercut[m[K│[1;45m[KJane Wilson[m[K    │Million tonne punch, Damage resistance, Superhuman reflexes                │39     │
│Molecule Man   │[1;42m[KDan Jukes[m[K      │Radiation resistance, [1;44m[KTurning tiny[m[K, Radiation [1;43m[Kblast[m[K                        │29     │
└───────────────┴───────────────┴───────────────────────────────────────────────────────────────────────────┴───────┘
EOF

      matches_expected_with_colors 'color_terms_add="$(cat shpecs/support/color_terms-partial.txt)" super_hero_member.table' <<-EOF
[1mSuper Heroes[0m
┌───────────────┬───────────────┬───────────────────────────────────────────────────────────────────────────┬───────┐
│[1mname           [0m│[1m:secretIdentity[0m│[1mpowers                                                                     [0m│[1mage    [0m│
├───────────────┼───────────────┼───────────────────────────────────────────────────────────────────────────┼───────┤
│[1;34m[KEternal[m[K Flame  │Unknown        │Immortality, Heat Immunity, Inferno, Teleportation, Interdimensional travel│1000000│
│[1;36m[KMadame[m[K [1;41m[KUppercut[m[K│[1;45m[KJane Wilson[m[K    │Million tonne punch, Damage resistance, Superhuman reflexes                │39     │
│Molecule Man   │[1;42m[KDan Jukes[m[K      │Radiation resistance, Turning tiny, Radiation [1;43m[Kblast[m[K                        │29     │
└───────────────┴───────────────┴───────────────────────────────────────────────────────────────────────────┴───────┘
EOF

      matches_expected_with_colors 'super_hero_member_color_terms_add="$(cat shpecs/support/color_terms-full.txt)" super_hero_member.table' <<-EOF
[1mSuper Heroes[0m
┌───────────────┬───────────────┬───────────────────────────────────────────────────────────────────────────┬───────┐
│[1mname           [0m│[1m:secretIdentity[0m│[1mpowers                                                                     [0m│[1mage    [0m│
├───────────────┼───────────────┼───────────────────────────────────────────────────────────────────────────┼───────┤
│[1;34m[KEternal[m[K Flame  │Unknown        │Immortality, Heat Immunity, Inferno, Teleportation, Interdimensional travel│1000000│
│[1;36m[KMadame[m[K [1;41m[KUppercut[m[K│[1;45m[KJane Wilson[m[K    │Million tonne punch, Damage resistance, Superhuman reflexes                │39     │
│Molecule Man   │[1;42m[KDan Jukes[m[K      │Radiation resistance, [1;44m[KTurning tiny[m[K, Radiation [1;43m[Kblast[m[K                        │29     │
└───────────────┴───────────────┴───────────────────────────────────────────────────────────────────────────┴───────┘
EOF

      matches_expected_with_colors 'super_hero_member_color_terms_add="$(cat shpecs/support/color_terms-partial.txt)" super_hero_member.table' <<-EOF
[1mSuper Heroes[0m
┌───────────────┬───────────────┬───────────────────────────────────────────────────────────────────────────┬───────┐
│[1mname           [0m│[1m:secretIdentity[0m│[1mpowers                                                                     [0m│[1mage    [0m│
├───────────────┼───────────────┼───────────────────────────────────────────────────────────────────────────┼───────┤
│[1;34m[KEternal[m[K Flame  │Unknown        │Immortality, Heat Immunity, Inferno, Teleportation, Interdimensional travel│1000000│
│[1;36m[KMadame[m[K [1;41m[KUppercut[m[K│[1;45m[KJane Wilson[m[K    │Million tonne punch, Damage resistance, Superhuman reflexes                │39     │
│Molecule Man   │[1;42m[KDan Jukes[m[K      │Radiation resistance, Turning tiny, Radiation [1;43m[Kblast[m[K                        │29     │
└───────────────┴───────────────┴───────────────────────────────────────────────────────────────────────────┴───────┘
EOF
    end_
  end_

  # there should be no difference between .json & .jsonl, so let's only bother doing one test...
  describe 'processing `.json` files'
    # shellcheck disable=SC2317
    input_cmd() { jq --compact-output '.members'; }

    describe 'cols'
      describe 'all'
        matches_expected 'json2table' <<-EOF
┌───────┬──────┬───────────────┬───────────────────────────────────────────────────────────────────────────────────┬───────────────┐
│age    │gender│name           │powers                                                                             │secret.identity│
├───────┼──────┼───────────────┼───────────────────────────────────────────────────────────────────────────────────┼───────────────┤
│29     │male  │Molecule Man   │["Radiation resistance","Turning tiny","Radiation blast"]                          │Dan Jukes      │
│39     │female│Madame Uppercut│["Million tonne punch","Damage resistance","Superhuman reflexes"]                  │Jane Wilson    │
│1000000│female│Eternal Flame  │["Immortality","Heat Immunity","Inferno","Teleportation","Interdimensional travel"]│Unknown        │
└───────┴──────┴───────────────┴───────────────────────────────────────────────────────────────────────────────────┴───────────────┘
EOF
      end_
    end_
  end_
end_
