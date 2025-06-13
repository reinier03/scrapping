import os
import telebot
from telebot.types import *
import f_src
import sys
import dill
import re
from traceback import format_exc
import threading
from flask import Flask, request
import subprocess

from f_src import facebook_scrapper
from f_src.usefull_functions import *


"""
-------------------------------------------------------
Variables de Entorno a Definir:
-------------------------------------------------------
token = token del bot
admin = ID del administrador del bot
MONGO_URL = Enlace del cluster de MongoDB (Atlas)

"""



cola = {}
cola["cola"] = []
cola["uso"] = False



telebot.apihelper.ENABLE_MIDDLEWARE = True

bot = telebot.TeleBot(os.environ["token"], "html")

bot.set_my_commands([
    BotCommand("/start", "Información sobre el bot"),
    BotCommand("/publicar", "Empieza a publicar en Facebook :)")
])

bot.send_message(os.environ["admin"], "Ando ready")



@bot.message_handler(func=lambda message: not message.chat.id == int(os.environ["admin"]))
def not_admin(m):
    bot.send_message(m.chat.id, "No disponible para el publico")
    return

@bot.message_handler(func=lambda message: not message.chat.type == "private")
def not_private(m):
    return

@bot.message_handler(commands=["start"])
def start(m):
    bot.send_message(m.chat.id,                      
"""
HOLA :D
¿Te parece tedioso estar re publicando por TODOS tus grupos en Facebook?
No te preocupes, yo me encargo por ti ;)

Envia /publicar para comenzar

Bot desarrollado por @mistakedelalaif, las dudas o quejas, ir a consultárselas a él
""")
    return
    

@bot.message_handler(commands=["publicar"])
def cmd_publish(m):
    global cola
    
    if cola["uso"]:
        bot.send_message("Al parecer alguien ya me está usando :(\nLo siento pero por ahora estoy ocupado, te avisaré cuando ya esté disponible")
        
        if not m.from_user.id in cola["cola"]:
            cola["cola"].append(m.from_user.id)
            
        return
    
    texto = (
"""A continuación ve a Facebook y sigue estos pasos para compartir la publicacion

1 - Selecciona la publicació
2 - Dale en el botón de '↪ Compartir'
3 - Luego en el menú que aparece dale a 'Obtener Enlace'
4 - Pega dicho enlace en el siguiente mensaje y envíamelo

Ahora enviame el enlace de la publicación
""")
    
    msg = bot.send_message(m.chat.id, texto, reply_markup=telebot.types.ForceReply())
    bot.register_next_step_handler(msg, get_url, texto)
    
    
def get_url(m, texto):
    global cola
    
    if cola["uso"]:
        bot.send_message("Al parecer alguien ya me está usando :(\nLo siento pero por ahora estoy ocupado, te avisaré cuando ya esté disponible")
        
        if not m.from_user.id in cola["cola"]:
            cola["cola"].append(m.from_user.id)
            
        return
    
    
    if not m.text.lower().startswith("https://www.facebook.com"):
        msg = bot.send_message(m.chat.id, f"Este enlace no es de Facebook! Inténtalo de nuevo...\n\n{texto}")
        
        return bot.register_next_step_handler(msg, get_url, texto)
    
    
    try:
        cola["uso"] = True
        if not m.from_user.id in cola["cola"]:
            cola["cola"].insert(0, m.from_user.id)
        
        try:
            facebook_scrapper.main(bot, m.from_user.id , m.text)
            
        except Exception as e:
            if e.lower() == "no":
                pass
            
            else:
                bot.send_message(m.from_user.id, f"Ha ocurrido un error inesperado! Reenviale a @mistakedelalaif este mensaje\n\n<blockquote expandable>{e.args}</blockquote>")
        
        if m.from_user.id in cola["cola"]:
            cola["cola"].remove(m.from_user.id)
            
        
            
            
    except:
        try:
            bot.send_message(m.chat.id, f"Ha ocurrido un error inesperado! Reenviale a @mistakedelalaif este mensaje\n\n<blockquote expandable>{format_exc()}</blockquote>")
            
        except:
            with open(os.path.join(main_folder(), f"error_{m.from_user.id}.txt"), "w") as file:
                file.write(f"Ha ocurrido un error inesperado!\nID del usuario: {m.from_user.id}\n\n{format_exc()}")
                
            with open(os.path.join(main_folder(), f"error_{m.from_user.id}.txt"), "r") as file:
                bot.send_document(m.from_user.id, telebot.types.InputFile(file, file_name=f"error_{m.from_user.id}.txt"))
                
            os.remove(os.path.join(main_folder(), f"error_{m.from_user.id}.txt"))
    
    cola["uso"] = False      
    
    print(f"He terminado con: {m.from_user.id}")

@bot.message_handler(func=lambda x: True)
def cmd_any(m):
    bot.send_message(m.chat.id, m.text)
    
    

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