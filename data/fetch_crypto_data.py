import requests
import psycopg2
from datetime import datetime

def fetch_crypto_data():
    """
    Fetch cryptocurrency data from CoinGecko API
    """
    print("🔄 Fetching cryptocurrency data from CoinGecko API...")
    
    url = "https://api.coingecko.com/api/v3/simple/price"
    
    params = {
        'ids': 'bitcoin,ethereum,tether,binancecoin,usd-coin,ripple,cardano,solana,tron,polkadot',
        'vs_currencies': 'usd',
        'include_market_cap': 'true',
        'include_24hr_vol': 'true'
    }
    
    try:
        response = requests.get(url, params=params, timeout=10)
        response.raise_for_status()
        data = response.json()
        
        print(f"✅ Successfully fetched data for: {list(data.keys())}")
        return data
        
    except Exception as e:
        print(f"❌ Error fetching data: {e}")
        return None


def insert_raw_data(data):
    """
    Connect to PostgreSQL and insert raw cryptocurrency data
    """
    if not data:
        print("❌ No data to insert")
        return
    
    try:
        conn = psycopg2.connect(
            host="localhost",
            database="postgres",
            user="postgres",
            password="0989!!"
        )
        
        cursor = conn.cursor()
        
        print("💾 Inserting data into PostgreSQL...")
        
        for coin, prices in data.items():
            cursor.execute(
                """
                INSERT INTO crypto_raw (coin_name, price, market_cap, volume)
                VALUES (%s, %s, %s, %s)
                """,
                (
                    coin,
                    prices.get('usd'),
                    prices.get('usd_market_cap'),
                    prices.get('usd_24h_vol')
                )
            )
        
        conn.commit()
        
        print(f"✅ Successfully inserted {len(data)} coins into crypto_raw")
        
        cursor.execute("SELECT COUNT(*) FROM crypto_raw")
        total_records = cursor.fetchone()[0]
        print(f"📊 Total records in crypto_raw: {total_records}")
        
        cursor.close()
        conn.close()
        
    except Exception as e:
        print(f"❌ Database error: {e}")


if __name__ == "__main__":
    print("=" * 50)
    print("CRYPTOCURRENCY DATA AUTOMATION")
    print(f"Started at: {datetime.now()}")
    print("=" * 50)
    
    crypto_data = fetch_crypto_data()
    
    if crypto_data:
        insert_raw_data(crypto_data)
    
    print("=" * 50)
    print(f"Completed at: {datetime.now()}")
    print("=" * 50)



