from urllib.request import urlopen

def raw_url(url):
    return urlopen(url).read()
