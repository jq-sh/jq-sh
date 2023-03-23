#!/usr/bin/env shpec
source shpecs/shpec_helper.sh


describe "jwt-decode"
  describe "HS256"
    input_file='shpecs/support/token-256.jwt'

    describe "verifying signature"
      matches_expected "2>&1 secret=your-256-bit-secret jwt-decode" \
<<-EOF
["DEBUG:",{"header":{"alg":"HS256","typ":"JWT"},"encoded_signature":"SflKxwRJSMeKKF2QT4fwpMeJf36POk6yJV_adQssw5c","computed_signature":"SflKxwRJSMeKKF2QT4fwpMeJf36POk6yJV_adQssw5c","signature_verified":true}]
{
  "sub": "1234567890",
  "name": "John Doe",
  "iat": 1516239022
}
EOF
    end

    describe "failing to verify signature"
      matches_expected "2>&1 secret=not-your-secret jwt-decode" \
<<-EOF
["DEBUG:",{"header":{"alg":"HS256","typ":"JWT"},"encoded_signature":"SflKxwRJSMeKKF2QT4fwpMeJf36POk6yJV_adQssw5c","computed_signature":"-Gb8Z4m_1jYcjQQ8r7UXaaZADtcSM1QuBkf5yDo6LQQ","signature_verified":false}]
{
  "sub": "1234567890",
  "name": "John Doe",
  "iat": 1516239022
}
EOF
    end
  end

  describe "HS384"
    input_file='shpecs/support/token-384.jwt'

    describe "verifying signature"
      matches_expected "2>&1 secret=your-384-bit-secret jwt-decode" \
<<-EOF
["DEBUG:",{"header":{"alg":"HS384","typ":"JWT"},"encoded_signature":"i4eWoHvLj_4RSElJS4qFL1Gin2i1KPhZnuMRrry41OAaDrXhBCxMZZ_MKujOhYjf","computed_signature":"i4eWoHvLj_4RSElJS4qFL1Gin2i1KPhZnuMRrry41OAaDrXhBCxMZZ_MKujOhYjf","signature_verified":true}]
{
  "sub": "1234567890",
  "name": "John Doe 384",
  "iat": 1516239022
}
EOF
    end
  end

  describe "HS512"
    input_file='shpecs/support/token-512.jwt'

    describe "verifying signature"
      matches_expected "2>&1 secret=your-512-bit-secret jwt-decode" \
<<-EOF
["DEBUG:",{"header":{"alg":"HS512","typ":"JWT"},"encoded_signature":"_LT96BNfks8L32sdff8BYsexuZA8W0tTY4FPJORP9JYvtCyOT8kZ-i0HDA8jrIVM2O4VVbyIFWrmtz4ApOJmUQ","computed_signature":"fpBgQAuMg9utEahHrKdzTI1wtcCPyKKro5pao4ua8xH5mKZydnl66BJMlhRmXP4xSA5UM825vCjIvhjscRkQjg","signature_verified":false}]
{
  "sub": "1234567890",
  "name": "John Doe 512",
  "iat": 1516239022
}
EOF
    end
  end
end
