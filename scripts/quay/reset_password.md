# How to reset a user password or user login count for the quay mirror registry

## Install required packages and modules
```console
dnf install python3 python3-pip sqlite
sudo python3 -m pip install --upgrade pip
python3 -m pip install --user bcrypt
```

## Generate a new password hash
```console
python3 -c 'import bcrypt; print(bcrypt.hashpw(b"NEW-PASSWORD-HERE", bcrypt.gensalt(12)).decode("utf-8"))'
```

## Stop the quay app
```console
systemctl --user stop quay-app
```

## Use podman unshare to access the DB file directly
```console
podman unshare
```

## Within the podman unshare shell, change directories to the location of the sqlite db file
```console
cd /home/ec2-user/quay-install/sqlite-storage

sqlite3	quay_sqlite.db
sqlite3 /sqlite-storage/quay_sqlite.db
sqlite> UPDATE user SET password_hash = 'HASH_FROM_STEP_1' WHERE username = 'init';
sqlite> UPDATE user SET invalid_login_attempts = 0 WHERE username = 'init';
sqlite> quit

exit
```

## Restart the quay app service
```console
systemctl --user start quay-app
```
