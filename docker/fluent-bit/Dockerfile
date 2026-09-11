# Custom Fluent Bit image with configuration files baked in
FROM fluent/fluent-bit:latest

# Copy configuration files
COPY fluent-bit.conf /fluent-bit/etc/fluent-bit.conf
COPY parsers.conf /fluent-bit/etc/parsers.conf
COPY otel_transform.lua /fluent-bit/etc/otel_transform.lua

# Fluent Bit runs as root by default
USER root

# Expose Fluent Bit ports
EXPOSE 2020

CMD ["/fluent-bit/bin/fluent-bit", "-c", "/fluent-bit/etc/fluent-bit.conf"]
