# Nb. walk() is only available from jq-1.6
# so we will just write our own as a workaround

def walk_pre16(f):
  . as $in
  | if type == "object" then
      reduce keys_unsorted[] as $key
        ( {}; . + { ($key):  ($in[$key] | walk_pre16(f)) } ) | f
  elif type == "array" then map( walk_pre16(f) ) | f
  else f
  end;
