#!/usr/bin/env bash
SCREENCAST_DIR=$(dirname "${BASH_SOURCE[0]}")

screencast_names() {
  cd "$SCREENCAST_DIR" || exit
  for f in *.cast; do
    echo "${f%.cast}"
  done
}

upload() { local name="$1"
  asciinema upload "${SCREENCAST_DIR}/${name}.cast"
}

asciinema_id() {
  grep 'asciinema.org' | cut -d'/' -f5
}

screencast_md() { local name="$1" asciinema_id="$2"
  cat <<-EOF 
## ${name}
[![asciicast](https://asciinema.org/a/${asciinema_id}.svg)](https://asciinema.org/a/${asciinema_id})
EOF
}

for name in $(screencast_names); do
  screencast_md "$name" "$(upload "$name" | asciinema_id)" > "${SCREENCAST_DIR}/${name}.md"
done
