export PATH=./bin:$PATH
export PATH="./shpecs/support:$PATH"

color_strip() {
  sed -e 's/[\[0-9;]*m//g' \
      -e 's/\[K//g'        \
      -e 's/ $//g'
}

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
           color_strip
        )
      assert equal $? 0
    end
  end
}
