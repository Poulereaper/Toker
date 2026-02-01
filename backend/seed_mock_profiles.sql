-- ============================================
-- SEED DATA script for Toker Database
-- Adds ~30 Mock Profiles (Users, Photos, Interests, Prompts)
-- FIXED: Uses valid UUIDs instead of simple strings
-- ============================================

-- Function to get interest ID by name (helper)
CREATE OR REPLACE FUNCTION get_interest_id(interest_name TEXT) 
RETURNS UUID AS $$
    SELECT id FROM interests WHERE name = interest_name LIMIT 1;
$$ LANGUAGE SQL;

-- Function to get prompt ID by question (helper)
CREATE OR REPLACE FUNCTION get_prompt_id(prompt_question TEXT) 
RETURNS UUID AS $$
    SELECT id FROM prompts WHERE question = prompt_question LIMIT 1;
$$ LANGUAGE SQL;

-- ============================================
-- 1. INSERT MOCK USERS (30 Profiles)
-- IDs are deterministic UUIDs for safe referencing
-- Pattern: a0000000-0000-0000-0000-0000000000XX
-- ============================================

-- 1. Emma (F, 24)
INSERT INTO users (id, tiktok_id, name, age, birthdate, gender, bio, location, interested_in) VALUES 
('a0000000-0000-0000-0000-000000000001', 'tk_emma', 'Emma', 24, '2000-05-15', 'Female', 'Amoureuse de voyages ✈️. Toujours partante pour un verre !', 'Paris, France', 'Men');

-- 2. Lucas (M, 26)
INSERT INTO users (id, tiktok_id, name, age, birthdate, gender, bio, location, interested_in) VALUES 
('a0000000-0000-0000-0000-000000000002', 'tk_lucas', 'Lucas', 26, '1998-03-20', 'Male', 'Musique & Concerts 🎵. Guitariste amateur.', 'Lyon, France', 'Women');

-- 3. Chloé (F, 22)
INSERT INTO users (id, tiktok_id, name, age, birthdate, gender, bio, location, interested_in) VALUES 
('a0000000-0000-0000-0000-000000000003', 'tk_chloe', 'Chloé', 22, '2002-07-10', 'Female', 'Crossfit et rando le week-end 🏃‍♀️.', 'Marseille, France', 'Men');

-- 4. Thomas (M, 28)
INSERT INTO users (id, tiktok_id, name, age, birthdate, gender, bio, location, interested_in) VALUES 
('a0000000-0000-0000-0000-000000000004', 'tk_thomas', 'Thomas', 28, '1996-11-05', 'Male', 'Tech, startups et bon vin 🍷.', 'Paris, France', 'Women');

-- 5. Manon (F, 25)
INSERT INTO users (id, tiktok_id, name, age, birthdate, gender, bio, location, interested_in) VALUES 
('a0000000-0000-0000-0000-000000000005', 'tk_manon', 'Manon', 25, '1999-01-30', 'Female', 'Artiste dans l''âme 🎨. Musées & cafés.', 'Bordeaux, France', 'Everyone');

-- 6. Hugo (M, 23)
INSERT INTO users (id, tiktok_id, name, age, birthdate, gender, bio, location, interested_in) VALUES 
('a0000000-0000-0000-0000-000000000006', 'tk_hugo', 'Hugo', 23, '2001-09-12', 'Male', 'Gamer et cinéphile 🎮🎬.', 'Toulouse, France', 'Women');

-- 7. Léa (F, 21)
INSERT INTO users (id, tiktok_id, name, age, birthdate, gender, bio, location, interested_in) VALUES 
('a0000000-0000-0000-0000-000000000007', 'tk_lea', 'Léa', 21, '2003-04-25', 'Female', 'Étudiante en droit, fan de fêtes 🎉.', 'Lille, France', 'Men');

-- 8. Alex (NB, 24)
INSERT INTO users (id, tiktok_id, name, age, birthdate, gender, bio, location, interested_in) VALUES 
('a0000000-0000-0000-0000-000000000008', 'tk_alex', 'Alex', 24, '2000-12-12', 'Non-binary', 'Photo & Nature 📸🌿. Vegan.', 'Nantes, France', 'Everyone');

-- 9. Sarah (F, 27)
INSERT INTO users (id, tiktok_id, name, age, birthdate, gender, bio, location, interested_in) VALUES 
('a0000000-0000-0000-0000-000000000009', 'tk_sarah', 'Sarah', 27, '1997-02-14', 'Female', 'Architecte d''intérieur 🏠. J''aime le design et les chats.', 'Lyon, France', 'Men');

