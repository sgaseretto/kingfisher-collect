import logging

from util import read_sql_files


def transform(db, country):
    read_sql_files(country)
    for basename, content in read_sql_files(country).items():
        logging.info(f'Ejecutando query {basename}')
        db.query(content)
    db.commit()


def database_creation(db, country):
    for basename, content in read_sql_files(country, 'migrations').items():
        db.query(content)
    db.commit()
