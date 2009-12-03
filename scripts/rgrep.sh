rgrep() {
  opts=
  while :; do
    case $1 in
      -?*)
        opts="$opts $1"
        ;;
      *)
        break ;;
    esac
    shift
  done
  find . -name "$2" -exec grep $opts -d skip -H "$1" {} \;
}

