import csv
import logging
import subprocess
import pandas as pd
import pyodbc

# logging setup / config
logger = logging.getLogger('Lex_examiner_table')
logger.setLevel(logging.DEBUG)
ch = logging.StreamHandler()
ch.setLevel(logging.INFO)
logger.addHandler(ch)
fh = logging.FileHandler('Lex_examiner_table.log')
fh.setLevel(logging.DEBUG)
logger.addHandler(fh)

# constants
CSV_FILE_NAME = r'\\MKLFILE\CLAIMS\corpfs06-filedrop\ClaimsReporting\Projects\Matter_Upload\Files\data\LEXexaminers.csv'
#PS1_SCRIPT_NAME = r'.\pull_claims_data.ps1'
#POWERSHELL_PATH = r'C:\Windows\System32\WindowsPowerShell\v1.0\powershell.exe'
MAX_ROWS_PER_BATCH = 900
MAX_PARAMS = 2000
DATABASE_STATEMENT_TEMPLATE = """
    use {database_name}
    go
"""

DATABASE_NAME = 'SANDBOX_CLAIMS_OPS'
#TRUNCATE_STATEMENT_TEMPLATE = 'truncate table {table_name}'
DROP_STATEMENT_TEMPLATE = 'DROP TABLE {table_name}'
CREATE_STATEMENT_TEMPLATE = 'CREATE TABLE {table_name} \n({create_column_names})'
INSERT_STATEMENT_TEMPLATE = 'insert into {table_name} ({column_names})\nvalues\n('
TABLE_NAME = 'SANDBOX_CLAIMS_OPS.data.LEXexaminers'
COLUMN_NAMES = [
    'Director LeX ID',
    'Director Name',
    'Manager_Name_ref',
    'Examiner Name In LeX_ref',
    'Examiner LeX ID',
    'Source system',
    'Examiner ID',
    'Examiner Name in Source System',
    'Examiner Name In LeX',
    'Active in LeX',
    'Manager Name',
    'Manager LeX ID',
    'Matter Class',
    'Matter Type',]
    
CREATE_COLUMN_NAMES = [
    '[Director LeX ID] varchar(50)',
    '[Director Name] varchar(50)',
    '[Manager_Name_ref] varchar(50)',
    '[Examiner Name In LeX_ref] varchar(50)',
    '[Examiner LeX ID] varchar(50)',
    '[Source system] varchar(50)',
    '[Examiner ID] varchar(50)',
    '[Examiner Name in Source System] varchar(50)',
    '[Examiner Name In LeX] varchar(50)',
    '[Active in LeX] varchar(50)',
    '[Manager Name] varchar(50)',
    '[Manager LeX ID] varchar(50)',
    '[Matter Class] varchar(50)',
    '[Matter Type] varchar(50)',
    ]
CONNECTION_STRING = "DRIVER={SQL Server};SERVER=VA1-PCORSQL210,21644;"


# the good stuff
def main():
#    logger.info(f'updating the people file ({CSV_FILE_NAME})...')
#    update_people_file()
    logger.info('extracting data...')
    create_csv_file()
    data = load_new_data(CSV_FILE_NAME)
    logger.debug(data)
    logger.info('pushing data...')
    push_data(data)


#def update_people_file():
#    """ Updates the people.csv file. """
#    # with open(PS1_SCRIPT_NAME) as f
#    subprocess.call([POWERSHELL_PATH, PS1_SCRIPT_NAME])
#    return

def create_csv_file():
    data = pd.read_excel(r'\\MKLFILE\CLAIMS\corpfs06-filedrop\ClaimsReporting\Projects\Matter_Upload\Files\data\Examiner Mapping from Source Systems to LeX.xlsx', sheetname = 0)
    data.to_csv(r'\\MKLFILE\CLAIMS\corpfs06-filedrop\ClaimsReporting\Projects\Matter_Upload\Files\data\LEXexaminers.csv', index = False)

#file_name=CSV_FILE_NAME
def load_new_data(file_name: str) -> list:
    """ Reads in a csv file named file_name,
    discards the very first row (ps is dumb like that)
    uses the next row as the headers
    reads the rest of the rows as content
    """
    with open(file_name) as f:
#        discard = next(f)
#        logger.debug(f'discarded {discard}')
        header_row = next(f)
        logger.debug(f'file header {header_row}')
        reader = csv.DictReader(f, fieldnames=COLUMN_NAMES)
        data = [row for row in reader]
    return data


def push_data(data: list):
    """ actually do something with the data """
    # # for now, just print how many rows we found.
    # logger.info(f'found {len(data)} rows!')
    # get the query for our data
    queries = build_queries(data)
    logger.info(f'made {len(queries)} queries!')
    # connect to the database
    conn = pyodbc.connect(CONNECTION_STRING)
    cur = conn.cursor()
    # truncate the table
#    truncate_statement = TRUNCATE_STATEMENT_TEMPLATE.format(table_name=TABLE_NAME)
#    cur.execute(truncate_statement)
    drop_statement = DROP_STATEMENT_TEMPLATE.format(table_name=TABLE_NAME)
    cur.execute(drop_statement)
    create_statement = CREATE_STATEMENT_TEMPLATE.format(table_name=TABLE_NAME, create_column_names = f"{','.join(CREATE_COLUMN_NAMES)}")
    cur.execute(create_statement)
    # update the new table
    for query in queries:
        sql, params = query
        logger.debug('running query:\n' + sql)
        cur.execute(sql,params)
    cur.commit()
    conn.close()
    return
#min([2100, 1000 // 14])
def build_queries(data: list) -> list:
    """ builds a list of tuples, containing the query and parameters it requires.
    ensures that each query does not exceed the MAX_PARAMETERS or BATCH_SIZE constraint
    """
    # determine whether the number of paramers per row or total rows limits rows per batch
    batch_size = min([MAX_ROWS_PER_BATCH, MAX_PARAMS // len(COLUMN_NAMES)])
    # start chunkin'
    queries = []
    while data:
        this_chunk = data[:batch_size]
        queries.append(build_query(this_chunk))
        data = data[batch_size:]
    return queries
  
def build_query(data: list) -> tuple:
    """ dynamically generate a parameterized sql query for this data """
    # start by selecting the correct database
    query = ''# DATABASE_STATEMENT_TEMPLATE.format(database_name=DATABASE_NAME)
    # add insert statements with placeholders
    insert_statement = INSERT_STATEMENT_TEMPLATE.format(table_name=TABLE_NAME, column_names=f"[{'],['.join(COLUMN_NAMES)}]")
    query += insert_statement
    # add placeholders
    params = []
    for row_number, row in enumerate(data):
        query += ','.join('?' for column in COLUMN_NAMES)
        query += '),\n('
        new_params = [row.get(column) for column in COLUMN_NAMES]
        logger.debug(f'new_params:\n{new_params}')
        params += new_params
    if query.endswith(',\n('):
        query = query[:-3]
    # query += '\ngo'
    return query, params
        

    
if __name__ == "__main__":
    logger.info('starting...')
    main()
    logger.info('...done!')


main()