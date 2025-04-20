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
┌───────────────┬───────┬──────┬───────────────┬───────────────────────────────────────────────────────────────────────────────────┐
│name           │age    │gender│secret.identity│powers                                                                             │
├───────────────┼───────┼──────┼───────────────┼───────────────────────────────────────────────────────────────────────────────────┤
│Molecule Man   │29     │male  │Dan Jukes      │["Radiation resistance","Turning tiny","Radiation blast"]                          │
│Madame Uppercut│39     │female│Jane Wilson    │["Million tonne punch","Damage resistance","Superhuman reflexes"]                  │
│Eternal Flame  │1000000│female│Unknown        │["Immortality","Heat Immunity","Inferno","Teleportation","Interdimensional travel"]│
└───────────────┴───────┴──────┴───────────────┴───────────────────────────────────────────────────────────────────────────────────┘
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
┌───────────────┬───────┬──────┬───────────────┬──────────────────────────────┐
│name           │age    │gender│secret.identity│powers                        │
├───────────────┼───────┼──────┼───────────────┼──────────────────────────────┤
│Molecule Man   │29     │male  │Dan Jukes      │["Radiation resistance","..."]│
│Madame Uppercut│39     │female│Jane Wilson    │["Million tonne punch","D..."]│
│Eternal Flame  │1000000│female│Unknown        │["Immortality","Heat Immu..."]│
└───────────────┴───────┴──────┴───────────────┴──────────────────────────────┘
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
┌───────────────┬───────┬──────┬───────────────┬───────────────────────────────────────────────────────────────────────────────────┐
│name           │age    │gender│secret.identity│powers                                                                             │
├───────────────┼───────┼──────┼───────────────┼───────────────────────────────────────────────────────────────────────────────────┤
│Madame Uppercut│39     │female│Jane Wilson    │["Million tonne punch","Damage resistance","Superhuman reflexes"]                  │
│Eternal Flame  │1000000│female│Unknown        │["Immortality","Heat Immunity","Inferno","Teleportation","Interdimensional travel"]│
└───────────────┴───────┴──────┴───────────────┴───────────────────────────────────────────────────────────────────────────────────┘
EOF
        end_

        describe 'regex filter'
          matches_expected 'sort_by=">name=/(Ma.*?m|man)/ix" json2table' <<-EOF
┌───────────────┬───┬──────┬───────────────┬─────────────────────────────────────────────────────────────────┐
│name           │age│gender│secret.identity│powers                                                           │
├───────────────┼───┼──────┼───────────────┼─────────────────────────────────────────────────────────────────┤
│Molecule Man   │29 │male  │Dan Jukes      │["Radiation resistance","Turning tiny","Radiation blast"]        │
│Madame Uppercut│39 │female│Jane Wilson    │["Million tonne punch","Damage resistance","Superhuman reflexes"]│
└───────────────┴───┴──────┴───────────────┴─────────────────────────────────────────────────────────────────┘
EOF
          describe 'with whitespace'
            matches_expected 'sort_by="name=\"/(Ma.*?m   |   man) # this regex also has ix flags to ignore case, comments & whitespace/ix\"" json2table' <<-EOF
┌───────────────┬───┬──────┬───────────────┬─────────────────────────────────────────────────────────────────┐
│name           │age│gender│secret.identity│powers                                                           │
├───────────────┼───┼──────┼───────────────┼─────────────────────────────────────────────────────────────────┤
│Madame Uppercut│39 │female│Jane Wilson    │["Million tonne punch","Damage resistance","Superhuman reflexes"]│
│Molecule Man   │29 │male  │Dan Jukes      │["Radiation resistance","Turning tiny","Radiation blast"]        │
└───────────────┴───┴──────┴───────────────┴─────────────────────────────────────────────────────────────────┘
EOF
        end_

        describe 'multiple filters'
          matches_expected 'sort_by="age=39 gender=female" json2table' <<-EOF
