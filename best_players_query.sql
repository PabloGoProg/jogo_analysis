-- ============================================================
-- CONSULTA SQL: MEJORES JUGADORES POR ROL Y EDAD
-- ============================================================
-- Base de datos: processed_database.sqlite
-- 
-- Objetivo: Identificar los 5 mejores jugadores para cada rol
-- (Goalkeeper, Defender, Midfielder, Forward, Sider) divididos en
-- dos grupos de edad: ≤29 años y >29 años
--
-- Metodología:
-- 1. Determinar rol principal de cada jugador (moda de últimos 50 partidos)
-- 2. Calcular puntaje ponderado de atributos generales (40%)
-- 3. Calcular puntaje ponderado de atributos específicos por rol (60%)
-- 4. Puntaje final = 0.4 * general + 0.6 * rol
-- ============================================================

WITH 
-- Paso 1: Obtener todas las posiciones jugadas por cada jugador
player_all_positions AS (
    SELECT home_player_1 as player_api_id, date, home_player_1_position as position FROM Match WHERE home_player_1 IS NOT NULL AND home_player_1_position IS NOT NULL
    UNION ALL SELECT home_player_2, date, home_player_2_position FROM Match WHERE home_player_2 IS NOT NULL AND home_player_2_position IS NOT NULL
    UNION ALL SELECT home_player_3, date, home_player_3_position FROM Match WHERE home_player_3 IS NOT NULL AND home_player_3_position IS NOT NULL
    UNION ALL SELECT home_player_4, date, home_player_4_position FROM Match WHERE home_player_4 IS NOT NULL AND home_player_4_position IS NOT NULL
    UNION ALL SELECT home_player_5, date, home_player_5_position FROM Match WHERE home_player_5 IS NOT NULL AND home_player_5_position IS NOT NULL
    UNION ALL SELECT home_player_6, date, home_player_6_position FROM Match WHERE home_player_6 IS NOT NULL AND home_player_6_position IS NOT NULL
    UNION ALL SELECT home_player_7, date, home_player_7_position FROM Match WHERE home_player_7 IS NOT NULL AND home_player_7_position IS NOT NULL
    UNION ALL SELECT home_player_8, date, home_player_8_position FROM Match WHERE home_player_8 IS NOT NULL AND home_player_8_position IS NOT NULL
    UNION ALL SELECT home_player_9, date, home_player_9_position FROM Match WHERE home_player_9 IS NOT NULL AND home_player_9_position IS NOT NULL
    UNION ALL SELECT home_player_10, date, home_player_10_position FROM Match WHERE home_player_10 IS NOT NULL AND home_player_10_position IS NOT NULL
    UNION ALL SELECT home_player_11, date, home_player_11_position FROM Match WHERE home_player_11 IS NOT NULL AND home_player_11_position IS NOT NULL
    UNION ALL SELECT away_player_1, date, away_player_1_position FROM Match WHERE away_player_1 IS NOT NULL AND away_player_1_position IS NOT NULL
    UNION ALL SELECT away_player_2, date, away_player_2_position FROM Match WHERE away_player_2 IS NOT NULL AND away_player_2_position IS NOT NULL
    UNION ALL SELECT away_player_3, date, away_player_3_position FROM Match WHERE away_player_3 IS NOT NULL AND away_player_3_position IS NOT NULL
    UNION ALL SELECT away_player_4, date, away_player_4_position FROM Match WHERE away_player_4 IS NOT NULL AND away_player_4_position IS NOT NULL
    UNION ALL SELECT away_player_5, date, away_player_5_position FROM Match WHERE away_player_5 IS NOT NULL AND away_player_5_position IS NOT NULL
    UNION ALL SELECT away_player_6, date, away_player_6_position FROM Match WHERE away_player_6 IS NOT NULL AND away_player_6_position IS NOT NULL
    UNION ALL SELECT away_player_7, date, away_player_7_position FROM Match WHERE away_player_7 IS NOT NULL AND away_player_7_position IS NOT NULL
    UNION ALL SELECT away_player_8, date, away_player_8_position FROM Match WHERE away_player_8 IS NOT NULL AND away_player_8_position IS NOT NULL
    UNION ALL SELECT away_player_9, date, away_player_9_position FROM Match WHERE away_player_9 IS NOT NULL AND away_player_9_position IS NOT NULL
    UNION ALL SELECT away_player_10, date, away_player_10_position FROM Match WHERE away_player_10 IS NOT NULL AND away_player_10_position IS NOT NULL
    UNION ALL SELECT away_player_11, date, away_player_11_position FROM Match WHERE away_player_11 IS NOT NULL AND away_player_11_position IS NOT NULL
),

