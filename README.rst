|Build Status| |Coverage Status|

Kingfisher Collect is a tool for downloading OCDS data and storing it on disk and/or sending it to an instance of `Kingfisher Process <https://kingfisher-process.readthedocs.io/>`_ for processing.

(If you are viewing this on GitHub, open the `full documentation <https://kingfisher-collect.readthedocs.io/>`__ for additional details.)

.. |Build Status| image:: https://github.com/open-contracting/kingfisher-collect/workflows/CI/badge.svg
.. |Coverage Status| image:: https://coveralls.io/repos/github/open-contracting/kingfisher-collect/badge.svg?branch=master
   :target: https://coveralls.io/github/open-contracting/kingfisher-collect?branch=master


### Levantar con docker

- Hacer una copia del archivo .env_sample y llamarlo .env, seteando los valores de las variables de entorno
- docker-compose build
- docker-compose up -d

La primera vez todas las tablas serán creadas y los datos de Paraguay será poblados desde el 2010 hasta la fecha de
ejecución. Luego quedará el scheduler configurado actualizando los datos cada EMPATIA_ETL_SCHEDULER_HOURS_PARAGUAY horas.
