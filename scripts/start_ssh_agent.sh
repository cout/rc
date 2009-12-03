if [ "$SHLVL" = "1" -a "$SSH_AUTH_SOCK" = "" ]; then
  if [ -f "$SHELL" ]; then
    exec ssh-agent $SHELL
  elif [ -f /bin/bash2 ]; then
    exec ssh-agent /bin/bash2
  else
    exec ssh-agent /bin/bash
  fi
fi