-- 10. Julien (M, 29)
INSERT INTO users (id, tiktok_id, name, age, birthdate, gender, bio, location, interested_in) VALUES 
('a0000000-0000-0000-0000-000000000010', 'tk_julien', 'Julien', 29, '1995-08-30', 'Male', 'Chef cuisinier 👨‍🍳. Je te fais les meilleures pâtes carbo.', 'Paris, France', 'Women');

-- 11. Camille (F, 23)
INSERT INTO users (id, tiktok_id, name, age, birthdate, gender, bio, location, interested_in) VALUES 
('a0000000-0000-0000-0000-000000000011', 'tk_camille', 'Camille', 23, '2001-05-05', 'Female', 'Infirmière 💉. Besoin de rire après le boulot !', 'Nice, France', 'Men');

-- 12. Antoine (M, 25)
INSERT INTO users (id, tiktok_id, name, age, birthdate, gender, bio, location, interested_in) VALUES 
('a0000000-0000-0000-0000-000000000012', 'tk_antoine', 'Antoine', 25, '1999-10-20', 'Male', 'Rugby & 3ème mi-temps 🏉. Bon vivant.', 'Toulouse, France', 'Women');

-- 13. Julie (F, 26)
INSERT INTO users (id, tiktok_id, name, age, birthdate, gender, bio, location, interested_in) VALUES 
('a0000000-0000-0000-0000-000000000013', 'tk_julie', 'Julie', 26, '1998-06-15', 'Female', 'Prof d''anglais 🇬🇧. Let''s travel together!', 'Paris, France', 'Men');

-- 14. Maxime (M, 22)
INSERT INTO users (id, tiktok_id, name, age, birthdate, gender, bio, location, interested_in) VALUES 
('a0000000-0000-0000-0000-000000000014', 'tk_maxime', 'Maxime', 22, '2002-11-11', 'Male', 'Étudiant en école de commerce 💼. Ambitieux.', 'Bordeaux, France', 'Women');

-- 15. Laura (F, 24)
INSERT INTO users (id, tiktok_id, name, age, birthdate, gender, bio, location, interested_in) VALUES 
('a0000000-0000-0000-0000-000000000015', 'tk_laura', 'Laura', 24, '2000-01-01', 'Female', 'Danseuse 💃. La musique c''est ma vie.', 'Paris, France', 'Everyone');

-- 16. Kevin (M, 27)
INSERT INTO users (id, tiktok_id, name, age, birthdate, gender, bio, location, interested_in) VALUES 
('a0000000-0000-0000-0000-000000000016', 'tk_kevin', 'Kevin', 27, '1997-07-07', 'Male', 'Coach sportif 💪. No pain no gain.', 'Marseille, France', 'Women');

-- 17. Marie (F, 28)
INSERT INTO users (id, tiktok_id, name, age, birthdate, gender, bio, location, interested_in) VALUES 
('a0000000-0000-0000-0000-000000000017', 'tk_marie', 'Marie', 28, '1996-09-09', 'Female', 'Journaliste 📰. Toujours à l''affût d''un scoop.', 'Paris, France', 'Men');

-- 18. Nicolas (M, 30)
INSERT INTO users (id, tiktok_id, name, age, birthdate, gender, bio, location, interested_in) VALUES 
('a0000000-0000-0000-0000-000000000018', 'tk_nicolas', 'Nicolas', 30, '1994-04-04', 'Male', 'Ingénieur 🏗️. J''aime construire des trucs.', 'Lyon, France', 'Women');

-- 19. Anaïs (F, 20)
INSERT INTO users (id, tiktok_id, name, age, birthdate, gender, bio, location, interested_in) VALUES 
('a0000000-0000-0000-0000-000000000019', 'tk_anais', 'Anaïs', 20, '2004-02-28', 'Female', 'Étudiante en psycho 🧠. J''analyse tout.', 'Rennes, France', 'Men');

-- 20. Paul (M, 24)
INSERT INTO users (id, tiktok_id, name, age, birthdate, gender, bio, location, interested_in) VALUES 
('a0000000-0000-0000-0000-000000000020', 'tk_paul', 'Paul', 24, '2000-08-15', 'Male', 'Photographe freelance 📷. Je cherche ma muse.', 'Paris, France', 'Women');

