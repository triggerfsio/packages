# Official TriggerFS Repository (https://triggerfs.io)

## Welcome to the official triggerFS repository
#### triggerFS is a distributed, realtime message passing and trigger system available as a SaaS Application.

&nbsp;

# Introduction
triggerFS is a new SaaS application powered by a highly motivated team to deliver a great experience with building distributed systems and messaging. Please have a look into the documentation to get an overview what triggerFS is and how it can help you. 

Please note that we are in the launching phase. We a trying hard to launch asap and make things work for you. The landing page is still in development.

* Our official website is https://triggerfs.io
* Our official docker repository is https://hub.docker.com/u/triggerfsio/
* Our official marketplace is https://marketplace.triggerfs.io
* Our official documentation is https://docs.triggerfs.io
* Our official API swagger demo is https://swagger.triggerfs.io

Our SaaS application has three pricing plans:
* Free (and yes, will always be free :) )
* Basic (charged)
* Advanced (charged)
* Enterprise (not available yet)

The pricing plan is not finished, yet. So we can't exactly tell you the cost, but we will update it once we know how we want to charge our customers.

Additionally, we want to provide you with as much information about our SaaS as possible. We will make use of animated gifs, pictures, videos, a series of screencasts and more to help you to understand what triggerFS is all about and how it can help you solve problems.

Although triggerFS is a closed source SaaS application, that doesn't mean you can not contribute to it.
Basically the only module not listed here is our message broker which runs in the cloud. Every other modules is distributed as a binary. However, our marketplace is open source and will be also launched soon. The marketplace will provide you with tons of usable plugins you can use with triggerFS.

Some facts:
```
     152 text files.
     139 unique files.                                          
     420 files ignored.

http://cloc.sourceforge.net v 1.60  T=0.34 s (296.5 files/s, 34247.9 lines/s)
-------------------------------------------------------------------------------
Language                     files          blank        comment           code
-------------------------------------------------------------------------------
Go                              43           1075            829           7176
SQL                             34            182            356           1201
Bourne Shell                    10             35             49            259
Lua                              6             20             37            110
YAML                             1              2             14             75
Javascript                       3             12              3             69
make                             2              8              2             26
Python                           1              2              1              8
-------------------------------------------------------------------------------
SUM:                           100           1336           1291           8924
-------------------------------------------------------------------------------
```

* the whole application has around 9k loc
* the core application is written in Go
* all modules are written in Go
* the backend uses postgrest as a database
* we use helper scripts written in bash and python for automated deployments and testings
* we do our testing in bash, javascript and sql for various checks and db testings
* we use the lua module in nginx for our HTTP JSON API
* the team is made of 4 members:
  * 1 core/backend developer
  * 1 frontend developer
  * 1 linux/systemadministrator
  * 1 testing guy
* we've built this application in 7 months and 23 days
* this application is being actively developed and maintained
* we hope to help others with this application and also hope to make profit with it

For more information please visit https://triggerfs.io.

Happy triggering! :)

&nbsp;

# Preface
This repository is made of three branches:
* cli (triggerfs-cli)
* client (triggerfs-client)
* worker (triggerfs-worker)
* fs (triggerfs)

Each of these branches holds the corresponding binary module. Every module makes use of the configuration toml file. In the master branch you will find a skeleton of such a configuration file.

If you want to know more about triggerFS - or want to sign up - please visit https://triggerfs.io

&nbsp;

## About TriggerFS
TriggerFS is a new multi-tenant SaaS application which aims to be a reliable service-oriented message passing system for building distributed, high-available clusters of services which make use of plugins to be able to do any job. TriggerFS is made of three modules which - put together - make up a powerful tool for distributing workload of any kind, build automation solutions or build whole networks of services talking to each other.

TriggerFS can do a lot. Let's dive a bit deeper into it...
___

