-- ============================================
-- TOKER DATABASE SCHEMA
-- Production-ready SQL schema for dating app
-- Compatible with PostgreSQL (recommended)
-- ============================================

-- Enable UUID extension (PostgreSQL)
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

-- ============================================
-- REFERENCE TABLES (Static Data)
-- ============================================

-- Table: interests
-- Stores all available interest tags
CREATE TABLE interests (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    name VARCHAR(100) NOT NULL UNIQUE,
    category VARCHAR(50), -- 'sports', 'arts', 'food', 'tech', etc.
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Table: prompts
-- Stores all available prompt questions
CREATE TABLE prompts (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    question TEXT NOT NULL UNIQUE,
    category VARCHAR(50) NOT NULL, -- 'aboutMe', 'myType', 'myWorld', 'selfCare', 'personal', 'photoCaption'
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- ============================================
-- USER TABLES
-- ============================================

-- Table: users
-- Core user profile information
CREATE TABLE users (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    tiktok_id VARCHAR(255) UNIQUE, -- TikTok OAuth identifier
    name VARCHAR(100) NOT NULL,
    age INTEGER NOT NULL CHECK (age >= 18 AND age <= 100),
    birthdate DATE,
    gender VARCHAR(20) NOT NULL CHECK (gender IN ('Male', 'Female', 'Non-binary')),
    bio TEXT,
    location VARCHAR(255),
    interested_in VARCHAR(20) NOT NULL CHECK (interested_in IN ('Men', 'Women', 'Everyone')),
    
    -- Account metadata
    is_premium BOOLEAN DEFAULT FALSE,
    is_active BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    last_active_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    
    -- Indexes for performance
    CONSTRAINT users_name_check CHECK (LENGTH(name) >= 2)
);

CREATE INDEX idx_users_tiktok_id ON users(tiktok_id);
CREATE INDEX idx_users_location ON users(location);
CREATE INDEX idx_users_interested_in ON users(interested_in);
CREATE INDEX idx_users_is_active ON users(is_active);

-- Table: user_interests
-- Many-to-many relationship between users and interests
CREATE TABLE user_interests (
    user_id UUID REFERENCES users(id) ON DELETE CASCADE,
    interest_id UUID REFERENCES interests(id) ON DELETE CASCADE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (user_id, interest_id)
);

CREATE INDEX idx_user_interests_user_id ON user_interests(user_id);
CREATE INDEX idx_user_interests_interest_id ON user_interests(interest_id);

-- Table: user_photos
-- Stores user profile photos
CREATE TABLE user_photos (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID REFERENCES users(id) ON DELETE CASCADE,
    photo_url TEXT NOT NULL,
    position INTEGER NOT NULL CHECK (position >= 0 AND position <= 5), -- 0-5 (max 6 photos)
    caption TEXT, -- Optional caption
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    
    UNIQUE(user_id, position)
);

CREATE INDEX idx_user_photos_user_id ON user_photos(user_id);

-- Table: user_prompts
-- Stores user's answers to prompts
CREATE TABLE user_prompts (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID REFERENCES users(id) ON DELETE CASCADE,
    prompt_id UUID REFERENCES prompts(id) ON DELETE CASCADE,
    answer TEXT NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    
    UNIQUE(user_id, prompt_id)
);

CREATE INDEX idx_user_prompts_user_id ON user_prompts(user_id);

-- ============================================
-- MATCHING & INTERACTION TABLES
-- ============================================

-- Table: swipes
-- Records all swipe actions (like/pass)
CREATE TABLE swipes (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    from_user_id UUID REFERENCES users(id) ON DELETE CASCADE,
    to_user_id UUID REFERENCES users(id) ON DELETE CASCADE,
    action VARCHAR(10) NOT NULL CHECK (action IN ('like', 'pass', 'superlike')),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    
    UNIQUE(from_user_id, to_user_id)
);

CREATE INDEX idx_swipes_from_user ON swipes(from_user_id);
CREATE INDEX idx_swipes_to_user ON swipes(to_user_id);
CREATE INDEX idx_swipes_action ON swipes(action);

-- Table: matches
-- Stores mutual likes (matches)
CREATE TABLE matches (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user1_id UUID REFERENCES users(id) ON DELETE CASCADE,
    user2_id UUID REFERENCES users(id) ON DELETE CASCADE,
    matched_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    compatibility_score DECIMAL(5,2), -- 0.00 to 100.00
    is_active BOOLEAN DEFAULT TRUE, -- FALSE if unmatched
    
    -- Ensure user1_id < user2_id to avoid duplicates
    CHECK (user1_id < user2_id),
    UNIQUE(user1_id, user2_id)
);

CREATE INDEX idx_matches_user1 ON matches(user1_id);
CREATE INDEX idx_matches_user2 ON matches(user2_id);
CREATE INDEX idx_matches_matched_at ON matches(matched_at DESC);

-- Table: messages
-- Chat messages between matched users
CREATE TABLE messages (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    match_id UUID REFERENCES matches(id) ON DELETE CASCADE,
    sender_id UUID REFERENCES users(id) ON DELETE CASCADE,
    receiver_id UUID REFERENCES users(id) ON DELETE CASCADE,
    content TEXT NOT NULL,
    is_read BOOLEAN DEFAULT FALSE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    
    CONSTRAINT messages_content_check CHECK (LENGTH(content) > 0)
);

CREATE INDEX idx_messages_match_id ON messages(match_id);
CREATE INDEX idx_messages_sender_id ON messages(sender_id);
CREATE INDEX idx_messages_receiver_id ON messages(receiver_id);
CREATE INDEX idx_messages_created_at ON messages(created_at DESC);

-- ============================================
-- PREMIUM FEATURES TABLES
-- ============================================

-- Table: standouts
-- Tracks which profiles are shown as "standouts" to users
CREATE TABLE standouts (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID REFERENCES users(id) ON DELETE CASCADE,
    standout_user_id UUID REFERENCES users(id) ON DELETE CASCADE,
    shown_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    expires_at TIMESTAMP NOT NULL -- Standouts refresh daily
);

-- Unique constraint on date part of shown_at (Functional Index)
CREATE UNIQUE INDEX idx_standouts_unique_daily ON standouts (user_id, standout_user_id, (shown_at::DATE));

CREATE INDEX idx_standouts_user_id ON standouts(user_id);
CREATE INDEX idx_standouts_expires_at ON standouts(expires_at);

-- ============================================
-- HELPER FUNCTIONS
-- ============================================

-- Function: Update updated_at timestamp automatically
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = CURRENT_TIMESTAMP;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Trigger: Auto-update users.updated_at
CREATE TRIGGER update_users_updated_at
    BEFORE UPDATE ON users
    FOR EACH ROW
    EXECUTE FUNCTION update_updated_at_column();

-- ============================================
-- VIEWS FOR COMMON QUERIES
-- ============================================

-- View: Complete user profiles with all related data
CREATE VIEW user_profiles_complete AS
SELECT 
    u.id,
    u.name,
    u.age,
    u.birthdate,
    u.gender,
    u.bio,
    u.location,
    u.interested_in,
    u.is_premium,
    u.created_at,
    
    -- Aggregate interests
    COALESCE(
        json_agg(DISTINCT i.name) FILTER (WHERE i.name IS NOT NULL),
        '[]'::json
    ) AS interests,
    
    -- Aggregate photos
    COALESCE(
        json_agg(
            json_build_object(
                'url', p.photo_url,
                'position', p.position,
                'caption', p.caption
            ) ORDER BY p.position
        ) FILTER (WHERE p.photo_url IS NOT NULL),
        '[]'::json
    ) AS photos,
    
    -- Aggregate prompts
    COALESCE(
        json_agg(
            json_build_object(
                'question', pr.question,
                'answer', up.answer,
                'category', pr.category
            )
        ) FILTER (WHERE pr.question IS NOT NULL),
        '[]'::json
    ) AS prompts
    
FROM users u
LEFT JOIN user_interests ui ON u.id = ui.user_id
LEFT JOIN interests i ON ui.interest_id = i.id
LEFT JOIN user_photos p ON u.id = p.user_id
LEFT JOIN user_prompts up ON u.id = up.user_id
LEFT JOIN prompts pr ON up.prompt_id = pr.id
GROUP BY u.id;

-- View: Match list with last message info
CREATE VIEW matches_with_messages AS
SELECT 
    m.id AS match_id,
    m.user1_id,
    m.user2_id,
    m.matched_at,
    m.compatibility_score,
    msg.content AS last_message,
    msg.created_at AS last_message_time,
    msg.sender_id AS last_message_sender_id,
    CASE 
        WHEN msg.is_read = FALSE AND msg.receiver_id = m.user1_id THEN TRUE
        WHEN msg.is_read = FALSE AND msg.receiver_id = m.user2_id THEN TRUE
        ELSE FALSE
    END AS has_unread
FROM matches m
LEFT JOIN LATERAL (
    SELECT content, created_at, sender_id, receiver_id, is_read
    FROM messages
    WHERE match_id = m.id
    ORDER BY created_at DESC
    LIMIT 1
) msg ON TRUE
WHERE m.is_active = TRUE;

-- ============================================
-- SAMPLE DATA INSERTION
-- ============================================

-- Insert sample interests (from MockDataService)
INSERT INTO interests (name, category) VALUES
-- Sports & Fitness
('Gaming', 'sports'), ('Sport', 'sports'), ('Fitness', 'sports'), ('Yoga', 'sports'),
('Randonnée', 'sports'), ('Course à pied', 'sports'), ('Vélo', 'sports'), ('Natation', 'sports'),
('Basketball', 'sports'), ('Football', 'sports'), ('Tennis', 'sports'), ('Golf', 'sports'),
('Ski', 'sports'), ('Snowboard', 'sports'), ('Surf', 'sports'), ('Escalade', 'sports'),
('Boxe', 'sports'), ('Danse', 'sports'), ('Pilates', 'sports'), ('Crossfit', 'sports'),

-- Arts & Culture
('Art', 'arts'), ('Photographie', 'arts'), ('Musique', 'arts'), ('Cinéma', 'arts'),
('Concerts', 'arts'), ('Théâtre', 'arts'), ('Musées', 'arts'), ('Lecture', 'arts'),
('Écriture', 'arts'), ('Poésie', 'arts'), ('Peinture', 'arts'), ('Dessin', 'arts'),
('Sculpture', 'arts'), ('Films', 'arts'), ('Anime', 'arts'), ('Manga', 'arts'),
('BD', 'arts'), ('Graffiti', 'arts'), ('Design', 'arts'), ('Architecture', 'arts'),

-- Food & Drinks
('Cuisine', 'food'), ('Pâtisserie', 'food'), ('Café', 'food'), ('Vin', 'food'),
('Cocktails', 'food'), ('Bière', 'food'), ('Thé', 'food'), ('Restaurants', 'food'),
('Street Food', 'food'), ('Vegan', 'food'), ('Végétarien', 'food'), ('Gâteaux', 'food'),
('BBQ', 'food'), ('Sushi', 'food'),

-- Tech & Innovation
('Tech', 'tech'), ('Programmation', 'tech'), ('IA', 'tech'), ('Crypto', 'tech'),
('Startups', 'tech'), ('Innovation', 'tech'), ('Gaming PC', 'tech'), ('VR', 'tech'),
('Robotique', 'tech'), ('Science', 'tech'), ('Espace', 'tech'), ('Astronomie', 'tech'),

-- Travel & Adventure
('Voyage', 'travel'), ('Backpacking', 'travel'), ('Road Trips', 'travel'), ('Camping', 'travel'),
('Aventure', 'travel'), ('Exploration', 'travel'), ('Plage', 'travel'), ('Montagne', 'travel'),
('City Breaks', 'travel'), ('Festivals', 'travel'),

-- Lifestyle & Hobbies
('Mode', 'lifestyle'), ('Shopping', 'lifestyle'), ('Maquillage', 'lifestyle'), ('Skincare', 'lifestyle'),
('Tattoos', 'lifestyle'), ('Piercings', 'lifestyle'), ('Vintage', 'lifestyle'), ('Friperie', 'lifestyle'),
('DIY', 'lifestyle'), ('Jardinage', 'lifestyle'), ('Décoration', 'lifestyle'), ('Animaux', 'lifestyle'),
('Chiens', 'lifestyle'), ('Chats', 'lifestyle'),

-- Entertainment
('Netflix', 'entertainment'), ('Séries', 'entertainment'), ('Télé-réalité', 'entertainment'),
('Podcasts', 'entertainment'), ('Stand-up', 'entertainment'), ('Karaoké', 'entertainment'),
('Jeux de société', 'entertainment'), ('Escape Game', 'entertainment'), ('Bowling', 'entertainment'),
('Billard', 'entertainment'), ('Karting', 'entertainment'), ('Laser Game', 'entertainment'),

-- Music Genres
('Rock', 'music'), ('Pop', 'music'), ('Hip-Hop', 'music'), ('Rap', 'music'),
('Jazz', 'music'), ('Blues', 'music'), ('Électro', 'music'), ('House', 'music'),
('Techno', 'music'), ('R&B', 'music'), ('Soul', 'music'), ('Reggae', 'music'),
('Metal', 'music'), ('Indie', 'music'), ('Folk', 'music'), ('Classique', 'music'),

-- Misc
('Méditation', 'misc'), ('Spiritualité', 'misc'), ('Astrologie', 'misc'), ('Psychologie', 'misc'),
('Philosophie', 'misc'), ('Histoire', 'misc'), ('Politique', 'misc'), ('Activisme', 'misc'),
('Bénévolat', 'misc'), ('Développement durable', 'misc'), ('Écologie', 'misc');

-- Insert sample prompts
INSERT INTO prompts (question, category) VALUES
-- About Me
('Dans mon groupe d''amis je suis...', 'aboutMe'),
('Le truc le plus random que j''adore...', 'aboutMe'),
('Mon talent caché c''est...', 'aboutMe'),
('Un truc sur moi que personne ne devine...', 'aboutMe'),
('Ce qui me rend unique...', 'aboutMe'),

-- My Type
('On s''entendra si...', 'myType'),
('Ce que je cherche chez quelqu''un...', 'myType'),
('Le meilleur premier date serait...', 'myType'),
('Je suis attiré(e) par...', 'myType'),

-- My World
('Ma passion secrète c''est...', 'myWorld'),
('Mon endroit préféré au monde...', 'myWorld'),
('Je ne peux pas vivre sans...', 'myWorld'),
('Ma définition d''une bonne soirée...', 'myWorld'),

-- Self Care
('Pour me détendre je...', 'selfCare'),
('Mon rituel du matin c''est...', 'selfCare'),
('Ce qui me fait du bien...', 'selfCare'),

-- Personal
('Ma plus grande fierté...', 'personal'),
('Le meilleur conseil qu''on m''ait donné...', 'personal'),
('Si je pouvais dîner avec quelqu''un...', 'personal'),
('Ce qui me fait rire à coup sûr...', 'personal'),

-- Photo Captions
('Quand je me la joue sérieux', 'photoCaption'),
('Mode vacances activé', 'photoCaption'),
('Dimanche typique', 'photoCaption'),
('Ma passion en image', 'photoCaption'),
('Avec mes gens préférés', 'photoCaption'),
('Moment de fierté', 'photoCaption'),
('Juste moi étant moi', 'photoCaption'),
('Aventure du jour', 'photoCaption'),
('Mon endroit favori', 'photoCaption'),
('Vibes du moment', 'photoCaption'),
('En mode détente', 'photoCaption'),
('Souvenir inoubliable', 'photoCaption');

-- ============================================
-- NOTES FOR BACKEND TEAM
-- ============================================

/*
IMPORTANT IMPLEMENTATION NOTES:

1. AUTHENTICATION:
   - Store TikTok OAuth tokens in a separate 'auth_tokens' table (not included here for security)
   - Use JWT for session management
   - Implement refresh token rotation

2. MATCHING ALGORITHM:
   - Calculate compatibility_score based on common interests
   - Use the user_interests table for efficient matching queries
   - Consider implementing a separate 'user_preferences' table for filters (age range, distance, etc.)

3. PERFORMANCE:
   - All critical foreign keys have indexes
   - Use the views for complex queries to simplify API code
   - Consider implementing Redis caching for frequently accessed profiles

4. PHOTO STORAGE:
   - Store only URLs in the database
   - Use cloud storage (S3, GCS, Azure Blob) for actual files
   - Implement CDN for fast image delivery

5. PRIVACY & SECURITY:
   - Implement soft deletes for user accounts (add 'deleted_at' column)
   - Log all swipe actions for analytics and abuse prevention
   - Add rate limiting on API level to prevent spam

6. SCALABILITY:
   - Consider partitioning the 'messages' table by date for large-scale deployments
   - Use read replicas for the discovery feed queries
   - Implement database connection pooling

7. MIGRATIONS:
   - Use a migration tool (Flyway, Liquibase, Alembic) to version control schema changes
   - Test migrations on staging before production deployment
*/
