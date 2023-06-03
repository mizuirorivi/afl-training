pass=`cat .env | grep pass | sed 's/pass=//'`
isexisted=`docker ps -a | grep fuzz-training | wc -l`
isexit=`docker ps | grep fuzz-training | grep 'Exited' | awk '{print $1}'`
## if docker id not exists, create it
if [ $isexisted -eq 0 ]; then
  echo "docker id not exists, create it"
  nohup docker run --privileged -p 2222:2222 -e PASSMETHOD=env -e PASS=$pass ghcr.io/mykter/fuzz-training &
  sleep 1
fi

## although docker id exists, but not running, remove it and create a new one
if [ $isexisted -eq 1 ] && [ $isexit ]; then
  echo "docker id exists, but not running, remove it and create a new one"
  docker rm $isexit
  nohup docker run --privileged -p 2222:2222 -e PASSMETHOD=env -e PASS=$pass ghcr.io/mykter/fuzz-training &
  sleep 1
fi

sshpass -p $pass ssh -o StrictHostKeyChecking=no -p 2222 fuzzer@localhost
