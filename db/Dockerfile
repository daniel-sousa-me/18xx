FROM postgres:13.1

RUN useradd --uid 33 --user-group --create-home --home-dir /home/db db

RUN chown www-data:www-data /var/lib/postgresql/data && \
    chown www-data:www-data /var/run/postgresql

USER www-data:www-data

COPY ./postgresql.conf /etc/postgresql/postgresql.conf

CMD ["postgres", "-c", "config_file=/etc/postgresql/postgresql.conf"]
