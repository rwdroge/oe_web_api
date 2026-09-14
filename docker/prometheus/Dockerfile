# Custom Prometheus image with config baked in
FROM prom/prometheus:main

# Copy configuration file
COPY prometheus.yml /etc/prometheus/prometheus.yml

USER nobody

CMD ["--config.file=/etc/prometheus/prometheus.yml", \
     "--storage.tsdb.path=/prometheus", \
     "--storage.tsdb.retention.time=30d", \
     "--web.enable-lifecycle"]
