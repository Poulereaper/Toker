-- ============================================
-- SCRIPT: SEED CONVERSATIONS (MESSAGES)
-- Description: Creates ONE realistic conversation (Emma) and cleans up others.
-- Run this in Supabase SQL Editor AFTER signing in.
-- ============================================

DO $$
DECLARE
    target_user_id UUID;
    emma_id UUID := 'a0000000-0000-0000-0000-000000000001'; -- Emma (Voyage)
    chloe_id UUID := 'a0000000-0000-0000-0000-000000000003'; -- Chloé (Sport) - Optional match
    lea_id UUID := 'a0000000-0000-0000-0000-000000000005'; -- Léa (Art)
    manon_id UUID := 'a0000000-0000-0000-0000-000000000004'; -- Manon (Nature)
    v_match_id UUID; -- RENAMED to avoid ambiguity
BEGIN
    -- 1. Find the target user (Your account)
    SELECT id INTO target_user_id
    FROM users
    WHERE id::text NOT LIKE 'a0000000%'
    ORDER BY created_at DESC
    LIMIT 1;

    IF target_user_id IS NULL THEN
        RAISE NOTICE '❌ Aucun utilisateur réel trouvé.';
        RETURN;
    END IF;

    RAISE NOTICE '✅ Utilisateur cible trouvé : %', target_user_id;

    -- 2. CLEANUP: Remove old messages & matches (start fresh)
    -- We specify table alias to be safe, although the ambiguity was likely with the variable above
    DELETE FROM messages WHERE match_id IN (
        SELECT id FROM matches 
        WHERE user1_id = target_user_id OR user2_id = target_user_id
    );
    DELETE FROM matches WHERE user1_id = target_user_id OR user2_id = target_user_id;
    -- Also Reset Swipes to allow re-matching manually for others
    DELETE FROM swipes WHERE from_user_id = target_user_id OR to_user_id = target_user_id;
    
    RAISE NOTICE '🧹 Nettoyage effectué (Messages, Matchs, Swipes réinitialisés)';


    -- ====================================================
    -- CONVERSATION 1: EMMA (Voyage ✈️) - ACTIVE
    -- ====================================================
    
    -- Create Swipe Pair (Mutual Like)
    INSERT INTO swipes (from_user_id, to_user_id, action) VALUES 
    (target_user_id, emma_id, 'like'),
    (emma_id, target_user_id, 'like');

    -- Create Match
    INSERT INTO matches (user1_id, user2_id, compatibility_score)
    VALUES (
        LEAST(target_user_id, emma_id),
        GREATEST(target_user_id, emma_id),
        95.0
    ) RETURNING id INTO v_match_id;

    -- Insert Messages (Emma initiates)
    INSERT INTO messages (match_id, sender_id, content, created_at) VALUES
    (v_match_id, emma_id, 'Salut ! J''adore ton profil, on a plein de points communs ! 😊', NOW() - INTERVAL '2 days'),
    (v_match_id, target_user_id, 'Salut Emma ! Merci, j''ai vu que tu aimais aussi les voyages ✈️', NOW() - INTERVAL '1 day 23 hours'),
    (v_match_id, emma_id, 'Ouiiii ! Je reviens du Japon c''était incroyable 🇯🇵 Tu es déjà allé ?', NOW() - INTERVAL '1 day 22 hours'),
    (v_match_id, target_user_id, 'Pas encore mais c''est sur ma liste !', NOW() - INTERVAL '1 day 20 hours'),
    (v_match_id, emma_id, 'Faut absolument qu''on en parle autour d''un verre 😉', NOW() - INTERVAL '5 hours');

    RAISE NOTICE '✅ Conversation avec Emma créée !';

    -- ====================================================
    -- OPTIONAL: Just send LIKES from others (to create "Likes Received")
    -- But DO NOT create matches yet (User must swipe them)
    -- ====================================================
    
    INSERT INTO swipes (from_user_id, to_user_id, action) VALUES 
    (chloe_id, target_user_id, 'like'),
    (lea_id, target_user_id, 'like'),
    (manon_id, target_user_id, 'superlike');

    RAISE NOTICE '✅ 3 Likes entrants (Chloé, Léa, Manon) ajoutés pour la démo.';

END $$;
