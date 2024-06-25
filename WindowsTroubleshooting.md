# Windows Troubleshooting

## Active Directory, DNS, and Troubleshooting

### Active Directory FSMO Roles (IMPORTANT)

#### Schema
- The schema cannot be extended. However, in the short term, no one will notice a missing Schema Master unless you plan a schema upgrade during that time.

#### Domain Naming 
- Unless you are going to run DCPROMO, then you will not miss this FSMO role.

#### RID
- Chances are good that the existing DCs will have enough unused RIDs to last some time, unless you're building hundreds of users or computer objects per week.

#### PDC Emulator
- Will be missed soon. NT 4.0 BDCs will not be able to replicate, there will be no time synchronization in the domain, you will probably not be able to change or troubleshoot group policies, and password changes will become a problem.

### Infrastructure
- Group memberships may be incomplete. If you only have one domain, then there will be no impact.

**Question: Which FSMO role is the most important, and which is the least important?**
The most important FSMO role is the PDC Emulator, as it is responsible for password changes, group policy application, and time synchronization in the domain. The least important FSMO role is the Domain Naming FSMO, as it is only needed when you run DCPROMO to create a new domain.

**Question: Do you know how authentication works in an Active Directory?**
A: When a user tries to authenticate, the following happens:
1. The user's credentials (username and password) are sent to a domain controller.
2. The domain controller checks the user's account information, including the user's security identifier (SID), group memberships, and any other relevant access rights.
3. If the credentials are valid, the domain controller generates an access token for the user. This token contains the user's SID and group information.
4. The access token is then used by other resources (like file servers) to grant the user the appropriate permissions to access those resources.

**Question: User accounts are not getting locked out, you noticed this in the logs, that over 100 attempts to log in to the username john. What do you think could be causing the user accounts to not get locked out?**
A: The security group policy that is responsible for setting the account lockout policy has likely not been configured correctly.

**Question: What ports are used for Kerberos?**
A: Kerberos uses port 88. LDAPS (Secure LDAP) uses port 636, and normal LDAP is 389.

**Question: How to check DC health?**
A: The `dcdiag` command-line tool can be used to check the health of domain controllers.

**Question: When to Seize and when to transfer FSMO roles?**
A: 
- Transfer roles when all DCs are running
- Seize roles when there is a physical hardware failure or a DC is not booting/accessible

**Question: How do you seize FSMO roles?**
A: 
- Using the `ntdsutil` command-line tool:
  1. Open an elevated command prompt and run `ntdsutil`.
  2. At the `ntdsutil` prompt, type `roles` to enter the FSMO role management interface.
  3. Type `connections` and then `connect to server <server_name>` to connect to the domain controller.
  4. Type `label <role_name>` to seize the desired FSMO role.
- Using PowerShell and the `Move-ADDirectoryServerOperationMasterRole` cmdlet:
  `Move-ADDirectoryServerOperationMasterRole -Identity "ChildDC1" -RIDMaster`

**Question: How to check replication health?**
A: Use the `repadmin` command-line tool. Some useful commands include:
- `repadmin /showrepl` - Displays replication metadata for a domain controller.
- `repadmin /syncall` - Forces replication between all domain controllers.
- `repadmin /replsum` - Provides a summary of replication activity.
- `repadmin /showsites` - Lists the sites in the forest and their domain controllers.

**Question: What happens if the PDC Emulator stops working?**
A: If the PDC Emulator stops working, the following issues will occur:
1. Authentication will stop working, as the PDC Emulator is responsible for handling password changes and replicating that information to other domain controllers.
2. Time synchronization in the domain will stop, as the PDC Emulator is the authoritative time source.
3. Group policy application and troubleshooting will become problematic, as the PDC Emulator plays a critical role in those processes.

### DNS
**Question: What protocols does DNS use?**
A: DNS uses UDP, TCP, and HTTPS. In most cases, customers use DNS with UDP, but it does use TCP for things like zone transfers or if the request size is larger than 512 bytes. The latest and newly released protocol is HTTPS for secure DNS (ISP can't see which sites you're requesting).

