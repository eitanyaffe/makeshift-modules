# 1: variable name
# 2: source directory to rsync
# 3: target bucket path
# 4: sleep parameter
# 5: filename with pid of megahit
while true
do
    sleep $4
    pid=`cat $5`
    kill -STOP $pid
    echo Pausing megahit run and delocalizing $1
    gsutil -mq rsync -r -x ".*\.dsub.*" $2 $3
    kill -CONT $pid
done
