# Regis [![master branch:](https://travis-ci.org/Lin777/ESUGConfRegistrationApp.svg?branch=master)](https://travis-ci.org/Lin777/ESUGConfRegistrationApp/branches)

Regis is Web application for managing ESUG conference registrations.

## Installation 

### Prerequisites

- Latest Pharo 7 image
- Pharo VM for Pharo 7

You can get both by downloading it from the [Pharo](http://pharo.org) site or in the command line with [zeroconf](http://get.pharo.org): 

```bash
wget -O- get.pharo.org | bash
```

To load the ESUGApp package into the Pharo image:

```Smalltalk
Metacello new
 baseline:'ESUGApp';
 repository: 'github://Lin777/ESUGConfRegistrationApp:master/src';
 load.
 
ESUGSetUp start
```

You can see the application run in: http://localhost:8000/ESUG

Admin credentials:

email: admin@esug.org
password: 12345678

### Testing Data

To automatically register attendees and group managers execute the following script after installation and initialization of the project (review previous script)

```Smalltalk
ERTest generateDataForTest 
```

This scripts fill the website with contrived information for testing purpose.
You can see the registered users by logging in as admin. 

All the users generated automatically have as password: 12345678

## Deploy with Docker

See documentation in [Docker/README.md](Docker/README.md)
