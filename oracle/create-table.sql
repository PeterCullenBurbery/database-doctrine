
remark we create the table. you can have any table name here like create table table. Make sure to add the parentheses so the general structure is create table table_name
CREATE TABLE bible_translation (
remark we have the primary key UUID
    bible_translation_id RAW(16) DEFAULT sys_guid() PRIMARY KEY,
remark because there is a unique constraint on bible_translation, the max length is 1000. That's why we can't make bible_translation 4000.
    bible_translation varchar2(1000) not null,
    CONSTRAINT unique_bible_translation UNIQUE ( bible_translation ),
remark we add note if there is something special about that record, for example, if I had to choose between undergraduate and graduate in note I could put I'm in accelerated masters degree. or if it only had 
remark freshman sophomore junior senior I could add in note that I'm a fifth year student. Or if there was only first middle last and someone had 2 middle names, they could put this in note.
    -- Additional columns for note and dates
    note                       VARCHAR2(4000),  -- General-purpose note field
remark date_created is helpful for establishing when the record was created. note that we use a timestamp, which includes a date and time. Also note that we include a time zone. MySQL does not support time zones.
remark also note that we use as the default systimestamp which will give the current date time.
remark also note that we use 9. 9 is for nanoseconds. 0 is for seconds s, 3 for milliseconds ms, 6 for microseconds ?s, 9 for nanoseconds ns.
remark we can make date_created not null because it has a default value so the person doesn't have to enter it.
    date_created               TIMESTAMP(9) WITH TIME ZONE DEFAULT systimestamp(9) NOT NULL,
remark date_updated is not the same as date_created. You could have it so date_updated defaults to date_created, too, but instead I store this in a virtual column. If date_updated is null, that means that record
remark has not been updated. date_updated could also be called date_modified. So for each record we store when it was created and when it was last modified.
    date_updated               TIMESTAMP(9) WITH TIME ZONE,
        date_created_or_updated    TIMESTAMP(9) WITH TIME ZONE GENERATED ALWAYS AS ( coalesce(date_updated, date_created) ) VIRTUAL
);

remark we create a trigger so date_updated is set when the record is updated. I'm not sure if we need to enable insert as well, like if have a record say 1, null, 3, and we insert 2 into null, would date_updated be fired.
remark or would it only count if we updated 1 to 2 or 3 to 4? I'm not sure. in that case, we might need before update or insert on bible_translation.
CREATE OR REPLACE TRIGGER trigger_set_date_updated_bible_translation
BEFORE UPDATE ON bible_translation
FOR EACH ROW
BEGIN
remark you should not do :NEW.date_updated := systimestamp(9). That will throw an error and not work. This is only in a trigger. you can use systimestamp(9) in the table (see above).
    :NEW.date_updated := systimestamp;
END;
/

-- 1. Create the bible table
CREATE TABLE bible_work (
    bible_work_id RAW(16) DEFAULT sys_guid() PRIMARY KEY,
remark here we have an example of a string field. By default, I make string fields max length 4000 characters. We can make it 4000, not 1000, because random bible verse does not need to be unique
remark and does not have a unique constraint on it.
    random_bible_verse varchar2(4000) not null,
    bible    VARCHAR2(1000) NOT NULL,
    bible_translation_id raw(16) not null,
    date_read               TIMESTAMP(9) WITH TIME ZONE DEFAULT systimestamp(9),
    CONSTRAINT unique_bible UNIQUE ( bible ),

    -- Additional columns for note and dates
    note                       VARCHAR2(4000),  -- General-purpose note field
    date_created               TIMESTAMP(9) WITH TIME ZONE DEFAULT systimestamp(9) NOT NULL,
    date_updated               TIMESTAMP(9) WITH TIME ZONE,
        date_created_or_updated    TIMESTAMP(9) WITH TIME ZONE GENERATED ALWAYS AS ( coalesce(date_updated, date_created) ) VIRTUAL,
remark here we have an example of a reference/foreign key constraint. we say table_references_other_table. So in this case, bible_work references bible_translation. We name the constraint, then say FOREIGN KEY and what
remark column in the table is that references out, and then we say REFERENCES the table out there (referenced column).
        CONSTRAINT foreign_key_bible_work_references_bible_translation FOREIGN KEY ( bible_translation_id )
        REFERENCES bible_translation ( bible_translation_id )
);


