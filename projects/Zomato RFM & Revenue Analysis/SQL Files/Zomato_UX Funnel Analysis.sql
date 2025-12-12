# Which channel brings in most users?
select utm_source, count(*) AS Sessions,
ROUND(count(*) * 100 / sum(count(*)) OVER(),2) AS percent_channel_wise
from app_sessions
group by utm_source;

