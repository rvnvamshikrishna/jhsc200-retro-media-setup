import urllib.request
import re

url = "https://raw.githubusercontent.com/retrobrews/nes-games/master/gamelist.xml"
try:
    with urllib.request.urlopen(url) as resp:
        xml = resp.read().decode('utf-8', errors='ignore')
        paths = re.findall(r'<path>\./([^<]+)</path>', xml)
        print("Found games:", len(paths))
        base = "https://raw.githubusercontent.com/retrobrews/nes-games/master/"
        for p in paths[:5]:
            fname = p.strip()
            print("Downloading:", fname)
            urllib.request.urlretrieve(base + urllib.parse.quote(fname), fname)
            print("Saved:", fname)
except Exception as e:
    print("Error:", e)

