#!/usr/bin/env shpec
source shpecs/shpec_helper.sh


describe "json2table"
  input_file='shpecs/support/super_heroes.json'

  describe 'processing `.json` files'
    input_cmd='jq --compact-output ".members"'

    describe 'cols'
      matches_expected 'cols="name secretIdentity:secret_identity" json2table' \
<<-EOF
┌───────────────┬────────────────┐
│name           │:secret_identity│
├───────────────┼────────────────┤
│Molecule Man   │Dan Jukes       │
│Madame Uppercut│Jane Wilson     │
│Eternal Flame  │Unknown         │
└───────────────┴────────────────┘
EOF
    end
  end

  describe 'processing `.jsonl` files'
    input_cmd='jq --compact-output ".members[]"'

    describe 'cols'
      matches_expected 'cols="name secretIdentity:secret_identity" json2table' \
<<-EOF
┌───────────────┬────────────────┐
│name           │:secret_identity│
├───────────────┼────────────────┤
│Molecule Man   │Dan Jukes       │
│Madame Uppercut│Jane Wilson     │
│Eternal Flame  │Unknown         │
└───────────────┴────────────────┘
EOF

      matches_expected 'json2table age name' \
<<-EOF
┌───────┬───────────────┐
│age    │name           │
├───────┼───────────────┤
│29     │Molecule Man   │
│39     │Madame Uppercut│
│1000000│Eternal Flame  │
└───────┴───────────────┘
EOF

      matches_expected 'json2table' \
<<-EOF
┌───────┬──────┬───────────────┬───────────────────────────────────────────────────────────────────────────────────┬──────────────┐
│age    │gender│name           │powers                                                                             │secretIdentity│
├───────┼──────┼───────────────┼───────────────────────────────────────────────────────────────────────────────────┼──────────────┤
│29     │male  │Molecule Man   │["Radiation resistance","Turning tiny","Radiation blast"]                          │Dan Jukes     │
│39     │female│Madame Uppercut│["Million tonne punch","Damage resistance","Superhuman reflexes"]                  │Jane Wilson   │
│1000000│female│Eternal Flame  │["Immortality","Heat Immunity","Inferno","Teleportation","Interdimensional travel"]│Unknown       │
└───────┴──────┴───────────────┴───────────────────────────────────────────────────────────────────────────────────┴──────────────┘
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

    describe 'json2table with `resource` key'
      input_cmd='cat'

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

    describe 'json2table with `resources` key'
      input_cmd='cat'

      matches_expected 'resource=member json2table name secretIdentity:secret_identity' \
<<-EOF
┌───────────────┬────────────────┐
│name           │:secret_identity│
├───────────────┼────────────────┤
│Molecule Man   │Dan Jukes       │
│Madame Uppercut│Jane Wilson     │
│Eternal Flame  │Unknown         │
└───────────────┴────────────────┘
EOF

      matches_expected 'resource=member json2table' \
<<-EOF
┌───────┬──────┬───────────────┬───────────────────────────────────────────────────────────────────────────────────┬──────────────┐
│age    │gender│name           │powers                                                                             │secretIdentity│
├───────┼──────┼───────────────┼───────────────────────────────────────────────────────────────────────────────────┼──────────────┤
│29     │male  │Molecule Man   │["Radiation resistance","Turning tiny","Radiation blast"]                          │Dan Jukes     │
│39     │female│Madame Uppercut│["Million tonne punch","Damage resistance","Superhuman reflexes"]                  │Jane Wilson   │
│1000000│female│Eternal Flame  │["Immortality","Heat Immunity","Inferno","Teleportation","Interdimensional travel"]│Unknown       │
└───────┴──────┴───────────────┴───────────────────────────────────────────────────────────────────────────────────┴──────────────┘
EOF
    end

    describe 'symlink: member.table -> json2table'
      input_cmd='cat'

      matches_expected 'member.table' \
