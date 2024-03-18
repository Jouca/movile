import csv, mysql.connector
from io import BytesIO
from zipfile import ZipFile
from urllib.request import urlopen
import time, datetime

import ssl
ssl._create_default_https_context = ssl._create_unverified_context

CONFIG = {
    'user': 'root',
    'password': 'xgefnT2k3wOH7nsL',
    'host': '127.0.0.1',
    'database': 'idfm_movile',
    'raise_on_warnings': True
}

def download_unzip_csv():
    """
    Fonction qui permet de télécharger et d'extraire un fichier CSV
    """
    resp = urlopen('https://data.iledefrance-mobilites.fr/explore/dataset/offre-horaires-tc-gtfs-idfm/files/a925e164271e4bca93433756d6a340d1/download/')
    myzip = ZipFile(BytesIO(resp.read()))
    myzip.extract('stop_times.txt')
    myzip.extract('calendar.txt')
    myzip.extract('trips.txt')
    return myzip


def drop_stoptimes_table():
    """
    Fonction qui permet de supprimer la table stop_times
    """
    try:
        sql = "DROP TABLE stop_times"
        db = DB()
        db.execute(sql)
        db.commit()
        db.close()
    except:
        pass

def change_table_name_stop_times():
    """
    Fonction qui permet de renommer la table stop_times_temp en stop_times
    """
    try:
        sql = "RENAME TABLE stop_times_temp TO stop_times"
        db = DB()
        db.execute(sql)
        db.commit()
        db.close()
    except:
        pass

def create_stoptimes_table():
    sql = """
    CREATE TABLE `stop_times_temp` (
    `trip_id` varchar(100) NOT NULL,
    `arrival_time` text NOT NULL,
    `departure_time` text NOT NULL,
    `stop_id` text NOT NULL,
    `stop_sequence` text NOT NULL,
    `pick_up_type` text NOT NULL,
    `drop_off_type` text NOT NULL,
    `local_zone_id` text NOT NULL,
    `stop_headsign` text NOT NULL,
    `timepoint` text NOT NULL,
    `service_id` text NOT NULL
    ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;
    """
    db = DB()
    db.execute(sql)
    db.commit()
    db.close()

def open_csv_stoptimes(trips):
    """
    Fonction qui permet d'ouvrir un fichier CSV et de renvoyer ses valeurs
    """
    with open("stop_times.txt", mode="r", encoding="utf-8") as csvfile:
        reader = csv.reader(csvfile, delimiter=',')
        db = DB()
        count = 0
        count2 = 0
        for row in reader:
            if count == 0:
                count += 1
                continue
            print(str(count) + " : Stop Times")
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
            service_id = trips[trip_id]
            sql = f"INSERT INTO stop_times_temp (trip_id, arrival_time, departure_time, stop_id, stop_sequence, pick_up_type, drop_off_type, local_zone_id, stop_headsign, timepoint, service_id) VALUES ('{trip_id}', '{arrival_time}', '{departure_time}', '{stop_id}', '{stop_sequence}', '{pick_up_type}', '{drop_off_type}', '{local_zone_id}', '{stop_headsign}', '{timepoint}', '{service_id}')"
            db.execute(sql)
            count += 1
        db.commit()
        db.close()


def store_trips():
    db = DB()
    sql = "SELECT * FROM trips"
    db.execute(sql)
    trips = db.fetchall()
    db.close()
    
    # make it on a dict
    trips_dict = {}
    for trip in trips:
        trips_dict[trip[2]] = trip[1]
    return trips_dict


def pop_calendar():
    db = DB()
    sql = "DELETE FROM calendar"
    db.execute(sql)
    db.commit()
    db.close()

def open_csv_calendar():
    """
    Fonction qui permet d'ouvrir un fichier CSV et de renvoyer ses valeurs
    """
    with open("calendar.txt", mode="r", encoding="utf-8") as csvfile:
        reader = csv.reader(csvfile, delimiter=',')
        db = DB()
        count = 0
        for row in reader:
            if count == 0:
                count += 1
                continue
            print(str(count) + " : Calendar")
            service_id = row[0]
            monday = row[1]
            tuesday = row[2]
            wednesday = row[3]
            thursday = row[4]
            friday = row[5]
            saturday = row[6]
            sunday = row[7]
            start_date = row[8]
            end_date = row[9]
            sql = f"INSERT INTO calendar (service_id, monday, tuesday, wednesday, thursday, friday, saturday, sunday, start_date, end_date) VALUES ('{service_id}', '{monday}', '{tuesday}', '{wednesday}', '{thursday}', '{friday}', '{saturday}', '{sunday}', '{start_date}', '{end_date}')"
            db.execute(sql)
            count += 1
        db.commit()
        db.close()


def pop_trips():
    db = DB()
    sql = "DELETE FROM trips"
    db.execute(sql)
    db.commit()
    db.close()

def open_csv_trips():
    """
    Fonction qui permet d'ouvrir un fichier CSV et de renvoyer ses valeurs
    """
    with open("trips.txt", mode="r", encoding="utf-8") as csvfile:
        reader = csv.reader(csvfile, delimiter=',')
        db = DB()
        count = 0
        for row in reader:
            if count == 0:
                count += 1
                continue
            print(str(count) + " : Trips")
            route_id = row[0]
            service_id = row[1]
            trip_id = row[2]
            trip_headsign = row[3]
            trip_short_name = row[4]
            direction_id = row[5]
            block_id = row[6]
            shape_id = row[7]
            wheelchair_accessible = row[8]
            bikes_allowed = row[9]

            sql = "INSERT INTO trips (route_id, service_id, trip_id, trip_headsign, trip_short_name, direction_id, block_id, shape_id, wheelchair_accessible, bikes_allowed) VALUES (%s, %s, %s, %s, %s, %s, %s, %s, %s, %s)"
            values = (route_id, service_id, trip_id, trip_headsign, trip_short_name, direction_id, block_id, shape_id, wheelchair_accessible, bikes_allowed)
            db.execute(sql, values)
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
    
    def execute(self, sql, values=None):
        """
        Méthode qui permet d'exécuter une requête SQL.
        """
        self.cursor.execute(sql, values)

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

def process():
    print("downloading")
    download_unzip_csv()

    # popping
    print("popping calendar")
    pop_calendar()
    print("popping trips")
    pop_trips()

    # inserting
    print("inserting calendar")
    open_csv_calendar()
    print("inserting trips")
    open_csv_trips()
    trips = store_trips()

    # creating and inserting stoptimes
    print("creating stoptimes")
    create_stoptimes_table()
    print("inserting stoptimes")
    open_csv_stoptimes(trips)

    print("deleting stoptimes")
    drop_stoptimes_table()

    change_table_name_stop_times()

def main():
    while True:
        # check if the time is at 08:00:00, 13:00:00 or 17:00:00
        now = datetime.datetime.now()
        if (now.hour == 8 or now.hour == 13 or now.hour == 17) and now.minute == 1 and now.second == 0:
            process()  

if __name__ == '__main__':
    #process()
    main()