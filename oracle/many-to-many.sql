remark many to many relationship example

CREATE TABLE student (
    student_id              RAW(16) DEFAULT sys_guid() PRIMARY KEY,
    student                 VARCHAR2(1000) NOT NULL,
    CONSTRAINT unique_student UNIQUE ( student ),

    -- Additional columns for note and dates
    note                    VARCHAR2(4000),  -- General-purpose note field
    date_created            TIMESTAMP(9) WITH TIME ZONE DEFAULT systimestamp(9) NOT NULL,
    date_updated            TIMESTAMP(9) WITH TIME ZONE,
        date_created_or_updated TIMESTAMP(9) WITH TIME ZONE GENERATED ALWAYS AS ( coalesce(date_updated, date_created) ) VIRTUAL
);

remark Trigger to update date_updated for operating_system
CREATE OR REPLACE TRIGGER trigger_set_date_updated_student BEFORE
    UPDATE ON student
    FOR EACH ROW
BEGIN
    :new.date_updated := systimestamp;
END;
/
remark class is another name you could have used for this table.
CREATE TABLE course (
    course_id               RAW(16) DEFAULT sys_guid() PRIMARY KEY,
    course                  VARCHAR2(1000) NOT NULL,
    CONSTRAINT unique_course UNIQUE ( course ),

    -- Additional columns for note and dates
    note                    VARCHAR2(4000),  -- General-purpose note field
    date_created            TIMESTAMP(9) WITH TIME ZONE DEFAULT systimestamp(9) NOT NULL,
    date_updated            TIMESTAMP(9) WITH TIME ZONE,
        date_created_or_updated TIMESTAMP(9) WITH TIME ZONE GENERATED ALWAYS AS ( coalesce(date_updated, date_created) ) VIRTUAL
);

remark Trigger to update date_updated for operating_system
CREATE OR REPLACE TRIGGER trigger_set_date_updated_course BEFORE
    UPDATE ON course
    FOR EACH ROW
BEGIN
    :new.date_updated := systimestamp;
END;
/
remark joining table for many-to-many relationship between course and student.
remark joining tables are to be named joining_table_of_(table 1)_and_(table 2).
remark one question to consider is should it be student and course or course and student? To answer this question, we should ask, which is higher? The average number of students in a course, or the number of 
remark courses a student takes. This might be hard to answer, considering a student might take 30 courses or more but you could have 30 people in a class.
remark so here joining_table_of_course_and_student is also okay.
remark I prefer the comment /* */ to -- or //
CREATE TABLE joining_table_of_student_and_course (
    joining_table_of_student_and_course_id RAW(16) DEFAULT sys_guid() PRIMARY KEY,
    joining_table_of_student_and_course    VARCHAR2(1000) NOT NULL,
    CONSTRAINT unique_joining_table_of_student_and_course UNIQUE ( joining_table_of_student_and_course ),
    --the not null constraint on student and course is important
    student_id raw(16) not null,
    course_id raw(16) not null,
--we add 2 foreign key constraints for many to many relationship
    CONSTRAINT foreign_key_joining_table_of_student_and_course_references_student FOREIGN KEY ( student_id )
        REFERENCES student ( student_id ),
    CONSTRAINT foreign_key_joining_table_of_student_and_course_references_course FOREIGN KEY ( course_id )
        REFERENCES course ( course_id ),
--we add a unique constraint
CONSTRAINT unique_combination_of_student_and_course UNIQUE ( student_id,course_id),
    -- Additional columns for note and dates
    note                                   VARCHAR2(4000),  -- General-purpose note field
    date_created                           TIMESTAMP(9) WITH TIME ZONE DEFAULT systimestamp(9) NOT NULL,
    date_updated                           TIMESTAMP(9) WITH TIME ZONE,
        date_created_or_updated                TIMESTAMP(9) WITH TIME ZONE GENERATED ALWAYS AS ( coalesce(date_updated, date_created)
        ) VIRTUAL
);

remark Trigger to update date_updated for operating_system
CREATE OR REPLACE TRIGGER trigger_set_date_updated_joining_table_of_student_and_course BEFORE
    UPDATE ON joining_table_of_student_and_course
    FOR EACH ROW
BEGIN
    :new.date_updated := systimestamp;
