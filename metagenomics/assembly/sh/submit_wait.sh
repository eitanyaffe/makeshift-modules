${@:2} &
pid=$!
echo savid pid $pid to file $1
echo $pid > $1
wait $pid
