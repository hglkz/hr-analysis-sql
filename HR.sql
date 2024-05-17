USE hr;

/*KPIs: Number of hired employees*/
SELECT COUNT(DISTINCT employee_id) AS active_employee
FROM hr1
WHERE status = 'Active';

/*KPIs: Turnover rate in the past 6 months--assuming 'today' is 2020/1/1*/
/*Using the following formula: ((no. of employee left) / ((no. of employee now + no. of employee then)/2)) *100 */
SELECT 
 departed_employee,
 ROUND((active_employee_now + active_employee_then)/2, 0) AS avg_active_employee,
 ROUND((departed_employee/(active_employee_now + active_employee_then)/2)*100, 2) AS turnover_rate
FROM (
    SELECT
        COUNT(DISTINCT CASE WHEN leave_date > '2019-07-01' THEN employee_id END) AS departed_employee,
        COUNT(DISTINCT CASE WHEN status = 'Active' THEN employee_id END) AS active_employee_now,
        COUNT(DISTINCT CASE WHEN hire_date <= '2019-07-01' AND (leave_date IS NULL OR leave_date > '2019-07-01') THEN employee_id END) AS active_employee_then
    FROM hr1
) AS turnover_calculation;

/*KPIs: Average satisfaction*/
SELECT 
 ROUND(AVG(employee_satisfaction), 2) AS avg_satisfaction,
 MAX(employee_satisfaction) AS max_possible_score
FROM hr1
WHERE status = 'Active';

/*KPIs: Distribution of performance ratings*/
SELECT
 COUNT(CASE WHEN performance = 'Exceeds' THEN employee_id END) AS exceeds,
 COUNT(CASE WHEN performance = 'Fully Meets' THEN employee_id END) AS fully_meets,
 COUNT(CASE WHEN performance = 'Needs Improvement' THEN employee_id END) AS need_improvement, 
 COUNT(CASE WHEN performance = 'PIP' THEN employee_id END) AS pip
FROM hr1
WHERE status = 'Active';

/*YoY: Number of employees, hiring rate, turnover rate*/
WITH i AS(
 SELECT 
  COUNT(DISTINCT CASE WHEN YEAR(hire_date) <= '2019' THEN employee_id END)
     - COUNT(DISTINCT CASE WHEN YEAR(leave_date) <= '2019' THEN employee_id END) AS no_of_employee_2019, 
  COUNT(DISTINCT CASE WHEN YEAR(hire_date) <= '2018' THEN employee_id END) 
     - COUNT(DISTINCT CASE WHEN YEAR(leave_date) <= '2018' THEN employee_id END) AS no_of_employee_2018, 
  COUNT(DISTINCT CASE WHEN YEAR(hire_date) <= '2017' THEN employee_id END)
    - COUNT(DISTINCT CASE WHEN YEAR(leave_date) <= '2017' THEN employee_id END) AS no_of_employee_2017, 
  COUNT(DISTINCT CASE WHEN YEAR(hire_date) <= '2016' THEN employee_id END)
   - COUNT(DISTINCT CASE WHEN YEAR(leave_date) <= '2016' THEN employee_id END) AS no_of_employee_2016,
  COUNT(DISTINCT CASE WHEN YEAR(hire_date) <= '2015' THEN employee_id END)
   - COUNT(DISTINCT CASE WHEN YEAR(leave_date) <= '2015' THEN employee_id END) AS no_of_employee_2015,
  COUNT(DISTINCT CASE WHEN YEAR(hire_date) = '2014' THEN employee_id END) AS no_of_employee_2014
 FROM hr1
)
SELECT no_of_employee_2019,
 no_of_employee_2018,
 no_of_employee_2017,
 no_of_employee_2016,
 no_of_employee_2015,
 no_of_employee_2014,
 
 ROUND(no_of_employee_2019/no_of_employee_2018, 2) AS hiring_rate_2019,
 ROUND(no_of_employee_2018/no_of_employee_2017, 2) AS hiring_rate_2018,
 ROUND(no_of_employee_2017/no_of_employee_2016, 2) AS hiring_rate_2017,
 ROUND(no_of_employee_2016/no_of_employee_2015, 2) AS hiring_rate_2016,
 ROUND(no_of_employee_2015/no_of_employee_2014, 2) AS hiring_rate_2015,

 ROUND((no_of_employee_2019 - no_of_employee_2018)*100/((no_of_employee_2019 + no_of_employee_2018))/2, 2) AS turnover_rate_2019,
 ROUND((no_of_employee_2018 - no_of_employee_2017)*100/((no_of_employee_2018 + no_of_employee_2017))/2, 2) AS turnover_rate_2018,
 ROUND((no_of_employee_2017 - no_of_employee_2016)*100/((no_of_employee_2017 + no_of_employee_2016))/2, 2) AS turnover_rate_2017,
 ROUND((no_of_employee_2016 - no_of_employee_2015)*100/((no_of_employee_2016 + no_of_employee_2015))/2, 2) AS turnover_rate_2016,
 ROUND((no_of_employee_2015 - no_of_employee_2014)*100/((no_of_employee_2015 + no_of_employee_2014))/2, 2) AS turnover_rate_2015
FROM i;

/*Demographics: Employee distribution by age and gender*/
SELECT gender, COUNT(DISTINCT employee_id)
FROM hr1
GROUP BY gender;

SELECT ROUND(AVG(age), 2), ROUND(STDDEV(age), 3)
FROM hr1;

/*Demographics: Employee distribution by level and gender (DE&I)*/
SELECT gender, manager, COUNT(DISTINCT employee_id)
FROM hr1
GROUP BY gender, manager
ORDER BY gender, manager;