**Question: How does DNS work, and what are all the caches in the OS and browser?**
A: When you type `www.amazon.com` in your web browser, the process is as follows:
1. The browser parses the request.
2. The browser looks in its history cache to see if the address is listed.
3. The browser determines whether it's a search term or a URL (uniform resource locator) request.
   - If it's a search term, the browser does a search.
   - If it's a URL, the browser starts the process to visit the page typed.
4. The browser determines the protocol (HTTP or HTTPS).
5. The browser looks up the IP address using DNS. If no local record is found (not in the hosts file), the request is passed on to the default gateway (router).
6. The router receives the packet, performs network address translation (NAT), and sends the information to the destination server.
7. The destination server receives the DNS request and responds with the information requested.
8. A TCP connection is established (which port?).

**Question: Do you know any DNS records that are essential for email servers to function?**
A: The essential DNS records for email servers include MX, CNAME (for autodiscover), A (for the exchange or mail server), SPF, and DKIM.

**Question: What is an iterative lookup?**
A: An iterative lookup is performed by DNS servers, where they look up the answer one hop at a time.

**Question: What is a recursive lookup?**
A: A recursive lookup is performed by clients (laptops or devices), where the client relies on a DNS server to provide the final answer.
https://www.cloudflare.com/learning/dns/what-is-recursive-dns/

**Question: Why do we use DNS forwarders?**

### General Troubleshooting
You should be familiar with network troubleshooting tools (telnet, test-netconnection, tracert, PowerShell: Resolve-DNSName, tracetcp, iperf, ntttcp, dig, and packet capture tools), as well as Windows troubleshooting tools (WinDbg, Windows Sysinternals, perfmon).

**What is a CIDR range?**

**IIS**: Basic understanding of how to set up a website and get multi-https sites running using SNI.

**Troubleshooting when things do not work as intended (i.e., OS not booting, black screen, blue screen)**: How to find the root cause of why it is not booting. (What if restore from backup is not a solution type thinking.)

**If you have a web application that throws an HTTP code 500, what does this mean, and how do you troubleshoot this?**

**System Crash Dumps (BSOD)**: Exception codes & Dumps (Location of memory dumps)

**Offline Registry Modification**: Re-enable Remote Desktop, Change RDP Port, Disable Firewall, Enable DHCP

**General Windows Troubleshooting**

### Troubleshooting Scenarios
- EC2 Domain controller not replicating a GPO to secondary DC
- Windows time issues on Domain Controller (EC2)
- RDP to Windows fails after doing a sysprep
- RDP connectivity issues (Failed network card driver - how to offline driver inject)

### Performance Troubleshooting (IMPORTANT)
- Using perfmon to get disk IOPS, CPU, Mem, and doing data collection sets
- WPR/WPA

### Remote Administration
- Using Remote Desktop for Management
- Server Manager
- PSEXEC
- PSREMOTING

### Networking
- TCP 3-way handshake
- Wireshark: https://www.comptia.org/content/articles/what-is-wireshark-and-how-to-use-it
- What is a stateful firewall?
  https://docs.aws.amazon.com/network-firewall/latest/developerguide/firewall-rules-engines.html
- ICMP
- ARP
- DNS
  - Address Resolution Mechanism: http://en.wikipedia.org/wiki/Domain_Name_System#Address_resolution_mechanism
  - Using DNS with Your VPC: http://docs.aws.amazon.com/AmazonVPC/latest/UserGuide/vpc-dns.html
- DHCP settings
  - DHCP Options Sets: http://docs.aws.amazon.com/AmazonVPC/latest/UserGuide/VPC_DHCP_Options.html
- Configure NAT in VPC
  - NAT Instances: http://docs.aws.amazon.com/AmazonVPC/latest/UserGuide/VPC_NAT_Instance.html

