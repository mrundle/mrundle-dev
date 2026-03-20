function get_timestamp {
    # ISO 8601 format, e.g. 2026-03-02T09:46:40-06:00
    return Get-Date -UFormat "%Y-%m-%dT%H:%M:%S%Z:00"
}
echo "example timestamp: $(get_timestamp)"
