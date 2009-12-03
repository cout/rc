set_prompt()
{
  pre=$1
  post=$2
  export PS1="${pre}[\u@\h \W]\$ ${post}"
  export PS1="\[\017\033[m\033[?9l\033[?1000l\]$PS1"
  #export PS1="\[\033]0;\u@\h \@\007\]$PS1"
  if [ "$TERM" = "xterm" ]; then
    export PS1="\[\033]0;\u@\h\007\]$PS1"
  fi
}
