FROM ubuntu:22.04

COPY scripts/copy_so.sh copy_so.sh
COPY _so _so
RUN chmod +x copy_so.sh
RUN ./copy_so.sh
RUN rm copy_so.sh
RUN rm -rf _so

COPY build_release/service_template app/service

RUN chmod +x /app/service

CMD ["app/service", "--config" , "configs/static_config.yaml", "--config_vars",  "configs/config_vars.yaml"]