-- Paso 2: Ordenar posiciones por fecha y tomar últimos 50 partidos
ranked_positions AS (
    SELECT 
        player_api_id,
        position,
        ROW_NUMBER() OVER (PARTITION BY player_api_id ORDER BY date DESC) as match_order
    FROM player_all_positions
),

recent_positions AS (
    SELECT player_api_id, position
    FROM ranked_positions
    WHERE match_order <= 50
),

-- Paso 3: Calcular la moda (posición más frecuente) por jugador
position_frequency AS (
    SELECT 
        player_api_id,
        position,
        COUNT(*) as freq,
        ROW_NUMBER() OVER (PARTITION BY player_api_id ORDER BY COUNT(*) DESC) as rank
    FROM recent_positions
    GROUP BY player_api_id, position
),

-- Paso 4: Clasificar jugadores en roles detallados
player_role AS (
    SELECT 
        pf.player_api_id,
        pf.position as base_position,
        pf.position as role
    FROM position_frequency pf
    WHERE pf.rank = 1
),

-- Paso 5: Obtener liga actual del jugador (partido más reciente)
player_recent_match AS (
    SELECT player_api_id, league_id, date,
           ROW_NUMBER() OVER (PARTITION BY player_api_id ORDER BY date DESC) as match_rank
    FROM (
        SELECT home_player_1 as player_api_id, league_id, date FROM Match WHERE home_player_1 IS NOT NULL
        UNION ALL SELECT home_player_2, league_id, date FROM Match WHERE home_player_2 IS NOT NULL
        UNION ALL SELECT home_player_3, league_id, date FROM Match WHERE home_player_3 IS NOT NULL
        UNION ALL SELECT home_player_4, league_id, date FROM Match WHERE home_player_4 IS NOT NULL
        UNION ALL SELECT home_player_5, league_id, date FROM Match WHERE home_player_5 IS NOT NULL
        UNION ALL SELECT home_player_6, league_id, date FROM Match WHERE home_player_6 IS NOT NULL
        UNION ALL SELECT home_player_7, league_id, date FROM Match WHERE home_player_7 IS NOT NULL
        UNION ALL SELECT home_player_8, league_id, date FROM Match WHERE home_player_8 IS NOT NULL
        UNION ALL SELECT home_player_9, league_id, date FROM Match WHERE home_player_9 IS NOT NULL
        UNION ALL SELECT home_player_10, league_id, date FROM Match WHERE home_player_10 IS NOT NULL
        UNION ALL SELECT home_player_11, league_id, date FROM Match WHERE home_player_11 IS NOT NULL
        UNION ALL SELECT away_player_1, league_id, date FROM Match WHERE away_player_1 IS NOT NULL
        UNION ALL SELECT away_player_2, league_id, date FROM Match WHERE away_player_2 IS NOT NULL
        UNION ALL SELECT away_player_3, league_id, date FROM Match WHERE away_player_3 IS NOT NULL
        UNION ALL SELECT away_player_4, league_id, date FROM Match WHERE away_player_4 IS NOT NULL
        UNION ALL SELECT away_player_5, league_id, date FROM Match WHERE away_player_5 IS NOT NULL
        UNION ALL SELECT away_player_6, league_id, date FROM Match WHERE away_player_6 IS NOT NULL
        UNION ALL SELECT away_player_7, league_id, date FROM Match WHERE away_player_7 IS NOT NULL
        UNION ALL SELECT away_player_8, league_id, date FROM Match WHERE away_player_8 IS NOT NULL
        UNION ALL SELECT away_player_9, league_id, date FROM Match WHERE away_player_9 IS NOT NULL
        UNION ALL SELECT away_player_10, league_id, date FROM Match WHERE away_player_10 IS NOT NULL
        UNION ALL SELECT away_player_11, league_id, date FROM Match WHERE away_player_11 IS NOT NULL
    )
),

player_league AS (
    SELECT 
        prm.player_api_id,
        CAST(COALESCE(l.level, '1') AS INTEGER) as league_level
    FROM player_recent_match prm
    LEFT JOIN League l ON prm.league_id = l.id
    WHERE prm.match_rank = 1
),


