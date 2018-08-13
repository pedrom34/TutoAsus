# Install a SSL reverse proxy on an Asus Router with OVH domain

## Menu
0. [What? Why?]()
1. [Install Merlin on the router]()
2. [Activate SSH and JFFS partition]()
3. [Install Entware]()
4. [Setup OVH DynHost on the router]()
5. [Install nginx]()
6. [Setup nginx]()
7. [Get Let's Encrypt certificate]()
8. [Conclusion]()
9. [Sources]()

## 0. What? Why?
An inverse proxy or reverse proxy is a small server that provides access to the user interfaces behind it, for example: camera web interfaces, multimedia servers, Nas, self-hosted calendar or email, etc. The goal is to access other resources from the outside, without having to use a VPN. VPN and reverse proxy are not mutually exclusive as the proxy is useful for web interfaces. In addition, the VPN allows increased security, when using public wifi for instance.  
  
### 0.1. What about security?
The reverse proxy *can be* secrure. One's just have to use a certificate, the connection will be encrypted between the external computer and the proxy. And with Let's Encrypt, it is possible to have a free certificate recognized by browsers and the little green padlock! In addiction, Let's Encrypt launched in 2018 the support for *wildcard* certificates: it is now possible to request a certificate for "\*.domain.com" rather than "pouet.domain.com, pouet2.domain. com, ... ".  
  
### 0.2. Concretely...
I set up this configuration because I have an Asus router - an AC86U - behind my box, it is there to fill the gaps of the box provided by my ISP: custom DNS, firewall and advanced DHCP, VPN server and client, dnsmasq, etc. And this router also allows me to run nginx - which I use as a reverse proxy - and to use a domain name rented from Ovh with my dynamic IP address (DynHost).  
  
I originally did this markdown file to remember what I had done. So why not share?
  
## 1. Install Merlin on the router
The Merlin firmware is a modification of the official Asus firmware. It has the advantage of offering many improvements without removing Asus pleasant graphical interface. It also allows Entware to be used - I'll come back to this a little later.  
Installing Merlin is very simple, just download the firmware from https://asuswrt.lostrealm.ca/download, and flash the file from Administration > Firumware Upgrade.  
There is no real risk in using Merlin, as it is very easy to go back, and reinstall the official firmware.  
  
## 2. Activate SSH et JFFS partition
Once the router is running Merlin, go to Administration > System, and activate the JFFS partition.
>![Interface routeur, activation de JFFS](https://i.imgur.com/ryhJJ6K.png)  
  
Still on the same page, enable SSH access by selecting "LAN Only", the interface will pass in https on port 8443 automatically:  
>![Interface routeur, activation SSH et GUI en https 8443](https://i.imgur.com/nq3UtuH.png)  
  
JFFS is a writeable partition of the router's flash memory, which will allow you to store small files (such as scripts) without the need to have a USB disk connected. This space will survive a reboot. It will also be available quite early on boot (before USB disks). In short, this partition is necessary for what we want to do.  
  
The router's graphical interface, reached with address 192.168.1.1, uses port 80 by default. Except that our reverse proxy will need ports 80 and 443, so we move the GUI to port 8443. The router will be accessible via https://192.168.1.1:8443, freeing ports 80 and 443.  
  
As for SSH access, it will be necessary later, because most of the tutorial will use a terminal and command lines. I personally use [PuTTY](https://www.putty.org/) with Windows.  
  
## 3 Install Entware
[Entware](http://entware.net/about.html) is free software, it is a packet manager for embedded systems, like Nas or routers. It allows to add a lot of softwares normally unavailable, like the nano text editor for example. Entware's advantage in this tutorial is that it allows you to install nginx.
  
### 3.1. Configuring the USB flash drive
Entware requires an EXT2 formatted USB flash drive, connected to the router's USB port. Easy if you have a computer running Linux. Less easy under Windows... The best is to use [MiniTool Partition Wizard Home Edition](https://www.partitionwizard.com/free-partition-manager.html) if your PC is running Windows. Nothing complex: you install the application, right click on its key, delete the partition or partitions already present. Right-click and create an EXT2 partition of at least 2GB. Click ok, and apply.  

### 3.2 Installation of entware
The key plugged in, we connect in SSH to the router with PuTTY, and type:
```shell
entware-setup.sh
```
The terminal will show:
```shell
 Info:  This script will guide you through the Entware installation.
 Info:  Script modifies only "entware" folder on the chosen drive,
 Info:  no other data will be touched. Existing installation will be
 Info:  replaced with this one. Also some start scripts will be installed,
 Info:  the old ones will be saved to .entwarejffs_scripts_backup.tgz

 Info:  Looking for available partitions...
[1] --> /tmp/mnt/sda1
 =>  Please enter partition number or 0 to exit
```
We choose the partition by typing the corresponding digit, and hop. It's over.

## 4. Using Ovh DynHost on your router
As indicated in the introduction, I have an Ovh domain name, and I want to access the different services I host at home, via this address. Problem, I don't have a static ip: if I link pouet.fr to my ip address, at the first ip change, the address will no longer point to my home. So I will create records at Ovh and use my router to update the linked ip address. To do this, you have to do a manipulation at Ovh, and create a script on the router.  
  
### 4.1. Ovh side
In the Ovh client area, go to the domain you want to use, and click on DynHost :one: , then on manage accesses :two:. In the window that opens, you create an access :three:  
- The suffix will be the identifier that we will use in the script: put what you want.  
- The subdomain is used to indicate the extent to which the ip address will be updated. Personally, I use "\*".  
- And finally, a password of your choice that will be used for the script.  
  
Back in the Dynhost window, we click on add a Dynhost :four: and we add current public ip (found on http://myip.dnsomatic.com/ for example). For the subdomain, I personally put nothing, but there is no obligation to do like me.
>![Dynhost Ovh, sous domaines](https://i.imgur.com/snYImlC.png)  
  
>![Dynhost Ovh, création des accès](https://i.imgur.com/AsdDX9m.png)  
  
Finally, last step, we will create as many redirections as there are services you want to access. For that, we go in redirection, and we create a CNAME redirection to the domain dynhost :
>![Redirections Ovh 1](https://i.imgur.com/ILhgyAd.png)
  
>![Redirections Ovh 2](https://i.imgur.com/Umkr7iA.png)
  
>![Redirections Ovh 3](https://i.imgur.com/LFvjVmD.png)
  
>![Redirections Ovh 4](https://i.imgur.com/Unx2Kjl.png)
  
It is also possible to create a wildcard redirect. Just delete the existing CNAME redirections if there are any, then add a CNAME entry in the DNS zone from \*.pouet.fr to pouet.fr  
  
>![Redirection Ovh 5](https://i.imgur.com/0II2GZY.png)  

### 4.2. Router side
In order for the router to update the ip address to which the domain points, you must use the router's DDNS function. By default, a series of suppliers like no-ip is proposed, but not Ovh. So you have to create a personal script. You are lucky, I tested and adapted [one](https://gist.github.com/pedrom34/0bfdf2bb7f2e17a8859c1fad7204d7bf).  
  
We connect to the router via the terminal, and:
```shell
wget https://gist.githubusercontent.com/pedrom34/0bfdf2bb7f2e17a8859c1fad7204d7bf/raw/d92e3c5f87afd6b0870db8a8eb0fd597ec904a7c/asuswrt-ovh-ddns.sh -O /jffs/scripts/ddns-start
``` 
Then we edit the downloaded script.
```shell
vi /jffs/scripts/ddns-start
``` 
We update the identification information of the DynHost Ovh (user & password) that we created in step [4.1.](#41-côté-ovh), as well as the domain (pouet.fr). In vi, simply type "i" to insert text at the cursor position. 
```bash
U=user
P=password
H=domain
```
To exit vi and save the script, press Esc, and type "ZZ" without quotes and in capital letters.
We make the script executable:
```shell
chmod a+x /jffs/scripts/ddns-start
```
And we return in router interface, in WAN and DDNS, we activate DynHost custom:
>![DynHost dans la GUI du routeur](https://i.imgur.com/HbA7ydG.png)  
  
Then we apply and restart.  
Tada! We have a domain name that points to the ip of our router! Even if your IP address changes!  
  
Note that the ddns-start script considers by default that the router is, like mine, double Nated behind an ISP box. If this is not the case, adapt the script by adding "#" before "IP=$(wget..." to line 29 of the script.
