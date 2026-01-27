#%%
import numpy as np
import matplotlib.pyplot as plt
import matplotlib.colors as mcolors
from PIL import Image
from wordcloud import WordCloud, STOPWORDS

#%%
with open("resources/Christmas_carol.txt", "r", encoding="utf-8") as f:
    text1 = f.read()
lines1 = text1.split('\n')
clean_text1 = " ".join(lines1[18:3874]) 

with open("resources/Match_girl.txt", "r", encoding="utf-8") as f:
    text2 = f.read()
lines2 = text2.split('\n')
clean_text2 = " ".join(lines2[:]) 

with open("resources/stories.txt", "r", encoding="utf-8") as f:
    text3 = f.read()
lines3 = text3.split('\n')
clean_text3 = " ".join(lines3[84:1044]) 
#%%
choinka_mask = np.array(Image.open("resources/Drzewo.jpg"))
pieniek_mask = np.array(Image.open("resources/Pieniek.jpg"))
gwiazda_mask = np.array(Image.open("resources/Gwiazda.jpg"))
#%%
greens = mcolors.LinearSegmentedColormap.from_list(
    "deep_green", ["#024002", "#00441b", "#006d2c", "#238b45", "#33ab39"], N=256)
yellows = mcolors.LinearSegmentedColormap.from_list(
    "star_gold", ["#b8860b", "#daa520", "#ffd700", "#ffcc00"], N=256)
browns = mcolors.LinearSegmentedColormap.from_list(
    "stem_brown", ["#3e2723", "#5d4037", "#795548", "#8d6e63"], N=256)
#%%
common_params = {
    "background_color": None,
    "mode": "RGBA",          
    "stopwords": STOPWORDS,
    "max_words": 300,
    "min_font_size": 3,
    "scale":3
}

wc_tree = WordCloud(**common_params, mask=choinka_mask, colormap=greens).generate(clean_text1)
wc_stem = WordCloud(**common_params, mask=pieniek_mask, colormap=browns).generate(clean_text2)
wc_star = WordCloud(**common_params, mask=gwiazda_mask, colormap=yellows).generate(clean_text3)

plt.figure(figsize=[12, 12], facecolor='white')

plt.imshow(wc_tree, interpolation='bilinear')
plt.imshow(wc_stem, interpolation='bilinear')
plt.imshow(wc_star, interpolation='bilinear')

plt.axis("off")
plt.savefig("Choinka.png", 
            dpi=300,        
            bbox_inches='tight', 
            pad_inches=0)
plt.show()