END;
/
remark As an example of a boolean column, see is_liar for the table suspect.
remark Oracle 23 ai includes boolean as a data type. However, Oracle 23 ai is not available as enterprise for free. Oracle 21 c enterprise is free. Oracle 19c enterprise is also free.
remark Oracle 23 ai is 950 dollars per license.
remark Oracle 23 ai is also not supported that well on Windows. You can run it in a virtual machine (VM) or Docker (container), but it's not as good.
remark its better to run Oracle 23 ai on Linux, such as Kali, Ubuntu, or Oracle Linux.
CREATE TABLE suspect (
    suspect_id              RAW(16) DEFAULT sys_guid() PRIMARY KEY,
    suspect                 VARCHAR2(1000) NOT NULL,
    CONSTRAINT unique_suspect UNIQUE ( suspect ),
    is_liar NUMBER(1) NOT NULL,  -- A boolean-like value of 1 for true and 0 for false
    CONSTRAINT is_liar_boolean CHECK (is_liar IN (0, 1)),  -- Ensuring only 0 or 1 values. This is needed because
    --with number(1), you can have 0,1, or -1. We don't want to allow -1 so we add a check constraint.
    -- Additional columns for note and dates
    note                    VARCHAR2(4000),  -- General-purpose note field
    date_created            TIMESTAMP(9) WITH TIME ZONE DEFAULT systimestamp(9) NOT NULL,
    date_updated            TIMESTAMP(9) WITH TIME ZONE,
        date_created_or_updated TIMESTAMP(9) WITH TIME ZONE GENERATED ALWAYS AS ( coalesce(date_updated, date_created) ) VIRTUAL
);

CREATE OR REPLACE TRIGGER trigger_set_date_updated_suspect BEFORE
    UPDATE ON suspect
    FOR EACH ROW
BEGIN
    :new.date_updated := systimestamp;
END;
/

remark as an example of a blob column
remark a blob column can be named image, thing_image, picture, video, document, etc.
CREATE TABLE animal (
    animal_id              RAW(16) DEFAULT sys_guid() PRIMARY KEY,
    animal                 VARCHAR2(1000) NOT NULL,
    CONSTRAINT unique_animal UNIQUE ( animal ),
    image blob,
    -- Additional columns for note and dates
    note                    VARCHAR2(4000),  -- General-purpose note field
    date_created            TIMESTAMP(9) WITH TIME ZONE DEFAULT systimestamp(9) NOT NULL,
    date_updated            TIMESTAMP(9) WITH TIME ZONE,
        date_created_or_updated TIMESTAMP(9) WITH TIME ZONE GENERATED ALWAYS AS ( coalesce(date_updated, date_created) ) VIRTUAL
);
remark note that with a blob column, you cannot check if its unique.
remark there is a way to store a reference link to file system instead of storing a blob named a b file. This can be helpful if the blob is too big.
remark blob can store up to 4 gigabytes. use the enterprise Oracle to take advantage of blob, otherwise, you might run out of space with the database.
CREATE OR REPLACE TRIGGER trigger_set_date_updated_animal BEFORE
    UPDATE ON animal
    FOR EACH ROW
BEGIN
    :new.date_updated := systimestamp;
END;
/
remark here is an example of a table with a date_eaten, date_attended, date_read column
remark we create the table. you can have any table name here like create table table. Make sure to add the parentheses so the general structure is create table table_name
CREATE TABLE food (
/*we have the primary key UUID*/
    food_id RAW(16) DEFAULT sys_guid() PRIMARY KEY,
--because there is a unique constraint on food, the max length is 1000. That's why we can't make food 4000.
    food varchar2(1000) not null,
    CONSTRAINT unique_food UNIQUE ( food ),
    date_eaten timestamp(9) with time zone default systimestamp(9)/*date_eaten could be null if we actually do not know the date we ate some food, unlike date_created
    which has a not null constraint and is not nullable.*/,
/* we add note if there is something special about that record, for example, if I had to choose between undergraduate and graduate in note I could put I'm in accelerated masters degree. or if it only had */
/* freshman sophomore junior senior I could add in note that I'm a fifth year student. Or if there was only first middle last and someone had 2 middle names, they could put this in note.*/
/*we want to add an additional column date_eated. date_eated/date_read. This would be slighly different from date_created, because a record could have been added after the fact but 
we eaten earlier, read earlier. food eaten, bible read, book read. So for example, maybe I entered it on 2024-10-03 but ate the food on 2024-09-01. The default is there because you're probably
entering it as you go, but there is a significant semantic difference between when the record/row became part of the table, and when the thing it represents happened/was done/became a thing.
*/    -- Additional columns for note and dates
    note                       VARCHAR2(4000),  -- General-purpose note field
/* date_created is helpful for establishing when the record was created. note that we use a timestamp, which includes a date and time. Also note that we include a time zone. MySQL does not support time zones.*/
/* also note that we use as the default systimestamp which will give the current date time.*/
/* also note that we use 9. 9 is for nanoseconds. 0 is for seconds s, 3 for milliseconds ms, 6 for microseconds ?s, 9 for nanoseconds ns.*/
/* we can make date_created not null because it has a default value so the person doesn't have to enter it.*/
    date_created               TIMESTAMP(9) WITH TIME ZONE DEFAULT systimestamp(9) NOT NULL,
/* date_updated is not the same as date_created. You could have it so date_updated defaults to date_created, too, but instead I store this in a virtual column. If date_updated is null, that means that record*/
/* has not been updated. date_updated could also be called date_modified. So for each record we store when it was created and when it was last modified.*/
    date_updated               TIMESTAMP(9) WITH TIME ZONE,
        date_created_or_updated    TIMESTAMP(9) WITH TIME ZONE GENERATED ALWAYS AS ( coalesce(date_updated, date_created) ) VIRTUAL
);