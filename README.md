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

# Demo Instructions

    ## On the controller
    ## 1. Set the `/etc/salt/autosign.conf` to set a pattern include all 'cassandra-*' nodes
    ## 2. Set the `/etc/salt/master` to turn the 'autosign_file: /etc/salt/autosign.conf' on
    ## 3. Install `dnsmasq` and add the IP of docker interface as `salt` in `/etc/hosts`
    ##
    sudo salt-master -l debug

---

    ## On a new terminal
    ## 1. Before launch the clients, delete old keys if the same name dockers had been launched
    sudo salt-key -D

    ## 2. *After* the clients got launched, copy the Cassandra file setup mentioned earlier to clients
    sudo salt-cp '*' cassandra.yaml '/etc/cassandra/cassandra.yaml'

    ## 3. Launch the Cassandra nodes on clients
    sudo salt '*' cmd.run 'cassandra'

    ## 4. You can run another container and execute a command in it to ensure nodes are
    ## running in the same cluster
    sudo nodetool -h cassandra-test1 ring

    ## If the command above only print one node, something was wrong.

---

    ## On the terminal want to launch the client
    ## 1. To build the image if you didn't build it yet
    sudo docker build -t snowmantw/cassandra .
    
    ## 2. Run it with the `demo-bootstrap` script, and find a way to find what IP it is
    demo-bootstrap test1        # Will launch a container named cassandra-test1
    demo-bootstrap test2        # Will launch a container named cassandra-test2

    ## 3. Edit the `/etc/hosts` on the controller to add the above nodes' IPs.
    ## 4. Restart the DNS on the controller to load the hostnames.