<<-EOF
┌───────┬──────┬───────────────┬───────────────────────────────────────────────────────────────────────────────────┬──────────────┐
│age    │gender│name           │powers                                                                             │secretIdentity│
├───────┼──────┼───────────────┼───────────────────────────────────────────────────────────────────────────────────┼──────────────┤
│29     │male  │Molecule Man   │["Radiation resistance","Turning tiny","Radiation blast"]                          │Dan Jukes     │
│39     │female│Madame Uppercut│["Million tonne punch","Damage resistance","Superhuman reflexes"]                  │Jane Wilson   │
│1000000│female│Eternal Flame  │["Immortality","Heat Immunity","Inferno","Teleportation","Interdimensional travel"]│Unknown       │
└───────┴──────┴───────────────┴───────────────────────────────────────────────────────────────────────────────────┴──────────────┘
EOF

      matches_expected 'member.table name secretIdentity:secret_identity' \
<<-EOF
┌───────────────┬────────────────┐
│name           │:secret_identity│
├───────────────┼────────────────┤
│Molecule Man   │Dan Jukes       │
│Madame Uppercut│Jane Wilson     │
│Eternal Flame  │Unknown         │
└───────────────┴────────────────┘
EOF
    end

    describe 'script: super_hero_members.table'
      input_cmd='jq --compact-output ".members[]"'

      describe 'cols'
        # from `cols` defined in super_hero_member.table
        matches_expected 'super_hero_member.table' \
<<-EOF
Super Heroes
┌───────────────┬────────────────┬───────────────────────────────────────────────────────────────────────────┬───────┐
│name           │:secret_identity│powers                                                                     │age    │
├───────────────┼────────────────┼───────────────────────────────────────────────────────────────────────────┼───────┤
│Eternal Flame  │Unknown         │Immortality, Heat Immunity, Inferno, Teleportation, Interdimensional travel│1000000│
│Madame Uppercut│Jane Wilson     │Million tonne punch, Damage resistance, Superhuman reflexes                │39     │
│Molecule Man   │Dan Jukes       │Radiation resistance, Turning tiny, Radiation blast                        │29     │
└───────────────┴────────────────┴───────────────────────────────────────────────────────────────────────────┴───────┘
EOF

        matches_expected 'cols="name secretIdentity:secret_identity" super_hero_member.table' \
<<-EOF
Super Heroes
┌───────────────┬────────────────┐
│name           │:secret_identity│
├───────────────┼────────────────┤
│Eternal Flame  │Unknown         │
│Madame Uppercut│Jane Wilson     │
│Molecule Man   │Dan Jukes       │
└───────────────┴────────────────┘
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
┌───────────────┬────────────────┬───────────────────────────────────────────────────────────────────────────┬───────┐
│name           │:secret_identity│powers                                                                     │age    │
├───────────────┼────────────────┼───────────────────────────────────────────────────────────────────────────┼───────┤
│Eternal Flame  │Unknown         │Immortality, Heat Immunity, Inferno, Teleportation, Interdimensional travel│1000000│
│Madame Uppercut│Jane Wilson     │Million tonne punch, Damage resistance, Superhuman reflexes                │39     │
│Molecule Man   │Dan Jukes       │Radiation resistance, Turning tiny, Radiation blast                        │29     │
└───────────────┴────────────────┴───────────────────────────────────────────────────────────────────────────┴───────┘
EOF

        matches_expected 'title="Heroes that are super" super_hero_member.table' \
<<-EOF
Heroes that are super
┌───────────────┬────────────────┬───────────────────────────────────────────────────────────────────────────┬───────┐
│name           │:secret_identity│powers                                                                     │age    │
├───────────────┼────────────────┼───────────────────────────────────────────────────────────────────────────┼───────┤
│Eternal Flame  │Unknown         │Immortality, Heat Immunity, Inferno, Teleportation, Interdimensional travel│1000000│
│Madame Uppercut│Jane Wilson     │Million tonne punch, Damage resistance, Superhuman reflexes                │39     │
│Molecule Man   │Dan Jukes       │Radiation resistance, Turning tiny, Radiation blast                        │29     │
└───────────────┴────────────────┴───────────────────────────────────────────────────────────────────────────┴───────┘
EOF
      end

      describe 'sort_by'
        # from `sort_by` defined in super_hero_member.table
        matches_expected 'super_hero_member.table' \
