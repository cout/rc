if [ "$BASH_VERSINFO" = "" ]; then

remove_path() {
  eval PATHVAL=":\$$1:"
  PATHVAL=`echo $PATHVAL | sed -e "s#:$2:#:#g" | sed -e "s/::/:/g"`
  export $1="$PATHVAL"
}

else

remove_path() {
  eval PATHVAL=":\$$1:"
  PATHVAL=${PATHVAL//:$2:/:} # remove $2 from $PATHVAL
  PATHVAL=${PATHVAL//::/:}   # remove any double colons left over
  PATHVAL=${PATHVAL#:}       # remove colons from the beginning of $PATHVAL
  PATHVAL=${PATHVAL%:}       # remove colons from the end of $PATHVAL
  export $1="$PATHVAL"
}

fi

append_path() {
  remove_path "$1" "$2"
  eval PATHVAL="\$$1"
  export $1="${PATHVAL}:$2"
}

prepend_path() {
  remove_path "$1" "$2"
  eval PATHVAL="\$$1"
  export $1="$2:${PATHVAL}"
}


