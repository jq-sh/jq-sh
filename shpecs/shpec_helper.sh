#!/usr/bin/env bash
#
export PATH="./bin:$PATH"
export PATH="./shpecs/support:$PATH"

input_file() { echo "/dev/null"; }
input_cmd()  { cat; }

input() { input_cmd < "$(input_file)"; }
subject() { eval "$cmd"; }

matches_expected() { local cmd="${cmd:-$1}"
  read -r -d '' expected_output

  describe '`'"${cmd:-echo}"'`'

    it "matches expected"
      diff -u \
        <(echo "$expected_output") \
        <(
         input |
           subject |
             if ${STRIP_COLOR:-true}; then
               strip_color
             else
               cat
             fi
        )
      assert equal $? 0
    end_
  end_
}

matches_expected_with_colors() {
  case $(uname -s) in
    Darwin) xmatches_expected_with_colors "$@" ;;
    *)  STRIP_COLOR=false matches_expected "$@" ;;
  esac
}

xmatches_expected() { local cmd="${cmd:-$1}"
  describe '`'"${cmd:-echo}"'`'
    it
      iecho "[33;1mpending[0m"
    end_
  end_
}

# Darwin is adding some weird ^[k control characters with grep's colors that aren't on linux
xmatches_expected_with_colors() {
  xmatches_expected "$@"
}
