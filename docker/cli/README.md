# triggerFS cli module

## cli module of triggerfs.io
This is the cli module of triggerfs.io called `triggerfs-cli`.


### Installation
* Get your configuration file named `triggerfs.toml` from https://github.com/triggerfsio/packages
* Change the settings in the toml file accordingly
* Pull docker image
```
sudo docker pull triggerfsio/cli
```
* Run image
```
sudo docker run -it --rm --privileged -v ~/triggerfs.toml:/root/triggerfs.toml triggerfsio/cli
```

IMPORTANT: since this module makes use of FUSE, you have to start the docker image with the `--privileged` parameter.

Note: the toml file has to be mapped into root's home directory `/root` of the docker image.


