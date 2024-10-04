CREATE TABLE purchase_something_or_gain_money (
    purchase_something_or_gain_money_id              RAW(16) DEFAULT sys_guid() PRIMARY KEY,
    purchase_something_or_gain_money                 VARCHAR2(1000) NOT NULL,
    purchase_amount number(38,3),
    money_gained_not_lost_or_paid NUMBER(1) NOT NULL,
    CONSTRAINT money_gained_not_lost_or_paid_boolean CHECK (money_gained_not_lost_or_paid IN (0, 1)),
    CONSTRAINT unique_purchase_something_or_gain_money UNIQUE ( purchase_something_or_gain_money ),
    -- Virtual column to adjust money value based on gain/loss or return null for invalid cases
    adjusted_purchase_amount AS (
        CASE
            -- If money is lost (0) and purchase amount is positive, multiply by -1
            WHEN money_gained_not_lost_or_paid = 0 AND purchase_amount > 0 THEN purchase_amount * -1
            -- If money is gained (1) and purchase amount is negative, output NULL
            WHEN money_gained_not_lost_or_paid = 1 AND purchase_amount < 0 THEN NULL
            -- Otherwise, return the purchase amount as it is
            ELSE purchase_amount
        END
    ) VIRTUAL,
    -- Additional columns for note and dates
    note                    VARCHAR2(4000),  -- General-purpose note field
    date_created            TIMESTAMP(9) WITH TIME ZONE DEFAULT systimestamp(9) NOT NULL,
    date_updated            TIMESTAMP(9) WITH TIME ZONE,
        date_created_or_updated TIMESTAMP(9) WITH TIME ZONE GENERATED ALWAYS AS ( coalesce(date_updated, date_created) ) VIRTUAL
);

CREATE OR REPLACE TRIGGER trigger_set_date_updated_purchase_something_or_gain_money BEFORE
    UPDATE ON purchase_something_or_gain_money
    FOR EACH ROW
BEGIN
    :new.date_updated := systimestamp;
END;
/