-- 21. Océane (F, 23)
INSERT INTO users (id, tiktok_id, name, age, birthdate, gender, bio, location, interested_in) VALUES 
('a0000000-0000-0000-0000-000000000021', 'tk_oceane', 'Océane', 23, '2001-03-30', 'Female', 'Surfeuse 🏄‍♀️. L''océan me manque.', 'Biarritz, France', 'Men');

-- 22. Arthur (M, 25)
INSERT INTO users (id, tiktok_id, name, age, birthdate, gender, bio, location, interested_in) VALUES 
('a0000000-0000-0000-0000-000000000022', 'tk_arthur', 'Arthur', 25, '1999-12-25', 'Male', 'Développeur Web 💻. Geek et fier.', 'Nantes, France', 'Women');

-- 23. Pauline (F, 26)
INSERT INTO users (id, tiktok_id, name, age, birthdate, gender, bio, location, interested_in) VALUES 
('a0000000-0000-0000-0000-000000000023', 'tk_pauline', 'Pauline', 26, '1998-05-20', 'Female', 'Vétérinaire 🐾. Les animaux avant les humains.', 'Lyon, France', 'Men');

-- 24. Raphaël (M, 29)
INSERT INTO users (id, tiktok_id, name, age, birthdate, gender, bio, location, interested_in) VALUES 
('a0000000-0000-0000-0000-000000000024', 'tk_raphael', 'Raphaël', 29, '1995-10-10', 'Male', 'Avocat ⚖️. Je gagne tous mes débats.', 'Paris, France', 'Women');

-- 25. Mathilde (F, 22)
INSERT INTO users (id, tiktok_id, name, age, birthdate, gender, bio, location, interested_in) VALUES 
('a0000000-0000-0000-0000-000000000025', 'tk_mathilde', 'Mathilde', 22, '2002-01-15', 'Female', 'Influenceuse mode 👗. Toujours bien habillée.', 'Paris, France', 'Men');

-- 26. Louis (M, 27)
INSERT INTO users (id, tiktok_id, name, age, birthdate, gender, bio, location, interested_in) VALUES 
('a0000000-0000-0000-0000-000000000026', 'tk_louis', 'Louis', 27, '1997-06-06', 'Male', 'Pompier 🚒. J''aime l''action.', 'Marseille, France', 'Women');

-- 27. Elodie (F, 25)
INSERT INTO users (id, tiktok_id, name, age, birthdate, gender, bio, location, interested_in) VALUES 
('a0000000-0000-0000-0000-000000000027', 'tk_elodie', 'Elodie', 25, '1999-09-18', 'Female', 'Pâtissière 🍰. Je suis douce et sucrée.', 'Strasbourg, France', 'Everyone');

-- 28. Gabriel (M, 23)
INSERT INTO users (id, tiktok_id, name, age, birthdate, gender, bio, location, interested_in) VALUES 
('a0000000-0000-0000-0000-000000000028', 'tk_gabriel', 'Gabriel', 23, '2001-11-20', 'Male', 'Étudiant en médecine 🩺. Sauver des vies bientôt.', 'Paris, France', 'Women');

-- 29. Inès (F, 21)
INSERT INTO users (id, tiktok_id, name, age, birthdate, gender, bio, location, interested_in) VALUES 
('a0000000-0000-0000-0000-000000000029', 'tk_ines', 'Inès', 21, '2003-08-08', 'Female', 'Chanteuse 🎤. La musique est mon langage.', 'Montpellier, France', 'Men');

-- 30. Pierre (M, 31)
INSERT INTO users (id, tiktok_id, name, age, birthdate, gender, bio, location, interested_in) VALUES 
('a0000000-0000-0000-0000-000000000030', 'tk_pierre', 'Pierre', 31, '1993-02-02', 'Male', 'Entrepreneur 🚀. Je ne dors jamais.', 'Paris, France', 'Women');


-- ============================================
-- 2. INSERT PHOTOS (Random selection)
-- ============================================

