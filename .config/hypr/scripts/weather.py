#!/usr/bin/env python3

import requests
import json
import os
from pyquery import PyQuery

def to_devanagari(text):
    devanagari_digits = str.maketrans("0123456789", "०१२३४५६७८९")
    return text.translate(devanagari_digits)

weather_translations = {
  # Clear / Sunny
    "Sunny": "घाम लागेको",
    "Mostly Sunny": "प्रायः घाम लागेको",
    "Clear": "सफा आकाश",

    # Cloudy
    "Partly Cloudy": "आंशिक बादल",
    "Mostly Cloudy": "प्रायः बादल",
    "Cloudy": "बादल",
    "Overcast": "पूर्ण बादल",

    # Fog / Mist / Haze
    "Fog": "कुहिरो",
    "Haze": "तुवाँलो",
    "Smoke": "धुवाँ",
    "Mist": "हल्का कुहिरो",

    # Rain
    "Showers": "छिटपुट वर्षा",
    "Scattered Showers": "फाटफुट वर्षा",
    "Rain": "वर्षा",
    "Drizzle": "सिमसिमे पानी",
    "Light Rain": "हल्का वर्षा",
    "Moderate Rain": "मध्यम वर्षा",
    "Heavy Rain": "भारी वर्षा",

    # Snow / Ice
    "Snow": "हिमपात",
    "Light Snow": "हल्का हिमपात",
    "Wintry Mix": "हिउँ र पानी मिश्रित",
    "Sleet": "असिना पानी",

    # Severe
    "Thunderstorm": "चट्याङ्ग",
    "Scattered Thunderstorms": "फाटफुट चट्याङ्ग",
    "Windy": "बतास चलेको"
}

weather_icons = {
    "sunnyDay": "9",
    "clearNight": "4",
    "cloudyFoggyDay": "",
    "cloudyFoggyNight": "",
    "rainyDay": "",
    "rainyNight": "",
    "snowyIcyDay": "",
    "snowyIcyNight": "",
    "severe": "",
    "default": "",
}

latitude = 27.7172
longitude = 85.3240

url = f"https://weather.com/en-PH/weather/today/l/{latitude},{longitude}"
html_data = PyQuery(url=url)

temp = to_devanagari(html_data("span[data-testid='TemperatureValue']").eq(0).text())
status = html_data("div[data-testid='wxPhrase']").text().strip()
translated_status = weather_translations.get(status, status)
translated_status = translated_status[:16] + ".." if len(translated_status) > 17 else translated_status
status_code = html_data("#regionHeader").attr("class").split(" ")[2].split("-")[2]
icon = weather_icons.get(status_code, weather_icons["default"])

temp_feel = to_devanagari(html_data("div[data-testid='FeelsLikeSection'] > span > span[data-testid='TemperatureValue']").text())
temp_feel_text = f"अनुभूत तापक्रम {temp_feel}C"

temp_min = to_devanagari(html_data("div[data-testid='wxData'] > span[data-testid='TemperatureValue']").eq(1).text())
temp_max = to_devanagari(html_data("div[data-testid='wxData'] > span[data-testid='TemperatureValue']").eq(0).text())
temp_min_max = f"  {temp_min}  		  {temp_max}"

wind_speed_raw = html_data("span[data-testid='Wind'] > span").text()
wind_speed = to_devanagari(wind_speed_raw if wind_speed_raw else "०")
wind_text = f"  {wind_speed}"

humidity = to_devanagari(html_data("span[data-testid='PercentageValue']").text())
humidity_text = f"  {humidity}"

visibility = to_devanagari(html_data("span[data-testid='VisibilityValue']").text())
visibility_text = f"  {visibility}"

air_quality_index = to_devanagari(html_data("text[data-testid='DonutChartValue']").text())

tooltip_text = str.format(
    "\t\t{}\t\t\n{}\n{}\n{}\n\n{}\n{}\t{}\n{}{}",
    f'<span size="xx-large">{temp}</span>',
    f"<big> {icon}</big>",
    f"<b>{translated_status}</b>",
    f"<small>{temp_feel_text}</small>",
    f"<b>{temp_min_max}</b>",
    wind_text,
    humidity_text,
    visibility_text,
    f" AQI {air_quality_index}"
)

out_data = {
    "text": f"{icon}  {temp}",
    "alt": translated_status,
    "tooltip": tooltip_text,
    "class": status_code,
}
print(json.dumps(out_data))

simple_weather = (
    f"{icon}  {translated_status}\n"
    + f"  {temp} ({temp_feel_text})\n"
    + f"{wind_text} \n"
    + f"{humidity_text} \n"
    + f"{visibility_text} AQI{air_quality_index}\n"
)

try:
    with open(os.path.expanduser("~/.cache/.weather_cache"), "w") as file:
        file.write(simple_weather)
except Exception as e:
    print(f"Error writing to cache: {e}")
