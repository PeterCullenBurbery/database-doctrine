CREATE TABLE game_setup (
    game_setup_id              RAW(16) DEFAULT sys_guid() PRIMARY KEY,
    game_setup                 VARCHAR2(1000) NOT NULL,
    CONSTRAINT unique_game_setup UNIQUE ( game_setup ),
    level_in_kingdom_rush_id raw(16) references level_in_kingdom_rush(level_in_kingdom_rush_id),

    -- Additional columns for note and dates
    note                    VARCHAR2(4000),  -- General-purpose note field
    date_created            TIMESTAMP(9) WITH TIME ZONE DEFAULT systimestamp(9) NOT NULL,
    date_updated            TIMESTAMP(9) WITH TIME ZONE,
        date_created_or_updated TIMESTAMP(9) WITH TIME ZONE GENERATED ALWAYS AS ( coalesce(date_updated, date_created) ) VIRTUAL
);

CREATE OR REPLACE TRIGGER trigger_set_date_updated_game_setup BEFORE
    UPDATE ON game_setup
    FOR EACH ROW
BEGIN
    :new.date_updated := systimestamp;
END;
/