echo "Waiting to execute config server script..."
while(-Not (docker-compose exec config1 mongo --port 27019 --eval "PONG" | Select-String -Pattern PONG)) {
  echo "Waiting..."
  sleep 1
}
echo "Running init script for configsvr..."
docker-compose exec config1 mongo --port 27019 scripts/init-configserver.js
echo "OK - Config servers configured"
echo ""

echo "Running init script for 5 shard clusters..."
docker-compose exec shard1 mongo --port 27018 scripts/init-shard.js
docker-compose exec shard2 mongo --port 27018 scripts/init-shard.js
docker-compose exec shard3 mongo --port 27018 scripts/init-shard.js
docker-compose exec shard4 mongo --port 27018 scripts/init-shard.js
docker-compose exec shard5 mongo --port 27018 scripts/init-shard.js
echo "OK - Shard servers configured"
echo ""

echo "Waiting to execute init router script..."
while(-Not (docker-compose exec router mongo --port 27017 --eval "PONG" | Select-String -Pattern PONG)) {
  echo "Waiting..."
  sleep 1
}
echo "Running init script for router"
docker-compose exec router mongo scripts/init-router.js
echo "OK - Router configured"
echo ""

echo "Initializing database and collection for sharding-ready"
docker-compose exec router mongo localhost/reddit scripts/init-router-db.js
echo "OK - Database and collection is ready for sharding"
echo ""

echo "Importing documents to reddit.posts..."
mongoimport --db reddit --collection posts --file posts_new.json
echo "OK"