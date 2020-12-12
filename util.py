import glob
import os
from datetime import datetime, timedelta

import dataset


def get_database(settings):
    args = settings.get('PG_PIPELINE', {})
    return dataset.connect(args.get('connection'))


def get_last_date(spidercls, database):
    last_date = database.query(f'SELECT max(release_date) as date from {spidercls.schema}.procurement').next()['date']
    if not last_date:
        last_date = datetime. strptime('2010-01-01T00:00:00', spidercls.VALID_DATE_FORMATS[spidercls.date_format])
    if spidercls.schema == 'colombia':
        last_date = last_date + timedelta(days=1)
    else:
        last_date = last_date + timedelta(seconds=1)
    return last_date.strftime(spidercls.VALID_DATE_FORMATS[spidercls.date_format])


def read_sql_files(country, folder='transform'):
    """
    Returns a dict in which keys are the basenames of SQL files and values are their contents.
    :param text country: directory from where run the queries
    """
    contents = {}
    path = os.path.join(os.path.dirname(os.path.realpath(__file__)), folder, country, '*.sql')
    filenames = glob.glob(path)
    for filename in sorted(filenames):
        basename = os.path.splitext(os.path.basename(filename))[0]
        with open(filename) as f:
            contents[basename] = f.read()

    return contents