-- Paso 6: Consolidar datos de jugadores
player_full_data AS (
    SELECT 
        p.player_api_id,
        p.player_name,
        pr.role,
        lpa.age,
        lpa.overall_rating,
        pl.league_level,
        -- Atributos generales
        lpa.reactions,
        lpa.stamina,
        lpa.strength,
        lpa.short_passing,
        lpa.dribbling,
        lpa.ball_control,
        lpa.vision,
        lpa.balance,
        lpa.positioning,
        -- Atributos específicos de Goalkeeper
        lpa.jumping,
        lpa.gk_diving,
        lpa.gk_handling,
        lpa.gk_kicking,
        lpa.gk_positioning,
        lpa.gk_reflexes,
        p.height,
        -- Atributos específicos de Defender
        lpa.defensive_work_rate,
        lpa.long_passing,
        lpa.aggression,
        lpa.interceptions,
        lpa.marking,
        lpa.standing_tackle,
        lpa.sliding_tackle,
        -- Atributos específicos de Midfielder/Forward/Sider
        lpa.attacking_work_rate,
        lpa.finishing,
        lpa.heading_accuracy,
        lpa.long_shots,
        lpa.penalties,
        lpa.free_kick_accuracy,
        lpa.acceleration,
        lpa.sprint_speed,
        lpa.agility,
        lpa.volleys,
        lpa.shot_power,
        lpa.curve,
        lpa.crossing
    FROM Player p
    INNER JOIN player_role pr ON p.player_api_id = pr.player_api_id
    INNER JOIN Player_Attributes lpa ON p.player_api_id = lpa.player_api_id
    LEFT JOIN player_league pl ON p.player_api_id = pl.player_api_id
    WHERE pr.role IN ('Goalkeeper', 'Defender', 'Midfielder', 'Forward', 'Sider')
),

-- Paso 7: Calcular puntajes ponderados
player_scores AS (
    SELECT 
        player_api_id,
        player_name,
        role,
        age,
        overall_rating,
        -- PUNTAJE GENERAL
        (
            COALESCE(league_level, 1) * 0.12 +       -- Liga competitiva
            COALESCE(reactions, 0) * 0.11 +          -- Reflejos/Reacción
            COALESCE(stamina, 0) * 0.09 +            -- Resistencia
            COALESCE(strength, 0) * 0.09 +           -- Fuerza
            COALESCE(short_passing, 0) * 0.11 +      -- Pases cortos
            COALESCE(dribbling, 0) * 0.10 +          -- Regate
            COALESCE(ball_control, 0) * 0.12 +       -- Control de balón
            COALESCE(vision, 0) * 0.10 +             -- Visión de juego
            COALESCE(balance, 0) * 0.08 +            -- Equilibrio
            COALESCE(positioning, 0) * 0.08          -- Posicionamiento
        ) as general_score,
        -- PUNTAJE ESPECÍFICO DE Goalkeeper
        CASE WHEN role = 'Goalkeeper' THEN
            (
                COALESCE(jumping, 0) * 0.05 +
                COALESCE(gk_diving, 0) * 0.20 +
                COALESCE(gk_handling, 0) * 0.20 +
                COALESCE(gk_kicking, 0) * 0.12 +
                COALESCE(gk_positioning, 0) * 0.18 +
                COALESCE(gk_reflexes, 0) * 0.18 +
                COALESCE(height, 0) * 0.05
            )
        ELSE 0 END as goalkeeper_score,
        -- PUNTAJE ESPECÍFICO DE Defender
        CASE WHEN role = 'Defender' THEN
            (
                COALESCE(defensive_work_rate, 0) * 0.15 +
                COALESCE(long_passing, 0) * 0.08 +
                COALESCE(strength, 0) * 0.10 +
                COALESCE(aggression, 0) * 0.10 +
                COALESCE(interceptions, 0) * 0.15 +
                COALESCE(marking, 0) * 0.15 +
                COALESCE(standing_tackle, 0) * 0.14 +
                COALESCE(sliding_tackle, 0) * 0.13
            )
        ELSE 0 END as defender_score,
        -- PUNTAJE ESPECÍFICO DE Midfielder (Centrocampista)
        CASE WHEN role = 'Midfielder' THEN
            (
                COALESCE(attacking_work_rate, 0) * 0.10 +
                COALESCE(finishing, 0) * 0.15 +
                COALESCE(heading_accuracy, 0) * 0.08 +
                COALESCE(long_shots, 0) * 0.10 +
                COALESCE(penalties, 0) * 0.05 +
                COALESCE(free_kick_accuracy, 0) * 0.07 +
                COALESCE(acceleration, 0) * 0.12 +
                COALESCE(sprint_speed, 0) * 0.12 +
                COALESCE(agility, 0) * 0.11 +
                COALESCE(interceptions, 0) * 0.10
            )
        ELSE 0 END as midfielder_score,
        -- PUNTAJE ESPECÍFICO DE Forward
        CASE WHEN role = 'Forward' THEN
            (
                COALESCE(attacking_work_rate, 0) * 0.08 +
                COALESCE(finishing, 0) * 0.18 +
                COALESCE(heading_accuracy, 0) * 0.10 +
                COALESCE(volleys, 0) * 0.08 +
                COALESCE(shot_power, 0) * 0.12 +
                COALESCE(penalties, 0) * 0.07 +
                COALESCE(curve, 0) * 0.06 +
                COALESCE(acceleration, 0) * 0.10 +
                COALESCE(sprint_speed, 0) * 0.10 +
                COALESCE(jumping, 0) * 0.06 +
                COALESCE(strength, 0) * 0.05
            )
        ELSE 0 END as forward_score,
        -- PUNTAJE ESPECÍFICO DE Sider
        CASE WHEN role = 'Sider' THEN
            (
                COALESCE(attacking_work_rate, 0) * 0.08 +
                COALESCE(crossing, 0) * 0.12 +
                COALESCE(shot_power, 0) * 0.10 +
                COALESCE(long_shots, 0) * 0.09 +
                COALESCE(free_kick_accuracy, 0) * 0.08 +
                COALESCE(long_passing, 0) * 0.08 +
                COALESCE(acceleration, 0) * 0.12 +
                COALESCE(sprint_speed, 0) * 0.12 +
                COALESCE(agility, 0) * 0.12 +
                COALESCE(strength, 0) * 0.06 +
                COALESCE(aggression, 0) * 0.03
            )
        ELSE 0 END as sider_score
    FROM player_full_data
),

