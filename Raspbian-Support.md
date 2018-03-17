
# Raspbian Stretch

This project supports Python 3.6 which at this time (March 2018)
isn't the default installation of Python 3 on Raspbian. If
you wish to use the Python module on a Raspberry Pi using the
current release of Raspbian you'll need to upgrade your Python.
Below are the steps I took to do compile and install 3.6.4 in
my home directory.  Your milleage may very.  Hopefully in an 
upcoming Raspbian release 3.6 will become the default and 
these instructions can go away.

```shell
    sudo apt-get install build-essential checkinstall
    sudo apt-get install libreadline-gplv2-dev libncursesw5-dev libssl-dev libsqlite3-dev tk-dev libgdbm-dev libc6-dev libbz2-dev
```

Download the Python 3.6.4 sources

```
    mkdir -p $HOME/src
    cd $HOME/src
    wget https://www.python.org/ftp/python/3.6.4/Python-3.6.4.tgz
    tar zxvf Python-3.6.4.tgz
    cd Python-3.6.4
    bash configure --prefix=$HOME
    make altinstall
```

The following were based on a [gist](https://gist.github.com/dschep/24aa61672a2092246eaca2824400d37f)
