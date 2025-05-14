from selenium import webdriver
from selenium.webdriver.chrome.service import Service
from selenium.webdriver.chrome.options import Options
from selenium.webdriver.common.by import By
from selenium.webdriver.support.ui import WebDriverWait
from selenium.webdriver.support import expected_conditions as EC
from bs4 import BeautifulSoup
import time
import datetime
import re
import os
import pandas as pd

def init_driver():
    service = Service(r'C:\Users\aravi\OneDrive\Desktop\chromedriver-win64\chromedriver.exe')  # ✅ Update path if needed

    options = Options()
    options.add_argument("--disable-blink-features=AutomationControlled")  # ✅ Helps bypass bot detection
    options.add_argument("user-agent=Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0.0.0 Safari/537.36")
    driver = webdriver.Chrome(service=service, options=options)
    return driver

def check_price():
    URL = 'https://www.amazon.in/Aaramkhor-T-Shirt-Computer-Science-Engineering/dp/B091F5TS19'
    driver = init_driver()
    driver.get(URL)
    driver.maximize_window()
    WebDriverWait(driver, 10).until(EC.presence_of_element_located((By.ID, "productTitle")))
    WebDriverWait(driver, 10).until(EC.presence_of_element_located((By.CLASS_NAME, "a-price-whole")))
    soup = BeautifulSoup(driver.page_source, 'html.parser')
    title_tag = soup.find(id="productTitle")
    price_tag = soup.find(class_="a-price-whole")

    title = title_tag.get_text(strip=True)
    price_raw = price_tag.get_text(strip=True)
    price = re.sub(r'[^\d]', '', price_raw)

    today = datetime.date.today().strftime("%d/%m/%Y")

    # Create a DataFrame with your data
    df = pd.DataFrame([[title, price, today]], columns=["Name", "Price", "Date"])
    file_path = r"C:\Users\aravi\OneDrive\Desktop\AmazonWebScraper.xlsx"
    if os.path.exists(file_path):
        # Load existing data
        existing_df = pd.read_excel(file_path)
        # Append new row
        combined_df = pd.concat([existing_df, df], ignore_index=True)
        # Save back to same file
        combined_df.to_excel(file_path, index=False)
    else:
        # File doesn't exist, so create a new one
        df.to_excel(file_path, index=False)

    driver.quit()

# Run every 24 hours
while True:
    check_price()
    time.sleep(5)  # Sleep for 1 day



