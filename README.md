## chat server in ruby

#### Usage

```bash
# start mqtt server
sudo service mosquitto start

# start sub process
ruby sub.rb

# start chat server
ruby server.rb
```

#### Client

```bash
ruby client.rb
```

#### Design

* Store session to redis
* Use mqtt(pub/sub) to exchange message
