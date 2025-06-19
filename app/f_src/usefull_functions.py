import time
import sys
import os
from f_src import bot_handlers
import telebot


def info_message(texto, bot:telebot.TeleBot, temp_dict, user, markup = False):
    if not markup:
        temp_dict[user]["info"] = bot.edit_message_text("🆕 Mensaje de Información\n\n{texto}".format(texto), chat_id=user, message_id=temp_dict[user]["info"].message_id)
    
    else:
        temp_dict[user]["info"] = bot.edit_message_text(f"🆕 Mensaje de Información\n\n{texto}", chat_id=user, message_id=temp_dict[user]["info"].message_id, reply_markup=markup)
        
    return temp_dict[user]["info"]

def main_folder():
    return os.path.dirname(sys.argv[0])

def user_folder(user):
    user = str(user)
    
    if not "user_archive" in os.listdir(main_folder()):
        os.mkdir(os.path.join(main_folder(), "user_archive"))
        os.mkdir(os.path.join(main_folder(), "user_archive", user))
        
    if not list(filter(lambda file: file.startswith(user), os.listdir(os.path.join(main_folder(), "user_archive")))):
        os.mkdir(os.path.join(main_folder(), "user_archive",  user))
        
    return os.path.join(main_folder(), "user_archive",  user)
    
def make_screenshoot(driver, user, element=False):
    user = str(user)
    if element:
        element.screenshot(os.path.join(user_folder(user) , f"{user}_error_facebook.png"))
    else:
        driver.save_screenshot(os.path.join(user_folder(user) , f"{user}_error_facebook.png"))
    
    return os.path.join(user_folder(user) , f"{user}_error_facebook.png")
    
def make_captcha_screenshoot(captcha_element, user):
    user = str(user)
    captcha_element.screenshot(os.path.join(f"{user_folder(user)}", f"{user}_captcha.png"))
    
    return os.path.join(f"{user_folder(user)}", f"{user}_captcha.png")


def handlers(bot: telebot.TeleBot, user , msg ,info, temp_dict , **kwargs):    
    
    
    if kwargs.get("file"):
        if kwargs.get("markup"):
            temp_dict[user]["msg"] = bot.send_photo(user, kwargs.get("file"), caption=msg, reply_markup=kwargs.get("markup"))
            
        else:
            temp_dict[user]["msg"] = bot.send_photo(user, kwargs.get("file"), caption=msg)
        
    else:
        if kwargs.get("markup"):
            temp_dict[user]["msg"] = bot.send_message(user, msg, reply_markup=kwargs.get("markup"))
        
        else:
            temp_dict[user]["msg"] = bot.send_message(user, msg)
    
    temp_dict[user]["completed"] = False
    
    
    match info:
        
        case "user":
        
            bot.register_next_step_handler(temp_dict[user]["msg"], bot_handlers.get_user, bot,user, info, temp_dict)
            
        case "password":
            
            bot.register_next_step_handler(temp_dict[user]["msg"], bot_handlers.get_user, bot,user, info, temp_dict)
            
        case "perfil_elegir":
            
            bot.register_next_step_handler(temp_dict[user]["msg"], bot_handlers.choose_perfil, bot,user, info, temp_dict)
            
        case "codigo_respaldo":
            
            bot.register_next_step_handler(temp_dict[user]["msg"], bot_handlers.get_codigo, bot,user, info, temp_dict)
            
        case "perfil_pregunta":
            
            
            bot.register_next_step_handler(temp_dict[user]["msg"], bot_handlers.perfil_pregunta, bot,user, info, temp_dict)
            
        case "captcha":
            
            bot.register_next_step_handler(temp_dict[user]["msg"], bot_handlers.captcha_getter, bot,user, info, temp_dict, kwargs.get("file"))
            
        case "perfil_seleccion":
            
            bot.register_next_step_handler(temp_dict[user]["msg"], bot_handlers.perfil_seleccion, bot,user, info, temp_dict, kwargs.get("markup"))
            
            
            
            
    while True:
        if not temp_dict[user]["completed"]:
            time.sleep(2)
            
        else:
            break
        
        
    return