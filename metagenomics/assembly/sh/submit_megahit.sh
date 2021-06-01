# 1: file to store pid
# 2...: rest of params to start megeahit
${@:2} &
ppid=$!
echo saving megahit pid $ppid to file: $1
echo $ppid > $1
wait $ppid


# sleeping is needed to get a chance for the megahit process to actually start
#sleep 1s
#pid=$(ps -o pid= --ppid $ppid)
#[[ $pid -ne "" ]] || { echo >&2 "children of $ppid not found"; exit 1; }
