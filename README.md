# Installation  NEW release Erigon [v3.0.7](https://github.com/erigontech/erigon/releases/tag/v3.0.7) + lighthouse [v7.0.1](https://github.com/sigp/lighthouse/tree/v7.0.1) or quick update
![Copy of Copy of Copy of Staking is live](https://github.com/user-attachments/assets/d87dc4fa-1143-4df0-a622-e96d9490d2d7)

## Table of Contents
- [Links](#links)
- [Node Specs](#node-specs)
- [Check your Node Specs](#check-your-node-specs)
- [Prerequisites](#prerequisites)
- [Installation](#installation-erigon-v2610--lighthouse-v601)
- [Update](#update-to-erigon-v2610--lighthouse-v601)
- [Check Status & Logs](#check-status--logs)
- [Delete Erigon + Lighthouse](#delete-erigon--lighthouse)
- [Do you need a server?](#do-you-need-a-server)
- [FAQ](#faq)
- [Contributing](#Contributing)

## Links
- official Github page Erigon [here](https://github.com/ledgerwatch/erigon)
- official Github page lighthouse [here](https://github.com/sigp/lighthouse)

![Erigon Latest Release](https://img.shields.io/github/v/release/erigontech/erigon?label=Erigon&color=blue)
![Lighthouse Latest Release](https://img.shields.io/github/v/release/sigp/lighthouse?label=Lighthouse&color=blueviolet)
![Test Workflow Status](https://github.com/papadritta/erigon_lighthouse/actions/workflows/test-scripts.yml/badge.svg)

## Node Specs

|      | Minimum       | Recommended    | Maxed out         |
| :---:|     :---:     |      :---:     |      :---:        |
| CPUs | 16 vcore      | 32 vcore       | 64 vcore          |
| RAM  | 32 G          | 64 GB          | 128 GB            |
| SSD  | 3 TB SATA SSD |5 TB NVME       | 5 TB NVME RAID 10	|

![2](https://github.com/user-attachments/assets/75769b81-195b-4310-82d4-5ac8d3afc458)
## Check your Node Specs
>Run this script to be sure that you have meet the min requiment for the following installation
```bash
wget -O check.sh https://raw.githubusercontent.com/papadritta/erigon_lighthouse/main/box/check.sh && chmod +x check.sh && ./check.sh
```

## Prerequisites
- Supported OS: Ubuntu 20.04+ (or any systemd-based Linux distro)
- Root or sudo privileges

## Important Note:
The provided bellow script is smart enough to:
- Install Erigon and Lighthouse from scratch if not installed.
- Update to the specified versions if they are already installed.

## Sync Times:
>The following are estimated sync times for syncing from scratch to the latest block. Actual times may vary depending on your hardware and network bandwidth.

| Chain      | Archive              | Full               | Minimal           |
|------------|----------------------|--------------------|-------------------|
| Ethereum   | 7 Hours, 55 Minutes | 4 Hours, 23 Minutes | 1 Hour, 41 Minutes |

![1](https://github.com/user-attachments/assets/789825b1-937e-44d6-940a-132303a7dd62)
## Installation Erigon + Lighthouse 
>installation on a Fresh Server  
```bash
wget -O erigon_lh_setup.sh https://raw.githubusercontent.com/papadritta/erigon_lighthouse/main/box/erigon_lh_setup.sh && chmod +x erigon_lh_setup.sh && ./erigon_lh_setup.sh
```

## Update Erigon + Lighthouse
>update from any version if you use previous installation script from /archive
```bash
wget -O erigon_lh_setup.sh https://raw.githubusercontent.com/papadritta/erigon_lighthouse/main/box/erigon_lh_setup.sh && chmod +x erigon_lh_setup.sh && ./erigon_lh_setup.sh
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
wget -O delete.sh https://raw.githubusercontent.com/papadritta/erigon_lighthouse/main/box/delete.sh && chmod +x delete.sh && ./delete.sh
```
## Do you need a server?

<a href="https://www.vultr.com/?ref=8997131"><img width="200" src="https://user-images.githubusercontent.com/90826754/200262610-b6251a9b-36a9-44f7-be30-fa691e7238de.png" /></a>

<a href="https://www.digitalocean.com/?refcode=87b8b298c106&utm_campaign=Referral_Invite&utm_medium=Referral_Program&utm_source=badge"><img src="https://web-platforms.sfo2.cdn.digitaloceanspaces.com/WWW/Badge%201.svg" alt="DigitalOcean Referral Badge" /></a>

**NOTE!: use a referal link & you will get 100$ to your server provider account**

## FAQ
- **Q: Can I install this on a server with less than the minimum specs?**  
  **A**: It is not recommended as performance will be significantly degraded.

- **Q: How do I verify the installation?**  
  **A**: Use `sudo systemctl status erigon` and `sudo systemctl status lighthousebeacon` to check the services.

- **Q: Can I run the node on a virtual machine (VM)?**  
  **A**: Yes, but ensure the VM meets the minimum specs for optimal performance.

- **Q: How do I stop the services temporarily?**  
  **A**: Use `sudo systemctl stop erigon` and `sudo systemctl stop lighthousebeacon` to stop the services.

- **Q: How can I restart the services after an update?**  
  **A**: Use `sudo systemctl restart erigon` and `sudo systemctl restart lighthousebeacon`.

- **Q: Still have questions?**  
  **A**: Ask in the [FAQ Discussions section](https://github.com/papadritta/erigon_lighthouse/discussions).

## Contributing
We welcome contributions from the community! To get started, see [CONTRIBUTING.md](https://github.com/papadritta/erigon_lighthouse/blob/main/CONTRIBUTING.md).

For ideas or feedback, participate in the [Discussions tab](https://github.com/papadritta/erigon_lighthouse/discussions).


ALL DONE!