<<-EOF
Super Heroes
┌───────────────┬────────────────┬───────────────────────────────────────────────────────────────────────────┬───────┐
│name           │:secret_identity│powers                                                                     │age    │
├───────────────┼────────────────┼───────────────────────────────────────────────────────────────────────────┼───────┤
│Eternal Flame  │Unknown         │Immortality, Heat Immunity, Inferno, Teleportation, Interdimensional travel│1000000│
│Madame Uppercut│Jane Wilson     │Million tonne punch, Damage resistance, Superhuman reflexes                │39     │
│Molecule Man   │Dan Jukes       │Radiation resistance, Turning tiny, Radiation blast                        │29     │
└───────────────┴────────────────┴───────────────────────────────────────────────────────────────────────────┴───────┘
EOF

        matches_expected 'sort_by="age" super_hero_member.table' \
<<-EOF
Super Heroes
┌───────────────┬────────────────┬───────────────────────────────────────────────────────────────────────────┬───────┐
│name           │:secret_identity│powers                                                                     │age    │
├───────────────┼────────────────┼───────────────────────────────────────────────────────────────────────────┼───────┤
│Molecule Man   │Dan Jukes       │Radiation resistance, Turning tiny, Radiation blast                        │29     │
│Madame Uppercut│Jane Wilson     │Million tonne punch, Damage resistance, Superhuman reflexes                │39     │
│Eternal Flame  │Unknown         │Immortality, Heat Immunity, Inferno, Teleportation, Interdimensional travel│1000000│
└───────────────┴────────────────┴───────────────────────────────────────────────────────────────────────────┴───────┘
EOF

        describe '(sorting by gender even though its not in the `cols` list)'
          matches_expected 'super_hero_member_sort_by="gender age" super_hero_member.table' \
<<-EOF
Super Heroes
┌───────────────┬────────────────┬───────────────────────────────────────────────────────────────────────────┬───────┐
│name           │:secret_identity│powers                                                                     │age    │
├───────────────┼────────────────┼───────────────────────────────────────────────────────────────────────────┼───────┤
│Madame Uppercut│Jane Wilson     │Million tonne punch, Damage resistance, Superhuman reflexes                │39     │
│Eternal Flame  │Unknown         │Immortality, Heat Immunity, Inferno, Teleportation, Interdimensional travel│1000000│
│Molecule Man   │Dan Jukes       │Radiation resistance, Turning tiny, Radiation blast                        │29     │
└───────────────┴────────────────┴───────────────────────────────────────────────────────────────────────────┴───────┘
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
┌───────────────┬────────────────┬───────────────────────────────────────────────────────────────────────────┬───────┬───┬──────┐
│name           │:secret_identity│powers                                                                     │age    │foo│gender│
├───────────────┼────────────────┼───────────────────────────────────────────────────────────────────────────┼───────┼───┼──────┤
│Eternal Flame  │Unknown         │Immortality, Heat Immunity, Inferno, Teleportation, Interdimensional travel│1000000│¿  │female│
│Madame Uppercut│Jane Wilson     │Million tonne punch, Damage resistance, Superhuman reflexes                │39     │¿  │female│
│Molecule Man   │Dan Jukes       │Radiation resistance, Turning tiny, Radiation blast                        │29     │¿  │male  │
└───────────────┴────────────────┴───────────────────────────────────────────────────────────────────────────┴───────┴───┴──────┘
EOF

        describe 'from ~/.json2table/${resource}.conf'
          HOME=shpecs/support matches_expected 'conf=~ super_hero_member.table' \