-- Emma (01)
INSERT INTO user_photos (user_id, photo_url, position, caption) VALUES ('a0000000-0000-0000-0000-000000000001', 'https://i.pravatar.cc/400?img=5', 0, 'Vacances ☀️'), ('a0000000-0000-0000-0000-000000000001', 'https://i.pravatar.cc/400?img=9', 1, NULL);
-- Lucas (02)
INSERT INTO user_photos (user_id, photo_url, position, caption) VALUES ('a0000000-0000-0000-0000-000000000002', 'https://i.pravatar.cc/400?img=11', 0, 'Concert 🎸'), ('a0000000-0000-0000-0000-000000000002', 'https://i.pravatar.cc/400?img=53', 1, 'Gaming');
-- Chloé (03)
INSERT INTO user_photos (user_id, photo_url, position, caption) VALUES ('a0000000-0000-0000-0000-000000000003', 'https://i.pravatar.cc/400?img=20', 0, 'Run 🏃‍♀️'), ('a0000000-0000-0000-0000-000000000003', 'https://i.pravatar.cc/400?img=24', 1, 'Summer');
-- Thomas (04)
INSERT INTO user_photos (user_id, photo_url, position, caption) VALUES ('a0000000-0000-0000-0000-000000000004', 'https://i.pravatar.cc/400?img=33', 0, 'Work'), ('a0000000-0000-0000-0000-000000000004', 'https://i.pravatar.cc/400?img=59', 1, 'Vin 🍷');
-- Manon (05)
INSERT INTO user_photos (user_id, photo_url, position, caption) VALUES ('a0000000-0000-0000-0000-000000000005', 'https://i.pravatar.cc/400?img=26', 0, 'Louvre'), ('a0000000-0000-0000-0000-000000000005', 'https://i.pravatar.cc/400?img=35', 1, 'Art');
-- Hugo (06)
INSERT INTO user_photos (user_id, photo_url, position, caption) VALUES ('a0000000-0000-0000-0000-000000000006', 'https://i.pravatar.cc/400?img=51', 0, 'Ciné'), ('a0000000-0000-0000-0000-000000000006', 'https://i.pravatar.cc/400?img=52', 1, NULL);
-- Léa (07)
INSERT INTO user_photos (user_id, photo_url, position, caption) VALUES ('a0000000-0000-0000-0000-000000000007', 'https://i.pravatar.cc/400?img=44', 0, 'Party 🎉'), ('a0000000-0000-0000-0000-000000000007', 'https://i.pravatar.cc/400?img=45', 1, 'Ski');
-- Alex (08)
INSERT INTO user_photos (user_id, photo_url, position, caption) VALUES ('a0000000-0000-0000-0000-000000000008', 'https://i.pravatar.cc/400?img=65', 0, 'Nature 🌿'), ('a0000000-0000-0000-0000-000000000008', 'https://i.pravatar.cc/400?img=60', 1, NULL);
-- Sarah (09)
INSERT INTO user_photos (user_id, photo_url, position, caption) VALUES ('a0000000-0000-0000-0000-000000000009', 'https://i.pravatar.cc/400?img=1', 0, 'Design'), ('a0000000-0000-0000-0000-000000000009', 'https://i.pravatar.cc/400?img=2', 1, 'Lyon');
-- Julien (10)
INSERT INTO user_photos (user_id, photo_url, position, caption) VALUES ('a0000000-0000-0000-0000-000000000010', 'https://i.pravatar.cc/400?img=3', 0, 'Cuisine'), ('a0000000-0000-0000-0000-000000000010', 'https://i.pravatar.cc/400?img=4', 1, 'Chef');
-- Camille (11)
INSERT INTO user_photos (user_id, photo_url, position, caption) VALUES ('a0000000-0000-0000-0000-000000000011', 'https://i.pravatar.cc/400?img=16', 0, 'Nice'), ('a0000000-0000-0000-0000-000000000011', 'https://i.pravatar.cc/400?img=19', 1, 'Work');
-- Antoine (12)
INSERT INTO user_photos (user_id, photo_url, position, caption) VALUES ('a0000000-0000-0000-0000-000000000012', 'https://i.pravatar.cc/400?img=13', 0, 'Rugby'), ('a0000000-0000-0000-0000-000000000012', 'https://i.pravatar.cc/400?img=14', 1, 'Toulouse');
-- Julie (13)
INSERT INTO user_photos (user_id, photo_url, position, caption) VALUES ('a0000000-0000-0000-0000-000000000013', 'https://i.pravatar.cc/400?img=21', 0, 'London'), ('a0000000-0000-0000-0000-000000000013', 'https://i.pravatar.cc/400?img=22', 1, 'Travel');
-- Maxime (14)
INSERT INTO user_photos (user_id, photo_url, position, caption) VALUES ('a0000000-0000-0000-0000-000000000014', 'https://i.pravatar.cc/400?img=15', 0, 'Business'), ('a0000000-0000-0000-0000-000000000014', 'https://i.pravatar.cc/400?img=54', 1, 'Bordeaux');
-- Laura (15)
INSERT INTO user_photos (user_id, photo_url, position, caption) VALUES ('a0000000-0000-0000-0000-000000000015', 'https://i.pravatar.cc/400?img=23', 0, 'Dance'), ('a0000000-0000-0000-0000-000000000015', 'https://i.pravatar.cc/400?img=25', 1, 'Music');
-- Kevin (16)
INSERT INTO user_photos (user_id, photo_url, position, caption) VALUES ('a0000000-0000-0000-0000-000000000016', 'https://i.pravatar.cc/400?img=55', 0, 'Gym'), ('a0000000-0000-0000-0000-000000000016', 'https://i.pravatar.cc/400?img=56', 1, 'Run');
-- Marie (17)
INSERT INTO user_photos (user_id, photo_url, position, caption) VALUES ('a0000000-0000-0000-0000-000000000017', 'https://i.pravatar.cc/400?img=29', 0, 'News'), ('a0000000-0000-0000-0000-000000000017', 'https://i.pravatar.cc/400?img=30', 1, 'Paris');
-- Nicolas (18)
INSERT INTO user_photos (user_id, photo_url, position, caption) VALUES ('a0000000-0000-0000-0000-000000000018', 'https://i.pravatar.cc/400?img=57', 0, 'Build'), ('a0000000-0000-0000-0000-000000000018', 'https://i.pravatar.cc/400?img=58', 1, 'Lyon');
-- Anaïs (19)
INSERT INTO user_photos (user_id, photo_url, position, caption) VALUES ('a0000000-0000-0000-0000-000000000019', 'https://i.pravatar.cc/400?img=31', 0, 'Study'), ('a0000000-0000-0000-0000-000000000019', 'https://i.pravatar.cc/400?img=32', 1, 'Rennes');
-- Paul (20)
INSERT INTO user_photos (user_id, photo_url, position, caption) VALUES ('a0000000-0000-0000-0000-000000000020', 'https://i.pravatar.cc/400?img=61', 0, 'Photo'), ('a0000000-0000-0000-0000-000000000020', 'https://i.pravatar.cc/400?img=62', 1, 'Art');
-- Océane (21)
INSERT INTO user_photos (user_id, photo_url, position, caption) VALUES ('a0000000-0000-0000-0000-000000000021', 'https://i.pravatar.cc/400?img=34', 0, 'Surf'), ('a0000000-0000-0000-0000-000000000021', 'https://i.pravatar.cc/400?img=36', 1, 'Beach');
-- Arthur (22)
INSERT INTO user_photos (user_id, photo_url, position, caption) VALUES ('a0000000-0000-0000-0000-000000000022', 'https://i.pravatar.cc/400?img=63', 0, 'Code'), ('a0000000-0000-0000-0000-000000000022', 'https://i.pravatar.cc/400?img=64', 1, 'Geek');
-- Pauline (23)
INSERT INTO user_photos (user_id, photo_url, position, caption) VALUES ('a0000000-0000-0000-0000-000000000023', 'https://i.pravatar.cc/400?img=38', 0, 'Vet'), ('a0000000-0000-0000-0000-000000000023', 'https://i.pravatar.cc/400?img=39', 1, 'Cat');
-- Raphaël (24)
INSERT INTO user_photos (user_id, photo_url, position, caption) VALUES ('a0000000-0000-0000-0000-000000000024', 'https://i.pravatar.cc/400?img=66', 0, 'Law'), ('a0000000-0000-0000-0000-000000000024', 'https://i.pravatar.cc/400?img=67', 1, 'Paris');
-- Mathilde (25)
INSERT INTO user_photos (user_id, photo_url, position, caption) VALUES ('a0000000-0000-0000-0000-000000000025', 'https://i.pravatar.cc/400?img=40', 0, 'Fashion'), ('a0000000-0000-0000-0000-000000000025', 'https://i.pravatar.cc/400?img=41', 1, 'Style');
-- Louis (26)
INSERT INTO user_photos (user_id, photo_url, position, caption) VALUES ('a0000000-0000-0000-0000-000000000026', 'https://i.pravatar.cc/400?img=68', 0, 'Fire'), ('a0000000-0000-0000-0000-000000000026', 'https://i.pravatar.cc/400?img=69', 1, 'Marseille');
-- Elodie (27)
INSERT INTO user_photos (user_id, photo_url, position, caption) VALUES ('a0000000-0000-0000-0000-000000000027', 'https://i.pravatar.cc/400?img=42', 0, 'Cake'), ('a0000000-0000-0000-0000-000000000027', 'https://i.pravatar.cc/400?img=43', 1, 'Sweet');
-- Gabriel (28)
INSERT INTO user_photos (user_id, photo_url, position, caption) VALUES ('a0000000-0000-0000-0000-000000000028', 'https://i.pravatar.cc/400?img=70', 0, 'Med'), ('a0000000-0000-0000-0000-000000000028', 'https://i.pravatar.cc/400?img=8', 1, NULL);
-- Inès (29)
INSERT INTO user_photos (user_id, photo_url, position, caption) VALUES ('a0000000-0000-0000-0000-000000000029', 'https://i.pravatar.cc/400?img=46', 0, 'Sing'), ('a0000000-0000-0000-0000-000000000029', 'https://i.pravatar.cc/400?img=47', 1, 'Music');
-- Pierre (30)
INSERT INTO user_photos (user_id, photo_url, position, caption) VALUES ('a0000000-0000-0000-0000-000000000030', 'https://i.pravatar.cc/400?img=6', 0, 'Startup'), ('a0000000-0000-0000-0000-000000000030', 'https://i.pravatar.cc/400?img=7', 1, 'Paris');


