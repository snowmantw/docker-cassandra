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
