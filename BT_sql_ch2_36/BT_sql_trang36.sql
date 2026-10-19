create table members (
	id int generated always as identity primary key,
	full_name varchar(100) not null,
	email varchar(150) not null unique,
	joined_at timestamptz not null default now()
);

create table courses (
	id int generated always as identity primary key,
	title varchar(200) not null,
	capacity int not null check (capacity > 0)
);

create table registrations (
    id int generated always as identity primary key,
    member_id int not null references members (id),
    course_id int not null references courses (id),
    status varchar(20) not null default 'pending',
    registered_at timestamptz not null default now(),
    unique (member_id, course_id)
);

create index ix_reg_course on registrations (course_id);

insert into members (full_name, email) values
('Nguyễn An', 'an@dthu.edu.vn'),
('Trần Bình', 'binh@dthu.edu.vn'),
('Lê Chi', 'chi@dthu.edu.vn');

insert into courses (title, capacity) values
('Lập trình Web', 2), 
('Cơ sở dữ liệu', 40);

insert into registrations (member_id, course_id) values
(1, 1), 
(1, 2), 
(2, 1);

select c.title as ten_khoa_hoc
from registrations r
join members m on m.id = r.member_id
join courses c on c.id = r.course_id
where m.full_name = 'Nguyễn An';

select c.title as ten_khoa_hoc, count(r.id) as so_thanh_vien
from courses c
left join registrations r on r.course_id = c.id
group by c.id, c.title
order by so_thanh_vien desc;

begin;

insert into registrations (member_id, course_id)
values (
    (select id from members where full_name = 'Lê Chi'),
    (select id from courses where title = 'Cơ sở dữ liệu')
);

commit;


select m.full_name, c.title, r.status
from registrations r
join members m on m.id = r.member_id
join courses c on c.id = r.course_id
where m.full_name = 'Lê Chi';