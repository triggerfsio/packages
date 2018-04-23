# triggerFS worker module

## worker module of triggerfs.io
This is the worker module of triggerfs.io called `triggerfs-worker`.


### Usage
Please make sure that you have configured a worker in your cli first.
You can get it at https://hub.docker.com/r/triggerfsio/cli/.

Also make sure you have the core plugins installed. You can find them at https://github.com/triggerfsio/plugins.
The worker uses plugins as a binary file. In order to make use of the plugins, please make sure that you have built them with `go build $plugin.go` in each directory.


### Installation
* Get your configuration file named `triggerfs.toml` from https://github.com/triggerfsio/packages
* Change the settings in the toml file accordingly
* Pull docker image
```
sudo docker pull triggerfsio/worker
```
* Run image
```
sudo docker run -it --rm -v ~/triggerfs.toml:/root/triggerfs.toml -v ~/plugins:/plugins -e IDENTITY=$workeridentity -e DEBUG=true triggerfsio/worker
```

Note: the toml file has to be mapped into root's home directory `/root` and the plugins folder into the root `/` directory of the docker image.
