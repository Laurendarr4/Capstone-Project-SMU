import pandas as pd
from sodapy import Socrata

#No need for token as this is open public data
# Example authenticated client (needed for non-public datasets):
# We are pulling a lot of data so we need a token
client = Socrata("www.dallasopendata.com", "token", username="userName, password="enterYourPassword")
# Pulls the data out in .JSON format
results = client.get("qqc2-eivj", content_type="json", limit=30000, q="BURGLARY")
# Convert JSON to csv
results_df = pd.DataFrame.from_records(results)

results_df.to_csv("dallasBurgCap.csv", sep='\t', encoding='utf-8')
