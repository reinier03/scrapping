import threading
from flask import Flask, request
from selenium.webdriver.common.by import By
import undetected_chromedriver as uc
import os
import telebot
from chrome_driver import uc_driver


bot = telebot.TeleBot(os.environ["token"])

current_dir = os.getcwd()
target_url = 'https://www.google.com/'

driver = uc_driver()

driver.get(target_url)
driver.save_screenshot("hola.png")


bot.send_message(os.environ["admin"], "Lo pude hacer!")
bot.send_photo(os.environ["admin"], telebot.types.InputFile("hola.png"), "Aqui está, enviado desde el contenedor Docker")


@bot.message_handler(func=lambda x: True)
def cmd_asd(m):
    bot.send_photo(os.environ["admin"], telebot.types.InputFile("hola.png"), "Aqui está, enviado desde el contenedor Docker")
    return


app = Flask(__name__)
@app.route('/')
def index():
    return "Hello World"

def flask():
    app.run(host="0.0.0.0", port=5000)



try:
    print(f"La dirección del servidor es:{request.host_url}")
except:
    hilo_flask=threading.Thread(name="hilo_flask", target=flask)
    hilo_flask.start()

try:
    bot.remove_webhook()
except:
    pass


print("tamo activo papi")
bot.infinity_polling()  
    

