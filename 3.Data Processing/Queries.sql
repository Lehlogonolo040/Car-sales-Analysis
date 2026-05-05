----------- Viewing table columns ---------------
SELECT *
FROM workspace.default.car_sales;

--------- Check start and end date of data collection ----------
SELECT MIN(saledate) AS Start_date,
       MAX(saledate) AS End_date
FROM workspace.default.car_sales;  --=== from 2015-04-03 to 2015-05-27

-------- Car brand available -----------
SELECT DISTINCT make
FROM workspace.default.car_sales

-------- checking duplicates -------------
SELECT make,
       COUNT(*) AS Total_record
FROM workspace.default.car_sales
GROUP BY make
HAVING COUNT(*) > 1 ;

SELECT
    year, make, model, trim, body, transmission,
    vin, state, condition, odometer, color,
    interior, seller, mmr, sellingprice, saledate,
    COUNT(*) AS duplicate_count
FROM workspace.default.car_sales
GROUP BY
    year, make, model, trim, body, transmission,
    vin, state, condition, odometer, color,
    interior, seller, mmr, sellingprice, saledate
HAVING COUNT(*) > 1
ORDER BY duplicate_count DESC;

--- EXPAND STATE ABBREVIATIONS TO FULL NAMES
SELECT
    *,
    CASE UPPER(TRIM(state))
        WHEN 'AL' THEN 'Alabama'
        WHEN 'AK' THEN 'Alaska'
        WHEN 'AZ' THEN 'Arizona'
        WHEN 'AR' THEN 'Arkansas'
        WHEN 'CA' THEN 'California'
        WHEN 'CO' THEN 'Colorado'
        WHEN 'CT' THEN 'Connecticut'
        WHEN 'DE' THEN 'Delaware'
        WHEN 'FL' THEN 'Florida'
        WHEN 'GA' THEN 'Georgia'
        WHEN 'HI' THEN 'Hawaii'
        WHEN 'ID' THEN 'Idaho'
        WHEN 'IL' THEN 'Illinois'
        WHEN 'IN' THEN 'Indiana'
        WHEN 'IA' THEN 'Iowa'
        WHEN 'KS' THEN 'Kansas'
        WHEN 'KY' THEN 'Kentucky'
        WHEN 'LA' THEN 'Louisiana'
        WHEN 'ME' THEN 'Maine'
        WHEN 'MD' THEN 'Maryland'
        WHEN 'MA' THEN 'Massachusetts'
        WHEN 'MI' THEN 'Michigan'
        WHEN 'MN' THEN 'Minnesota'
        WHEN 'MS' THEN 'Mississippi'
        WHEN 'MO' THEN 'Missouri'
        WHEN 'MT' THEN 'Montana'
        WHEN 'NE' THEN 'Nebraska'
        WHEN 'NV' THEN 'Nevada'
        WHEN 'NH' THEN 'New Hampshire'
        WHEN 'NJ' THEN 'New Jersey'
        WHEN 'NM' THEN 'New Mexico'
        WHEN 'NY' THEN 'New York'
        WHEN 'NC' THEN 'North Carolina'
        WHEN 'ND' THEN 'North Dakota'
        WHEN 'OH' THEN 'Ohio'
        WHEN 'OK' THEN 'Oklahoma'
        WHEN 'OR' THEN 'Oregon'
        WHEN 'PA' THEN 'Pennsylvania'
        WHEN 'RI' THEN 'Rhode Island'
        WHEN 'SC' THEN 'South Carolina'
        WHEN 'SD' THEN 'South Dakota'
        WHEN 'TN' THEN 'Tennessee'
        WHEN 'TX' THEN 'Texas'
        WHEN 'UT' THEN 'Utah'
        WHEN 'VT' THEN 'Vermont'
        WHEN 'VA' THEN 'Virginia'
        WHEN 'WA' THEN 'Washington'
        WHEN 'WV' THEN 'West Virginia'
        WHEN 'WI' THEN 'Wisconsin'
        WHEN 'WY' THEN 'Wyoming'
        WHEN 'DC' THEN 'District of Columbia'
        ELSE 'Unknown'
    END AS state_full_name
 
