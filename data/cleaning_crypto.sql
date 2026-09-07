CREATE OR REPLACE PROCEDURE clean_cryptocurrency_data()
LANGUAGE plpgsql
AS $$
DECLARE
  v_records_cleaned INT;
BEGIN
  RAISE NOTICE '====================================';
  RAISE NOTICE 'Starting cryptocurrency data cleaning';
  RAISE NOTICE 'Time: %', NOW();
  RAISE NOTICE '====================================';
  
  DELETE FROM crypto_clean;
  
  INSERT INTO crypto_clean (coin_name, price_usd, market_cap_usd, volume_usd)
  SELECT 
    UPPER(coin_name) as coin_name,
    
    ROUND(price, 8) as price_usd,
    
    COALESCE(market_cap, 0) as market_cap_usd,
    
    COALESCE(volume, 0) as volume_usd
    
  FROM crypto_raw
  
  WHERE (coin_name, fetched_at) IN (
    SELECT coin_name, MAX(fetched_at)
    FROM crypto_raw
    GROUP BY coin_name
  )
  
  AND price IS NOT NULL
  AND coin_name IS NOT NULL
  AND price > 0;
  
  GET DIAGNOSTICS v_records_cleaned = ROW_COUNT;
  
  RAISE NOTICE '====================================';
  RAISE NOTICE 'Cleaning completed successfully!';
  RAISE NOTICE 'Records cleaned: %', v_records_cleaned;
  RAISE NOTICE 'Time: %', NOW();
  RAISE NOTICE '====================================';
  
END;
$$;


call clean_cryptocurrency_data();


select *
from crypto_clean


select '===RAW DATA==' as section; 
SELECT * FROM crypto_raw ORDER BY fetched_at;

SELECT '=== CLEAN DATA ===' as section;
SELECT * FROM crypto_clean;























