# triggerFS fs module

## fs module of triggerfs.io
This is the fs module of triggerfs.io called `triggerfs`.


### Installation
* Get your configuration file named `triggerfs.toml` from https://github.com/triggerfsio/packages
* Change the settings in the toml file accordingly
* Pull docker image
```
sudo docker pull triggerfsio/fs
```
* Run image
```
sudo docker run -it --rm --name triggerfs --privileged -v ~/triggerfs.toml:/root/triggerfs.toml triggerfsio/fs
```

The module will run in foreground. So open another terminal and...


* Drop into docker container (attach)
```
sudo docker exec -it triggerfs bash
```

* Use the fs module
 ``
echo uptime > /mountpoint/...
```

IMPORTANT: since this module makes use of FUSE, you have to start the docker image with the `--privileged` parameter.

Note: the toml file has to be mapped into root's home directory `/root` of the docker image.


