include "color";

def dig_keys:
  . as $obj |
  reduce (keys_unsorted[]) as $k ([];
    . + (
      if ($obj[$k] | type == "object") then
        $obj[$k] | dig_keys | map("\($k).\(.)")
      else
        [$k]
      end
    )
  )
;

# `haspath` implementation from  https://github.com/stedolan/jq/issues/2062
def haspath($path):
  def h:
    . as [$json, $p]
    | (($p|length)==0) or
      ($json | (has($p[0]) and ( [getpath([$p[0]]), $p[1:] ] | h)));
  [., $path] | h
;

def tocell:
  [ tostring ] |
  @tsv
;

def data_row(cols):
  [
    foreach cols[] as $col (.; .;
      if haspath($col / ".") then
        getpath($col / ".") | tocell
      else
        $missing_key
      end
    )
  ]
;

def truncate(max; end_size):
  if length > max then
    "\(.[0:(max-end_size-3)])...\(.[-end_size:])"
  else
    .
  end
;
def truncate(max): truncate(max; 2);

def sorted_cell_widths:
  map(map(length)) |
  transpose        |
  map(sort)
;

def width_diffs:
  map(
    sort as $sorted_lengths |
    [
      range(0; length) |
      $sorted_lengths[.] - (if . > 0 then $sorted_lengths[.-1] else 0 end)
    ]
  )
;

def sum_max_cell_widths:
  map(last) | add
;

def col_to_shrink:
  map(last) |
  [
    foreach .[] as $i (-1; .+1;
      [$i, .]
    )
  ] |
  max[1]
;

def shrink_cell_widths(target_col_width_sum; col_width_sum):
  # Uncomment this to debug the cell width shrinking
  # empty = ({ col_width_sum: col_width_sum, widths: .} | debug) |

  if col_width_sum <= target_col_width_sum then
    # The final base case adds all the width differences together
    # to get a final width for each column
    map(add)
  else
    col_to_shrink                          as $col_to_shrink       |
    .[$col_to_shrink][-1]                  as $available_shrinkage |
    (col_width_sum - target_col_width_sum) as $shrinkage           |

    if $shrinkage > $available_shrinkage then
      # If there is still more shrinking to do then remove the last difference
      del(.[$col_to_shrink][-1])
    else
      # Else there is got just enough shrinkage so subtract it from the last difference
      .[$col_to_shrink][-1] -= $shrinkage
    end |

    # Recurse with a new sum of column widths
    shrink_cell_widths(
      target_col_width_sum;
      col_width_sum - (if $shrinkage > $available_shrinkage then $available_shrinkage else $shrinkage end)
    )
  end
;

def truncate_rows(cell_widths):
  map(
    [
      foreach .[] as $cell (-1; . + 1;
        cell_widths[.] as $width |
        if $width then
          $cell | truncate($width)
        else
          $cell
        end
      )
    ]
  )
;

def truncate_rows(cell_widths; end_sizes):
  map(
    [
      foreach .[] as $cell (-1; . + 1;
        cell_widths[.] as $width    |
        end_sizes[.]   as $end_size |
        if $width then
          $cell | if $end_size then truncate($width; $end_size) else truncate($width) end
        else
          $cell
        end
      )
    ]
  )
;

def col_sizes:
  transpose | map(map(length) | max)
;

def pad_col:
  . as [$col, $size]  |
  ($size - ($col | length)) |
  "\($col)\(if . > 0 then " " * . else "" end)"
;

def pad_row(col_sizes):
  [., col_sizes] |
  transpose      |
  map(pad_col)
;

# Although it works fin in jq-1.6, there's some kind of weird bug with `gsub`
# in jq-1.5 (which is the default version in ubuntu), so we'll hack around it.
def gsub_bug_in_jq1_5(regex; str):
  split("") |
  map(sub(regex; str)) |
  join("")
;

def build_border(chars):
  "\(chars[0])\(gsub_bug_in_jq1_5("│"; chars[1]))\(chars[2])"
;

def title:
  (if ($title|length) > 0 then "[1m\($title)[0m" else empty end)
;

def shrink_rows:
  if $max_width > 0 then
    sorted_cell_widths as $sorted_cell_widths |

    truncate_rows(
      $sorted_cell_widths |
      width_diffs         |
      shrink_cell_widths(
        ($max_width - ($sorted_cell_widths | length - 1) * 2 + 1);
        ($sorted_cell_widths | sum_max_cell_widths)
      )
    )
  else
    .
  end
;

