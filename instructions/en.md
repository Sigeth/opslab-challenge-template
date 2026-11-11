# Remove a world-writable secret

The application in `/opt/app` reads its API token from `/opt/app/token`. Every user on the machine can read **and modify** it.

Fix the file so that:

1. only its owner can read and write it,
2. its owner is the `app` user.

Press **Check** when you are done.