-- ============================================
-- 3. INSERT USER INTERESTS (Selections)
-- ============================================

INSERT INTO user_interests (user_id, interest_id) VALUES
-- Emma (Voyage, Sushi)
('a0000000-0000-0000-0000-000000000001', get_interest_id('Voyage')), ('a0000000-0000-0000-0000-000000000001', get_interest_id('Sushi')),
-- Lucas (Musique, Concerts)
('a0000000-0000-0000-0000-000000000002', get_interest_id('Musique')), ('a0000000-0000-0000-0000-000000000002', get_interest_id('Concerts')),
-- Chloé (Sport, Fitness)
('a0000000-0000-0000-0000-000000000003', get_interest_id('Sport')), ('a0000000-0000-0000-0000-000000000003', get_interest_id('Fitness')),
-- Thomas (Tech, Vin)
('a0000000-0000-0000-0000-000000000004', get_interest_id('Tech')), ('a0000000-0000-0000-0000-000000000004', get_interest_id('Vin')),
-- Manon (Art, Musées)
('a0000000-0000-0000-0000-000000000005', get_interest_id('Art')), ('a0000000-0000-0000-0000-000000000005', get_interest_id('Musées')),
-- Hugo (Gaming, Cinéma)
('a0000000-0000-0000-0000-000000000006', get_interest_id('Gaming')), ('a0000000-0000-0000-0000-000000000006', get_interest_id('Cinéma')),
-- Léa (Festivals, Voyage) -> Fixed 'Party' to 'Festivals'
('a0000000-0000-0000-0000-000000000007', get_interest_id('Festivals')), ('a0000000-0000-0000-0000-000000000007', get_interest_id('Voyage')),
-- Alex (Photographie, Nature -> Randonnée)
('a0000000-0000-0000-0000-000000000008', get_interest_id('Photographie')), ('a0000000-0000-0000-0000-000000000008', get_interest_id('Randonnée')),
-- Sarah (Design, Chats) -> Fixed 'Cats' to 'Chats'
('a0000000-0000-0000-0000-000000000009', get_interest_id('Design')), ('a0000000-0000-0000-0000-000000000009', get_interest_id('Chats')),
-- Julien (Cuisine, Restaurants) -> Fixed 'Pâtes' to 'Restaurants'
('a0000000-0000-0000-0000-000000000010', get_interest_id('Cuisine')), ('a0000000-0000-0000-0000-000000000010', get_interest_id('Restaurants')),
-- Camille (Fitness, Stand-up) -> Fixed 'Santé'/'Rire'
('a0000000-0000-0000-0000-000000000011', get_interest_id('Fitness')), ('a0000000-0000-0000-0000-000000000011', get_interest_id('Stand-up')),
-- Antoine (Sport, Bière) -> Fixed 'Rugby' to 'Sport'
('a0000000-0000-0000-0000-000000000012', get_interest_id('Sport')), ('a0000000-0000-0000-0000-000000000012', get_interest_id('Bière')),
-- Julie (Voyage, Lecture) -> Fixed 'Anglais' to 'Lecture'
('a0000000-0000-0000-0000-000000000013', get_interest_id('Voyage')), ('a0000000-0000-0000-0000-000000000013', get_interest_id('Lecture')),
-- Maxime (Startups, Vin) -> Fixed 'Business' to 'Startups'
('a0000000-0000-0000-0000-000000000014', get_interest_id('Startups')), ('a0000000-0000-0000-0000-000000000014', get_interest_id('Vin')),
-- Laura (Danse, Musique)
('a0000000-0000-0000-0000-000000000015', get_interest_id('Danse')), ('a0000000-0000-0000-0000-000000000015', get_interest_id('Musique')),
-- Kevin (Sport, Crossfit) -> Fixed 'Muscu' to 'Crossfit'
('a0000000-0000-0000-0000-000000000016', get_interest_id('Sport')), ('a0000000-0000-0000-0000-000000000016', get_interest_id('Crossfit')),
-- Marie (Écriture, Musées) -> Fixed 'Journalisme'/'Paris'
('a0000000-0000-0000-0000-000000000017', get_interest_id('Écriture')), ('a0000000-0000-0000-0000-000000000017', get_interest_id('Musées')),
-- Nicolas (DIY, Tech) -> Fixed 'Bricolage' to 'DIY'
('a0000000-0000-0000-0000-000000000018', get_interest_id('DIY')), ('a0000000-0000-0000-0000-000000000018', get_interest_id('Tech')),
-- Anaïs (Psychologie, Lecture) -> Fixed 'Psycho' to 'Psychologie'
('a0000000-0000-0000-0000-000000000019', get_interest_id('Psychologie')), ('a0000000-0000-0000-0000-000000000019', get_interest_id('Lecture')),
-- Paul (Photographie, Art)
('a0000000-0000-0000-0000-000000000020', get_interest_id('Photographie')), ('a0000000-0000-0000-0000-000000000020', get_interest_id('Art')),
-- Océane (Surf, Plage)
('a0000000-0000-0000-0000-000000000021', get_interest_id('Surf')), ('a0000000-0000-0000-0000-000000000021', get_interest_id('Plage')),
-- Arthur (Tech, Programmation) -> Fixed 'Code' to 'Programmation'
('a0000000-0000-0000-0000-000000000022', get_interest_id('Tech')), ('a0000000-0000-0000-0000-000000000022', get_interest_id('Programmation')),
-- Pauline (Animaux, Randonnée) -> Fixed 'Nature' to 'Randonnée'
('a0000000-0000-0000-0000-000000000023', get_interest_id('Animaux')), ('a0000000-0000-0000-0000-000000000023', get_interest_id('Randonnée')),
-- Raphaël (Politique, Philosophie) -> Fixed 'Droit'/'Débat'
('a0000000-0000-0000-0000-000000000024', get_interest_id('Politique')), ('a0000000-0000-0000-0000-000000000024', get_interest_id('Philosophie')),
-- Mathilde (Mode, Shopping)
('a0000000-0000-0000-0000-000000000025', get_interest_id('Mode')), ('a0000000-0000-0000-0000-000000000025', get_interest_id('Shopping')),
-- Louis (Sport, Aventure) -> Fixed 'Action' to 'Aventure'
('a0000000-0000-0000-0000-000000000026', get_interest_id('Sport')), ('a0000000-0000-0000-0000-000000000026', get_interest_id('Aventure')),
-- Elodie (Cuisine, Gâteaux) -> Fixed 'Sweet' to 'Gâteaux'
('a0000000-0000-0000-0000-000000000027', get_interest_id('Cuisine')), ('a0000000-0000-0000-0000-000000000027', get_interest_id('Gâteaux')),
-- Gabriel (Science, Tech) -> Fixed 'Med' to 'Science'
('a0000000-0000-0000-0000-000000000028', get_interest_id('Science')), ('a0000000-0000-0000-0000-000000000028', get_interest_id('Tech')),
-- Inès (Musique, Concerts) -> Fixed 'Chant' to 'Concerts'
('a0000000-0000-0000-0000-000000000029', get_interest_id('Musique')), ('a0000000-0000-0000-0000-000000000029', get_interest_id('Concerts')),
-- Pierre (Startups, Tech) -> Fixed 'Business' to 'Startups'
('a0000000-0000-0000-0000-000000000030', get_interest_id('Startups')), ('a0000000-0000-0000-0000-000000000030', get_interest_id('Tech'));