<<-EOF
Super Heroes
┌───────────────┬────────────────┬───────────────────────────────────────────────────────────────────────────┬───────┬───┬──────┐
│name           │:secret_identity│powers                                                                     │age    │bar│gender│
├───────────────┼────────────────┼───────────────────────────────────────────────────────────────────────────┼───────┼───┼──────┤
│Madame Uppercut│Jane Wilson     │Million tonne punch, Damage resistance, Superhuman reflexes                │39     │¿  │female│
│Eternal Flame  │Unknown         │Immortality, Heat Immunity, Inferno, Teleportation, Interdimensional travel│1000000│¿  │female│
│Molecule Man   │Dan Jukes       │Radiation resistance, Turning tiny, Radiation blast                        │29     │¿  │male  │
└───────────────┴────────────────┴───────────────────────────────────────────────────────────────────────────┴───────┴───┴──────┘
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
┌───────────────┬────────────────┬───────────────────────────────────────────────────────────────────────────┬───────┬───┬──────┐
│name           │:secret_identity│powers                                                                     │age    │bar│gender│
├───────────────┼────────────────┼───────────────────────────────────────────────────────────────────────────┼───────┼───┼──────┤
│Madame Uppercut│Jane Wilson     │Million tonne punch, Damage resistance, Superhuman reflexes                │39     │¿  │female│
│Eternal Flame  │Unknown         │Immortality, Heat Immunity, Inferno, Teleportation, Interdimensional travel│1000000│¿  │female│
│Molecule Man   │Dan Jukes       │Radiation resistance, Turning tiny, Radiation blast                        │29     │¿  │male  │
└───────────────┴────────────────┴───────────────────────────────────────────────────────────────────────────┴───────┴───┴──────┘
EOF
      end
    end

    describe 'color_terms'
      input_cmd='jq --compact-output ".members[]"'

      matches_expected_with_colors 'color_terms="$(cat shpecs/support/color_terms-full.txt)" super_hero_member.table' \
