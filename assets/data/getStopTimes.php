<?php
    ini_set("memory_limit", "-1");
    error_reporting(E_ALL & ~E_NOTICE);

    class newPDO extends PDO {
        public function __construct() {
            $dsn = 'mysql:host=localhost;dbname=idfm_movile';

            parent::__construct($dsn, 'root', 'xgefnT2k3wOH7nsL');

            $this->setAttribute(PDO::ATTR_ERRMODE, PDO::ERRMODE_EXCEPTION);
            $this->setAttribute(PDO::ATTR_EMULATE_PREPARES, false);
        }
    }
    
    function req_csv(Array $array) {
        $pdo = new newPDO();
        $sql = "SELECT * FROM stop_times INNER JOIN calendar ON stop_times.service_id = calendar.service_id WHERE trip_id IN (" . implode(',', array_fill(0, count($array), '?')) . ") AND " . get_current_day_of_the_week_in_str() . " = 1";
        $stmt = $pdo->prepare($sql);
        $stmt->execute($array);
        $result = $stmt->fetchAll(PDO::FETCH_ASSOC);
        return $result;
    }

    function get_current_day_of_the_week_in_str() {
        $days = ['sunday', 'monday', 'tuesday', 'wednesday', 'thursday', 'friday', 'saturday'];
        return $days[date('w')];
    }

    if ($_SERVER['REQUEST_METHOD'] === 'POST') {
        if (isset($_POST['trip_id'])) {
            // to array
            $trip_ids = explode(',', $_POST['trip_id']);
            $lines = [];
            array_push($lines, ['trip_id', 'arrival_time', 'departure_time', 'stop_id', 'stop_sequence', 'pickup_type', 'drop_off_type', 'local_zone_id', 'stop_headsign', 'timepoint']);

            // get data and push with "," separator as a string
            $result = req_csv($trip_ids);
            foreach ($result as $row) {
                array_push($lines, [
                    $row['trip_id'],
                    $row['arrival_time'],
                    $row['departure_time'],
                    $row['stop_id'],
                    $row['stop_sequence'],
                    $row['pickup_type'],
                    $row['drop_off_type'],
                    $row['local_zone_id'],
                    $row['stop_headsign'],
                    $row['timepoint']
                ]);
            }

            // echo lines
            for ($i = 0; $i < count($lines); $i++) {
                echo implode(',', $lines[$i]);
                echo "\n";
            }
        }
    }
?>