┌───────────────┬───┬──────┬───────────────┬─────────────────────────────────────────────────────────────────┐
│name           │age│gender│secret.identity│powers                                                           │
├───────────────┼───┼──────┼───────────────┼─────────────────────────────────────────────────────────────────┤
│Madame Uppercut│39 │female│Jane Wilson    │["Million tonne punch","Damage resistance","Superhuman reflexes"]│
└───────────────┴───┴──────┴───────────────┴─────────────────────────────────────────────────────────────────┘
EOF
        end_

        describe 'multiple filters on multiple lines'
          export age=39 gender=female; sort_by=$(set | grep -E '^(age|gender)')
          matches_expected "sort_by='$sort_by' json2table" <<-EOF
┌───────────────┬───┬──────┬───────────────┬─────────────────────────────────────────────────────────────────┐
│name           │age│gender│secret.identity│powers                                                           │
├───────────────┼───┼──────┼───────────────┼─────────────────────────────────────────────────────────────────┤
│Madame Uppercut│39 │female│Jane Wilson    │["Million tonne punch","Damage resistance","Superhuman reflexes"]│
└───────────────┴───┴──────┴───────────────┴─────────────────────────────────────────────────────────────────┘
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
            matches_expected '               cols="name gender  age" json2table ">age<=39"           ' <<< "$expected"
            matches_expected '               cols="name gender >age" json2table "name=/e[ ] (u|m)/ix"' <<< "$expected"
          end_
          describe 'cols'
            matches_expected 'sort_by=">age" cols=" name                gender  age<=39" json2table' <<< "$expected"
            matches_expected '               cols=" name                gender >age<=39" json2table' <<< "$expected"
            matches_expected '               cols="<name=/^m/i          gender  age"     json2table' <<< "$expected"
            matches_expected '               cols="<name=/e (u|m)/i     gender  age"     json2table' <<< "$expected"
            matches_expected '               cols="<name=/e[ ] (u|m)/ix gender  age"     json2table' <<< "$expected"
          end_
          describe 'sort_by'
            matches_expected 'sort_by="        >age<=39"                                       json2table name gender age' <<< "$expected"
            matches_expected 'sort_by="        >age    " cols="name gender age<=39"            json2table                ' <<< "$expected"
            matches_expected 'sort_by="<gender <age    " cols="name gender age<=39"            json2table                ' <<< "$expected"
            matches_expected 'sort_by="gender   age    " cols="name gender age<=39"            json2table                ' <<< "$expected"
            matches_expected 'sort_by="gender   age    " cols="name=/e[ ] (u|m)/ix gender age" json2table                ' <<< "$expected"
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
┌───────────────┬───────┬──────┬───────────────┬───────────────────────────────────────────────────────────────────────────────────┐
│name           │age    │gender│secret.identity│powers                                                                             │
├───────────────┼───────┼──────┼───────────────┼───────────────────────────────────────────────────────────────────────────────────┤
│Molecule Man   │29     │male  │Dan Jukes      │["Radiation resistance","Turning tiny","Radiation blast"]                          │
│Madame Uppercut│39     │female│Jane Wilson    │["Million tonne punch","Damage resistance","Superhuman reflexes"]                  │
│Eternal Flame  │1000000│female│Unknown        │["Immortality","Heat Immunity","Inferno","Teleportation","Interdimensional travel"]│
└───────────────┴───────┴──────┴───────────────┴───────────────────────────────────────────────────────────────────────────────────┘
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
┌───────────────┬───────┬──────┬───────────────┬───────────────────────────────────────────────────────────────────────────────────┐
│name           │age    │gender│secret.identity│powers                                                                             │
├───────────────┼───────┼──────┼───────────────┼───────────────────────────────────────────────────────────────────────────────────┤
│Molecule Man   │29     │male  │Dan Jukes      │["Radiation resistance","Turning tiny","Radiation blast"]                          │
│Madame Uppercut│39     │female│Jane Wilson    │["Million tonne punch","Damage resistance","Superhuman reflexes"]                  │
│Eternal Flame  │1000000│female│Unknown        │["Immortality","Heat Immunity","Inferno","Teleportation","Interdimensional travel"]│
└───────────────┴───────┴──────┴───────────────┴───────────────────────────────────────────────────────────────────────────────────┘
EOF
        end_
      end_
    end_

    describe 'symlink: member.table -> json2table'
      # shellcheck disable=SC2317
      input_cmd() { cat; }

      matches_expected 'member.table' <<-EOF
