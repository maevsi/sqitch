BEGIN;

SELECT id,
       name,
       icon_svg,
       url,
       url_attendance,
       created_at,
       created_by
FROM vibetype.app WHERE FALSE;

ROLLBACK;
