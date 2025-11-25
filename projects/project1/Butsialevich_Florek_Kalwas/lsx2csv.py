import pandas as pd
import os

def excel_to_csv(excel_path, output_dir=None):
    if output_dir is None:
        output_dir = os.path.dirname(excel_path)
    xls = pd.read_excel(excel_path, sheet_name=None)
    for sheet_name, df in xls.items():
        safe_name = "".join(c if c.isalnum() else "_" for c in sheet_name)
        csv_path = os.path.join(output_dir, f"{safe_name}.csv")
        df.to_csv(csv_path, index=False, encoding='utf-8-sig')
        print(f"Zapisano: {csv_path}")

excel_to_csv("sciezka do excela") #tylko sciezke zmienic