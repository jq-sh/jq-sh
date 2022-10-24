#!/usr/bin/env shpec
# shellcheck disable=SC1090,SC1091,SC2016
source "${BASH_SOURCE[0]%/*}/shpec_helper.sh"
export input_cmd input_file


describe "json2table"
  input_file='shpecs/support/super_heroes.json'

  describe 'processing `.jsonl` files'
    input_cmd='jq --compact-output ".members[]"'

    describe 'cols'
      describe 'all'
        matches_expected 'json2table' \
<<-EOF
┌───────┬──────┬───────────────┬───────────────────────────────────────────────────────────────────────────────────┬───────────────┐
│age    │gender│name           │powers                                                                             │secret.identity│
├───────┼──────┼───────────────┼───────────────────────────────────────────────────────────────────────────────────┼───────────────┤
│29     │male  │Molecule Man   │["Radiation resistance","Turning tiny","Radiation blast"]                          │Dan Jukes      │
│39     │female│Madame Uppercut│["Million tonne punch","Damage resistance","Superhuman reflexes"]                  │Jane Wilson    │
│1000000│female│Eternal Flame  │["Immortality","Heat Immunity","Inferno","Teleportation","Interdimensional travel"]│Unknown        │
└───────┴──────┴───────────────┴───────────────────────────────────────────────────────────────────────────────────┴───────────────┘
EOF
      end

      describe 'cols from arguments'
        matches_expected 'json2table age name secret.identity' \
<<-EOF
┌───────┬───────────────┬───────────────┐
│age    │name           │secret.identity│
├───────┼───────────────┼───────────────┤
│29     │Molecule Man   │Dan Jukes      │
│39     │Madame Uppercut│Jane Wilson    │
│1000000│Eternal Flame  │Unknown        │
└───────┴───────────────┴───────────────┘
EOF
      end

      describe 'cols from an env var'
        matches_expected 'cols="age name secret.identity" json2table' \
<<-EOF
┌───────┬───────────────┬───────────────┐
│age    │name           │secret.identity│
├───────┼───────────────┼───────────────┤
│29     │Molecule Man   │Dan Jukes      │
│39     │Madame Uppercut│Jane Wilson    │
│1000000│Eternal Flame  │Unknown        │
└───────┴───────────────┴───────────────┘
EOF
      end

      describe 'using an alias'
        matches_expected 'json2table age name secret.identity:shh_name' \
<<-EOF
┌───────┬───────────────┬───────────┐
│age    │name           │:shh_name  │
├───────┼───────────────┼───────────┤
│29     │Molecule Man   │Dan Jukes  │
│39     │Madame Uppercut│Jane Wilson│
│1000000│Eternal Flame  │Unknown    │
└───────┴───────────────┴───────────┘
EOF
      end

      describe 'using truncation'
        matches_expected 'json2table name powers%30' \
<<-EOF
┌───────────────┬──────────────────────────────┐
│name           │powers                        │
├───────────────┼──────────────────────────────┤
│Molecule Man   │["Radiation resistance","..."]│
│Madame Uppercut│["Million tonne punch","D..."]│
│Eternal Flame  │["Immortality","Heat Immu..."]│
└───────────────┴──────────────────────────────┘
EOF

        matches_expected 'json2table name powers%30,10' \
<<-EOF
┌───────────────┬──────────────────────────────┐
│name           │powers                        │
├───────────────┼──────────────────────────────┤
│Molecule Man   │["Radiation resis...on blast"]│
│Madame Uppercut│["Million tonne p...reflexes"]│
│Eternal Flame  │["Immortality","H...l travel"]│
└───────────────┴──────────────────────────────┘
EOF
      end

      describe 'using max_width'
        matches_expected 'max_width=80 json2table' \
<<-EOF
┌───────┬──────┬───────────────┬──────────────────────────────┬───────────────┐
│age    │gender│name           │powers                        │secret.identity│
├───────┼──────┼───────────────┼──────────────────────────────┼───────────────┤
│29     │male  │Molecule Man   │["Radiation resistance","..."]│Dan Jukes      │
│39     │female│Madame Uppercut│["Million tonne punch","D..."]│Jane Wilson    │
│1000000│female│Eternal Flame  │["Immortality","Heat Immu..."]│Unknown        │
└───────┴──────┴───────────────┴──────────────────────────────┴───────────────┘
EOF
        describe 'and truncation'
          matches_expected 'max_width=80 json2table age gender name%10 powers secret.identity' \
