import urllib.request
import json

headers = {'User-Agent': 'Mozilla/5.0'}

def fetch_apk(query, filename):
    url = f"https://ws75.aptoide.com/api/7/apps/search?query={query}&limit=3"
    try:
        req = urllib.request.Request(url, headers=headers)
        with urllib.request.urlopen(req) as resp:
            data = json.loads(resp.read().decode('utf-8'))
            for app in data.get('datalist', {}).get('list', []):
                pname = app.get('package')
                apk_url = app.get('file', {}).get('path')
                name = app.get('name')
                print(f"Candidate: {name} ({pname}) -> {apk_url[:50]}...")
                if apk_url:
                    print(f"Downloading {name} to {filename}...")
                    urllib.request.urlretrieve(apk_url, filename)
                    print(f"Saved {filename}!")
                    return True
    except Exception as e:
        print("Error:", e)
    return False

fetch_apk("nostalgia.nes.lite", "nostalgia_nes.apk")

