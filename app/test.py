
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


@bot.message_handler(lambda x: True)
def cmd_asd(m):
    bot.send_photo(os.environ["admin"], telebot.types.InputFile("hola.png"), "Aqui está, enviado desde el contenedor Docker")
    return


bot.infinity_polling()    
    