FROM workspace.default.car_sales;

--- See nulls & empty strings before cleaning
SELECT
    COUNT(*)                                                        AS total_rows, --== 558811
 
    -- Critical columns (drop row if NULL)
    SUM(CASE WHEN make        = '' OR make        IS NULL THEN 1 ELSE 0 END) AS null_make, --== 10301
    SUM(CASE WHEN model       = '' OR model       IS NULL THEN 1 ELSE 0 END) AS null_model, --== 10399
    SUM(CASE WHEN sellingprice IS NULL OR sellingprice = 0         THEN 1 ELSE 0 END) AS null_sellingprice, --== 12
    SUM(CASE WHEN saledate    = '' OR saledate    IS NULL THEN 1 ELSE 0 END) AS null_saledate, --== 12
 
    -- Non-critical columns (replace with default)
    SUM(CASE WHEN trim         = '' OR trim         IS NULL THEN 1 ELSE 0 END) AS null_trim, --== 10651
    SUM(CASE WHEN body         = '' OR body         IS NULL THEN 1 ELSE 0 END) AS null_body,  --== 13195
    SUM(CASE WHEN transmission = '' OR transmission IS NULL THEN 1 ELSE 0 END) AS null_transmission, --== 65352
    SUM(CASE WHEN condition    IS NULL                       THEN 1 ELSE 0 END) AS null_condition, --== 11794
    SUM(CASE WHEN odometer     IS NULL                       THEN 1 ELSE 0 END) AS null_odometer, --== 94
    SUM(CASE WHEN mmr          IS NULL                       THEN 1 ELSE 0 END) AS null_mmr, --== 12
    SUM(CASE WHEN color  IN ('', '—', '-') OR color  IS NULL THEN 1 ELSE 0 END) AS null_color, --== 25434
    SUM(CASE WHEN interior IN ('', '—', '-') OR interior IS NULL THEN 1 ELSE 0 END) AS null_interior --== 17825
 
FROM workspace.default.car_sales;

 ----  REPLACE empty strings — text columns
-- =============================================
 -- transmission: 65,352 missing (11.69%) → 'Unknown'
UPDATE workspace.default.car_sales
SET transmission = 'Unknown'
WHERE transmission IS NULL OR TRIM(transmission) = '';
 
-- body type: 13,195 missing (2.36%) → 'Unknown'
UPDATE workspace.default.car_sales
SET body = 'Unknown'
WHERE body IS NULL OR TRIM(body) = '';
 
-- trim level: 10,651 missing (1.91%) → 'Standard'
UPDATE workspace.default.car_sales
SET trim = 'Standard'
WHERE trim IS NULL OR TRIM(trim) = '';
 
-- color: 25,434 missing including 'not avail' strings → 'Not Specified'
UPDATE workspace.default.car_sales
SET color = 'Not Specified'
WHERE color IS NULL
   OR TRIM(color) = ''
   OR LOWER(TRIM(color)) IN ('not avail', 'none', 'na', 'n/a', '—', '-');
 
-- interior: 17,825 missing including 'not avail' strings → 'Not Specified'
UPDATE workspace.default.car_sales
SET interior = 'Not Specified'
WHERE interior IS NULL
   OR TRIM(interior) = ''
   OR LOWER(TRIM(interior)) IN ('not avail', 'none', 'na', 'n/a', '—', '-');
 
 
-- ============================================================
-- STEP 3: REPLACE NULL values — numeric columns
-- ============================================================
 
-- condition: 11,794 NULLs → 3.0 (midpoint of 1–5 scale)
UPDATE workspace.default.car_sales
SET condition = 3.0
WHERE condition IS NULL;
 
-- odometer: 94 NULLs → 0 (mileage unknown)
UPDATE workspace.default.car_sales
SET odometer = 0
WHERE odometer IS NULL;
 
-- mmr (cost price proxy): 12 NULLs → use sellingprice
-- assumes 0% margin when cost is unknown
UPDATE workspace.default.car_sales
SET mmr = sellingprice
WHERE mmr IS NULL;


--======================================================
--- Final Query 
--======================================================
 
