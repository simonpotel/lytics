CREATE TABLE IF NOT EXISTS users (
    id            SERIAL PRIMARY KEY,
    password_hash TEXT NOT NULL,
    created_at    TIMESTAMPTZ NOT NULL DEFAULT now()
);

CREATE TABLE IF NOT EXISTS projects (
    id          SERIAL PRIMARY KEY,
    user_id     INTEGER NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    name        TEXT NOT NULL,
    slug        TEXT NOT NULL UNIQUE,
    created_at  TIMESTAMPTZ NOT NULL DEFAULT now(),
    updated_at  TIMESTAMPTZ NOT NULL DEFAULT now()
);

CREATE TABLE IF NOT EXISTS markdown_pages (
    id            SERIAL PRIMARY KEY,
    project_id    INTEGER NOT NULL REFERENCES projects(id) ON DELETE CASCADE,
    title         TEXT NOT NULL,
    content       TEXT NOT NULL,          
    created_at    TIMESTAMPTZ NOT NULL DEFAULT now(),
    updated_at    TIMESTAMPTZ NOT NULL DEFAULT now()
);

DO $$ 
BEGIN
        IF NOT EXISTS (SELECT 1 FROM pg_type WHERE typname = 'column_type') THEN
                CREATE TYPE column_type AS ENUM (
                    'text','number','select','multi_select',
                    'status','date','checkbox','url',
                    'files_and_media','phone','created_time','created_by'
                );
        END IF;
END $$;

CREATE TABLE IF NOT EXISTS table_columns (
    id          SERIAL PRIMARY KEY,
    project_id  INTEGER NOT NULL REFERENCES projects(id) ON DELETE CASCADE,
    name        TEXT NOT NULL,
    type        column_type NOT NULL,
    options     JSONB,                        
    position    INTEGER NOT NULL DEFAULT 0,  
    created_at  TIMESTAMPTZ NOT NULL DEFAULT now(),
    updated_at  TIMESTAMPTZ NOT NULL DEFAULT now()
);

CREATE TABLE IF NOT EXISTS table_rows (
    id            SERIAL PRIMARY KEY,
    project_id    INTEGER NOT NULL REFERENCES projects(id) ON DELETE CASCADE,
    created_by    INTEGER REFERENCES users(id),
    created_time  TIMESTAMPTZ NOT NULL DEFAULT now(),
    updated_time  TIMESTAMPTZ NOT NULL DEFAULT now()
);


CREATE TABLE IF NOT EXISTS table_cells (
    id           SERIAL PRIMARY KEY,
    row_id       INTEGER NOT NULL REFERENCES table_rows(id) ON DELETE CASCADE,
    column_id    INTEGER NOT NULL REFERENCES table_columns(id) ON DELETE CASCADE,
    value        JSONB,                        
    created_at   TIMESTAMPTZ NOT NULL DEFAULT now(),
    updated_at   TIMESTAMPTZ NOT NULL DEFAULT now(),
    UNIQUE (row_id, column_id)                 
);

CREATE TABLE IF NOT EXISTS uploads (
    id          SERIAL PRIMARY KEY,
    project_id  INTEGER REFERENCES projects(id),
    filename    TEXT NOT NULL,
    url         TEXT NOT NULL,
    mime_type   TEXT,
    size_bytes  INTEGER,
    uploaded_at TIMESTAMPTZ NOT NULL DEFAULT now()
);
