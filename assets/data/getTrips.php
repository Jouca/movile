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
    
    function req_csv() {
        $pdo = new newPDO();
        $sql = "SELECT * FROM trips";
        $stmt = $pdo->prepare($sql);
        $stmt->execute();
        $result = $stmt->fetchAll(PDO::FETCH_ASSOC);
        return $result;
    }

    $lines = [];
    array_push($lines, ['route_id', 'service_id', 'trip_id', 'trip_headsign', 'trip_short_name', 'direction_id', 'block_id', 'shape_id', 'wheelchair_accessible', 'bikes_allowed']);

    // get data and push with "," separator as a string
    $result = req_csv();
    foreach ($result as $row) {
        array_push($lines, [
            $row['route_id'],
            $row['service_id'],
            $row['trip_id'],
            $row['trip_headsign'],
            $row['trip_short_name'],
            $row['direction_id'],
            $row['block_id'],
            $row['shape_id'],
            $row['wheelchair_accessible'],
            $row['bikes_allowed']
        ]);
    }

    // echo lines
    $string = '';
    for ($i = 0; $i < count($lines); $i++) {
        $string .= implode(',', $lines[$i]);
        $string .= "\n";
    }
    echo gzcompress($string, 9);
?>