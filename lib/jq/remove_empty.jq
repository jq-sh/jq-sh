include "walk_pre16";

def remove_empty:
  walk_pre16(
    if type == "object" then
      with_entries(
        select(.value != {})
      )
    else
      .
    end
  );
