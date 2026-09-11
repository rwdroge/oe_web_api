function add_otel_timestamp(tag, timestamp, record)
    -- Convert Fluent Bit timestamp to OpenTelemetry format (nanoseconds since epoch)
    local otel_timestamp = timestamp * 1000000000
    
    -- Add OpenTelemetry specific fields
    record["observedTimeUnixNano"] = otel_timestamp
    record["timeUnixNano"] = otel_timestamp
    
    -- Map severity level to OpenTelemetry severity number
    local severity_map = {
        TRACE = 1,
        DEBUG = 5,
        INFO = 9,
        WARN = 13,
        ERROR = 17,
        FATAL = 21
    }
    
    if record["level"] then
        local level_upper = string.upper(record["level"])
        record["severityNumber"] = severity_map[level_upper] or 0
        record["severityText"] = level_upper
    end
    
    -- Create log body from message
    if record["message"] then
        record["body"] = record["message"]
    end
    
    return 2, timestamp, record
end
