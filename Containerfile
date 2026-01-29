# Use official Hive image to get a working hiveutil binary
FROM quay.io/openshift-hive/hive:715614a9f3 AS source

# Runtime image
FROM registry.access.redhat.com/ubi9/ubi-minimal:latest

LABEL name="hiveutil" \
      summary="OpenShift Hive utility tool" \
      description="hiveutil is a CLI tool for interacting with OpenShift Hive" \
      url="https://github.com/openshift/hive" \
      vendor="Red Hat, Inc."

# Copy the hiveutil binary from the official image
COPY --from=source /usr/bin/hiveutil /usr/local/bin/hiveutil

# Create non-root user for security
RUN microdnf install -y shadow-utils \
    && useradd -r -u 1001 -g 0 hive \
    && microdnf remove -y shadow-utils \
    && microdnf clean all \
    && rm -rf /var/cache/yum

# Set up home directory with proper permissions
ENV HOME=/home/hive
RUN mkdir -p /home/hive \
    && chown -R 1001:0 /home/hive \
    && chmod -R g=u /home/hive

USER 1001

ENTRYPOINT ["/usr/local/bin/hiveutil"]