-- Trigger to update date_updated for operating_system
CREATE OR REPLACE TRIGGER trigger_set_date_updated_bible_work 
BEFORE UPDATE ON bible_work
FOR EACH ROW
BEGIN
    :NEW.date_updated := systimestamp;
END;
/

remark triggers are named trigger_set_date_updated_(table_name) if its for date_updated. foreign keys are named foreign_key_(table)_references_(outside table). unique constraints are name
remark unique_(column name) or for combinations unique_combination_of_(column 1)_and_(column 2)_and_(column 3)_etc...
remark joining tables are to be named joining_table_of_(table 1)_and_(table 2).
remark the tables start out with one main column as a string. this makes data entry easy without worrying about complicated columns. so we have one column bible_translation for the table bible_translation and one column 
remark bible_work for the table bible_work. This is opposed to a more complicated setup like bible work having chapter, verse, reading plan information, random verse inspiration, etc. Its good to have structured columns but 
remark they are more of a headache.
remark the idea is to have the main column named after the table. Notice you have bible_translation.bible_translation and bible_work.bible_work, as opposed to common things like bible_translation.bible_translation_name,
remark or city.name.
remark the id column I like to include the name of the table. I am flexible with just using id instead of (table name)_id for the id column, because id is faster to type shorter, and id is clear (that it's a key).
remark however, the benefit of something like city_id, book_id, etc. is that I have some idea of what thing we're talking about whereas as with id I don't know if that's book id, city id, or what.
remark another advantage of using just id is that its faster to type in joins like select * from book bk join author at on bk.author_id=at.id. I think the reason that I use id is because to be consistent. Notice there's a
remark inconsistency here. Why not use bk.author_id=at.author_id? I think that's clearer, and you don't have to think wait, do I use author_id for book, but wait just id for author?
remark I am more flexible on this and open to people convincing me otherwise. I know a lot of people like Ben Brumm that do just id not author_id or whatever.
remark one disadvantage of using full id is that you have to type it out more and things become longer. For example, you start ending with up join_of_table_1_and_table_2.join_of_table_1_and_table_2_id which can become a pain
remark to type compared to just join_of_table_1_and_table_2.id if you're joining on a many-to-many relationship.
remark when you create a table, you want to think of functionally primary keys like email address. Email address uniquely identifies a person. one email address per person.
remark one to one relationship between person and email address. put a unique constraint on that. think about unique constraints.
remark think about not null constraint. phone number make it not null say you have to get the person's phone number before you add them to the table.
remark middle name could be nullable. maybe someone doesn't have a middle name (Malcom X). a person should have a first and last name.
remark think about triggers. triggers can be used to add a default value, though you could also use a virtual column if something was computed. triggers can get kind of complicated and so you
remark might want to handle it in the application logic.

remark many to many relationship example

CREATE TABLE student (
    student_id RAW(16) DEFAULT sys_guid() PRIMARY KEY,
    student varchar2(1000) not null,
    CONSTRAINT unique_student UNIQUE ( student ),

    -- Additional columns for note and dates
    note                       VARCHAR2(4000),  -- General-purpose note field
    date_created               TIMESTAMP(9) WITH TIME ZONE DEFAULT systimestamp(9) NOT NULL,
    date_updated               TIMESTAMP(9) WITH TIME ZONE,
        date_created_or_updated    TIMESTAMP(9) WITH TIME ZONE GENERATED ALWAYS AS ( coalesce(date_updated, date_created) ) VIRTUAL
);

-- Trigger to update date_updated for operating_system
CREATE OR REPLACE TRIGGER trigger_set_date_updated_student
BEFORE UPDATE ON student
FOR EACH ROW
BEGIN
    :NEW.date_updated := systimestamp;
END;
/