#### Description
A set of workers sit behind a service and wait for incoming messages (eg. job requests). Services are bound to one or more so called trigger-files. A trigger-file defines a configuration of how a message will be passed (eg. which message [the payload] will be relayed to which service [a set of workers] and which plugin shall be used by that service and more. These trigger-files are exposed through FUSE as regular files which can be written to and read from.

Writing to a file (which is the representation of a trigger with all its configured options) ends up in firing a trigger and thus in starting a chain of events like sending a message to one or more services which could result in sending even more messages by firing up another trigger and so on. Hence the name *trigger*.

### TL;DR
TriggerFS - in a nutshell:
* multi-tenant SaaS application
* reliable, service-oriented message passing through the use of *trigger*-files mounted as FUSE on your filesystem (**triggerfs** module)
* writing to a *trigger*-file fires a trigger (sends a message)
* a *trigger* triggers something. usually a job which is executed by the worker by the help of a plugin (eg. run a command on the system)
* **triggerfs-cli** module as a central management cli application for managing your infrastructure (set of workers, services, triggers, users, timeouts, logging, etc.)
* **triggerfs-worker** module for spawning worker instances across servers and build cluster of services or do logical grouping of services


### TriggerFS Modules
#### triggerfs
The main module which exposes your configured triggers as regular files within your filesystem. triggerfs uses FUSE to let you mount your trigger-files into your filesystem so you can read from and write to them. This is the module which will be used most of the time since it is the only way to send a message and fire up a trigger. Since other applications on your system know how to write to a file (common syscall operations) triggerfs is also "apps friendly", meaning that everything which can handle files will be able to fire up a trigger by writing to the trigger-files in that mountpoint.

#### triggerfs-worker
This module is the worker part which connects to a central broker in the cloud and provides not only its own service (the worker itself) but also listens for other services a user has created. Deploy your triggerfs-worker on any server and it will be under your control. Spawn a bunch of workers on different servers and put them under the same service and magically every server is a member of a newly created cluster.
These workers have access to different plugins to do their job. Plugins are tiny, language-agnostic, rpc-based programs which can be executed by a worker on demand. Our goal is to provide a plugin for every kind of task one can imagine. A plugin should be a simple program which does one job and does it well. It can be a self-written executable made for your specific needs or can be downloaded from the TriggerFS **marketplace** because someone else already wrote one to do the job. We want the marketplace to be a place where the community can share their plugins. There should be a plugin for any job out there. We (the team behind TriggerFS) are actively pushing the marketplace to be able to launch it soon so we can build a community and reach more people and motivate more developers to build their plugins and share them with others. We also write our own plugins which we share officially on our Github repository. The marketplace will be online soon and will hopefully complete our vision of a nice experience of this application.

TriggerFS already comes with its first plugin out-of-the-box which is a basic *command* plugin. The *command* plugin will execute whatever command is being sent to a service. It is written in golang and can be executed to run arbitrary commands in a shell where the worker is running. When we say "basic plugin", we mean the codebase. This doesn't mean that you can't do more complex things like ssh'ing into another machine for ad-hoc commands (no tty supported) or run an ansible playbook ;).

#### triggerfs-cli
Finally there is the triggerfs-cli module which is the central place for configuring and managing your infrastructure. You can add/remove services, create users or define new triggers and more. This module is a cli application and its goal is to provide a nice management platform to the user.

<!-- TriggerFS has several features. Here are some of the most important ones:
* build high-availability clusters of workers by putting them behind a service
* choose between two algorithms for distributing messages to services: roundrobin (load-balancing) and mirror (duplicating)
* zero-downtime interrupt of services (joining workers, failing worker, disconnecting worker)
* centralized cli management tool for managing and configuring the infrastructure with triggerfs-cli
* future feature: one marketplace for every kind of plugin. command plugin, graphite plugin, logging plugin, etc.
* easy to understand and scalable subscription based pricing model which fits your needs -->
___

### Target Group
We think that devops and system administrators will love to use our SaaS product due to the way it simplifies building tools such as automation systems and communication of services. We see DCs (data centers) in general also as a target group. A triggerfs-worker as a top-of-the-rack (tor) worker which is responsible for the systems in a rack to handle deployments, automation, triggering of jobs, etc. is one of the scenarios TriggerFS can fit in. Of course everybody is welcome to try out TriggerFS (there is a free-tier subscription. Go try it out!)

### Problem Solving
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

<!-- 
### Benefits Of Using TriggerFS

### TriggerFS Modules
#### A Message Passing System
#### A Trigger System
#### A Distributed Filesystem

### TriggerFS Evolution
#### Defining The Problem
#### The Idea
#### Finding a solution

### Overview
#### Infrastructure
#### Modules
#### Plugin System
#### Marketplace
#### SaaS vs. On-Premise Model

### Security

### Updates

### Documentations
#### Users Manual
#### Developer's Guide (Plugins)

### Install & Usage
#### Installation
#### Configuration
#### Usage

### Examples
#### Basics
#### Use Cases

### Features

### Roadmap
#### Current Status
#### Active Development
#### What's Next?
#### Releases

### Subscription Model & Pricing Plan
#### Subscription-Bases Pricing

#### Subscription Tiers
##### Free Tier
##### Basic Tier
##### Premium Tier

#### On-Premise Solutions
##### Enterprise Tier

### About Us
#### Team
#### Vision
#### Goals
-->