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
             if ${STRIP_COLOR:-false}; then
               cat
             else
               strip_color
             fi
        )
      assert equal $? 0
    end
  end
}

matches_expected_with_colors() {
  STRIP_COLOR=true matches_expected "$@"
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
