#!/bin/bash

CSV_FILE="all_results.csv"
ROBOT_TEST="DNSTest.robot"
LOOPS=20
SLEEP_SECONDS=5  # Sekunden

echo "dns_server,url,resolution_time_ms" > $CSV_FILE

for ((i=1; i<=LOOPS; i++)); do
    echo "[$(date)] Starte Durchlauf $i von $LOOPS"
    # Starte den Robot-Test und schreibe die Ergebnisse in die CSV-Datei (anhängen)
    robot --output NONE --log NONE --report NONE $ROBOT_TEST
    cat results.csv | tail -n +2 >> $CSV_FILE

    echo "[$(date)] Durchlauf $i abgeschlossen, warte $SLEEP_SECONDS Sekunden..."
    sleep $SLEEP_SECONDS
    python3 graph.py
done
echo "Alle $LOOPS DNS-Tests abgeschlossen."
echo "Erste Graphik"
python3 graph.py
echo "Grafik unter dns_performance_heatmap.png gespeichert"