-- ============================================
-- SCRIPT: SEED LIKES
-- Description: Finds the "Real" user (not a mock profile) and inserts likes FROM mock profiles TO them.
-- Run this in your Supabase SQL Editor.
-- ============================================

DO $$
DECLARE
    target_user_id UUID;
BEGIN
    -- 1. Find the target user (Your account)
    -- We select the most recently created user whose ID does NOT start with the mock prefix 'a0000000'
    SELECT id INTO target_user_id
    FROM users
    WHERE id::text NOT LIKE 'a0000000%'
    ORDER BY created_at DESC
    LIMIT 1;

    -- Check if found
    IF target_user_id IS NULL THEN
        RAISE NOTICE '❌ Aucun utilisateur réel trouvé. Connectez-vous d''abord à l''application.';
        RETURN;
    END IF;

    RAISE NOTICE '✅ Utilisateur cible trouvé : %', target_user_id;

    -- 2. Insert Likes FROM Mock Users (The "Likers") TO Target User
    -- We use ON CONFLICT DO NOTHING to avoid errors if run multiple times

    -- Emma (01) likes you
    INSERT INTO swipes (from_user_id, to_user_id, action) 
    VALUES ('a0000000-0000-0000-0000-000000000001', target_user_id, 'like') ON CONFLICT DO NOTHING;

    -- Chloé (03) likes you
    INSERT INTO swipes (from_user_id, to_user_id, action) 
    VALUES ('a0000000-0000-0000-0000-000000000003', target_user_id, 'like') ON CONFLICT DO NOTHING;

    -- Manon (05) likes you
    INSERT INTO swipes (from_user_id, to_user_id, action) 
    VALUES ('a0000000-0000-0000-0000-000000000005', target_user_id, 'like') ON CONFLICT DO NOTHING;

    -- Léa (07) likes you
    INSERT INTO swipes (from_user_id, to_user_id, action) 
    VALUES ('a0000000-0000-0000-0000-000000000007', target_user_id, 'like') ON CONFLICT DO NOTHING;

    -- Sarah (09) likes you
    INSERT INTO swipes (from_user_id, to_user_id, action) 
    VALUES ('a0000000-0000-0000-0000-000000000009', target_user_id, 'like') ON CONFLICT DO NOTHING;

    -- Camille (11) likes you
    INSERT INTO swipes (from_user_id, to_user_id, action) 
    VALUES ('a0000000-0000-0000-0000-000000000011', target_user_id, 'like') ON CONFLICT DO NOTHING;
    
    -- Julie (13) likes you
    INSERT INTO swipes (from_user_id, to_user_id, action) 
    VALUES ('a0000000-0000-0000-0000-000000000013', target_user_id, 'like') ON CONFLICT DO NOTHING;

    -- Laura (15) likes you
    INSERT INTO swipes (from_user_id, to_user_id, action) 
    VALUES ('a0000000-0000-0000-0000-000000000015', target_user_id, 'like') ON CONFLICT DO NOTHING;

    -- Marie (17) likes you
    INSERT INTO swipes (from_user_id, to_user_id, action) 
    VALUES ('a0000000-0000-0000-0000-000000000017', target_user_id, 'like') ON CONFLICT DO NOTHING;

    -- Anaïs (19) likes you
    INSERT INTO swipes (from_user_id, to_user_id, action) 
    VALUES ('a0000000-0000-0000-0000-000000000019', target_user_id, 'like') ON CONFLICT DO NOTHING;

    RAISE NOTICE '✅ 10 nouveaux likes ajoutés pour l''utilisateur !';

END $$;
