# WPA2 Enterprise

## Type of WPA2 Protocol

### 1. WPA2-PSK

WPA2-PSK (Pre-Shared Key) is generally used in home environment or small business where the WIFI is only protected by a single password and distributed to all users. 

### 2. WPA2-Enterprise

An **802.1X RADIUS server for WiFi authentication** is a necessary component of enterprise network security. Remote Authentication Dial In User Service (RADIUS) secures WiFi by requiring a unique login for each user, as well as recording event logs and applying authorization policies.

### WPA2-Enterprise Authentication Protocols

1. EAP-TLS (Certificate based)
2. EAP-TTLS/PAP (Credential based)
3. PEAP-MSCHAPv2 (Credential based)

---

## Installation

### FreeRadius setup

1. Install `freeradius`

```sh
sudo apt install freeradius
```

2. Setup test user in `/etc/freeradius/3.0/mods-config/files/authorize`

```
testing Cleartext-Password := "password"
```

3. Setup shared secret for AP to connect in `/etc/freeradius/3.0/clients.conf`

```
client <ap-name> {
        ipaddr = <ap-ipaddress>
        secret = <shared-secret> # random password
}
```


### AP setup

General setup flow:

1. Create a new authentication Radius profile.
2. Input the IP of Radius server, port (default 1812), and the shared secret.
3. Create a new WLAN with WPA2 Enterprise. 
4. Use the radius profile setup in #1 & #2. 

---

## Troubleshooting

#### 1. Windows 10 unable to connect to WPA2 Enterprise
Windows is using TLS v1.3 when communicating using EAP protocl. However, it seems like (need more research) freeradius is not supporting TLS v1.3, so the authentication failed. 

**Solution:** Setup `tls_max_version` on freeradius server

`/etc/freeradius/3.0/mods-enabled/eap`:

```toml
tls_max_version = "1.2"
```
