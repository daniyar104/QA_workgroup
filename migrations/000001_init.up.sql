CREATE SCHEMA IF NOT EXISTS qaapp;

CREATE TABLE qaapp.users (
    id          BIGSERIAL PRIMARY KEY,
    provider    TEXT NOT NULL,
    external_id TEXT NOT NULL,
    email       TEXT,
    name        TEXT,
    created_at  TIMESTAMPTZ NOT NULL DEFAULT now(),
    UNIQUE (provider, external_id)
);

CREATE TABLE qaapp.quizzes (
    id           BIGSERIAL PRIMARY KEY,
    title        TEXT NOT NULL,
    description  TEXT,
    kind         TEXT NOT NULL CHECK (kind IN ('test', 'survey')),
    created_by   BIGINT NOT NULL REFERENCES qaapp.users(id),
    is_published BOOLEAN NOT NULL DEFAULT FALSE,
    created_at   TIMESTAMPTZ NOT NULL DEFAULT now()
);

CREATE TABLE qaapp.questions (
    id       BIGSERIAL PRIMARY KEY,
    quiz_id  BIGINT NOT NULL REFERENCES qaapp.quizzes(id) ON DELETE CASCADE,
    body     TEXT NOT NULL,
    type     TEXT NOT NULL CHECK (type IN ('single', 'multiple', 'text')),
    points   INT NOT NULL DEFAULT 1,
    position INT NOT NULL
);

CREATE TABLE qaapp.options (
    id          BIGSERIAL PRIMARY KEY,
    question_id BIGINT NOT NULL REFERENCES qaapp.questions(id) ON DELETE CASCADE,
    body        TEXT NOT NULL,
    is_correct  BOOLEAN NOT NULL DEFAULT FALSE,
    position    INT NOT NULL
);

CREATE TABLE qaapp.attempts (
    id          BIGSERIAL PRIMARY KEY,
    quiz_id     BIGINT NOT NULL REFERENCES qaapp.quizzes(id) ON DELETE CASCADE,
    user_id     BIGINT NOT NULL REFERENCES qaapp.users(id),
    started_at  TIMESTAMPTZ NOT NULL DEFAULT now(),
    finished_at TIMESTAMPTZ,
    score       INT
);

CREATE TABLE qaapp.attempt_answers (
    id          BIGSERIAL PRIMARY KEY,
    attempt_id  BIGINT NOT NULL REFERENCES qaapp.attempts(id) ON DELETE CASCADE,
    question_id BIGINT NOT NULL REFERENCES qaapp.questions(id),
    option_id   BIGINT REFERENCES qaapp.options(id),
    text_answer TEXT
);


CREATE INDEX idx_questions_quiz   ON qaapp.questions(quiz_id);
CREATE INDEX idx_options_question ON qaapp.options(question_id);
CREATE INDEX idx_attempts_user    ON qaapp.attempts(user_id);
CREATE INDEX idx_answers_attempt  ON qaapp.attempt_answers(attempt_id);