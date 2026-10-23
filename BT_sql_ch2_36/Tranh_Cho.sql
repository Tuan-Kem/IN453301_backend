BEGIN;

SELECT capacity FROM courses WHERE id = 2 FOR UPDATE;

INSERT INTO registrations (member_id, course_id)
SELECT 
    (SELECT id FROM members WHERE full_name = 'Lê Chi'), 
    2
WHERE 
    (SELECT capacity FROM courses WHERE id = 2) > 
    (SELECT COUNT(*) FROM registrations WHERE course_id = 2);

COMMIT;