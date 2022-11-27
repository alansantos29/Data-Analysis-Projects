/*
Data cleaning processes 
On Housing Dataset
*/


SELECT *
FROM housing.housing;

#CONVERTING  TIME FORMATS
SELECT SaleDate, str_to_date(SaleDate, "%M %D %Y")
FROM housing.housing;

UPDATE housing.housing
SET SaleDate = str_to_date(SaleDate, "%M %D %Y");


-- Populate addres Data (On this data base there where no null vaues yet some datafiles where empty)
SELECT *
FROM housing
where PropertyAddress ="";

-- Convert Empty values to null

SELECT PropertyAddress, IF(PropertyAddress= "", NULL, PropertyAddress)
FROM housing
where PropertyAddress ="";


update housing.housing
set PropertyAddress = IF(PropertyAddress= "", NULL, PropertyAddress);


-- convert Null values to addressess 
SELECT a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, ifnull(a.PropertyAddress, b.PropertyAddress)
FROM housing.housing a
JOIN housing.housing b
ON a.ParcelID = b.ParcelID
AND a.UniqueID <> b.UniqueID
WHERE a.PropertyAddress is null;

-- why is it not working??? it was denined ??? fix later
UPDATE housing.housing
SET PropertyAddress = ifnull(a.PropertyAddress, b.PropertyAddress)
WHERE a.ParcelID = b.ParcelID
AND a.UniqueID <> b.UniqueID;



-- Breaking out Address into indivual columns (Address,City, State)
SELECT PropertyAddress 
FROM housing.housing;

-- Spliting the address and City
SELECT substring_index(PropertyAddress, ",",1 ) Address,
substring_index(PropertyAddress, ",", -1) City
FROM housing.housing;

-- Adding a extra column for the address 
ALTER TABLE housing.housing
ADD PropertySplitAddress VARCHAR(255);

-- Populating the new column
UPDATE housing.housing
SET PropertySplitAddress = substring_index(PropertyAddress, ",",1 );

-- Creating an extra column for the city
ALTER TABLE housing.housing
ADD PropertySplitCity VARCHAR(255);

-- Populating the new column
UPDATE  housing.housing
SET PropertySplitCity = substring_index(PropertyAddress, ",", -1);


-- Splitting the owner address to get the State

SELECT OwnerAddress, substring_index(OwnerAddress, ",",-1)
FROM housing.housing;

-- Create an extra column for state
ALTER TABLE housing.housing
ADD PropertySplitState VARCHAR(255);

-- Populate the State Column
UPDATE housing.housing
SET PropertySplitState =substring_index(OwnerAddress, ",",-1);




--  Chanye Y and N to Yes and No in the SoldAsVacant column
SELECT distinct(SoldAsVacant), count(SoldAsVacant)
from housing.housing
Group by 1
Order by 2;

SELECT SoldAsVacant,
CASE WHEN  SoldAsVacant = "Y" THEN "YES"
	 WHEN  SoldAsVacant = "N" THEN "NO"
	 ELSE  SoldAsVacant
     END
FROM housing.housing;


UPDATE housing.housing
SET SoldAsVacant = CASE WHEN  SoldAsVacant = "Y" THEN "YES"
	 WHEN  SoldAsVacant = "N" THEN "NO"
	 ELSE  SoldAsVacant
     END
     
     
-- Remove Duplicates 

SELECT  *, 
		ROW_NUMBER() OVER (
						PARTITION BY ParcelID,
				 PropertyAddress,
				 SalePrice,
				 SaleDate,
				 LegalReference
			ORDER BY UniqueID
        ) AS row_num
FROM housing.housing;

-- shows the list of duplicates rows
SELECT UniqueID, PropertyAddress, SalePrice, SaleDate, LegalReference

FROM(
SELECT  *, 
		ROW_NUMBER() OVER (
						PARTITION BY ParcelID,
				 PropertyAddress,
				 SalePrice,
				 SaleDate,
				 LegalReference
			ORDER BY UniqueID
        ) AS row_num
FROM housing.housing
) t
WHERE row_num>1;

-- Delete Duplicates
DELETE FROM housing.housing
WHERE 
		UniqueID IN (
        SELECT UniqueID

FROM(
SELECT  *, 
		ROW_NUMBER() OVER (
						PARTITION BY ParcelID,
				 PropertyAddress,
				 SalePrice,
				 SaleDate,
				 LegalReference
			ORDER BY UniqueID
        ) AS row_num
FROM housing.housing
) t
WHERE row_num>1
);


-- Delete Unsused Columns
SELECT * 
FROM housing.housing;

ALTER TABLE housing.housing
DROP COLUMN OwnerAddress,
DROP COLUMN TaxDistrict, 
DROP COLUMN PropertyAddress,
DROP column SaleDate;


