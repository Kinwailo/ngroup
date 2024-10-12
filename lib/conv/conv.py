import json
import urllib.request
# 繁簡體字轉換表
# https://github.com/kfcd/fanjian
contents = urllib.request.urlopen("https://raw.githubusercontent.com/kfcd/fanjian/master/dist/json/jianfan.json").read()
obj = json.loads(contents)
i = [x["i"] for x in obj]
o = [x['o'] for x in obj]
i2 = ""
o2 = ""
for n in range(0, len(obj), 50):
    i2 += "r'''" + ",".join(i[n: n + 50]) + ",'''\n"
    o2 += "r'''" + ",".join(o[n: n + 50]) + ",'''\n"
with open("conv.txt", "w") as text_file:
    text_file.write("%s\n\n%s" % (i2, o2))