┌───────────────┬───────┬──────┬───────────────┬───────────────────────────────────────────────────────────────────────────────────┐
│name           │age    │gender│secret.identity│powers                                                                             │
├───────────────┼───────┼──────┼───────────────┼───────────────────────────────────────────────────────────────────────────────────┤
│Molecule Man   │29     │male  │Dan Jukes      │["Radiation resistance","Turning tiny","Radiation blast"]                          │
│Madame Uppercut│39     │female│Jane Wilson    │["Million tonne punch","Damage resistance","Superhuman reflexes"]                  │
│Eternal Flame  │1000000│female│Unknown        │["Immortality","Heat Immunity","Inferno","Teleportation","Interdimensional travel"]│
└───────────────┴───────┴──────┴───────────────┴───────────────────────────────────────────────────────────────────────────────────┘
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

      STRIP_COLOR=false matches_expected 'color_terms="$(cat shpecs/support/color_terms-full.txt)" super_hero_member.table' <<-EOF
[1mSuper Heroes[0m
┌───────────────┬───────────────┬───────────────────────────────────────────────────────────────────────────┬───────┐
│[1mname           [0m│[1m:secretIdentity[0m│[1mpowers                                                                     [0m│[1mage    [0m│
├───────────────┼───────────────┼───────────────────────────────────────────────────────────────────────────┼───────┤
│Eternal Flame  │Unknown        │Immortality, Heat Immunity, Inferno, Teleportation, Interdimensional travel│1000000│
│Madame Uppercut│[1;36mJane Wilson[0m    │Million tonne punch, Damage resistance, Superhuman reflexes                │39     │
│Molecule Man   │Dan Jukes      │Radiation resistance, [1;35mTurning tiny[0m, Radiation [1;34mblast[0m                        │29     │
└───────────────┴───────────────┴───────────────────────────────────────────────────────────────────────────┴───────┘
EOF

      STRIP_COLOR=false matches_expected 'color_terms="$(cat shpecs/support/color_terms-partial.txt)" super_hero_member.table' <<-EOF
[1mSuper Heroes[0m
┌───────────────┬───────────────┬───────────────────────────────────────────────────────────────────────────┬───────┐
│[1mname           [0m│[1m:secretIdentity[0m│[1mpowers                                                                     [0m│[1mage    [0m│
├───────────────┼───────────────┼───────────────────────────────────────────────────────────────────────────┼───────┤
│Eternal Flame  │Unknown        │Immortality, Heat Immunity, Inferno, Teleportation, Interdimensional travel│1000000│
│Madame Uppercut│[1;36mJane Wilson[0m    │Million tonne punch, Damage resistance, Superhuman reflexes                │39     │
│Molecule Man   │Dan Jukes      │Radiation resistance, Turning tiny, Radiation [1;34mblast[0m                        │29     │
└───────────────┴───────────────┴───────────────────────────────────────────────────────────────────────────┴───────┘
EOF

      STRIP_COLOR=false matches_expected 'super_hero_member_color_terms="$(cat shpecs/support/color_terms-full.txt)" super_hero_member.table' <<-EOF
[1mSuper Heroes[0m
┌───────────────┬───────────────┬───────────────────────────────────────────────────────────────────────────┬───────┐
│[1mname           [0m│[1m:secretIdentity[0m│[1mpowers                                                                     [0m│[1mage    [0m│
├───────────────┼───────────────┼───────────────────────────────────────────────────────────────────────────┼───────┤
│Eternal Flame  │Unknown        │Immortality, Heat Immunity, Inferno, Teleportation, Interdimensional travel│1000000│
│Madame Uppercut│[1;36mJane Wilson[0m    │Million tonne punch, Damage resistance, Superhuman reflexes                │39     │
│Molecule Man   │Dan Jukes      │Radiation resistance, [1;35mTurning tiny[0m, Radiation [1;34mblast[0m                        │29     │
└───────────────┴───────────────┴───────────────────────────────────────────────────────────────────────────┴───────┘
EOF

      STRIP_COLOR=false matches_expected 'super_hero_member_color_terms="$(cat shpecs/support/color_terms-partial.txt)" super_hero_member.table' <<-EOF
[1mSuper Heroes[0m
┌───────────────┬───────────────┬───────────────────────────────────────────────────────────────────────────┬───────┐
│[1mname           [0m│[1m:secretIdentity[0m│[1mpowers                                                                     [0m│[1mage    [0m│
├───────────────┼───────────────┼───────────────────────────────────────────────────────────────────────────┼───────┤
│Eternal Flame  │Unknown        │Immortality, Heat Immunity, Inferno, Teleportation, Interdimensional travel│1000000│
│Madame Uppercut│[1;36mJane Wilson[0m    │Million tonne punch, Damage resistance, Superhuman reflexes                │39     │
│Molecule Man   │Dan Jukes      │Radiation resistance, Turning tiny, Radiation [1;34mblast[0m                        │29     │
└───────────────┴───────────────┴───────────────────────────────────────────────────────────────────────────┴───────┘
EOF

      STRIP_COLOR=false matches_expected 'conf=shpecs/support/specific.conf super_hero_member.table' <<-EOF
[1mSuper Specific Heroes[0m
┌───────────────────────────────────────────────────────────────────────────┬───┬──────┐
│[1mpowers                                                                     [0m│[1mfoo[0m│[1mgender[0m│
├───────────────────────────────────────────────────────────────────────────┼───┼──────┤
│Million tonne punch, [1;34mDamage resistance[0m, [1;35mSuperhuman[0m reflexes                │¿  │female│
│Immortality, [1;41mHeat[0m [1;42mImmunity[0m, Inferno, Teleportation, Interdimensional travel│¿  │female│
│Radiation resistance, Turning tiny, Radiation blast                        │¿  │male  │
└───────────────────────────────────────────────────────────────────────────┴───┴──────┘
EOF

      STRIP_COLOR=false matches_expected 'conf=shpecs/support/shared.conf super_hero_member.table' <<-EOF
[1mSuper Heroes[0m
┌───────────────────────────────────────────────────────────────────────────┬───┬──────┐
│[1mpowers                                                                     [0m│[1mbar[0m│[1mgender[0m│
├───────────────────────────────────────────────────────────────────────────┼───┼──────┤
│Million tonne punch, [1;42mDamage resistance[0m, [1;36mSuperhuman[0m reflexes                │¿  │female│
│Immortality, [1;34mHeat[0m [1;35mImmunity[0m, Inferno, Teleportation, Interdimensional travel│¿  │female│
│Radiation resistance, Turning tiny, Radiation blast                        │¿  │male  │
└───────────────────────────────────────────────────────────────────────────┴───┴──────┘
EOF
    end_

    describe 'color_terms_add'
      input_cmd() { jq --compact-output '.members[]'; }

      STRIP_COLOR=false matches_expected 'conf=shpecs/support/specific-add.conf super_hero_member.table' <<-EOF
[1mSuper Heroes[0m
┌───────────────┬───────────────┬───────────────────────────────────────────────────────────────────────────┬───────┬───┬──────┐
│[1mname           [0m│[1m:secretIdentity[0m│[1mpowers                                                                     [0m│[1mage    [0m│[1mfoo[0m│[1mgender[0m│
├───────────────┼───────────────┼───────────────────────────────────────────────────────────────────────────┼───────┼───┼──────┤
│[1;34mEternal[0m Flame  │Unknown        │Immortality, Heat Immunity, Inferno, Teleportation, [1;45mInterdimensional travel[0m│1000000│¿  │[1;44mfemale[0m│
│[1;36mMadame[0m [1;41mUppercut[0m│Jane Wilson    │Million tonne punch, Damage resistance, Superhuman reflexes                │39     │¿  │[1;44mfemale[0m│
│Molecule [1;43mMan[0m   │[1;42mDan Jukes[0m      │Radiation resistance, Turning tiny, Radiation blast                        │29     │¿  │[1;43mmale[0m  │
└───────────────┴───────────────┴───────────────────────────────────────────────────────────────────────────┴───────┴───┴──────┘
EOF

      STRIP_COLOR=false matches_expected 'conf=shpecs/support/shared-add.conf super_hero_member.table' <<-EOF
[1mSuper Shared Heroes[0m
┌───────────────┬───────────────┬───────────────────────────────────────────────────────────────────────────┬───────┬───┬──────┐
│[1mname           [0m│[1m:secretIdentity[0m│[1mpowers                                                                     [0m│[1mage    [0m│[1mbar[0m│[1mgender[0m│
├───────────────┼───────────────┼───────────────────────────────────────────────────────────────────────────┼───────┼───┼──────┤
│[1;36mMadame[0m [1;41mUppercut[0m│Jane Wilson    │Million tonne punch, Damage resistance, Superhuman reflexes                │39     │¿  │[1;43mfemale[0m│
│[1;34mEternal[0m Flame  │Unknown        │Immortality, Heat Immunity, Inferno, Teleportation, [1;45mInterdimensional travel[0m│1000000│¿  │[1;43mfemale[0m│
│Molecule [1;44mMan[0m   │[1;42mDan Jukes[0m      │Radiation resistance, Turning tiny, Radiation blast                        │29     │¿  │[1;44mmale[0m  │
└───────────────┴───────────────┴───────────────────────────────────────────────────────────────────────────┴───────┴───┴──────┘
EOF

      STRIP_COLOR=false matches_expected 'color_terms_add="$(cat shpecs/support/color_terms-full.txt)" super_hero_member.table' <<-EOF
[1mSuper Heroes[0m
┌───────────────┬───────────────┬───────────────────────────────────────────────────────────────────────────┬───────┐
│[1mname           [0m│[1m:secretIdentity[0m│[1mpowers                                                                     [0m│[1mage    [0m│
├───────────────┼───────────────┼───────────────────────────────────────────────────────────────────────────┼───────┤
│[1;34mEternal[0m Flame  │Unknown        │Immortality, Heat Immunity, Inferno, Teleportation, Interdimensional travel│1000000│
│[1;36mMadame[0m [1;41mUppercut[0m│[1;45mJane Wilson[0m    │Million tonne punch, Damage resistance, Superhuman reflexes                │39     │
│Molecule Man   │[1;42mDan Jukes[0m      │Radiation resistance, [1;44mTurning tiny[0m, Radiation [1;43mblast[0m                        │29     │
└───────────────┴───────────────┴───────────────────────────────────────────────────────────────────────────┴───────┘
EOF

      STRIP_COLOR=false matches_expected 'color_terms_add="$(cat shpecs/support/color_terms-partial.txt)" super_hero_member.table' <<-EOF
[1mSuper Heroes[0m
┌───────────────┬───────────────┬───────────────────────────────────────────────────────────────────────────┬───────┐
│[1mname           [0m│[1m:secretIdentity[0m│[1mpowers                                                                     [0m│[1mage    [0m│
├───────────────┼───────────────┼───────────────────────────────────────────────────────────────────────────┼───────┤
│[1;34mEternal[0m Flame  │Unknown        │Immortality, Heat Immunity, Inferno, Teleportation, Interdimensional travel│1000000│
│[1;36mMadame[0m [1;41mUppercut[0m│[1;45mJane Wilson[0m    │Million tonne punch, Damage resistance, Superhuman reflexes                │39     │
│Molecule Man   │[1;42mDan Jukes[0m      │Radiation resistance, Turning tiny, Radiation [1;43mblast[0m                        │29     │
└───────────────┴───────────────┴───────────────────────────────────────────────────────────────────────────┴───────┘
EOF

      STRIP_COLOR=false matches_expected 'super_hero_member_color_terms_add="$(cat shpecs/support/color_terms-full.txt)" super_hero_member.table' <<-EOF
[1mSuper Heroes[0m
┌───────────────┬───────────────┬───────────────────────────────────────────────────────────────────────────┬───────┐
│[1mname           [0m│[1m:secretIdentity[0m│[1mpowers                                                                     [0m│[1mage    [0m│
├───────────────┼───────────────┼───────────────────────────────────────────────────────────────────────────┼───────┤
│[1;34mEternal[0m Flame  │Unknown        │Immortality, Heat Immunity, Inferno, Teleportation, Interdimensional travel│1000000│
│[1;36mMadame[0m [1;41mUppercut[0m│[1;45mJane Wilson[0m    │Million tonne punch, Damage resistance, Superhuman reflexes                │39     │
│Molecule Man   │[1;42mDan Jukes[0m      │Radiation resistance, [1;44mTurning tiny[0m, Radiation [1;43mblast[0m                        │29     │
└───────────────┴───────────────┴───────────────────────────────────────────────────────────────────────────┴───────┘
EOF

      STRIP_COLOR=false matches_expected 'super_hero_member_color_terms_add="$(cat shpecs/support/color_terms-partial.txt)" super_hero_member.table' <<-EOF
[1mSuper Heroes[0m
┌───────────────┬───────────────┬───────────────────────────────────────────────────────────────────────────┬───────┐
│[1mname           [0m│[1m:secretIdentity[0m│[1mpowers                                                                     [0m│[1mage    [0m│
├───────────────┼───────────────┼───────────────────────────────────────────────────────────────────────────┼───────┤
│[1;34mEternal[0m Flame  │Unknown        │Immortality, Heat Immunity, Inferno, Teleportation, Interdimensional travel│1000000│
│[1;36mMadame[0m [1;41mUppercut[0m│[1;45mJane Wilson[0m    │Million tonne punch, Damage resistance, Superhuman reflexes                │39     │
│Molecule Man   │[1;42mDan Jukes[0m      │Radiation resistance, Turning tiny, Radiation [1;43mblast[0m                        │29     │
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
┌───────────────┬───────┬──────┬───────────────┬───────────────────────────────────────────────────────────────────────────────────┐
│name           │age    │gender│secret.identity│powers                                                                             │
├───────────────┼───────┼──────┼───────────────┼───────────────────────────────────────────────────────────────────────────────────┤
│Molecule Man   │29     │male  │Dan Jukes      │["Radiation resistance","Turning tiny","Radiation blast"]                          │
│Madame Uppercut│39     │female│Jane Wilson    │["Million tonne punch","Damage resistance","Superhuman reflexes"]                  │
│Eternal Flame  │1000000│female│Unknown        │["Immortality","Heat Immunity","Inferno","Teleportation","Interdimensional travel"]│
└───────────────┴───────┴──────┴───────────────┴───────────────────────────────────────────────────────────────────────────────────┘
EOF
      end_
    end_
  end_

  describe 'find missing cols'
    input_cmd() { echo '[null, {"c": 3, "a": 1}, null, {"b": 2}, {"b": 2, "c": 3}]'; }

    describe 'from all rows'
      matches_expected 'json2table' <<-EOF
┌─┬─┬─┐
│c│a│b│
├─┼─┼─┤
│¿│¿│¿│
│3│1│¿│
│¿│¿│¿│
│¿│¿│2│
│3│¿│2│
└─┴─┴─┘
EOF
    end_

    describe 'from first non null row'
      matches_expected 'find_all_cols=false json2table' <<-EOF
┌─┬─┐
│c│a│
├─┼─┤
│¿│¿│
│3│1│
│¿│¿│
│¿│¿│
│3│¿│
└─┴─┘
EOF
    end_

    describe 'sorting cols'
      matches_expected 'sort_cols=true json2table' <<-EOF
┌─┬─┬─┐
│a│b│c│
├─┼─┼─┤
│¿│¿│¿│
│1│¿│3│
│¿│¿│¿│
│¿│2│¿│
│¿│2│3│
└─┴─┴─┘
EOF
    end_

  end_
end_
