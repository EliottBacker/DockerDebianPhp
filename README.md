# Docker Debian Apache + PHP
This image allows to get Apache and PHP running on Docker.

# Usage
## Getting image from a registry
To pull an image from a registry, simply start the container using the following command:
```
docker pull eliottbacker/debian-php
```

## Getting it running
To run apache in a background process, simply start the container using the following command:
```
docker run -p 8080:80 -d debian-php
```

If you’re actively developing and you want to be able to change files in your usual editor and have them reflected within the container without having to rebuild it. The -v flag allows us to mount a directory from the host into the container:
```
docker run -d -p 8080:80  -v `pwd`/www::/var/www/html debian-php
```

Please report any issues with the Docker container to https://github.com/EliottBacker/DockerDebianPhp/issues
