export PATH=./bin:$PATH
export PATH="./shpecs/support:$PATH"

input_file=${input_file:-"/dev/null"}

matches_expected() { local cmd="${cmd:-$1}"
  read -r -d '' expected_output

  describe '`'"${cmd:-echo}"'`'
    subject() { eval "$cmd"; }
    input() { eval "${input_cmd:-cat}" < "${input_file}"; }

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
    end
  end
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
    end
  end
}

xmatches_expected_with_colors() {
  xmatches_expected "$@"
}
