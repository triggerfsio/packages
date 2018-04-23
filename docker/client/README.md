# triggerFS client module

## client module of triggerfs.io
This is the fs module of triggerfs.io called `triggerfs`.

### Installation
* Get your configuration file named `triggerfs.toml` from https://github.com/triggerfsio/packages
* Change the settings in the toml file accordingly
* Pull docker image
```
sudo docker pull triggerfsio/client
```
* Run image
```
sudo docker run -it --rm -v ~/triggerfs.toml:/root/triggerfs.toml -e SERVICE=myworker01 -e PLUGIN=command/command -e COMMAND=uptime -e TIMEOUT=10s triggerfs-client
```

Note: the toml file has to be mapped into root's home directory `/root` of the docker image.
