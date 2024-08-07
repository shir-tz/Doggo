from configparser import ConfigParser

def load_database_config(filename="/app/configurations.ini"):
    parser = ConfigParser()
    try:
        parser.read(filename)

        # Extract and convert database credentials from the INI file
        db = {
            'host': parser.get('postgresql', 'db_host').strip(),
            'port': parser.getint('postgresql', 'db_port'),
            'dbname': parser.get('postgresql', 'db_name').strip(),
            'user': parser.get('postgresql', 'db_user').strip(),
            'password': parser.get('postgresql', 'db_password').strip()
        }
        return db

    except Exception as e:
        raise RuntimeError(f"Error reading configuration file: {e}")
