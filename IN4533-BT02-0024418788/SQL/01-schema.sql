-- Bang thanh vien (members)
CREATE TABLE members (
    id        INT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    full_name VARCHAR(100) NOT NULL,
    email     VARCHAR(150) NOT NULL UNIQUE,
    joined_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- Bang khoa hoc (courses)
CREATE TABLE courses (
    id       INT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    title    VARCHAR(200) NOT NULL,
    capacity INT NOT NULL CHECK (capacity > 0)
);

-- Bang trung gian phieu dang ky (registrations)
CREATE TABLE registrations (
    id            INT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    member_id     INT NOT NULL REFERENCES members (id),
    course_id     INT NOT NULL REFERENCES courses (id),
    status        VARCHAR(20) NOT NULL DEFAULT 'pending'
                  CHECK (status IN ('pending', 'confirmed', 'cancelled')),
    registered_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    UNIQUE (member_id, course_id)
);

-- Index ho tro truy van theo khoa hoc va thanh vien
CREATE INDEX ix_reg_course ON registrations (course_id);
CREATE INDEX ix_reg_member ON registrations (member_id);