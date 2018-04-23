# Official TriggerFS Repository (https://triggerfs.io)

## Welcome to the official triggerFS repository

### Signup has been enabled now. Beta testing has begun!
The beta testing has just started (as of April 23th 2018) and will last for a period of time.

**Sign up now for free and all features enabled** - We have enabled the signup process via our installer. You get free access with all features enabled so you can get the full experience.
The free version has no trial and will also be free after the testing phase.

[0] *once we finished our paid plans the free plan stays free but will have a limited feature set.*

#### Installer now available
You will find install.sh in this repository.

Installing triggerFS is now easy with the installer. curl one-liner:
```
curl https://install.triggerfs.io/ | bash
```


&nbsp;

This repository includes following modules:
* cli (triggerfs-cli)
* client (triggerfs-client)
* worker (triggerfs-worker)
* fs (triggerfs)

All binaries are statically linked and do not need any dependencies except the *fs* module (it needs libfuse2/fuse).
Every module makes use of the configuration toml file. You will find a skeleton of such a configuration file called `triggerfs.toml`.

* Our official website and documentation is https://triggerfs.io
* Our official core plugins repository is https://github.com/triggerfsio/plugins
* Our official docker repository is https://hub.docker.com/u/triggerfsio/
___

&nbsp;


## Introduction
triggerFS is a distributed, realtime message passing and trigger system. triggerFS enables you to build distributed systems and do realtime messaging in a service-oriented fashion. It is made up of four modules:
* worker
* client
* cli
* fs

Each one of these modules play a key role in your triggerFS environment:


## Modules
### **worker**
A worker is or has a service and receives messages (requests) from one or more clients in a safe and concurrent way and executes them by using a *plugin*. Deploy a worker to a bunch of servers and connect them together, build a network of services for high-speed messaging, to distribute workload or create clusters or groups of workers.

A plugin is a tiny binary (written and compiled in go) which does one thing and does it well. A plugin could be anything:
* compute something
* filter, grep, grok, sort or manipulate data
* write to a file
* log to a file
* forward a message
* read logs
* collect metrics (eg. send metrics to graphite)
* just echo back the received message
* monitor the server the worker is running on
* execute something on a remote machine via ssh
* run a chef/puppet/fabric recipe or ansible playbook
* run a bash script
* send an SMS via twillio
* send a text message to telegram
* flip a switch (0/1 flipflops)
* start/stop/restart a service
* kill a process
* chain requests by writing to another trigger file (this is fun)
* ...

you name it. As you can see the job of a plugin is to make our life easier and serve us with mostly things that can be automated or are needed on-demand. You can write your own plugins or search for existing plugins on the marketplace (more about that below).

&nbsp;

### **client**
A client sends messages (requests) to a service and gets back a response. The client can specify which service it wants to talk to and what plugin shall be used. The client module is simple but powerful.

&nbsp;

### **cli**
The cli module is an interactive cli-based management console for managing everything on your triggerFS platform. With the cli module you can:
* create new users
* create new workers
* create new services
* make services public (public services feature)
* select the message dispatching algorithm (loadbalancing and more)
* create *triggers*
* make requests to your services in realtime
* and much more

The triggerFS cli module is **the** central place for managing, orchestrating and configuring your triggerFS environment.

Suppose we wanted to do the following:   
If we know that there will be a service called *demo* with a *command* plugin and three workers behind that service (announcing that service), we could create a trigger named *command*, attach it to the *demo* service, add the *demo* service to all of our three workers and set a timeout of - let's say - 10s. Now we have created a trigger which is represented as a file in our fs module.

&nbsp;

### **fs**
The fs module is a module for mapping the above mentioned *triggers* to files with the help of FUSE. It was built to go a step further than just sending messages back and forth. It enables machine-to-machine communication. Mounting files is cheap and doing socket communication by using files makes this module attractive to embedded devices or small computers like the Raspberry Pi™.

Create a directory and define a trigger in that directory in your cli. Now, if you mount the fs module to a place on your filesystem, you end up with a file in that directory within that mountpoint. Every write to that file (with the content being the data written to that file) will send a request to the workers behind the above defined service with all the predefined set of rules we configured ealier. The fs module aims to make triggerFS "apps-friendly" in such a way that other applications can use files as their way to send a message to your services.

For example:  
A trigger file could be defined in such a way that the result would be a logging of the request being sent to a service. Now we could tell Nginx to log into our trigger file instead of /var/log/nginx/*. Now everytime Nginx wants to log someting, it makes a syscall (write) to our file which would result in a message being sent. Our service would then write it to eg. a central NFS server of the company which is located on the machine where the worker is running.

Another example would be a raspberry pi which collects weather data and sends it to a central server (service) by writing into the trigger-files it mounted on its filesystem. Either scripted or syscalled.  
A simple `echo 'somedata 31F;10°;3.2' > /mnt/triggerfs/weatherstation/rpi/station1` is enough to send your data.

What we just did is, we triggered an action by writing to a file. Hence the name *trigger*.

&nbsp;
___

## Marketplace
triggerFS gives you the platform for high-speed realtime messaging. But that is only a small fraction of what this is all about, really. What really powers triggerFS is the gigantic amount of plugins you can use to do any kind of task. These plugins or the combination of several of them is what makes triggerFS a pleasure to work with.

Those plugins need a place where they can be listed to the public, so everyone can benefit and download and use them. That is our vision of building the triggerFS marketplace. Anyone who can write go (https://golang.org/) can also write plugins. Check out our core plugins so you can get a feeling of how a plugin works. Our plugin skeleton has 57 lines of code (loc). Add your own function to it and you have just created your first own plugin.

Plugins are small pieces of code, doing one thing and doing it well.
We want to build as many plugins as possible for any kind of job. You can host them on github and link your repository in the triggerFS marketplace, making it accessible within the triggerFS app. Our goal is to provide you with tons of plugins with the help of the community in the near future.

This should give a simple overview of what triggerFS is. But there is so much more to it. Please refer to our official documentations at https://triggerfs.io if you want to know how much fun you can have with triggerFS.

## Target Group
We think that devops and system administrators will love to use triggerFS due to the way it simplifies building tools such as automation systems and communication of services. We see DCs (data centers) in general also as a target group. A triggerfs-worker as a top-of-the-rack (tor) worker which is responsible for the systems in a rack to handle deployments, automation, triggering of jobs, etc. is one of the scenarios triggerFS can fit into. Of course everybody is welcome to try out triggerFS (there is a free-tier subscription. Go try it out!)

## Problem Solving
TriggerFS is here to help you with the right tool. We don't want to invent anything new, we want to take already existing parts and put them together to build a system which can deliver the experience many people are looking for when:
* there is a new problem to be solved
* building distributed systems can actually be tricky
* suddenly automating things becomes relevant
* communication across boundaries is necessary but firewalls are in your way
* tasks need to be outsourced to other systems
* tasks need to be scheduled
* periodic tasks need to be run
* geo-replication is a topic
* a "serverless" design is taken into consideration
* lambda functions on own servers are needed
* fire&forget-style events could be needed
* wanting a central place where everything can be run (triggered) from

&nbsp;
___
If you want to know more about triggerFS please visit https://triggerfs.io.  

&nbsp;
[0] - *The pricing plan is not finished, yet. So we can't exactly tell the price, but we will update it once we know how we want to charge our customers. We want to start with the free tier with all features enabled so we can offer you the full featured experience of triggerFS.*
