# Custom OpenTelemetry Collector image with config baked in
FROM otel/opentelemetry-collector-contrib:latest

# Copy configuration file
COPY otel-collector-config.yaml /etc/otel-collector-config.yaml


CMD ["--config=/etc/otel-collector-config.yaml"]
