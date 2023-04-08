# faucet-package

This repo helps you set up a minimal deployment of the `mobilecoind-dev-faucet`.

## Quick start

Start by getting a cloud machine somewhere.

I used [Amazon Lightsail](https://aws.amazon.com/free/compute/lightsail/?trk=56417dfe-8849-4622-bfa4-7ec30bd6f5a3&sc_channel=ps&ef_id=Cj0KCQjw_r6hBhDdARIsAMIDhV9mF7D1mX0JVrE8kVXF_gKbQw3GOy8Prk3Bc6AtwPdOZHMYgTAY3t4aAgMyEALw_wcB:G:s&s_kwcid=AL!4422!3!536323500429!e!!g!!amazon%20lightsail!11199789546!116615087504) with 4 GB RAM, 2 vCPUs, 80 GB SSD.

I configured a machine with OS-only and selected Ubuntu 22.04.

Then, get a prompt in the container. You will need to install `supervisord` and `nginx`.

```
sudo apt-get update && sudo apt-get install supervisor nginx
```

You can use `wget` to fetch the pre-created package and install it with `tar`.

```
sudo su
cd /
wget https://github.com/cbeck88/faucet-package/releases/download/v0.2/package.tar.gz
tar -xzvf package.tar.gz
```

Then, run `supervisorctl`. You can use `reload` to start the services.

To monitor the services using `supervisorctl`, you can use the commands `status` and `tail -f mobilecoind` or `tail -f faucet` to look at logs.
You can also `stop` and `start` the services using `supervisorctl`.

You can also look at the `/var/log/mobilecoind.log` and `/var/log/faucet.log` files on disk, outside of `supervisorctl`.

## Ports and Networking

With the packaged configs, nginx listens on port 80 for HTTP, and it proxies `POST /` and `GET /status` to the faucet on 8080.
It serves other `GET` requests from the `/var/www` directory.

* You can modify `/etc/supervisord/conf.d/nginx.conf` if you want to change how it is launched.

I recommend that you

1. Click on the networking tab and configure a static ip.
1. Ensure that port 80 HTTP is exposed.

If you have a static ip, you can set up an A record in DNS if you like.

## Testing that it is working

You can try navigating to `http://123.456.789.000` in the browser to see if you can access the `index.html` page. You may be able to request payment by pasting your b58 into the form.

You can try to ask the dev-faucet for its status:

```
curl http://123.456.789.000/status
```

You should get back a json blob.

If the `index.html` page is not working, but `status` is, you may be able to request payment directly using curl.

```
curl http://123.456.789.000/ -d '{"b58_address": "5KBMnd8cs5zPsytGgZrjmQ8z9VJYThuh1B39pKzDERTfzm3sVGQxnZPC8JEWP69togpSPRz3e6pBsLzwnMjrXTbDqoRTQ8VF98sQu7LqjL5"}' -X POST
```

## Building the package

To build the package, start by checking out this repo and building the rust part.

```
git submodule update --recursive
./build_rust.sh
```

Then you can build the package, which produces `package.tar.gz`.

```
./make_package.sh
```

If you want to make a new release, simply tag whatever changes you made and attach `package.tar.gz` to the release.