-- ============================================
-- 4. INSERT USER PROMPTS (Samples)
-- ============================================

INSERT INTO user_prompts (user_id, prompt_id, answer) VALUES
('a0000000-0000-0000-0000-000000000001', get_prompt_id('Dans mon groupe d''amis je suis...'), 'L''organisatrice'),
('a0000000-0000-0000-0000-000000000002', get_prompt_id('Mon talent caché c''est...'), 'Imiter Chewbacca'),
('a0000000-0000-0000-0000-000000000003', get_prompt_id('Ma plus grande fierté...'), 'Mon marathon'),
('a0000000-0000-0000-0000-000000000004', get_prompt_id('Le truc le plus random que j''adore...'), 'L''espace'),
('a0000000-0000-0000-0000-000000000005', get_prompt_id('Si je pouvais dîner avec quelqu''un...'), 'Van Gogh'),
('a0000000-0000-0000-0000-000000000006', get_prompt_id('Ce qui me rend unique...'), 'Je finis tous les jeux à 100%'),
('a0000000-0000-0000-0000-000000000007', get_prompt_id('Ma définition d''une bonne soirée...'), 'Danser jusqu''à l''aube'),
('a0000000-0000-0000-0000-000000000008', get_prompt_id('Mon endroit préféré au monde...'), 'La forêt de Brocéliande'),
('a0000000-0000-0000-0000-000000000009', get_prompt_id('On s''entendra si...'), 'Tu aimes l''architecture'),
('a0000000-0000-0000-0000-000000000010', get_prompt_id('Pour me détendre je...'), 'Cuisine pour mes amis'),
('a0000000-0000-0000-0000-000000000011', get_prompt_id('Je ne peux pas vivre sans...'), 'Café'),
('a0000000-0000-0000-0000-000000000012', get_prompt_id('Le meilleur premier date serait...'), 'Un match de rugby'),
('a0000000-0000-0000-0000-000000000013', get_prompt_id('Mon rituel du matin c''est...'), 'Thé Earl Grey'),
('a0000000-0000-0000-0000-000000000014', get_prompt_id('Ma passion secrète c''est...'), 'Les échecs'),
('a0000000-0000-0000-0000-000000000015', get_prompt_id('Ce qui me fait du bien...'), 'Danser'),
('a0000000-0000-0000-0000-000000000016', get_prompt_id('Dans mon groupe d''amis je suis...'), 'Le coach'),
('a0000000-0000-0000-0000-000000000017', get_prompt_id('Une info inutile mais drôle...'), 'Je sais bouger mes oreilles'),
('a0000000-0000-0000-0000-000000000018', get_prompt_id('Mon talent caché c''est...'), 'Je répare tout'),
('a0000000-0000-0000-0000-000000000019', get_prompt_id('Ce que je cherche chez quelqu''un...'), 'L''écoute'),
('a0000000-0000-0000-0000-000000000020', get_prompt_id('Si je pouvais dîner avec quelqu''un...'), 'Henri Cartier-Bresson'),
('a0000000-0000-0000-0000-000000000021', get_prompt_id('Mon endroit préféré au monde...'), 'Hossegor'),
('a0000000-0000-0000-0000-000000000022', get_prompt_id('Je ne peux pas vivre sans...'), 'Mon clavier mécanique'),
('a0000000-0000-0000-0000-000000000023', get_prompt_id('Ma plus grande fierté...'), 'Avoir sauvé un chaton'),
('a0000000-0000-0000-0000-000000000024', get_prompt_id('On s''entendra si...'), 'Tu as de la répartie'),
('a0000000-0000-0000-0000-000000000025', get_prompt_id('Ce qui me fait rire à coup sûr...'), 'Les mèmes de chats'),
('a0000000-0000-0000-0000-000000000026', get_prompt_id('Ma passion secrète c''est...'), 'Le tricot'),
('a0000000-0000-0000-0000-000000000027', get_prompt_id('Pour me détendre je...'), 'Fais des macarons'),
('a0000000-0000-0000-0000-000000000028', get_prompt_id('Le meilleur conseil qu''on m''ait donné...'), 'Dors plus'),
('a0000000-0000-0000-0000-000000000029', get_prompt_id('Mon talent caché c''est...'), 'Chanter l''opéra sous la douche'),
('a0000000-0000-0000-0000-000000000030', get_prompt_id('Ma définition d''une bonne soirée...'), 'Brainstormer sur une idée');

-- Cleanup
DROP FUNCTION get_interest_id;
DROP FUNCTION get_prompt_id;
