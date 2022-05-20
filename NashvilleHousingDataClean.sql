/* Data Cleaning in SQL queries */

-- Convert SaleDate from timestamp to date data type

ALTER TABLE "NashvilleHousing"
ADD "SaleDateConverted" Date

UPDATE "NashvilleHousing"
SET "SaleDateConverted" = "SaleDate"::Date


-- Populate PropertyAddress data

SELECT * FROM "NashvilleHousing"
--WHERE "PropertyAddress" IS NULL
ORDER BY "ParcelID"


SELECT a."ParcelID",a."PropertyAddress",b."ParcelID",b."PropertyAddress", COALESCE(a."PropertyAddress",b."PropertyAddress")
FROM "NashvilleHousing" a
JOIN "NashvilleHousing" b
	ON a."ParcelID" = b."ParcelID"
	AND a."UniqueID" <> b."UniqueID"
WHERE a."PropertyAddress" IS NULL


UPDATE "NashvilleHousing" a
	SET "PropertyAddress" = COALESCE(a."PropertyAddress",b."PropertyAddress")
FROM "NashvilleHousing" b
WHERE a."ParcelID" = b."ParcelID" 
	AND a."UniqueID" <> b."UniqueID"
AND a."PropertyAddress" IS NULL;


---------------------------------------
-- Separate Address into individual columns (address, city, and state)


SELECT
SUBSTRING("PropertyAddress", 1, POSITION(',' in "PropertyAddress")-1) as Address,
SUBSTRING("PropertyAddress", POSITION(',' in "PropertyAddress")+2, LENGTH("PropertyAddress")) as City
FROM "NashvilleHousing"


ALTER TABLE "NashvilleHousing"
ADD "PropertySplitAddress" VARCHAR(255);

UPDATE "NashvilleHousing"
SET "PropertySplitAddress" = SUBSTRING("PropertyAddress", 1, POSITION(',' in "PropertyAddress")-1)


ALTER TABLE "NashvilleHousing"
ADD "PropertySplitCity" VARCHAR(255);

UPDATE "NashvilleHousing"
SET "PropertySplitCity" = SUBSTRING("PropertyAddress", POSITION(',' in "PropertyAddress")+2, LENGTH("PropertyAddress"))


SELECT SPLIT_PART("OwnerAddress",', ',1),
SPLIT_PART("OwnerAddress",', ',2),
SPLIT_PART("OwnerAddress",', ',3) 
FROM "NashvilleHousing"

ALTER TABLE "NashvilleHousing"
ADD "OwnerSplitAddress" VARCHAR(255);

UPDATE "NashvilleHousing"
SET "OwnerSplitAddress" = SPLIT_PART("OwnerAddress",', ',1)


ALTER TABLE "NashvilleHousing"
ADD "OwnerSplitCity" VARCHAR(255);

UPDATE "NashvilleHousing"
SET "OwnerSplitCity" = SPLIT_PART("OwnerAddress",', ',2)


ALTER TABLE "NashvilleHousing"
ADD "OwnerSplitState" VARCHAR(255);

UPDATE "NashvilleHousing"
SET "OwnerSplitState" = SPLIT_PART("OwnerAddress",', ',3)


---------------------------------------
-- Change Y and N to Yes and No in SoldAsVacant column

SELECT DISTINCT("SoldAsVacant"), COUNT("SoldAsVacant")
FROM "NashvilleHousing"
GROUP BY "SoldAsVacant"
ORDER BY 2


SELECT "SoldAsVacant",
CASE 
	WHEN "SoldAsVacant" = 'Y' THEN 'Yes'
	WHEN "SoldAsVacant" = 'N' THEN 'No'
	ELSE "SoldAsVacant"
	END
FROM "NashvilleHousing"

UPDATE "NashvilleHousing"
SET "SoldAsVacant" = CASE 
	WHEN "SoldAsVacant" = 'Y' THEN 'Yes'
	WHEN "SoldAsVacant" = 'N' THEN 'No'
	ELSE "SoldAsVacant"
	END


---------------------------------------
-- Removes duplicates

WITH RowNumCTE 
	AS (SELECT "UniqueID", ROW_NUMBER() 
	OVER (
	PARTITION BY "ParcelID","PropertyAddress","SalePrice","SaleDate","LegalReference"
	ORDER BY "UniqueID"
		) row_num
FROM "NashvilleHousing"
)
DELETE FROM "NashvilleHousing"
WHERE "UniqueID" in (SELECT "UniqueID" FROM RowNumCTE WHERE row_num > 1)
--ORDER BY "PropertyAddress"


---------------------------------------
-- Removes unused columns

ALTER TABLE "NashvilleHousing"
DROP COLUMN "SaleDate",
DROP COLUMN "OwnerAddress",
DROP COLUMN "PropertyAddress",
DROP COLUMN "TaxDistrict"