<<-EOF
[1mSuper Heroes[0m
┌───────────────┬────────────────┬───────────────────────────────────────────────────────────────────────────┬───────┐
│[1mname           [0m│[1m:secret_identity[0m│[1mpowers                                                                     [0m│[1mage    [0m│
├───────────────┼────────────────┼───────────────────────────────────────────────────────────────────────────┼───────┤
│Eternal Flame  │Unknown         │Immortality, Heat Immunity, Inferno, Teleportation, Interdimensional travel│1000000│
│Madame Uppercut│[1;36m[KJane Wilson[m[K     │Million tonne punch, Damage resistance, Superhuman reflexes                │39     │
│Molecule Man   │Dan Jukes       │Radiation resistance, [1;35m[KTurning tiny[m[K, Radiation [1;34m[Kblast[m[K                        │29     │
└───────────────┴────────────────┴───────────────────────────────────────────────────────────────────────────┴───────┘
EOF

      matches_expected_with_colors 'color_terms="$(cat shpecs/support/color_terms-partial.txt)" super_hero_member.table' \
<<-EOF
[1mSuper Heroes[0m
┌───────────────┬────────────────┬───────────────────────────────────────────────────────────────────────────┬───────┐
│[1mname           [0m│[1m:secret_identity[0m│[1mpowers                                                                     [0m│[1mage    [0m│
├───────────────┼────────────────┼───────────────────────────────────────────────────────────────────────────┼───────┤
│Eternal Flame  │Unknown         │Immortality, Heat Immunity, Inferno, Teleportation, Interdimensional travel│1000000│
│Madame Uppercut│[1;36m[KJane Wilson[m[K     │Million tonne punch, Damage resistance, Superhuman reflexes                │39     │
│Molecule Man   │Dan Jukes       │Radiation resistance, Turning tiny, Radiation [1;34m[Kblast[m[K                        │29     │
└───────────────┴────────────────┴───────────────────────────────────────────────────────────────────────────┴───────┘
EOF

      matches_expected_with_colors 'super_hero_member_color_terms="$(cat shpecs/support/color_terms-full.txt)" super_hero_member.table' \
<<-EOF
[1mSuper Heroes[0m
┌───────────────┬────────────────┬───────────────────────────────────────────────────────────────────────────┬───────┐
│[1mname           [0m│[1m:secret_identity[0m│[1mpowers                                                                     [0m│[1mage    [0m│
├───────────────┼────────────────┼───────────────────────────────────────────────────────────────────────────┼───────┤
│Eternal Flame  │Unknown         │Immortality, Heat Immunity, Inferno, Teleportation, Interdimensional travel│1000000│
│Madame Uppercut│[1;36m[KJane Wilson[m[K     │Million tonne punch, Damage resistance, Superhuman reflexes                │39     │
│Molecule Man   │Dan Jukes       │Radiation resistance, [1;35m[KTurning tiny[m[K, Radiation [1;34m[Kblast[m[K                        │29     │
└───────────────┴────────────────┴───────────────────────────────────────────────────────────────────────────┴───────┘
EOF

      matches_expected_with_colors 'super_hero_member_color_terms="$(cat shpecs/support/color_terms-partial.txt)" super_hero_member.table' \
<<-EOF
[1mSuper Heroes[0m
┌───────────────┬────────────────┬───────────────────────────────────────────────────────────────────────────┬───────┐
│[1mname           [0m│[1m:secret_identity[0m│[1mpowers                                                                     [0m│[1mage    [0m│
├───────────────┼────────────────┼───────────────────────────────────────────────────────────────────────────┼───────┤
│Eternal Flame  │Unknown         │Immortality, Heat Immunity, Inferno, Teleportation, Interdimensional travel│1000000│
│Madame Uppercut│[1;36m[KJane Wilson[m[K     │Million tonne punch, Damage resistance, Superhuman reflexes                │39     │
│Molecule Man   │Dan Jukes       │Radiation resistance, Turning tiny, Radiation [1;34m[Kblast[m[K                        │29     │
└───────────────┴────────────────┴───────────────────────────────────────────────────────────────────────────┴───────┘
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
┌───────────────┬────────────────┬───────────────────────────────────────────────────────────────────────────┬───────┬───┬──────┐
│[1mname           [0m│[1m:secret_identity[0m│[1mpowers                                                                     [0m│[1mage    [0m│[1mfoo[0m│[1mgender[0m│
├───────────────┼────────────────┼───────────────────────────────────────────────────────────────────────────┼───────┼───┼──────┤
│[1;34m[KEternal[m[K Flame  │Unknown         │Immortality, Heat Immunity, Inferno, Teleportation, [1;45m[KInterdimensional travel[m[K│1000000│[1;41m[K¿[m[K  │[1;44m[Kfemale[m[K│
│[1;36m[KMadame[m[K [1;41m[KUppercut[m[K│Jane Wilson     │Million tonne punch, Damage resistance, Superhuman reflexes                │39     │[1;41m[K¿[m[K  │[1;44m[Kfemale[m[K│
│Molecule [1;43m[KMan[m[K   │[1;42m[KDan Jukes[m[K       │Radiation resistance, Turning tiny, Radiation blast                        │29     │[1;41m[K¿[m[K  │[1;43m[Kmale[m[K  │
└───────────────┴────────────────┴───────────────────────────────────────────────────────────────────────────┴───────┴───┴──────┘
EOF

      matches_expected_with_colors 'conf=shpecs/support/shared-add.conf super_hero_member.table' \
<<-EOF
[1mSuper Shared Heroes[0m
┌───────────────┬────────────────┬───────────────────────────────────────────────────────────────────────────┬───────┬───┬──────┐
│[1mname           [0m│[1m:secret_identity[0m│[1mpowers                                                                     [0m│[1mage    [0m│[1mbar[0m│[1mgender[0m│
├───────────────┼────────────────┼───────────────────────────────────────────────────────────────────────────┼───────┼───┼──────┤
│[1;36m[KMadame[m[K [1;41m[KUppercut[m[K│Jane Wilson     │Million tonne punch, Damage resistance, Superhuman reflexes                │39     │[1;41m[K¿[m[K  │[1;43m[Kfemale[m[K│
│[1;34m[KEternal[m[K Flame  │Unknown         │Immortality, Heat Immunity, Inferno, Teleportation, [1;45m[KInterdimensional travel[m[K│1000000│[1;41m[K¿[m[K  │[1;43m[Kfemale[m[K│
│Molecule [1;44m[KMan[m[K   │[1;42m[KDan Jukes[m[K       │Radiation resistance, Turning tiny, Radiation blast                        │29     │[1;41m[K¿[m[K  │[1;44m[Kmale[m[K  │
└───────────────┴────────────────┴───────────────────────────────────────────────────────────────────────────┴───────┴───┴──────┘
EOF

      matches_expected_with_colors 'color_terms_add="$(cat shpecs/support/color_terms-full.txt)" super_hero_member.table' \
<<-EOF
[1mSuper Heroes[0m
┌───────────────┬────────────────┬───────────────────────────────────────────────────────────────────────────┬───────┐
│[1mname           [0m│[1m:secret_identity[0m│[1mpowers                                                                     [0m│[1mage    [0m│
├───────────────┼────────────────┼───────────────────────────────────────────────────────────────────────────┼───────┤
│[1;34m[KEternal[m[K Flame  │Unknown         │Immortality, Heat Immunity, Inferno, Teleportation, Interdimensional travel│1000000│
│[1;36m[KMadame[m[K [1;41m[KUppercut[m[K│[1;45m[KJane Wilson[m[K     │Million tonne punch, Damage resistance, Superhuman reflexes                │39     │
│Molecule Man   │[1;42m[KDan Jukes[m[K       │Radiation resistance, [1;44m[KTurning tiny[m[K, Radiation [1;43m[Kblast[m[K                        │29     │
└───────────────┴────────────────┴───────────────────────────────────────────────────────────────────────────┴───────┘
EOF

      matches_expected_with_colors 'color_terms_add="$(cat shpecs/support/color_terms-partial.txt)" super_hero_member.table' \
<<-EOF
[1mSuper Heroes[0m
┌───────────────┬────────────────┬───────────────────────────────────────────────────────────────────────────┬───────┐
│[1mname           [0m│[1m:secret_identity[0m│[1mpowers                                                                     [0m│[1mage    [0m│
├───────────────┼────────────────┼───────────────────────────────────────────────────────────────────────────┼───────┤
│[1;34m[KEternal[m[K Flame  │Unknown         │Immortality, Heat Immunity, Inferno, Teleportation, Interdimensional travel│1000000│
│[1;36m[KMadame[m[K [1;41m[KUppercut[m[K│[1;45m[KJane Wilson[m[K     │Million tonne punch, Damage resistance, Superhuman reflexes                │39     │
│Molecule Man   │[1;42m[KDan Jukes[m[K       │Radiation resistance, Turning tiny, Radiation [1;43m[Kblast[m[K                        │29     │
└───────────────┴────────────────┴───────────────────────────────────────────────────────────────────────────┴───────┘
EOF

      matches_expected_with_colors 'super_hero_member_color_terms_add="$(cat shpecs/support/color_terms-full.txt)" super_hero_member.table' \
<<-EOF
[1mSuper Heroes[0m
┌───────────────┬────────────────┬───────────────────────────────────────────────────────────────────────────┬───────┐
│[1mname           [0m│[1m:secret_identity[0m│[1mpowers                                                                     [0m│[1mage    [0m│
├───────────────┼────────────────┼───────────────────────────────────────────────────────────────────────────┼───────┤
│[1;34m[KEternal[m[K Flame  │Unknown         │Immortality, Heat Immunity, Inferno, Teleportation, Interdimensional travel│1000000│
│[1;36m[KMadame[m[K [1;41m[KUppercut[m[K│[1;45m[KJane Wilson[m[K     │Million tonne punch, Damage resistance, Superhuman reflexes                │39     │
│Molecule Man   │[1;42m[KDan Jukes[m[K       │Radiation resistance, [1;44m[KTurning tiny[m[K, Radiation [1;43m[Kblast[m[K                        │29     │
└───────────────┴────────────────┴───────────────────────────────────────────────────────────────────────────┴───────┘
EOF

      matches_expected_with_colors 'super_hero_member_color_terms_add="$(cat shpecs/support/color_terms-partial.txt)" super_hero_member.table' \
<<-EOF
[1mSuper Heroes[0m
┌───────────────┬────────────────┬───────────────────────────────────────────────────────────────────────────┬───────┐
│[1mname           [0m│[1m:secret_identity[0m│[1mpowers                                                                     [0m│[1mage    [0m│
├───────────────┼────────────────┼───────────────────────────────────────────────────────────────────────────┼───────┤
│[1;34m[KEternal[m[K Flame  │Unknown         │Immortality, Heat Immunity, Inferno, Teleportation, Interdimensional travel│1000000│
│[1;36m[KMadame[m[K [1;41m[KUppercut[m[K│[1;45m[KJane Wilson[m[K     │Million tonne punch, Damage resistance, Superhuman reflexes                │39     │
│Molecule Man   │[1;42m[KDan Jukes[m[K       │Radiation resistance, Turning tiny, Radiation [1;43m[Kblast[m[K                        │29     │
└───────────────┴────────────────┴───────────────────────────────────────────────────────────────────────────┴───────┘
EOF
    end
  end
end
