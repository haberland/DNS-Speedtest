import pandas as pd
import matplotlib.pyplot as plt
import seaborn as sns

# CSV laden
df = pd.read_csv('results.csv')

# Sicherstellen, dass alles numerisch ist
df['resolution_time_ms'] = pd.to_numeric(df['resolution_time_ms'], errors='coerce')

# Durchschnittliche Zeiten je DNS-Server über alle URLs
pivot = df.pivot_table(index='url', columns='dns_server', values='resolution_time_ms', aggfunc='mean')

# Plot
plt.figure(figsize=(12, 6))
sns.heatmap(pivot, annot=True, fmt=".1f", cmap="YlGnBu")
plt.title("Durchschnittliche DNS-Auflösezeiten (ms)")
plt.ylabel("Domain")
plt.xlabel("DNS Server")
plt.tight_layout()
plt.savefig("dns_performance_heatmap.png")
plt.show()

