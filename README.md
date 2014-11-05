interclock
==========

Daily internet allowance system
-------------------------------
Interclock allows me to control the daily internet allowance for my kids.
In order to browse the net, they need to open a terminal and run the command:
 interclock in
To stop the clock and leave some time for later usage, they need to clock out with the command:
 interclock out
During the day they can check their usage by running the command:
 interclock status

As a parent I do not have to deal with discussions of how long have they been online. I neither need to use boolean logic when they need to concetrate on other activities.
I can raise or lower the allowance at will.

The kids learned to administer their internet time.

Installation
------------

1. Create shared filesystem

On the central machine create a shared directory (I use NFS) 

	mkdir -p /export/interclock/{kid1,kid2}/{punch,allow,history}

Give ownership to the kids to their respective 'punch' directory.
The other directories should be owned by root but with read access to the kids.

2. Setup cron job for user root on central server to reset allowances.
i.e.

	0 8 * * * echo 120 > /export/interclock/kid1/allow/ance.txt

	0 8 * * * echo 90 > /export/interclock/kid2/allow/ance.txt

3. Setup cron job to clean old records.
i.e.

	0 1 * * * find /export/interclock/kid{1,2} -type f -mtime +1 -exec rm {} \;

4. Copy the files under bin to all computers under /usr/local/bin/

5. Copy the cfg files to /etc/interclock

6. Setup iptables on workstation
See iptables.sample file for a simple iptables structure. The first version of the software would have only restrictions for the kids user ids.
My daughter, created a second account for which I was not aware of and had unlimited access.
This new version restricts the network access only to the home network address.
So now I have an iptables rule to allow the root user and my user id to go beyond the router.

7. Setup cron job for user root on each workstation to run every minute. This cron is the responsible for opening/closing the gates to the internet.
i.e.

	* * * * * /usr/local/bin/interclock-cron.sh 

Monitoring
----------