def render_table:
  col_sizes as $col_sizes  |

  map(pad_row($col_sizes)) |
  map(join("│")) |
  [.[0], .[1:]] as [$headers, $rows] |
  ( $headers | gsub_bug_in_jq1_5("[^│]"; "─")) as $border |
  [
    ($border  | build_border(["┌", "┬", "┐"])),
    ($headers | "│[1m\(gsub_bug_in_jq1_5("│"; "[0m│[1m"))[0m│"),
    ($border  | build_border(["├", "┼", "┤"]))
  ] +
  ( $rows | map("│\(.)│")) +
  [
    ($border | build_border(["└","┴", "┘"]))
  ] |
  join("\n")
;

def new_col:
  capture(
    "
      (?<key>[^%:]*)
      (%(?<truncation>[0-9]+))?
      (,(?<end_size>[0-9]+))?
      ((?<heading>:[a-zA-Z][^ ]*))?
    ";
    "x"
  ) |
  .key as $key |
  if .truncation then .truncation |= tonumber else .                end |
  if .end_size   then .end_size   |= tonumber else .                end |
  if .heading    then .                       else .heading |= $key end
;

def cols_regex:
  "(?<sort>[<>])?(?<name>[a-zA-Z0-9_.:%,]+)(?<operator>[<>=!]*)?(?:\"(?<value>[^\"]*)\"|(?<value>[^ \n]+))?"
;

def col_regex:
  "(?x)                        # 'x' for extended regex so we can have comments...
  (
    (?<sort>[<>])?             # (optional) > descending, < ascending
    (?<name>[a-zA-Z0-9_.:%,]+) # column name
    (?<operator>[<>=!]*)       # (optional) equality operator
    (?<value>                  # (optional) value
        /.*?/\\S*                # regex value
      | '[^']*'                  # 'quoted value'
      | \"[^\"]*\"               # \"quoted value\"
      | \\S*                     # unqouted value
    )?
  )
  "
;

def scan_captures(regex; capture_count):
  [
    scan(regex)                            |
    to_entries                             |
    map(select(.key % capture_count == 0)) |
    map(.value)[]
  ]
;

def unique_unsorted:
  # like unique, but doesn't sort the output
  reduce .[] as $item ([]; if index($item) == null then . + [$item] else . end)
;

def find_cols:
  if $find_all_cols then
    # search through all cols to find all possible keys
    map(select(. != null) | dig_keys) | add | unique_unsorted
  else
    # search through the first non null row to find all possible keys
    map(select(. != null)) | first | dig_keys
  end |
  if $sort_cols then sort else . end
;

def cols:
  if $cols == "" then
    find_cols | join(" ")
  else
    $cols
  end
| scan_captures(col_regex; 5)
| map(capture(col_regex).name)
;

def env_filter(x):
  (x // "") |
  scan_captures(col_regex; 5) |
  map(
   capture(col_regex)       |
    .name     as $name      |
    .operator as $operator  |
    .value    as $value_str |
    # Nb. looks like there's some weird bug that means we *have* to do this here and not below
    ($value_str | try fromjson catch $value_str) as $value |
    {
      (.name): (if .sort then { sort: .sort } else {} end)
    } |
    if $operator and $value_str then
      .[$name].filter |= {
          value: $value,
          operator: $operator
        }
    else
      .
    end
  ) | add
;

def filter_json(x):
  def regex_regex: "^/(?<regex>.*?)/(?<flags>[gimnpslx]*)$";

  env_filter(x) as $f |

  if $f then
    reduce ($f | keys_unsorted)[] as $name (.;
      $f[$name].filter as $filter |
      $f[$name].sort   as $sort   |

      if $filter then
        $filter.value    as $value    |
        $filter.operator as $operator |
        if ($value|type) == "string" and ($value | test(regex_regex)) then
          # `jq` incorporates the [Oniguruma](https://github.com/kkos/oniguruma/blob/master/doc/RE) regex library.
          # It is largely compatible with Perl v5.8 regexes.
          # Pretend that jq has a regex type if the string is surrounded by slashes followed by flags
          ($value | capture(regex_regex)) as { regex: $regex, flags: $flags } |
          map(select(.[$name] // "" | test($regex; $flags)))
        elif $operator ==    "<"  then
          map(select(.[$name] <  $value))
        elif $operator ==    "<=" then
          map(select(.[$name] <= $value))
        elif $operator ==    "==" or $operator == "=" then
          map(select(.[$name] == $value))
        elif $operator ==    ">=" then
          map(select(.[$name] >= $value))
        elif $operator ==    ">"  then
          map(select(.[$name] >  $value))
        elif $operator ==    "!=" or $operator == "<>" or $operator == "!" then
          map(select(.[$name] != $value))
        elif $operator ==    "" then
          .
        else
          empty = ("Invalid operator: \($filter.operator)" | debug) |
          .
        end
      else
        .
      end
    )
  else
    .
  end
;

def sort_json(str; default_asc):
  def sort_by_layers(sort_by):
    if sort_by == [] then .
    else
      group_by(.[sort_by[0].name]) | if sort_by[0].desc then reverse else . end |
      map(sort_by_layers(sort_by[1:]))
    end | flatten
  ;

  def env_sort_by(default_asc):
    def sort_by_regex: "(?<sort>[<>])?(?<name>[a-zA-Z0-9_]+)";
    if str then
      [
        str |
        scan(sort_by_regex) | (
            if .[0] == ">" then
            { desc: true,  name: .[1] }
          elif .[0] == "<" then
            { desc: false, name: .[1] }
          else
            if default_asc then
              { desc: false, name: .[1] }
            else
              empty
            end
          end
        )
      ]
    else
      []
    end
  ;

  sort_by_layers(env_sort_by(default_asc))
;

def data_rows($keys):
  filter_json(env.cols   ) |
  filter_json(env.sort_by) |
  sort_json(env.cols   ; false) |
  sort_json(env.sort_by; true ) |
  map(data_row($keys))[]
;

def json_objects_array:
    if type == "array" then
    .
  elif has($resource) then
    [.[$resource]] | flatten
  elif has("\($resource)s") then
    .["\($resource)s"]
  else
    [., inputs]
  end // {}
;

def table:
  ( cols                            ) as $cols        |
  ( $cols        | map(new_col    ) ) as $col_objects |
  ( $col_objects | map(.key       ) ) as $keys        |
  ( $col_objects | map(.heading   ) ) as $headings    |
  ( $col_objects | map(.truncation) ) as $truncations |
  ( $col_objects | map(.end_size  ) ) as $end_sizes   |

  # DEBUGGING...
  #empty = ({$cols, $col_objects, $keys, $headings, $truncations, $end_sizes} | debug) |

  [$headings, data_rows($keys)]           |
  truncate_rows($truncations; $end_sizes) |
  shrink_rows                             |
  render_table                            |
  color(env.color_terms | split("\n"))
;
