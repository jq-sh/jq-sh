#!/usr/bin/env shpec
# shellcheck disable=SC1091
source shpecs/shpec_helper.sh

describe "tsv2table"
  input_file() { echo 'shpecs/support/data.tsv'; }
  input_cmd() { cat; }

  matches_expected 'tsv2table' <<-EOF
┌─────┬───────────┬─────────────┐
│th1  │th2        │tableheading3│
├─────┼───────────┼─────────────┤
│tr1.1│           │tr1.3        │
│tr2.1│tablerow2.2│tablerow2.3  │
│     │           │             │
│     │           │tr4.3        │
└─────┴───────────┴─────────────┘
EOF

  describe "with \$title"
    matches_expected 'title=title1 tsv2table' <<-EOF
title1
┌─────┬───────────┬─────────────┐
│th1  │th2        │tableheading3│
├─────┼───────────┼─────────────┤
│tr1.1│           │tr1.3        │
│tr2.1│tablerow2.2│tablerow2.3  │
│     │           │             │
│     │           │tr4.3        │
└─────┴───────────┴─────────────┘
EOF
  end_

  describe "with \$max_width"
    matches_expected 'max_width=30 tsv2table' <<-EOF
┌─────┬─────────┬─────────────┐
│th1  │th2      │tableheading3│
├─────┼─────────┼─────────────┤
│tr1.1│         │tr1.3        │
│tr2.1│tabl....2│tablerow2.3  │
│     │         │             │
│     │         │tr4.3        │
└─────┴─────────┴─────────────┘
EOF
  end_

  describe 'with truncations'
    matches_expected 'tsv2table null 7 null' <<-EOF
┌─────┬───────┬─────────────┐
│th1  │th2    │tableheading3│
├─────┼───────┼─────────────┤
│tr1.1│       │tr1.3        │
│tr2.1│ta....2│tablerow2.3  │
│     │       │             │
│     │       │tr4.3        │
└─────┴───────┴─────────────┘
EOF
  end_
end_