<<-EOF
┌───────┬──────┬──────────┬───────────────────────────────────┬───────────────┐
│age    │gender│name      │powers                             │secret.identity│
├───────┼──────┼──────────┼───────────────────────────────────┼───────────────┤
│29     │male  │Molec...an│["Radiation resistance","Turni..."]│Dan Jukes      │
│39     │female│Madam...ut│["Million tonne punch","Damage..."]│Jane Wilson    │
│1000000│female│Etern...me│["Immortality","Heat Immunity"..."]│Unknown        │
└───────┴──────┴──────────┴───────────────────────────────────┴───────────────┘
EOF
        end

        describe 'of 0 (ie. no truncation despite not having enough COLUMNS)'
          COLUMNS=60 matches_expected 'max_width=0 json2table age gender name powers secret.identity' \
<<-EOF
┌───────┬──────┬───────────────┬───────────────────────────────────────────────────────────────────────────────────┬───────────────┐
│age    │gender│name           │powers                                                                             │secret.identity│
├───────┼──────┼───────────────┼───────────────────────────────────────────────────────────────────────────────────┼───────────────┤
│29     │male  │Molecule Man   │["Radiation resistance","Turning tiny","Radiation blast"]                          │Dan Jukes      │
│39     │female│Madame Uppercut│["Million tonne punch","Damage resistance","Superhuman reflexes"]                  │Jane Wilson    │
│1000000│female│Eternal Flame  │["Immortality","Heat Immunity","Inferno","Teleportation","Interdimensional travel"]│Unknown        │
└───────┴──────┴───────────────┴───────────────────────────────────────────────────────────────────────────────────┴───────────────┘
EOF
        end
      end
    end

    describe 'multi-line data'
      input_cmd='jq --compact-output ".members[] | .powers |= join(\"\n\")"'
      matches_expected 'json2table name powers' \
<<-EOF
┌───────────────┬───────────────────────────────────────────────────────────────────────────┐
│name           │powers                                                                     │
├───────────────┼───────────────────────────────────────────────────────────────────────────┤
│Molecule Man   │Radiation resistance\nTurning tiny\nRadiation blast                        │
│Madame Uppercut│Million tonne punch\nDamage resistance\nSuperhuman reflexes                │
│Eternal Flame  │Immortality\nHeat Immunity\nInferno\nTeleportation\nInterdimensional travel│
└───────────────┴───────────────────────────────────────────────────────────────────────────┘
EOF
    end

    describe 'sort_by'
      matches_expected 'sort_by="gender age" json2table name gender age' \
<<-EOF
┌───────────────┬──────┬───────┐
│name           │gender│age    │
├───────────────┼──────┼───────┤
│Madame Uppercut│female│39     │
│Eternal Flame  │female│1000000│
│Molecule Man   │male  │29     │
└───────────────┴──────┴───────┘
EOF
    end

    describe 'larger json'
      input_cmd='cat'

      describe 'with `resource` var'
        matches_expected 'resource=location json2table' \
<<-EOF
┌──────────┬───────────┐
│homeTown  │secretBase │
├──────────┼───────────┤
│Metro City│Super tower│
└──────────┴───────────┘
EOF

        matches_expected 'resource=location json2table secretBase homeTown' \
<<-EOF
┌───────────┬──────────┐
│secretBase │homeTown  │
├───────────┼──────────┤
│Super tower│Metro City│
└───────────┴──────────┘
EOF
      end

      describe 'with `resources` var'
        matches_expected 'resources=members json2table' \
<<-EOF
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
          matches_expected 'resources="location members" json2table' \
<<-EOF
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
        end
      end
    end

    describe 'symlink: member.table -> json2table'
      input_cmd='cat'

      matches_expected 'member.table' \
<<-EOF
┌───────┬──────┬───────────────┬───────────────────────────────────────────────────────────────────────────────────┬───────────────┐
│age    │gender│name           │powers                                                                             │secret.identity│
├───────┼──────┼───────────────┼───────────────────────────────────────────────────────────────────────────────────┼───────────────┤
│29     │male  │Molecule Man   │["Radiation resistance","Turning tiny","Radiation blast"]                          │Dan Jukes      │
│39     │female│Madame Uppercut│["Million tonne punch","Damage resistance","Superhuman reflexes"]                  │Jane Wilson    │
│1000000│female│Eternal Flame  │["Immortality","Heat Immunity","Inferno","Teleportation","Interdimensional travel"]│Unknown        │
└───────┴──────┴───────────────┴───────────────────────────────────────────────────────────────────────────────────┴───────────────┘
EOF

      matches_expected 'member.table name secret.identity:secretIdentity' \
<<-EOF
┌───────────────┬───────────────┐
│name           │:secretIdentity│
├───────────────┼───────────────┤
│Molecule Man   │Dan Jukes      │
│Madame Uppercut│Jane Wilson    │
│Eternal Flame  │Unknown        │
└───────────────┴───────────────┘
EOF
    end

    describe 'script: super_hero_member.table'
      input_cmd='jq --compact-output ".members[]"'

      describe 'cols'
        # from `cols` defined in super_hero_member.table
        matches_expected 'super_hero_member.table' \
<<-EOF
Super Heroes
┌───────────────┬───────────────┬───────────────────────────────────────────────────────────────────────────┬───────┐
│name           │:secretIdentity│powers                                                                     │age    │
├───────────────┼───────────────┼───────────────────────────────────────────────────────────────────────────┼───────┤
│Eternal Flame  │Unknown        │Immortality, Heat Immunity, Inferno, Teleportation, Interdimensional travel│1000000│
│Madame Uppercut│Jane Wilson    │Million tonne punch, Damage resistance, Superhuman reflexes                │39     │
│Molecule Man   │Dan Jukes      │Radiation resistance, Turning tiny, Radiation blast                        │29     │
└───────────────┴───────────────┴───────────────────────────────────────────────────────────────────────────┴───────┘
EOF

        matches_expected 'cols="name secret.identity:secretIdentity" super_hero_member.table' \
<<-EOF
Super Heroes
┌───────────────┬───────────────┐
│name           │:secretIdentity│
├───────────────┼───────────────┤
│Eternal Flame  │Unknown        │
│Madame Uppercut│Jane Wilson    │
│Molecule Man   │Dan Jukes      │
└───────────────┴───────────────┘
EOF

        matches_expected 'super_hero_member_cols="name age" super_hero_member.table' \
<<-EOF
Super Heroes
┌───────────────┬───────┐
│name           │age    │
├───────────────┼───────┤
│Eternal Flame  │1000000│
│Madame Uppercut│39     │
│Molecule Man   │29     │
└───────────────┴───────┘
EOF

        matches_expected 'super_hero_member_cols="name missing_key age" super_hero_member.table' \
<<-EOF
Super Heroes
┌───────────────┬───────────┬───────┐
│name           │missing_key│age    │
├───────────────┼───────────┼───────┤
│Eternal Flame  │¿          │1000000│
│Madame Uppercut│¿          │39     │
│Molecule Man   │¿          │29     │
└───────────────┴───────────┴───────┘
EOF

        matches_expected 'super_hero_member.table age name' \
<<-EOF
Super Heroes
┌───────┬───────────────┐
│age    │name           │
├───────┼───────────────┤
│1000000│Eternal Flame  │
│39     │Madame Uppercut│
│29     │Molecule Man   │
└───────┴───────────────┘
EOF
      end

      describe 'title'
        # from `title` defined in super_hero_member.table
        matches_expected 'super_hero_member.table' \
<<-EOF
Super Heroes
┌───────────────┬───────────────┬───────────────────────────────────────────────────────────────────────────┬───────┐
│name           │:secretIdentity│powers                                                                     │age    │
├───────────────┼───────────────┼───────────────────────────────────────────────────────────────────────────┼───────┤
│Eternal Flame  │Unknown        │Immortality, Heat Immunity, Inferno, Teleportation, Interdimensional travel│1000000│
│Madame Uppercut│Jane Wilson    │Million tonne punch, Damage resistance, Superhuman reflexes                │39     │
│Molecule Man   │Dan Jukes      │Radiation resistance, Turning tiny, Radiation blast                        │29     │
└───────────────┴───────────────┴───────────────────────────────────────────────────────────────────────────┴───────┘
EOF

        matches_expected 'title="Heroes that are super" super_hero_member.table' \
<<-EOF
Heroes that are super
┌───────────────┬───────────────┬───────────────────────────────────────────────────────────────────────────┬───────┐
│name           │:secretIdentity│powers                                                                     │age    │
├───────────────┼───────────────┼───────────────────────────────────────────────────────────────────────────┼───────┤
│Eternal Flame  │Unknown        │Immortality, Heat Immunity, Inferno, Teleportation, Interdimensional travel│1000000│
│Madame Uppercut│Jane Wilson    │Million tonne punch, Damage resistance, Superhuman reflexes                │39     │
│Molecule Man   │Dan Jukes      │Radiation resistance, Turning tiny, Radiation blast                        │29     │
└───────────────┴───────────────┴───────────────────────────────────────────────────────────────────────────┴───────┘
EOF
      end

      describe 'sort_by'
        # from `sort_by` defined in super_hero_member.table
        matches_expected 'super_hero_member.table' \
<<-EOF
Super Heroes
┌───────────────┬───────────────┬───────────────────────────────────────────────────────────────────────────┬───────┐
│name           │:secretIdentity│powers                                                                     │age    │
├───────────────┼───────────────┼───────────────────────────────────────────────────────────────────────────┼───────┤
│Eternal Flame  │Unknown        │Immortality, Heat Immunity, Inferno, Teleportation, Interdimensional travel│1000000│
│Madame Uppercut│Jane Wilson    │Million tonne punch, Damage resistance, Superhuman reflexes                │39     │
│Molecule Man   │Dan Jukes      │Radiation resistance, Turning tiny, Radiation blast                        │29     │
└───────────────┴───────────────┴───────────────────────────────────────────────────────────────────────────┴───────┘
EOF

        matches_expected 'sort_by="age" super_hero_member.table' \
<<-EOF
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
          matches_expected 'super_hero_member_sort_by="gender age" super_hero_member.table' \
<<-EOF
Super Heroes
┌───────────────┬───────────────┬───────────────────────────────────────────────────────────────────────────┬───────┐
│name           │:secretIdentity│powers                                                                     │age    │
├───────────────┼───────────────┼───────────────────────────────────────────────────────────────────────────┼───────┤
│Madame Uppercut│Jane Wilson    │Million tonne punch, Damage resistance, Superhuman reflexes                │39     │
│Eternal Flame  │Unknown        │Immortality, Heat Immunity, Inferno, Teleportation, Interdimensional travel│1000000│
│Molecule Man   │Dan Jukes      │Radiation resistance, Turning tiny, Radiation blast                        │29     │
└───────────────┴───────────────┴───────────────────────────────────────────────────────────────────────────┴───────┘
EOF
        end
      end
    end

    describe 'conf files'
      input_cmd='jq --compact-output ".members[]"'

      describe 'specific conf'
        matches_expected 'conf=shpecs/support/specific.conf super_hero_member.table' \
<<-EOF
Super Specific Heroes
┌───────────────────────────────────────────────────────────────────────────┬───┬──────┐
│powers                                                                     │foo│gender│
├───────────────────────────────────────────────────────────────────────────┼───┼──────┤
│Million tonne punch, Damage resistance, Superhuman reflexes                │¿  │female│
│Immortality, Heat Immunity, Inferno, Teleportation, Interdimensional travel│¿  │female│
│Radiation resistance, Turning tiny, Radiation blast                        │¿  │male  │
└───────────────────────────────────────────────────────────────────────────┴───┴──────┘
EOF

        matches_expected 'conf=shpecs/support/specific-add.conf super_hero_member.table' \
<<-EOF
Super Heroes
┌───────────────┬───────────────┬───────────────────────────────────────────────────────────────────────────┬───────┬───┬──────┐
│name           │:secretIdentity│powers                                                                     │age    │foo│gender│
├───────────────┼───────────────┼───────────────────────────────────────────────────────────────────────────┼───────┼───┼──────┤
│Eternal Flame  │Unknown        │Immortality, Heat Immunity, Inferno, Teleportation, Interdimensional travel│1000000│¿  │female│
│Madame Uppercut│Jane Wilson    │Million tonne punch, Damage resistance, Superhuman reflexes                │39     │¿  │female│
│Molecule Man   │Dan Jukes      │Radiation resistance, Turning tiny, Radiation blast                        │29     │¿  │male  │
└───────────────┴───────────────┴───────────────────────────────────────────────────────────────────────────┴───────┴───┴──────┘
EOF

        describe 'from ~/.json2table/${resource}.conf'
          HOME=shpecs/support matches_expected 'conf=~ super_hero_member.table' \
<<-EOF
Super Heroes
┌───────────────┬───────────────┬───────────────────────────────────────────────────────────────────────────┬───────┬───┬──────┐
│name           │:secretIdentity│powers                                                                     │age    │bar│gender│
├───────────────┼───────────────┼───────────────────────────────────────────────────────────────────────────┼───────┼───┼──────┤
│Madame Uppercut│Jane Wilson    │Million tonne punch, Damage resistance, Superhuman reflexes                │39     │¿  │female│
│Eternal Flame  │Unknown        │Immortality, Heat Immunity, Inferno, Teleportation, Interdimensional travel│1000000│¿  │female│
│Molecule Man   │Dan Jukes      │Radiation resistance, Turning tiny, Radiation blast                        │29     │¿  │male  │
└───────────────┴───────────────┴───────────────────────────────────────────────────────────────────────────┴───────┴───┴──────┘
EOF
        end
      end

      describe 'shared conf'
        matches_expected 'conf=shpecs/support/shared.conf super_hero_member.table' \
<<-EOF
Super Heroes
┌───────────────────────────────────────────────────────────────────────────┬───┬──────┐
│powers                                                                     │bar│gender│
├───────────────────────────────────────────────────────────────────────────┼───┼──────┤
│Million tonne punch, Damage resistance, Superhuman reflexes                │¿  │female│
│Immortality, Heat Immunity, Inferno, Teleportation, Interdimensional travel│¿  │female│
│Radiation resistance, Turning tiny, Radiation blast                        │¿  │male  │
└───────────────────────────────────────────────────────────────────────────┴───┴──────┘
EOF

        matches_expected 'conf=shpecs/support/shared-add.conf super_hero_member.table' \
<<-EOF
Super Shared Heroes
┌───────────────┬───────────────┬───────────────────────────────────────────────────────────────────────────┬───────┬───┬──────┐
│name           │:secretIdentity│powers                                                                     │age    │bar│gender│
├───────────────┼───────────────┼───────────────────────────────────────────────────────────────────────────┼───────┼───┼──────┤
│Madame Uppercut│Jane Wilson    │Million tonne punch, Damage resistance, Superhuman reflexes                │39     │¿  │female│
│Eternal Flame  │Unknown        │Immortality, Heat Immunity, Inferno, Teleportation, Interdimensional travel│1000000│¿  │female│
│Molecule Man   │Dan Jukes      │Radiation resistance, Turning tiny, Radiation blast                        │29     │¿  │male  │
└───────────────┴───────────────┴───────────────────────────────────────────────────────────────────────────┴───────┴───┴──────┘
EOF
      end
    end

    describe 'color_terms'
      input_cmd='jq --compact-output ".members[]"'

      matches_expected_with_colors 'color_terms="$(cat shpecs/support/color_terms-full.txt)" super_hero_member.table' \
<<-EOF
[1mSuper Heroes[0m
┌───────────────┬───────────────┬───────────────────────────────────────────────────────────────────────────┬───────┐
│[1mname           [0m│[1m:secretIdentity[0m│[1mpowers                                                                     [0m│[1mage    [0m│
├───────────────┼───────────────┼───────────────────────────────────────────────────────────────────────────┼───────┤
│Eternal Flame  │Unknown        │Immortality, Heat Immunity, Inferno, Teleportation, Interdimensional travel│1000000│
│Madame Uppercut│[1;36m[KJane Wilson[m[K    │Million tonne punch, Damage resistance, Superhuman reflexes                │39     │
│Molecule Man   │Dan Jukes      │Radiation resistance, [1;35m[KTurning tiny[m[K, Radiation [1;34m[Kblast[m[K                        │29     │
└───────────────┴───────────────┴───────────────────────────────────────────────────────────────────────────┴───────┘
EOF

      matches_expected_with_colors 'color_terms="$(cat shpecs/support/color_terms-partial.txt)" super_hero_member.table' \
<<-EOF
[1mSuper Heroes[0m
┌───────────────┬───────────────┬───────────────────────────────────────────────────────────────────────────┬───────┐
│[1mname           [0m│[1m:secretIdentity[0m│[1mpowers                                                                     [0m│[1mage    [0m│
├───────────────┼───────────────┼───────────────────────────────────────────────────────────────────────────┼───────┤
│Eternal Flame  │Unknown        │Immortality, Heat Immunity, Inferno, Teleportation, Interdimensional travel│1000000│
│Madame Uppercut│[1;36m[KJane Wilson[m[K    │Million tonne punch, Damage resistance, Superhuman reflexes                │39     │
│Molecule Man   │Dan Jukes      │Radiation resistance, Turning tiny, Radiation [1;34m[Kblast[m[K                        │29     │
└───────────────┴───────────────┴───────────────────────────────────────────────────────────────────────────┴───────┘
EOF

      matches_expected_with_colors 'super_hero_member_color_terms="$(cat shpecs/support/color_terms-full.txt)" super_hero_member.table' \
<<-EOF
[1mSuper Heroes[0m
┌───────────────┬───────────────┬───────────────────────────────────────────────────────────────────────────┬───────┐
│[1mname           [0m│[1m:secretIdentity[0m│[1mpowers                                                                     [0m│[1mage    [0m│
├───────────────┼───────────────┼───────────────────────────────────────────────────────────────────────────┼───────┤
│Eternal Flame  │Unknown        │Immortality, Heat Immunity, Inferno, Teleportation, Interdimensional travel│1000000│
│Madame Uppercut│[1;36m[KJane Wilson[m[K    │Million tonne punch, Damage resistance, Superhuman reflexes                │39     │
│Molecule Man   │Dan Jukes      │Radiation resistance, [1;35m[KTurning tiny[m[K, Radiation [1;34m[Kblast[m[K                        │29     │
└───────────────┴───────────────┴───────────────────────────────────────────────────────────────────────────┴───────┘
EOF

      matches_expected_with_colors 'super_hero_member_color_terms="$(cat shpecs/support/color_terms-partial.txt)" super_hero_member.table' \
<<-EOF
[1mSuper Heroes[0m
┌───────────────┬───────────────┬───────────────────────────────────────────────────────────────────────────┬───────┐
│[1mname           [0m│[1m:secretIdentity[0m│[1mpowers                                                                     [0m│[1mage    [0m│
├───────────────┼───────────────┼───────────────────────────────────────────────────────────────────────────┼───────┤
│Eternal Flame  │Unknown        │Immortality, Heat Immunity, Inferno, Teleportation, Interdimensional travel│1000000│
│Madame Uppercut│[1;36m[KJane Wilson[m[K    │Million tonne punch, Damage resistance, Superhuman reflexes                │39     │
│Molecule Man   │Dan Jukes      │Radiation resistance, Turning tiny, Radiation [1;34m[Kblast[m[K                        │29     │
└───────────────┴───────────────┴───────────────────────────────────────────────────────────────────────────┴───────┘
EOF

      matches_expected_with_colors 'conf=shpecs/support/specific.conf super_hero_member.table' \
<<-EOF
[1mSuper Specific Heroes[0m
┌───────────────────────────────────────────────────────────────────────────┬───┬──────┐
│[1mpowers                                                                     [0m│[1mfoo[0m│[1mgender[0m│
├───────────────────────────────────────────────────────────────────────────┼───┼──────┤
│Million tonne punch, [1;34m[KDamage resistance[m[K, [1;35m[KSuperhuman[m[K reflexes                │[1;41m[K¿[m[K  │female│
│Immortality, [1;41m[KHeat[m[K [1;42m[KImmunity[m[K, Inferno, Teleportation, Interdimensional travel│[1;41m[K¿[m[K  │female│
│Radiation resistance, Turning tiny, Radiation blast                        │[1;41m[K¿[m[K  │male  │
└───────────────────────────────────────────────────────────────────────────┴───┴──────┘
EOF

      matches_expected_with_colors 'conf=shpecs/support/shared.conf super_hero_member.table' \
<<-EOF
[1mSuper Heroes[0m
┌───────────────────────────────────────────────────────────────────────────┬───┬──────┐
│[1mpowers                                                                     [0m│[1mbar[0m│[1mgender[0m│
├───────────────────────────────────────────────────────────────────────────┼───┼──────┤
│Million tonne punch, [1;42m[KDamage resistance[m[K, [1;36m[KSuperhuman[m[K reflexes                │[1;41m[K¿[m[K  │female│
│Immortality, [1;34m[KHeat[m[K [1;35m[KImmunity[m[K, Inferno, Teleportation, Interdimensional travel│[1;41m[K¿[m[K  │female│
│Radiation resistance, Turning tiny, Radiation blast                        │[1;41m[K¿[m[K  │male  │
└───────────────────────────────────────────────────────────────────────────┴───┴──────┘
EOF
    end

    describe 'color_terms_add'
      input_cmd='jq --compact-output ".members[]"'

      matches_expected_with_colors 'conf=shpecs/support/specific-add.conf super_hero_member.table' \
<<-EOF
[1mSuper Heroes[0m
┌───────────────┬───────────────┬───────────────────────────────────────────────────────────────────────────┬───────┬───┬──────┐
│[1mname           [0m│[1m:secretIdentity[0m│[1mpowers                                                                     [0m│[1mage    [0m│[1mfoo[0m│[1mgender[0m│
├───────────────┼───────────────┼───────────────────────────────────────────────────────────────────────────┼───────┼───┼──────┤
│[1;34m[KEternal[m[K Flame  │Unknown        │Immortality, Heat Immunity, Inferno, Teleportation, [1;45m[KInterdimensional travel[m[K│1000000│[1;41m[K¿[m[K  │[1;44m[Kfemale[m[K│
│[1;36m[KMadame[m[K [1;41m[KUppercut[m[K│Jane Wilson    │Million tonne punch, Damage resistance, Superhuman reflexes                │39     │[1;41m[K¿[m[K  │[1;44m[Kfemale[m[K│
│Molecule [1;43m[KMan[m[K   │[1;42m[KDan Jukes[m[K      │Radiation resistance, Turning tiny, Radiation blast                        │29     │[1;41m[K¿[m[K  │[1;43m[Kmale[m[K  │
└───────────────┴───────────────┴───────────────────────────────────────────────────────────────────────────┴───────┴───┴──────┘
EOF

      matches_expected_with_colors 'conf=shpecs/support/shared-add.conf super_hero_member.table' \
<<-EOF
[1mSuper Shared Heroes[0m
┌───────────────┬───────────────┬───────────────────────────────────────────────────────────────────────────┬───────┬───┬──────┐
│[1mname           [0m│[1m:secretIdentity[0m│[1mpowers                                                                     [0m│[1mage    [0m│[1mbar[0m│[1mgender[0m│
├───────────────┼───────────────┼───────────────────────────────────────────────────────────────────────────┼───────┼───┼──────┤
│[1;36m[KMadame[m[K [1;41m[KUppercut[m[K│Jane Wilson    │Million tonne punch, Damage resistance, Superhuman reflexes                │39     │[1;41m[K¿[m[K  │[1;43m[Kfemale[m[K│
│[1;34m[KEternal[m[K Flame  │Unknown        │Immortality, Heat Immunity, Inferno, Teleportation, [1;45m[KInterdimensional travel[m[K│1000000│[1;41m[K¿[m[K  │[1;43m[Kfemale[m[K│
│Molecule [1;44m[KMan[m[K   │[1;42m[KDan Jukes[m[K      │Radiation resistance, Turning tiny, Radiation blast                        │29     │[1;41m[K¿[m[K  │[1;44m[Kmale[m[K  │
└───────────────┴───────────────┴───────────────────────────────────────────────────────────────────────────┴───────┴───┴──────┘
EOF

      matches_expected_with_colors 'color_terms_add="$(cat shpecs/support/color_terms-full.txt)" super_hero_member.table' \
<<-EOF
[1mSuper Heroes[0m
┌───────────────┬───────────────┬───────────────────────────────────────────────────────────────────────────┬───────┐
│[1mname           [0m│[1m:secretIdentity[0m│[1mpowers                                                                     [0m│[1mage    [0m│
├───────────────┼───────────────┼───────────────────────────────────────────────────────────────────────────┼───────┤
│[1;34m[KEternal[m[K Flame  │Unknown        │Immortality, Heat Immunity, Inferno, Teleportation, Interdimensional travel│1000000│
│[1;36m[KMadame[m[K [1;41m[KUppercut[m[K│[1;45m[KJane Wilson[m[K    │Million tonne punch, Damage resistance, Superhuman reflexes                │39     │
│Molecule Man   │[1;42m[KDan Jukes[m[K      │Radiation resistance, [1;44m[KTurning tiny[m[K, Radiation [1;43m[Kblast[m[K                        │29     │
└───────────────┴───────────────┴───────────────────────────────────────────────────────────────────────────┴───────┘
EOF

      matches_expected_with_colors 'color_terms_add="$(cat shpecs/support/color_terms-partial.txt)" super_hero_member.table' \
<<-EOF
[1mSuper Heroes[0m
┌───────────────┬───────────────┬───────────────────────────────────────────────────────────────────────────┬───────┐
│[1mname           [0m│[1m:secretIdentity[0m│[1mpowers                                                                     [0m│[1mage    [0m│
├───────────────┼───────────────┼───────────────────────────────────────────────────────────────────────────┼───────┤
│[1;34m[KEternal[m[K Flame  │Unknown        │Immortality, Heat Immunity, Inferno, Teleportation, Interdimensional travel│1000000│
│[1;36m[KMadame[m[K [1;41m[KUppercut[m[K│[1;45m[KJane Wilson[m[K    │Million tonne punch, Damage resistance, Superhuman reflexes                │39     │
│Molecule Man   │[1;42m[KDan Jukes[m[K      │Radiation resistance, Turning tiny, Radiation [1;43m[Kblast[m[K                        │29     │
└───────────────┴───────────────┴───────────────────────────────────────────────────────────────────────────┴───────┘
EOF

      matches_expected_with_colors 'super_hero_member_color_terms_add="$(cat shpecs/support/color_terms-full.txt)" super_hero_member.table' \
<<-EOF
[1mSuper Heroes[0m
┌───────────────┬───────────────┬───────────────────────────────────────────────────────────────────────────┬───────┐
│[1mname           [0m│[1m:secretIdentity[0m│[1mpowers                                                                     [0m│[1mage    [0m│
├───────────────┼───────────────┼───────────────────────────────────────────────────────────────────────────┼───────┤
│[1;34m[KEternal[m[K Flame  │Unknown        │Immortality, Heat Immunity, Inferno, Teleportation, Interdimensional travel│1000000│
│[1;36m[KMadame[m[K [1;41m[KUppercut[m[K│[1;45m[KJane Wilson[m[K    │Million tonne punch, Damage resistance, Superhuman reflexes                │39     │
│Molecule Man   │[1;42m[KDan Jukes[m[K      │Radiation resistance, [1;44m[KTurning tiny[m[K, Radiation [1;43m[Kblast[m[K                        │29     │
└───────────────┴───────────────┴───────────────────────────────────────────────────────────────────────────┴───────┘
EOF

      matches_expected_with_colors 'super_hero_member_color_terms_add="$(cat shpecs/support/color_terms-partial.txt)" super_hero_member.table' \
<<-EOF
[1mSuper Heroes[0m
┌───────────────┬───────────────┬───────────────────────────────────────────────────────────────────────────┬───────┐
│[1mname           [0m│[1m:secretIdentity[0m│[1mpowers                                                                     [0m│[1mage    [0m│
├───────────────┼───────────────┼───────────────────────────────────────────────────────────────────────────┼───────┤
│[1;34m[KEternal[m[K Flame  │Unknown        │Immortality, Heat Immunity, Inferno, Teleportation, Interdimensional travel│1000000│
│[1;36m[KMadame[m[K [1;41m[KUppercut[m[K│[1;45m[KJane Wilson[m[K    │Million tonne punch, Damage resistance, Superhuman reflexes                │39     │
│Molecule Man   │[1;42m[KDan Jukes[m[K      │Radiation resistance, Turning tiny, Radiation [1;43m[Kblast[m[K                        │29     │
└───────────────┴───────────────┴───────────────────────────────────────────────────────────────────────────┴───────┘
EOF
    end
  end

  # there should be no difference between .json & .jsonl, so let's only bother doing one test...
  describe 'processing `.json` files'
    input_cmd='jq --compact-output ".members"'

    describe 'cols'
      describe 'all'
        matches_expected 'json2table' \
<<-EOF
┌───────┬──────┬───────────────┬───────────────────────────────────────────────────────────────────────────────────┬───────────────┐
│age    │gender│name           │powers                                                                             │secret.identity│
├───────┼──────┼───────────────┼───────────────────────────────────────────────────────────────────────────────────┼───────────────┤
│29     │male  │Molecule Man   │["Radiation resistance","Turning tiny","Radiation blast"]                          │Dan Jukes      │
│39     │female│Madame Uppercut│["Million tonne punch","Damage resistance","Superhuman reflexes"]                  │Jane Wilson    │
│1000000│female│Eternal Flame  │["Immortality","Heat Immunity","Inferno","Teleportation","Interdimensional travel"]│Unknown        │
└───────┴──────┴───────────────┴───────────────────────────────────────────────────────────────────────────────────┴───────────────┘
EOF
      end
    end
  end

end