SELECT
 
    -- --------------------------------------------------------
    -- 1. VEHICLE IDENTITY
    -- --------------------------------------------------------
    UPPER(TRIM(vin))                                                AS vin,
    UPPER(TRIM(make))                                               AS make,
    UPPER(TRIM(model))                                              AS model,
 
    CASE
        WHEN TRIM(trim) = '' OR trim IS NULL THEN 'Standard'
        ELSE INITCAP(TRIM(trim))
    END                                                             AS trim_level,
 
    CASE
        WHEN TRIM(body) = '' OR body IS NULL                        THEN 'Unknown'
        WHEN LOWER(TRIM(body)) IN (
            'crew cab','supercrew','supercab','regular cab',
            'extended cab','quad cab','king cab',
            'double cab','access cab')                              THEN 'Truck'
        WHEN LOWER(TRIM(body)) LIKE '%sedan%'                       THEN 'Sedan'
        ELSE INITCAP(TRIM(body))
    END                                                             AS body_type,
 
    CASE
        WHEN TRIM(transmission) = '' OR transmission IS NULL        THEN 'Unknown'
        ELSE INITCAP(TRIM(transmission))
    END                                                             AS transmission,
 
    -- --------------------------------------------------------
    -- 2. LOCATION
    -- --------------------------------------------------------
    UPPER(TRIM(state))                                              AS state_code,
 
    CASE UPPER(TRIM(state))
        WHEN 'AL' THEN 'Alabama'          WHEN 'AK' THEN 'Alaska'
        WHEN 'AZ' THEN 'Arizona'          WHEN 'AR' THEN 'Arkansas'
        WHEN 'CA' THEN 'California'       WHEN 'CO' THEN 'Colorado'
        WHEN 'CT' THEN 'Connecticut'      WHEN 'DE' THEN 'Delaware'
        WHEN 'FL' THEN 'Florida'          WHEN 'GA' THEN 'Georgia'
        WHEN 'HI' THEN 'Hawaii'           WHEN 'ID' THEN 'Idaho'
        WHEN 'IL' THEN 'Illinois'         WHEN 'IN' THEN 'Indiana'
        WHEN 'IA' THEN 'Iowa'             WHEN 'KS' THEN 'Kansas'
        WHEN 'KY' THEN 'Kentucky'         WHEN 'LA' THEN 'Louisiana'
        WHEN 'ME' THEN 'Maine'            WHEN 'MD' THEN 'Maryland'
        WHEN 'MA' THEN 'Massachusetts'    WHEN 'MI' THEN 'Michigan'
        WHEN 'MN' THEN 'Minnesota'        WHEN 'MS' THEN 'Mississippi'
        WHEN 'MO' THEN 'Missouri'         WHEN 'MT' THEN 'Montana'
        WHEN 'NE' THEN 'Nebraska'         WHEN 'NV' THEN 'Nevada'
        WHEN 'NH' THEN 'New Hampshire'    WHEN 'NJ' THEN 'New Jersey'
        WHEN 'NM' THEN 'New Mexico'       WHEN 'NY' THEN 'New York'
        WHEN 'NC' THEN 'North Carolina'   WHEN 'ND' THEN 'North Dakota'
        WHEN 'OH' THEN 'Ohio'             WHEN 'OK' THEN 'Oklahoma'
        WHEN 'OR' THEN 'Oregon'           WHEN 'PA' THEN 'Pennsylvania'
        WHEN 'RI' THEN 'Rhode Island'     WHEN 'SC' THEN 'South Carolina'
        WHEN 'SD' THEN 'South Dakota'     WHEN 'TN' THEN 'Tennessee'
        WHEN 'TX' THEN 'Texas'            WHEN 'UT' THEN 'Utah'
        WHEN 'VT' THEN 'Vermont'          WHEN 'VA' THEN 'Virginia'
        WHEN 'WA' THEN 'Washington'       WHEN 'WV' THEN 'West Virginia'
        WHEN 'WI' THEN 'Wisconsin'        WHEN 'WY' THEN 'Wyoming'
        WHEN 'DC' THEN 'District of Columbia'
        ELSE 'Unknown'
    END                                                             AS state_full_name,
 
    -- --------------------------------------------------------
    -- 3. APPEARANCE
    -- --------------------------------------------------------
    CASE
        WHEN color IS NULL
          OR TRIM(color) = ''
          OR LOWER(TRIM(color)) IN ('—','-','not avail','none','na','n/a')
                                                                    THEN 'Not Specified'
        ELSE INITCAP(TRIM(color))
    END                                                             AS color,
 
    CASE
        WHEN interior IS NULL
          OR TRIM(interior) = ''
          OR LOWER(TRIM(interior)) IN ('—','-','not avail','none','na','n/a')
                                                                    THEN 'Not Specified'
        ELSE INITCAP(TRIM(interior))
    END                                                             AS interior,
 
    -- --------------------------------------------------------
    -- 4. MANUFACTURE YEAR & VEHICLE AGE
    -- --------------------------------------------------------
    year                                                            AS manufacture_year,
 
    -- --------------------------------------------------------
    -- 5. DATE DIMENSIONS
    --    saledate format: 'Tue Dec 16 2014 12:30:00'
    --    Using REGEXP_EXTRACT + EXTRACT() — Spark 3.0 safe
    -- --------------------------------------------------------
 
    -- Extract 4-digit sale year using regex (no 'Y' pattern used)
    CAST(REGEXP_EXTRACT(TRIM(saledate), '(\\d{4})', 1) AS INT)     AS sale_year,
 
    -- Vehicle age at time of sale
    CAST(REGEXP_EXTRACT(TRIM(saledate), '(\\d{4})', 1) AS INT)
        - year                                                      AS vehicle_age_years,
 
    -- Extract month name from saledate string (position 5–7: 'Dec')
    -- Then map to month number for correct Power BI sorting
    TRIM(SPLIT(TRIM(saledate), ' ')[1])                             AS sale_month_name,
 
    CASE UPPER(TRIM(SPLIT(TRIM(saledate), ' ')[1]))
        WHEN 'JAN' THEN 1    WHEN 'FEB' THEN 2
        WHEN 'MAR' THEN 3    WHEN 'APR' THEN 4
        WHEN 'MAY' THEN 5    WHEN 'JUN' THEN 6
        WHEN 'JUL' THEN 7    WHEN 'AUG' THEN 8
        WHEN 'SEP' THEN 9    WHEN 'OCT' THEN 10
        WHEN 'NOV' THEN 11   WHEN 'DEC' THEN 12
        ELSE NULL
    END                                                             AS sale_month_num,
 
    -- Full month name (expanded) for display
    CASE UPPER(TRIM(SPLIT(TRIM(saledate), ' ')[1]))
        WHEN 'JAN' THEN 'January'    WHEN 'FEB' THEN 'February'
        WHEN 'MAR' THEN 'March'      WHEN 'APR' THEN 'April'
        WHEN 'MAY' THEN 'May'        WHEN 'JUN' THEN 'June'
        WHEN 'JUL' THEN 'July'       WHEN 'AUG' THEN 'August'
        WHEN 'SEP' THEN 'September'  WHEN 'OCT' THEN 'October'
        WHEN 'NOV' THEN 'November'   WHEN 'DEC' THEN 'December'
        ELSE 'Unknown'
    END                                                             AS sale_month_full,
 
    -- Quarter derived from month number — no date functions needed
    CASE UPPER(TRIM(SPLIT(TRIM(saledate), ' ')[1]))
        WHEN 'JAN' THEN 'Q1'  WHEN 'FEB' THEN 'Q1'  WHEN 'MAR' THEN 'Q1'
        WHEN 'APR' THEN 'Q2'  WHEN 'MAY' THEN 'Q2'  WHEN 'JUN' THEN 'Q2'
        WHEN 'JUL' THEN 'Q3'  WHEN 'AUG' THEN 'Q3'  WHEN 'SEP' THEN 'Q3'
        WHEN 'OCT' THEN 'Q4'  WHEN 'NOV' THEN 'Q4'  WHEN 'DEC' THEN 'Q4'
        ELSE 'Unknown'
    END                                                             AS sale_quarter,
 
    -- --------------------------------------------------------
    -- 6. NUMERIC FIELDS (cleaned)
    -- --------------------------------------------------------
    COALESCE(condition, 3.0)                                        AS condition_score,
    COALESCE(odometer, 0)                                           AS odometer_km,
    COALESCE(mmr, sellingprice)                                     AS cost_price,
    COALESCE(sellingprice, 0)                                       AS selling_price,
 
    -- Mileage bucket
    CASE
        WHEN COALESCE(odometer, 0) = 0                              THEN 'Unknown'
        WHEN odometer < 20000                                       THEN '1. 0–20k km'
        WHEN odometer < 50000                                       THEN '2. 20k–50k km'
        WHEN odometer < 100000                                      THEN '3. 50k–100k km'
        WHEN odometer < 150000                                      THEN '4. 100k–150k km'
        ELSE                                                             '5. 150k+ km'
    END                                                             AS mileage_bucket,
 
    -- Condition label
    CASE
        WHEN COALESCE(condition, 3) >= 4.5                          THEN 'Excellent'
        WHEN COALESCE(condition, 3) >= 3.5                          THEN 'Good'
        WHEN COALESCE(condition, 3) >= 2.5                          THEN 'Fair'
        ELSE                                                             'Poor'
    END                                                             AS condition_label,
 
    -- --------------------------------------------------------
    -- 7. KEY CALCULATED METRICS
    -- --------------------------------------------------------
    1                                                               AS units_sold,
 
    COALESCE(sellingprice, 0)                                       AS total_revenue,
 
    COALESCE(sellingprice, 0)
        - COALESCE(mmr, sellingprice)                               AS profit_per_unit,
 
    CASE
        WHEN COALESCE(sellingprice, 0) > 0
        THEN ROUND(
            (COALESCE(sellingprice, 0) - COALESCE(mmr, sellingprice))
            / COALESCE(sellingprice, 0) * 100, 2)
        ELSE 0
    END                                                             AS profit_margin_pct,
 
    -- Margin tier
    CASE
        WHEN COALESCE(sellingprice, 0) > 0
          AND ((COALESCE(sellingprice,0) - COALESCE(mmr, sellingprice))
               / COALESCE(sellingprice, 0) * 100) >= 15            THEN 'High Margin'
        WHEN COALESCE(sellingprice, 0) > 0
          AND ((COALESCE(sellingprice,0) - COALESCE(mmr, sellingprice))
               / COALESCE(sellingprice, 0) * 100) >= 5             THEN 'Medium Margin'
        ELSE                                                             'Low Margin'
    END                                                             AS margin_tier,
 
    -- Price segment
    CASE
        WHEN COALESCE(sellingprice, 0) < 10000                      THEN '1. Budget (< $10k)'
        WHEN sellingprice              < 20000                      THEN '2. Economy ($10k–$20k)'
        WHEN sellingprice              < 35000                      THEN '3. Mid-Range ($20k–$35k)'
        WHEN sellingprice              < 60000                      THEN '4. Premium ($35k–$60k)'
        ELSE                                                             '5. Luxury ($60k+)'
    END                                                             AS price_segment,
 
    INITCAP(TRIM(seller))                                           AS seller
 
FROM workspace.default.car_sales
 
-- --------------------------------------------------------
-- FILTERS: Remove rows that cause misleading insights
-- --------------------------------------------------------
WHERE
    make         IS NOT NULL AND TRIM(make)         <> ''
    AND model    IS NOT NULL AND TRIM(model)        <> ''
    AND vin      IS NOT NULL AND TRIM(vin)          <> ''
    AND saledate IS NOT NULL AND TRIM(saledate)     <> ''
    AND sellingprice IS NOT NULL
    AND sellingprice  > 0
    AND (mmr IS NULL OR mmr >= 0)
    AND year >= 1990
    AND year <= 2025
    AND (odometer IS NULL OR odometer >= 0)
 
-- Deduplicate VINs — keep latest sale (Spark QUALIFY support)
QUALIFY ROW_NUMBER() OVER (
    PARTITION BY vin
    ORDER BY CAST(REGEXP_EXTRACT(TRIM(saledate), '(\\d{4})', 1) AS INT) DESC,
             TRIM(saledate) DESC
) = 1;
