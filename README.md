# Setup

* Install `salt-master`

    sudo apt-get install salt-master

* Install dnsmasq  (salt will need)

    sudo apt-get install dnsmasq

* Setup the `salt` in the `/etc/hosts`, which is the same as the controller server

    echo '172.17.42.1    salt' >> /etc/hosts

* In the project's directory, build the image

    sudo docker build .

* Next you can follow the instructions in the Docker documents to init it

* A note is the DNS option should include the IP you specified as the 'salt'

# Run It

* The `salt` master and minions must exchange keys. The key name generated according to the minion's hostname,
so we should run the container with specific names to let the master can accept them

( in `/etc/salt/master` we can use several ways to automatically add minions' keys. For example, an `/etc/salt/autosign.conf`
file can contains the matched hosts).

* The node must run `salt-minion -l debug` to enable minion. If it report a Python error occurs when generate key, 
it may be the problem that the versions between controller and nodes are not the same. So it's recommended to use the 
same version provided by the official site

    http://docs.saltstack.com/topics/installation/index.html

# Some Other Notes

To solve these manual steps, maybe a salt script should be a part of my container.

1. Container must resolvable in the DNS: this require we add every node's IP into the DNS. Currently, it's a manually process, and need to reload the dnsmasq on the controller everytime we launched a new container. The docker lacking a way to assign static IP for containers make this even worse: everytime the docker got run, it's IP would be changed, thus the DNS settings must be changed and ther service must be reloaded.

2. The rpc_address in the cassandra.yaml should be '0.0.0.0', and the cluster name need to be changed before bootstraping. This can be done by a preset cassandra.yaml pushed by Salt. (salt-cp). And Cassandra seems need a seed node to provide information that nodes need to join to the cluster: -seeds: "cassandra-node1,cassandra-node2"
