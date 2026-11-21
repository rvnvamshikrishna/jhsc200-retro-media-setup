import urllib.request
import json
import re

headers = {
    'User-Agent': 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0.0.0 Safari/537.36'
}

# Try Aptoide Web Services API for zank.remote
url = "https://ws75.aptoide.com/api/7/apps/search?query=zank.remote&limit=5"
try:
    req = urllib.request.Request(url, headers=headers)
    with urllib.request.urlopen(req) as resp:
        data = json.loads(resp.read().decode('utf-8'))
        datalist = data.get('datalist', {}).get('list', [])
        for app in datalist:
            name = app.get('name')
            pname = app.get('package')
            apk_url = app.get('file', {}).get('path')
            print(f"Found: {name} ({pname}) -> {apk_url}")
            if pname == 'zank.remote' and apk_url:
                print(f"Downloading {name}...")
                urllib.request.urlretrieve(apk_url, "zank_remote.apk")
                print("Downloaded successfully!")
                break
except Exception as e:
    print("Error:", e)

