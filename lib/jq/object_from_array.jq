def object_from_array:
  map(
    {
      (.name): (. | del(.name))
    }
  ) |
  add;
