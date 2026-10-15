-- Enable pgvector extension to store embeddings
CREATE EXTENSION IF NOT EXISTS vector;

-- Create Teams table, representing all NBA teams
CREATE TABLE IF NOT EXISTS teams (
    id  SERIAL PRIMARY KEY,
    team_id INTEGER UNIQUE NOT NULL, 
    name TEXT NOT NULL,
    abbreviation TEXT NOT NULL,
    city TEXT NOT NULL,
    conference TEXT,
    division TEXT
);

-- Players table, representing NBA players
CREATE TABLE IF NOT EXISTS players (
    id  SERIAL PRIMARY KEY,
    player_id INTEGER UNIQUE NOT NULL,
    full_name TEXT NOT NULL,
    team_id INTEGER REFERENCES teams(team_id),
    position TEXT,
    is_active BOOLEAN DEFAULT TRUE
);

-- Player season stats table
CREATE TABLE IF NOT EXISTS player_stats (
    id  SERIAL PRIMARY KEY,
    player_id INTEGER REFERENCES players(player_id),
    season TEXT NOT NULL,
    games_played INTEGER,
    points_per_game NUMERIC(5, 2),
    rebounds_per_game NUMERIC(5, 2),
    assists_per_game NUMERIC(5, 2),
    fg_percentage NUMERIC(5, 3),
    three_point_percentage NUMERIC(5, 3),
    ft_percentage NUMERIC(5, 3),
    minutes_per_game NUMERIC(5, 2),
    UNIQUE(player_id, season)
);

-- Articles table, the unstructured data we will be using (like news articles, scouting reports etc.) for RAG
-- embedding column stores the Voyage AI vector (1024 dimensions)
CREATE TABLE IF NOT EXISTS articles (
    id SERIAL PRIMARY KEY,
    title TEXT NOT NULL,
    content TEXT NOT NULL,
    source TEXT,
    url TEXT UNIQUE,
    published_at TIMESTAMPTZ,
    embedding vector(1024)
);

-- Create Index for fast vector similarity search
CREATE INDEX IF NOT EXISTS articles_embedding_idx
    ON articles
    USING ivfflat (embedding vector_cosine_ops)
    WITH (lists = 100);
