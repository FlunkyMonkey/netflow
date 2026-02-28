# Netflow Schema

_Discovered: 2026-02-28 via live data from softflowd on Proxmox nodes_

## Measurement: `netflow`

### Tags (indexed, low-cardinality)

| Tag | Example | Description |
|-----|---------|-------------|
| `source` | `172.18.1.10` | Exporter IP (Proxmox node sending Netflow) |
| `version` | `NetFlowV9` | Netflow protocol version |
| `host` | `telegraf-ff494cf55-7mlhp` | Telegraf pod hostname |

### Fields (not indexed)

| Field | Type | Description |
|-------|------|-------------|
| `src` | string | Source IP address of flow |
| `dst` | string | Destination IP address of flow |
| `src_port` | int | Source TCP/UDP port |
| `dst_port` | int | Destination TCP/UDP port |
| `in_bytes` | int | Bytes in flow |
| `in_packets` | int | Packets in flow |
| `protocol` | int | IP protocol number (6=TCP, 17=UDP, 1=ICMP) |
| `direction` | int | Flow direction |
| `ip_version` | int | IP version (4 or 6) |
| `tcp_flags` | int | TCP flags bitmask |
| `src_tos` | int | Type of service / DSCP |
| `in_snmp` | int | Input interface SNMP index |
| `out_snmp` | int | Output interface SNMP index |
| `first_switched` | int | First packet timestamp (ms since boot) |
| `last_switched` | int | Last packet timestamp (ms since boot) |
| `flow_end_reason` | int | Reason flow ended |
| `icmp_type` | int | ICMP type (ICMP flows only) |
| `icmp_code` | int | ICMP code (ICMP flows only) |

### DNS Enrichment Fields (added by reverse_dns processor)

| Field | Type | Description |
|-------|------|-------------|
| `src_host` | string | Reverse DNS hostname for `src` IP |
| `dst_host` | string | Reverse DNS hostname for `dst` IP |

## Notes

- `src` and `dst` are **fields** (not tags) — avoid grouping by them for high-cardinality queries
- `source` (tag) = exporter Proxmox node IP; `src` (field) = IP observed in the flow packet
- Exporter IPs: `172.18.1.10` (prox1), `172.18.1.20` (prox2), `172.18.1.30` (prox3),
  `172.18.1.40` (prox4), `172.18.1.50` (prox5)
- `externalTrafficPolicy: Local` required on Telegraf Service to preserve source IP through MetalLB
- DNS enrichment TTL: 5 minutes; lookups via 172.18.232.10 and 172.18.5.10
