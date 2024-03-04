import csv, mysql.connector

CONFIG = {
    'user': 'root',
    'password': 'xgefnT2k3wOH7nsL',
    'host': '127.0.0.1',
    'database': 'idfm_movile',
    'raise_on_warnings': True
}

def open_csv(file):
    """
    Fonction qui permet d'ouvrir un fichier CSV et de renvoyer ses valeurs
    """
    with open(file, newline='', encoding='utf-8') as csvfile:
        reader = csv.reader(csvfile, delimiter=',')
        db = DB()
        count = 0
        for row in reader:
            if count == 0:
                count += 1
                continue
            print(count)
            trip_id = row[0]
            arrival_time = row[1]
            departure_time = row[2]
            stop_id = row[3]
            stop_sequence = row[4]
            pick_up_type = row[5]
            drop_off_type = row[6]
            local_zone_id = row[7]
            stop_headsign = row[8]
            timepoint = row[9]
            sql = f"INSERT INTO stop_times (trip_id, arrival_time, departure_time, stop_id, stop_sequence, pick_up_type, drop_off_type, local_zone_id, stop_headsign, timepoint) VALUES ('{trip_id}', '{arrival_time}', '{departure_time}', '{stop_id}', '{stop_sequence}', '{pick_up_type}', '{drop_off_type}', '{local_zone_id}', '{stop_headsign}', '{timepoint}')"
            db.execute(sql)
            count += 1
        db.commit()
        db.close()

class DB:
    """
    Classe qui permet de gérer la base de données.
    """
    def __init__(self):
        self.mydb = mysql.connector.connect(**CONFIG)
        self.cursor = self.mydb.cursor()
    
    def execute(self, sql):
        """
        Méthode qui permet d'exécuter une requête SQL.
        """
        self.cursor.execute(sql)

    def fetchall(self):
        """
        Méthode qui permet de récupérer toutes les données d'une requête SQL.
        """
        return self.cursor.fetchall()

    def fetchone(self):
        """
        Méthode qui permet de récupérer la première donnée d'une requête SQL.
        """
        return self.cursor.fetchone()
    
    def commit(self):
        """
        Méthode qui permet de valider les changements dans la base de données.
        """
        self.mydb.commit()

    def close(self):
        """
        Méthode qui permet de fermer la connexion à la base de données.
        """
        self.mydb.close()

if __name__ == '__main__':
    open_csv('stop_times.csv')