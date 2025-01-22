# Installation  NEW release Erigon [v2.61.0](https://github.com/ledgerwatch/erigon/releases/tag/v2.61.0) + lighthouse [v6.0.1](https://github.com/sigp/lighthouse/tree/v6.0.1) or quick update
![Copy of Copy of Copy of Staking is live](https://github.com/user-attachments/assets/d87dc4fa-1143-4df0-a622-e96d9490d2d7)

## Links
- official Github page Erigon [here](https://github.com/ledgerwatch/erigon)
- official Github page lighthouse [here](https://github.com/sigp/lighthouse)

## Node Specs

|      | Minimum       | Recommended    | Maxed out         |
| :---:|     :---:     |      :---:     |      :---:        |
| CPUs | 16 vcore      | 32 vcore       | 64 vcore          |
| RAM  | 32 G          | 64 GB          | 128 GB            |
| SSD  | 3 TB SATA SSD |5 TB NVME       | 5 TB NVME RAID 10	|
	
## Prerequisites
- Supported OS: Ubuntu 20.04+ (or any systemd-based Linux distro)
- Root or sudo privileges

## Important Note:
The provided script is smart enough to:
- Install Erigon and Lighthouse from scratch if not installed.
- Update to the specified versions if they are already installed.

## Installation from Scratch Erigon v2.61.0 + Lighthouse v6.0.1 (if not installed)
```bash
wget -O erigon_lh_setup.sh https://raw.githubusercontent.com/papadritta/erigon_lighthouse/main/erigon_lh_setup.sh && chmod +x erigon_lh_setup.sh && ./erigon_lh_setup.sh
```

## or
## Update to Erigon v2.61.0 + Lighthouse v6.0.1 (from any version)
>works only if you use installation script above with different version of Erigon & Lighthouse
```bash
wget -O erigon_lh_setup.sh https://raw.githubusercontent.com/papadritta/erigon_lighthouse/main/erigon_lh_setup.sh && chmod +x erigon_lh_setup.sh && ./erigon_lh_setup.sh
```
## Check status & logs
- Erigon
```bash
sudo systemctl status erigon
sudo journalctl -fu erigon
```
- Lighthouse
```bash
sudo systemctl status lighthousebeacon
sudo journalctl -fu lighthousebeacon
```
## Delete Erigon + lighthouse
```bash
wget -O delete.sh https://raw.githubusercontent.com/papadritta/erigon_lighthouse/main/delete.sh && chmod +x delete.sh && ./delete.sh
```
## Do you need a server?
- Use the links with referal programm <a href="https://www.vultr.com/?ref=8997131"><img width="200" src="https://user-images.githubusercontent.com/90826754/200262610-b6251a9b-36a9-44f7-be30-fa691e7238de.png" /></a>
            <a href="https://www.digitalocean.com/?refcode=87b8b298c106&utm_campaign=Referral_Invite&utm_medium=Referral_Program&utm_source=badge"><img src="https://web-platforms.sfo2.cdn.digitaloceanspaces.com/WWW/Badge%201.svg" alt="DigitalOcean Referral Badge" /></a>

**NOTE!: use a referal link & you will get 100$ to your server provider account**

ALL DONE!