-- Paso 8: Calcular puntaje final y clasificar por edad
final_scores AS (
    SELECT 
        player_api_id,
        player_name,
        role,
        age,
        overall_rating,
        general_score,
        -- Seleccionar puntaje específico según rol
        CASE 
            WHEN role = 'Goalkeeper' THEN goalkeeper_score
            WHEN role = 'Defender' THEN defender_score
            WHEN role = 'Midfielder' THEN midfielder_score
            WHEN role = 'Forward' THEN forward_score
            WHEN role = 'Sider' THEN sider_score
        END as role_score,
        -- PUNTAJE FINAL: 40% general + 60% específico de rol
        (general_score * 0.4) + 
        (CASE 
            WHEN role = 'Goalkeeper' THEN goalkeeper_score
            WHEN role = 'Defender' THEN defender_score
            WHEN role = 'Midfielder' THEN midfielder_score
            WHEN role = 'Forward' THEN forward_score
            WHEN role = 'Sider' THEN sider_score
        END * 0.6) as final_score,
        -- Clasificación por edad
        CASE WHEN age <= 29 THEN 'Young' ELSE 'Veteran' END as age_group
    FROM player_scores
),

-- Paso 9: Rankear jugadores por rol y edad
ranked_players AS (
    SELECT 
        role as Rol,
        age_group as Grupo_Edad,
        player_name as Jugador,
        age as Edad,
        overall_rating as Rating_General,
        ROUND(general_score, 2) as General_Score,
        ROUND(role_score, 2) as Role_Score,
        ROUND(final_score, 2) as Final_Score,
        ROW_NUMBER() OVER (PARTITION BY role, age_group ORDER BY final_score DESC) as Ranking
    FROM final_scores
    WHERE role IN ('Goalkeeper', 'Defender', 'Midfielder', 'Forward', 'Sider')
)

-- CONSULTA FINAL: Top 5 por rol y edad
SELECT * FROM ranked_players
WHERE Ranking = 1
ORDER BY Rol, Grupo_Edad, Final_Score DESC;
