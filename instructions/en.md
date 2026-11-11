# Remove a world-writable secret

The application in `~/app` reads its API token from `~/app/token`. Every user on the machine can read **and modify** it, and anyone can add files to `~/app`.

Fix it so that:

1. only you can read and write the token,
2. nothing in `~/app` is writable by other users.

Press **Check my work** when you are done.
