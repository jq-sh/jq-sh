def color(terms):
  [
    range(31;37),
    range(41;47),
    range(91;98),
    range(100;103),
    range(104;107)
  ] as $colors |

  (
    terms                    |
    [_nwise($colors|length)] |
    transpose                |
    map("(?<m>(\(map(values)|join("|"))))")
  ) as $patterns |

  reduce range($patterns|length) as $i (.;
    gsub($patterns[$i]; "[1;\($colors[$i])m\(.m)[0m")
  )
;
