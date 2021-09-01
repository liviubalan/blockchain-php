# liviubalan/blockchain-php

This repo is used for educational purpose only and should not be used on a production environment.
The purpose is to understand how
[Blockchain](https://en.wikipedia.org/wiki/Blockchain) works using the technologies that currently build and maintain
[eMAG](https://www.emag.ro/).

You can run this project on:
1. `local` environment (with [Vagrant](https://en.wikipedia.org/wiki/Vagrant_(software)) to create one or multiple
[VM](https://en.wikipedia.org/wiki/Virtual_machine))
2. `OpenStack EOS` machine. Here you will have to be an eMAG web developer with access on
[OpenStack](https://en.wikipedia.org/wiki/OpenStack) EOS

## Requirements

### 1. localhost

In order to run this project on your machine you have to install the following packages:

* [Git](https://git-scm.com/). Checkout
[Git install on Ubuntu Server](https://www.liviubalan.com/git-install-on-ubuntu-server) for more details
* [VirtualBox](https://www.virtualbox.org/). Checkout
[Install VirtualBox on Linux Mint using CLI](https://www.liviubalan.com/install-virtualbox-on-linux-mint-using-cli)
for more details
* [Vagrant](https://www.vagrantup.com/). Checkout
[Vagrant Install on Linux Mint/Ubuntu Desktop](https://www.liviubalan.com/vagrant-install-on-linux-mintubuntu-desktop)
for more details

**Note:** This project was tested on a host machine using an Ubuntu based Linux distribution
([Linux Mint](https://en.wikipedia.org/wiki/Linux_Mint) / [Ubuntu Desktop](https://en.wikipedia.org/wiki/Ubuntu_(operating_system))).

### 2. OpenStack EOS

A web browser (such as [Google Chrome](https://en.wikipedia.org/wiki/Google_Chrome)) and an SSH client will be enough.

## Installation

### 1. localhost

After the [Requirements](https://github.com/liviubalan/blockchain-php#1-localhost) section is checked, open a
[console](https://en.wikipedia.org/wiki/Command-line_interface) and follow this steps:

1. Clone the [GitHub](https://github.com/liviubalan/blockchain-php) main project. To clone the project to
`blockchain-php` use:

    ```bash
    git clone git@github.com:liviubalan/blockchain-php.git blockchain-php
    ```

2. Clone the [GitHub](https://github.com/liviubalan/blockchain-php) temporary project. This will help you to follow the
project during the course without typing any line of code but be able to see the changes in your PhpStorm IDE. Remember
that this directory is temporary so do not rely on its content.  To clone the project to `blockchain-php-2` use:

    ```bash
    git clone git@github.com:liviubalan/blockchain-php.git blockchain-php-2
    ```

3. Generate `follow.sh` by following the wizard. For this follow the steps after running:

    ```bash
    cd blockchain-php/
    bash bash/follow/wizard.sh
    ```

4. Move to a specific step (starting from **1**). For example, in order to move to the 2nd step use:

    ```bash
    bash follow.sh 2
    ```

5. *Optional.* If you haven't set your hostname via [DNS](https://en.wikipedia.org/wiki/Domain_Name_System) you need to
edit your host operating system [hosts file](https://en.wikipedia.org/wiki/Hosts_(file)) (more info on
[Ubuntu Linux hosts file](https://www.liviubalan.com/ubuntu-linux-hosts-file)) and map the machine
[IP](https://en.wikipedia.org/wiki/Internet_Protocol) on the hostname. Your host operating system
[hosts file](https://en.wikipedia.org/wiki/Hosts_(file)) should look something like:

    ```bash
    192.168.33.11 node1.net
    192.168.33.12 node2.net
    192.168.33.13 node3.net
    192.168.33.14 node4.net
    192.168.33.15 node5.net
    ```

6. *Optional.* If you're using [Vagrant](https://en.wikipedia.org/wiki/Vagrant_(software)) you have to create and
configure the [VM](https://en.wikipedia.org/wiki/Virtual_machine) guest machine (more info on
[Vagrant Install ubuntu-precise32 and ubuntu-trusty32 on Linux Mint/Ubuntu Desktop](https://www.liviubalan.com/vagrant-install-ubuntu-precise32-and-ubuntu-trusty32-on-linux-mintubuntu-desktop)).
For this type:

    ```bash
    vagrant up
    ```

7. *Optional.* If you've followed step 5 and 6 above you can now connect to the
[VM](https://en.wikipedia.org/wiki/Virtual_machine) using:

    ```bash
    vagrant ssh
    ```

    On the Vagrant multi machine setup you will have to specify the node that you want to connect to:

    ```bash
    vagrant ssh node1
    ```

8. *Optional.* If you've using [Vagrant](https://en.wikipedia.org/wiki/Vagrant_(software)) you can destroy the
[VM](https://en.wikipedia.org/wiki/Virtual_machine) by typing:

    ```bash
    vagrant destroy -f
    ```

   Remember that this command only destroys the [VM](https://en.wikipedia.org/wiki/Virtual_machine). If you want to
   set your environment to a clean state you will have to recreate the project or reset it to a specific state using
   `git reset`.

9. *Optional.* To speed up the [VM](https://en.wikipedia.org/wiki/Virtual_machine) management after you create it you
can use `vagrant provision`:

    ```bash
    vagrant provision
    ```

10. If you're using [Symfony](https://symfony.com/) run `composer install` before accessing the domain:

    ```bash
    cd www/
    php -d memory_limit=-1 composer.phar install
    ```

### 2. OpenStack EOS

1. Change the current working directory to `/var/www/`:

    ```bash
    cd /var/www/
    ```

2. Clone the [GitHub](https://github.com/liviubalan/blockchain-php) main project to `blockchain.emag`:

    ```bash
    git clone git@github.com:liviubalan/blockchain-php.git blockchain.emag
    ```

3. Clone the [GitHub](https://github.com/liviubalan/blockchain-php) temporary project. This will help you to follow the
   project during the course without typing any line of code but be able to see the changes in CLI. Remember that this 
   environment is CLI only so you will not be able to see the changes in PhpStorm IDE. Use `git diff` instead. Remember
   that this directory is temporary so do not rely on its content.  To clone the project to `blockchain.emag-2` use:

    ```bash
    git clone git@github.com:liviubalan/blockchain-php.git blockchain.emag-2
    ```

4. Setup environment by running `open-stack.sh`. For this follow the steps after running:

    ```bash
    cd blockchain.emag/
    bash bash/follow/open-stack.sh
    ```

5. Generate `follow.sh` by following the wizard. For this follow the steps after running:

    ```bash
    bash bash/follow/wizard.sh
    ```

6. Move to a specific step (starting from **1**). For example, in order to move to the 2nd step use:

    ```bash
    bash follow.sh 2
    ```

7. If you're using [Symfony](https://symfony.com/) run `composer install` before accessing the domain:

    ```bash
    cd www/
    php -d memory_limit=-1 composer.phar install
    ```

## Resources

* https://medium.com/@essentia1/50-examples-of-how-blockchains-are-taking-over-the-world-4276bf488a4b
* https://en.wikipedia.org/wiki/Bitcoin
* https://en.wikipedia.org/wiki/Ethereum
* https://github.com/bitcoin/bitcoin
* https://github.com/ethereum
* https://en.wikipedia.org/wiki/Blockchain
* https://github.com/liviubalan/blockchain-php
* https://github.com/liviubalan/blockchain-php-v1
* https://github.com/liviubalan/blockchain-php
* https://linuxconfig.org/how-to-check-centos-version
* https://app.vagrantup.com/bento/boxes/centos-7
* https://www.digitalocean.com/community/tutorials/how-to-install-git-on-centos-7
* https://serverfault.com/questions/442088/how-do-you-answer-yes-for-yum-install-automatically
* https://www.digitalocean.com/community/tutorials/how-to-install-linux-nginx-mysql-php-lemp-stack-on-centos-7
* https://stackoverflow.com/questions/60241148/linux-shell-su-c-sed-command
* https://linuxhint.com/replace_string_in_file_bash/
* https://phoenixnap.com/kb/how-to-set-up-nginx-server-blocks-virtual-hosts-centos-7
* https://www.digitalocean.com/community/tutorials/how-to-set-up-nginx-server-blocks-on-centos-7
* https://stackoverflow.com/questions/32087679/vagrant-and-synced-folders-how-to-set-the-owner-to-a-user-other-than-the-defaul
* https://github.com/hashicorp/vagrant/issues/936
* https://symfony.com/doc/4.4/setup.html
* https://stackoverflow.com/questions/38793676/php-xml-extension-not-installed
* https://symfony.com/doc/4.4/setup/web_server_configuration.html
* https://phoenixnap.com/kb/how-to-set-up-nginx-server-blocks-virtual-hosts-centos-7
* https://stackoverflow.com/questions/60241148/linux-shell-su-c-sed-command
* https://www.milesweb.com/hosting-faqs/service-nginx-restart-fails/
* https://stackoverflow.com/questions/41766195/nginx-emerg-server-directive-is-not-allowed-here
* https://www.digitalocean.com/community/tutorials/how-to-set-up-nginx-server-blocks-on-centos-7
* https://www.cyberciti.biz/faq/fedora-redhat-scientific-linuxenable-bash-completion/
* https://serverfault.com/questions/558936/how-to-accurately-check-if-package-is-installed-in-yum/558943
* https://chrome.google.com/webstore/detail/json-formatter/bcjindcccaagfpapjjmafapmmgkkhgoa?hl=en
* https://en.wikipedia.org/wiki/JSON
* https://en.wikipedia.org/wiki/Cryptographic_nonce
* https://en.wikipedia.org/wiki/Cryptographic_hash_function
* https://www.php.net/manual/en/function.md5.php
* https://www.php.net/manual/en/function.sha1.php
* https://www.php.net/manual/en/function.crc32.php
* https://www.php.net/manual/en/function.hash.php
* https://www.php.net/manual/en/function.var-dump.php
* https://en.wikipedia.org/wiki/Proof_of_work
* https://en.bitcoin.it/wiki/Genesis_block
