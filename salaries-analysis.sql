SELECT * FROM ds.ds_salaries;
USE ds;
DESCRIBE ds_salaries;

-- 1. apakah ada data yang null?
SELECT * FROM ds_salaries
WHERE work_year IS NULL
OR experience_level IS NULL
OR employment_type IS NULL
OR job_title IS NULL
OR salary IS NULL
OR salary_currency IS NULL
OR salary_in_usd IS NULL
OR employee_residence IS NULL
OR remote_ratio IS NULL
OR company_location IS NULL
OR company_size IS NULL;

-- 2. melihat job title ada apa aja
SELECT DISTINCT job_title
FROM ds_salaries
ORDER BY job_title;

-- 3. job title apa saja yang erkaitan dengan data analyst
SELECT DISTINCT job_title FROM ds_salaries
WHERE job_title LIKE '%data analyst'
ORDER BY job_title;

SELECT * FROM ds_salaries
WHERE job_title LIKE '%data analyst'
ORDER BY job_title;

-- 4. rerata nilai gaji data analyst (rupiah)
SELECT (AVG(salary_in_usd) * 15000)/12 AS avg_sal_rp_monthly
FROM ds_salaries;

-- 4.1 rerata nilai gaji data analyst berdasarkan experience level
SELECT experience_level, 
	(AVG(salary_in_usd) * 15000)/12 AS avg_sal_rp_monthly
FROM ds_salaries
GROUP BY experience_level;

-- 4.2 rerata nilai gaji data analyst berdasarkan experience level dan jenis employmentnya
SELECT experience_level, employment_type,
	(AVG(salary_in_usd) * 15000)/12 AS avg_sal_rp_monthly
FROM ds_salaries
GROUP BY experience_level, employment_type
ORDER BY experience_level,employment_type;

-- 5. Negara yang memberikan gaji menarik untuk posisi full time data analyst
SELECT company_location, 
	ROUND(AVG(salary_in_usd),0) AS avg_sal_loc
FROM ds_salaries
WHERE job_title LIKE '%data analyst%' 
	AND employment_type = 'FT'
	AND experience_level IN('MI', 'EN')
GROUP BY company_location
HAVING avg_sal_loc >= 22000
ORDER BY avg_sal_loc DESC;

-- periode kerja
SELECT DISTINCT work_year
FROM ds_salaries;

-- 6. di tahun berapa, kenaikan gaji dari mid ke senior itu memiliki gaji tertinggi
-- (catatan: pekerjaan data analyst yang full time)
WITH ds_1 AS (
    SELECT work_year, AVG(salary_in_usd) AS avg_sal_ex
    FROM ds_salaries
    WHERE employment_type = 'FT'
      AND experience_level = 'EX'
      AND job_title LIKE '%data analyst%'
    GROUP BY work_year
), 
ds_2 AS (
    SELECT work_year, AVG(salary_in_usd) AS avg_sal_mi
    FROM ds_salaries
    WHERE employment_type = 'FT'
      AND experience_level = 'MI'
      AND job_title LIKE '%data analyst%'
    GROUP BY work_year
),
t_year AS(
	SELECT DISTINCT work_year
    FROM ds_salaries
)
SELECT 
    t_year.work_year,
    ROUND(ds_1.avg_sal_ex, 2) AS avg_salary_ex, 
    ROUND(ds_2.avg_sal_mi, 2) AS avg_salary_mi,
    -- Hitung selisih langsung menggunakan kolom dari CTE
    ROUND(ds_1.avg_sal_ex - ds_2.avg_sal_mi, 2) AS difference
FROM t_year
LEFT JOIN ds_1 ON ds_1.work_year = t_year.work_year
LEFT JOIN ds_2 ON ds_2.work_year = t_year.work_year;
