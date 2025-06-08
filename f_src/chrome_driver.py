from selenium import webdriver
from selenium.webdriver.chrome.options import Options
from selenium.webdriver.chrome.service import Service
import undetected_chromedriver as uc
import seleniumbase



def anadir_opciones(o, container=False):
    o.add_argument("user-agent=Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, como Gecko) Chrome/135.0.0.0 Safari/537.36")
    o.add_argument("--disable-web-security")
    o.add_argument("--disable-extensions")
    o.add_argument("--disable-notifications")
    o.add_argument("--ignore-certificate-errors")
    o.add_argument("--no-sandbox")
    o.add_argument("--log-level=3") #para no mostrar nada en la terminal
    o.add_argument("--allow-running-insecure-content")
    o.add_argument("--no-default-browser-check")
    o.add_argument("--no-first-run")
    o.add_argument("--no-proxy-server")
    o.add_argument("--disable-blink-features=AutomationControlled")
    o.add_argument("--disable-infobars")
    
    o.add_argument("--disable-blink-features=AutomationControlled")
    o.add_argument("--disable-features=ChromeWhatsNewUI")
    
    if container:
        o.add_argument("--headless=new")  # O usa "--headless" si hay errores con "new"
        o.add_argument("--no-sandbox")
        o.add_argument("--disable-dev-shm-usage")
        o.add_argument("--disable-gpu")
        o.add_argument("--window-size=1920,1080")
        o.add_argument("--disable-extensions")
        o.add_argument("--disable-dev-shm-usage")
        o.add_argument("--disable-software-rasterizer")


    


    

    prefers = {"profile.default_content_setting_values.notifications": 2,
            "intl.accept_languages": ["es-ES", "es"],
            "credentials_enable_service": False}
    


    o.add_experimental_option("prefs", prefers)
    
    
    return o
    

def sb_driver():
    

    # options = Options()
    # options.add_argument("--headless=new")  # O usa "--headless" si hay errores con "new"
    # options.add_argument("--no-sandbox")
    # options.add_argument("--disable-dev-shm-usage")
    # options.add_argument("--disable-gpu")
    # options.add_argument("--window-size=1920,1080")
    # options.add_argument("--disable-extensions")
    # options.add_argument("--disable-dev-shm-usage")
    # options.add_argument("--disable-software-rasterizer")
    driver = seleniumbase.Driver(
    browser="chrome",
    uc=True,
    headless=True,
    headless2=True,
    disable_gpu=True,
    no_sandbox=True,
    incognito=True,
    remote_debug=False,
    chs = True,
    window_size="1920,1080")
    
    # driver = seleniumbase.Driver("chrome", locale_code="es", uc=True, headless=False)
        
    return driver


def selenium_driver():
    o = Options()

    o = anadir_opciones(o)
    
    #parametros a omitir en el inicio de chromedriver
    exp_opt= [
        "enable-automation",
        "ignore-certificate-errors",
        "enable-logging"
    ]
    
    o.add_experimental_option("excludeSwitches", exp_opt)
    o.add_experimental_option("excludeSwitches" , ["enable-automation"])
    o.add_argument("user-agent=Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, como Gecko) Chrome/135.0.0.0 Safari/537.36")

    s = Service("D:\\chromedriver.exe")

    driver = webdriver.Chrome(o , s)

    return driver


def uc_driver():
    o = uc.ChromeOptions()
    
    #desactivar el guardado de credenciales
    o.add_argument("--password-store=basic")
    #estas opciones son copiadas de arriba
    
    
    o.add_experimental_option(
        "prefs", {
            "credentials_enable_service": False,
            "profile.password_manager_enabled" : False
        }
    )
    
    o = anadir_opciones(o, True)
    
    driver = uc.Chrome(
        options=o,
        log_level=3
        # driver_executable_path="D:\\Programacion\\Proyectos personales\\webscrapping\\chromedriver.exe",
    )
    
    
    
    return driver




