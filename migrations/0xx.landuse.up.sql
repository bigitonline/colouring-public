-- Create land use and fields
--Landuse is hierachical. Highest level is Order (Residential) then Group (Residential-Dwelling) then Class (Residential-Dwelling-Detached house)
--Some ETL work required to get this together refer to analysis repo
--Prerequesite is to have first run bulk_data_sources migrations
 --Then create table landuse_order for the app, this is used as foreign key for current and original landuse_order

CREATE TABLE IF NOT EXISTS reference_tables.buildings_landuse_order AS
SELECT a.landuse_id,
       a.description,
       a."level",
       a.parent_id,
       a.parent_name
FROM reference_tables.landuse_classifications a
WHERE a."level" = 'order'
  AND a.is_used IS TRUE ;

--the below is for front end reference, not current used as a constraint
  CREATE TABLE IF NOT EXISTS reference_tables.buildings_landuse_class AS
  SELECT a.landuse_id,
         a.description,
         a."level",
         a.parent_id,
         a.parent_name
  FROM reference_tables.landuse_classifications a
  WHERE a."level" = 'class'
    AND a.is_used IS TRUE ;

ALTER TABLE buildings ADD COLUMN IF NOT EXISTS current_landuse_order text, ADD CONSTRAINT fk_current_landuse_order
FOREIGN KEY (current_landuse_order) REFERENCES reference_tables.buildings_landuse_order (description);

--Landuse is hierachical. Highest level is Order (Residential) then Group (Residential-Dwelling) then Class (Residential-Dwelling-Detached house)
--Interface will collected most detailed (class) but visualise highest level (order)
--Landuse is a table as #358
--Prerequisite run bulk_sources migration first
 -- Land use is table with 3 levels of hierachy (highest to lowest). order > group > class
 -- Land use class or classes, array object, client constrained. ARRAY[] is used to constrain array size. The array is limited to 250 based on Westfield Stratford as a single toid with many uses, this may want to be reduced down to reduce maximum size.

ALTER TABLE buildings ADD COLUMN IF NOT EXISTS current_landuse_class text ARRAY[250];

-- Land use order, singular. Client and db constrained with foreign key



--===========================================
--
-- We also collect original landuse, structure & process is as current land use
-- We don't currently collect intermediate historic uses
--
--===========================================
 -- Original Land use class or classes, array object, client constrained.

ALTER TABLE buildings ADD COLUMN IF NOT EXISTS original_landuse_class text ARRAY[250];

-- Land use order, singular. Client and db constrained.

ALTER TABLE buildings ADD COLUMN IF NOT EXISTS original_landuse_order text, ADD CONSTRAINT fk_original_landuse_order
FOREIGN KEY (original_landuse_order) REFERENCES reference_tables.buildings_landuse_order (description);
