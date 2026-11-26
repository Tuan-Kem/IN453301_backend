-- (a) Ho ten thanh vien va ten khoa hoc cua cac phieu confirmed, sap xep theo ho ten
SELECT m.full_name, c.title
FROM registrations r
JOIN members m ON m.id = r.member_id
JOIN courses c ON c.id = r.course_id
WHERE r.status = 'confirmed'
ORDER BY m.full_name;

-- (b) So phieu dang ky cua tung khoa hoc, ke ca khoa chua co phieu nao
SELECT c.title, COUNT(r.id) AS so_dang_ky
FROM courses c
LEFT JOIN registrations r ON r.course_id = c.id
GROUP BY c.id, c.title;

-- (c) Cac thanh vien chua dang ky khoa nao
SELECT m.full_name
FROM members m
LEFT JOIN registrations r ON r.member_id = m.id
WHERE r.id IS NULL;