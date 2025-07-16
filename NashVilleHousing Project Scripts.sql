
-- Cleaning Nashville Housing Data

SELECT *
FROM PortfolioProject..NashvilleHousing;

-- Data Formating

ALTER TABLE NashvilleHousing
	ADD SaleDate_2 DATE;
UPDATE NashvilleHousing
	SET SaleDate_2 = CONVERT(DATE, SaleDate);

-- Populate Property Address Data

SELECT *
FROM PortfolioProject..NashvilleHousing
WHERE PropertyAddress IS NULL
ORDER BY ParcelID

SELECT NH1.ParcelID, NH1.PropertyAddress, NH2.ParcelID, NH2.PropertyAddress, ISNULL(NH1.PropertyAddress, NH2.PropertyAddress)
FROM PortfolioProject..NashvilleHousing NH1
JOIN PortfolioProject..NashvilleHousing NH2
		ON NH1.ParcelID = NH2.ParcelID
			AND NH1.UniqueID <> NH2.UniqueID
WHERE NH1.PropertyAddress IS NULL;

UPDATE NH1
	SET PropertyAddress = ISNULL(NH1.PropertyAddress, NH2.PropertyAddress)
FROM PortfolioProject..NashvilleHousing NH1
JOIN PortfolioProject..NashvilleHousing NH2
		ON NH1.ParcelID = NH2.ParcelID
			AND NH1.UniqueID <> NH2.UniqueID
WHERE NH1.PropertyAddress IS NULL;

-- Seperating Full Address Into (Address | City | State)

SELECT PropertyAddress
FROM PortfolioProject..NashvilleHousing;

SELECT
	SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1) AS Address,
	SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) +1, LEN(PropertyAddress)) AS Address2
FROM PortfolioProject..NashvilleHousing;

ALTER TABLE NashvilleHousing
	ADD StreetAddress NVARCHAR(255);
UPDATE NashvilleHousing
	SET StreetAddress = SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1);

ALTER TABLE NashvilleHousing
	ADD City NVARCHAR(255);
UPDATE NashvilleHousing
	SET City = SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) +1, LEN(PropertyAddress));

SELECT PropertyAddress, StreetAddress, City
FROM PortfolioProject..NashvilleHousing;

SELECT OwnerAddress
FROM PortfolioProject..NashvilleHousing;

SELECT
	PARSENAME(REPLACE(OwnerAddress, ',', '.'), 3),
	PARSENAME(REPLACE(OwnerAddress, ',', '.'), 2),
	PARSENAME(REPLACE(OwnerAddress, ',', '.'), 1)
FROM PortfolioProject..NashvilleHousing;

ALTER TABLE NashvilleHousing
	ADD OwnerStreetAddress NVARCHAR(255);
UPDATE NashvilleHousing
	SET OwnerStreetAddress = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 3);

ALTER TABLE NashvilleHousing
	ADD OwnerCity NVARCHAR(255);
UPDATE NashvilleHousing
	SET OwnerCity = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 2);

ALTER TABLE NashvilleHousing
	ADD OwnerState NVARCHAR(255);
UPDATE NashvilleHousing
	SET OwnerState = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 1);

SELECT OwnerAddress, OwnerStreetAddress, OwnerCity, OwnerState
FROM PortfolioProject..NashvilleHousing;

-- Change Y/N to Yes/No within "SoldAsVacant" Column

SELECT DISTINCT(SoldAsVacant)
FROM PortfolioProject..NashvilleHousing;


SELECT SoldAsVacant,
	CASE
		WHEN SoldAsVacant = 'Y' THEN 'Yes'
		WHEN SoldAsVacant = 'N' THEN 'No'
		ELSE SoldAsVacant
	END
FROM PortfolioProject..NashvilleHousing;


UPDATE NashvilleHousing
	SET SoldAsVacant = CASE
							WHEN SoldAsVacant = 'Y' THEN 'Yes'
							WHEN SoldAsVacant = 'N' THEN 'No'
							ELSE SoldAsVacant
						END;

-- Remove Duplicates

WITH RowNumCTE AS(
					SELECT *,
						ROW_NUMBER() OVER (PARTITION BY ParcelID,
														PropertyAddress,
														SalePrice,
														SaleDate,
														LegalReference
											ORDER BY UniqueID
											) RowNum
					FROM PortfolioProject..NashvilleHousing
					)
DELETE
FROM RowNumCTE
WHERE RowNum > 1;

-- Delete Unused Columns

SELECT *
FROM PortfolioProject..NashvilleHousing;

ALTER TABLE PortfolioProject..NashvilleHousing
DROP COLUMN PropertyAddress,
			SaleDate,
			OwnerAddress,
			TaxDistrict;

-- Cleanup/Tweaking

ALTER TABLE NashvilleHousing
	ADD SaleDate DATE;
UPDATE NashvilleHousing
	SET SaleDate = SaleDate_2;

ALTER TABLE PortfolioProject..NashvilleHousing
DROP COLUMN SaleDate_2;