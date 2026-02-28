option task = {name: "new-device-detection", every: 5m}

// Grace period: skip task if we have less than 48h of data
dataAge = (from(bucket: "netflow")
  |> range(start: -48h)
  |> count()
  |> findRecord(fn: (key) => true, idx: 0))._value

// Only run if we have established baseline data
if dataAge > 0 then
  // Step 1: IPs seen in the last 5 minutes
  recentIPs = from(bucket: "netflow")
    |> range(start: -5m)
    |> filter(fn: (r) => r._measurement == "netflow")
    |> keep(columns: ["source_ipv4_address"])
    |> distinct(column: "source_ipv4_address")
    |> filter(fn: (r) =>
        not strings.hasPrefix(v: r._value, prefix: "172.18.") and
        not strings.hasPrefix(v: r._value, prefix: "10.") and
        not strings.hasPrefix(v: r._value, prefix: "192.168."))

  // Step 2: IPs seen in the historical window (excludes last 5 minutes)
  historicalIPs = from(bucket: "netflow")
    |> range(start: -24h, stop: -5m)
    |> filter(fn: (r) => r._measurement == "netflow")
    |> keep(columns: ["source_ipv4_address"])
    |> distinct(column: "source_ipv4_address")

  // Step 3: Anti-join — find new IPs not in historical window
  newDevices = join(
    tables: {recent: recentIPs, hist: historicalIPs},
    on: ["source_ipv4_address"],
    method: "left"
  )
    |> filter(fn: (r) => not exists r._value_hist)
    |> map(fn: (r) => ({
        _time: now(),
        _measurement: "netflow_new_devices",
        source_ipv4_address: r.source_ipv4_address,
        _field: "new_device",
        _value: 1
    }))
    |> to(bucket: "netflow", org: "homelab")
else
  // Not enough data yet — write nothing
  array.from(rows: [{}]) |> filter(fn: (r) => false)
