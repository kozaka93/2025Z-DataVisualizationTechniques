
import pandas as pd
from sentimentpl.models import SentimentPLModel
import re
import os
from pathlib import Path
import torch
from tqdm import tqdm

os.environ['CUDA_LAUNCH_BLOCKING'] = "1"

device = "cuda" if torch.cuda.is_available() else "cpu"
print(f"Używane urządzenie: {device}")

def clean_and_fix(text):
    if text is None or not isinstance(text, str):
        return ""
    try:
        return text.encode('latin1').decode('utf-8').strip()
    except:
        return str(text).strip()

SCRIPT_DIR = Path(__file__).resolve().parent
PROJECT_ROOT = SCRIPT_DIR.parent
DATA_DIR = PROJECT_ROOT / 'dane'
file_path = DATA_DIR / 'wszystkie_wiadomosci_wika1.csv'
df = pd.read_csv(file_path, sep=';', encoding='utf-8')

target_sender = "Wiktoria Postek" 
messages_df = df[df['sender_name'] == target_sender].copy()

if messages_df.empty:
    print("BŁĄD: Nie znaleziono użytkownika! Sprawdź pisownię w konsoli powyżej.")
    exit()

def remove_links(text):
    if not isinstance(text, str): return ""
    return re.sub(r'http\S+', '', text).strip()

messages_df['clean_content'] = messages_df['content'].apply(remove_links)
messages_df['clean_content'] = messages_df['clean_content'].apply(clean_and_fix)
messages_df = messages_df[messages_df['clean_content'] != ""].copy()
messages_df['datetime'] = pd.to_datetime(messages_df['timestamp_ms'], unit='ms')
messages_df['date'] = messages_df['datetime'].dt.date
messages_df['day_num'] = messages_df['datetime'].dt.dayofweek
messages_df = messages_df[["sender_name","clean_content", "datetime", "date", "day_num"]]

print(f"Sukces! Analizuję {len(messages_df)} wiadomości...")

model = SentimentPLModel(from_pretrained='latest')
model.to(device) 
model.eval()     

texts = messages_df['clean_content'].tolist()
batch_size = 32  
results = []

print(f"Rozpoczynam analizę batchową na {device}...")

with torch.no_grad():
    for i in tqdm(range(0, len(texts), batch_size)):
        batch = texts[i : i + batch_size]
        batch = [str(t)[:512] for t in batch]         
        try:
            scores = model(batch)
            normalized_scores = ((scores + 1) / 2).flatten().cpu().numpy().tolist()
            
            results.extend(normalized_scores)            
        except Exception as e:
            print(f"\nBłąd w paczce {i}: {e}")
            results.extend([0.5] * len(batch))            
            if 'cuda' in str(e).lower():
                torch.cuda.empty_cache()

missing_count = len(messages_df) - len(results)
if missing_count > 0:
    print(f"OSTRZEŻENIE: Uzupełnianie {missing_count} brakujących wyników wartością 0.5")
    results.extend([0.5] * missing_count)

messages_df['sentiment'] = results

output_path = os.path.join(DATA_DIR, "wika_sentyment.csv")
messages_df.to_csv(output_path, index=False, sep=';', encoding='utf-8-sig')

print("\n--- Najbardziej negatywne wiadomości (skala 0-1) ---")
print(messages_df[['clean_content', 'sentiment']].sort_values(by='sentiment').head(3))
print("\n--- Najbardziej pozytywne wiadomości (skala 0-1) ---")
print(messages_df[['clean_content', 'sentiment']].sort_values(by='sentiment', ascending=False).head(3))