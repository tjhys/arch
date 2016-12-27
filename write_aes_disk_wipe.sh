


openssl enc -aes-256-ctr -pass pass:"$(dd if=/dev/urandom bs=128 count=1 2>/dev/null | base64)" -nosalt </dev/zero | pv -bartpes 256060514304 | dd bs=64K of=/dev/sd"X"