### Storage (Optional)
- Disk, partitions, volumes
  - https://docs.microsoft.com/en-us/windows/win32/fileio/disk-devices-and-partitions
  - https://docs.microsoft.com/en-us/troubleshoot/windows-server/backup-and-storage/support-policy-4k-sector-hard-drives
- NTFS
  - https://docs.microsoft.com/en-us/windows-server/storage/file-server/ntfs-overview
  - https://docs.microsoft.com/en-us/windows-server/storage/storage
- RAID 1, 0, 10, and 5
- NTFS vs FAT
- MBR vs GPT
- iSCSI on Storage Spaces

### Memory Dumps (IMPORTANT)
There are majorly 4 types of memory dumps that can be configured and captured on Windows OS:
- Minidump (mostly useless)
- Kernel dump (captures details of drivers and their threads loaded in kernel)
- Complete dump (captures both user and kernel mode)
- Active memory dump (captures only the memory loaded at the time, requires less disk space)

Active memory dump is most helpful in hang and unresponsive OS scenarios. Memory dumps make the most sense with symbols and complete context of the issue.

### Process Dump
Process Dump is helpful when you know a particular process on the OS is terminating, crashing, or hanging. It can capture these scenarios, but it only captures user mode data.
https://docs.microsoft.com/en-us/sysinternals/downloads/procdump

### Process Explorer
Process Explorer is a live debugging tool that can be used to see what's causing CPU interrupts or why a process is exiting.
https://docs.microsoft.com/en-us/sysinternals/downloads/process-explorer

### RAMMap and VMMap
- RAMMap: Used to see what's eating up physical memory.
  https://docs.microsoft.com/en-us/sysinternals/downloads/rammap
- VMMap: Used to see what's loaded on the OS virtual memory.
  https://docs.microsoft.com/en-us/sysinternals/downloads/vmmap

These tools are helpful on older versions of Windows to troubleshoot slowness or high memory consumption issues.

### ProcMon (IMPORTANT)
ProcMon can be used to dig deep into a process's permissions, file locations, and details like the number of open handles, process activity, and resources it touched.
https://docs.microsoft.com/en-us/sysinternals/downloads/procmon

There are many tools for troubleshooting Windows. The key is to isolate issues, ask questions to funnel down to a handful of possibilities, and then go for data capture.

### Useful Links
- Log files: https://docs.microsoft.com/en-us/windows/deployment/upgrade/log-files
- What is SFC: https://docs.microsoft.com/en-us/troubleshoot/windows-server/deployment/system-file-checker
- CBS logs show files weren't repaired: https://docs.microsoft.com/en-us/troubleshoot/windows-server/deployment/cbs-log-file-record-entries-not-repaired-run-sfc
- DISM and Checksur: https://docs.microsoft.com/en-us/windows-hardware/manufacture/desktop/dism---deployment-image-servicing-and-management-technical-reference-for-windows
- WMI: https://docs.microsoft.com/en-us/windows/win32/wmisdk/wmi-troubleshooting
- DCOM: https://techcommunity.microsoft.com/t5/ask-the-performance-team/wmi-troubleshooting-permissions/ba-p/372496
- WinRM: https://docs.microsoft.com/en-us/windows/win32/winrm/installation-and-configuration-for-windows-remote-management
- PS Remoting: https://docs.microsoft.com/en-us/powershell/module/microsoft.powershell.core/enable-psremoting?view=powershell-7.1
- WMF: https://docs.microsoft.com/en-us/powershell/scripting/windows-powershell/wmf/overview?view=powershell-7.1

### SQL Cluster (Super Extra Optional)
- What is Failover Cluster Manager and why use it?
  https://docs.microsoft.com/en-us/windows-server/failover-clustering/failover-clustering-overview
- How to create a two-node cluster (Optional but nice to know):
  https://docs.microsoft.com/en-us/windows-server/failover-clustering/create-failover-cluster
