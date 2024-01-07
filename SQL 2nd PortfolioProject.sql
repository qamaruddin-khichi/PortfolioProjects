-- Cleaning Data in SQL Queries

-- Select the entire data for the Project

SELECT *
FROM PortfolioProjects.dbo.NashvilleHousing$

-- Standradize Data Format

SELECT ConvertedDate, CONVERT(Date,SaleDate) AS ConvertedDate
FROM PortfolioProjects.dbo.NashvilleHousing$

ALTER TABLE PortfolioProjects.dbo.NashvilleHousing$
ADD ConvertedDate Date;

UPDATE PortfolioProjects.dbo.NashvilleHousing$
SET ConvertedDate = CONVERT(Date,SaleDate)

-- Populate Property Address Data

SELECT a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, ISNULL(a.PropertyAddress,b.PropertyAddress)
FROM PortfolioProjects.dbo.NashvilleHousing$ a
JOIN PortfolioProjects.dbo.NashvilleHousing$ b
	ON a.ParcelID = b.ParcelID
	AND a.[UniqueID ] <> b.[UniqueID ]
WHERE a.PropertyAddress IS NULL

UPDATE a
SET PropertyAddress = ISNULL(a.PropertyAddress,b.PropertyAddress)
FROM PortfolioProjects.dbo.NashvilleHousing$ a
JOIN PortfolioProjects.dbo.NashvilleHousing$ b
	ON a.ParcelID = b.ParcelID
	AND a.[UniqueID ] <> b.[UniqueID ]
WHERE a.PropertyAddress IS NULL

-- Breaking Out Address into Individual Columns (Address, City, State)

SELECT PropertyAddress
FROM PortfolioProjects.dbo.NashvilleHousing$

SELECT 
SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress)-1) AS Address
, SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress)+1, LEN(PropertyAddress)) AS City
FROM PortfolioProjects.dbo.NashvilleHousing$
 
ALTER TABLE PortfolioProjects.dbo.NashvilleHousing$
ADD Address nvarchar(255)

UPDATE PortfolioProjects.dbo.NashvilleHousing$
SET Address = SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress)-1)

ALTER TABLE PortfolioProjects.dbo.NashvilleHousing$
ADD City nvarchar(255)

UPDATE PortfolioProjects.dbo.NashvilleHousing$
SET City = SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress)+1, LEN(PropertyAddress))

SELECT OwnerAddress
FROM PortfolioProjects.dbo.NashvilleHousing$

SELECT
PARSENAME(REPLACE(OwnerAddress,',' , '.'),3) AS OwnerSplitAddress
, PARSENAME(REPLACE(OwnerAddress,',' , '.'),2) AS OwnerSplitCity
, PARSENAME(REPLACE(OwnerAddress,',' , '.'),1) AS OwnerSplitState
FROM PortfolioProjects.dbo.NashvilleHousing$

ALTER TABLE PortfolioProjects.dbo.NashvilleHousing$
ADD OwnerSplitAddress nvarchar(255)

UPDATE PortfolioProjects.dbo.NashvilleHousing$
SET OwnerSplitAddress = PARSENAME(REPLACE(OwnerAddress,',' , '.'),3)

ALTER TABLE PortfolioProjects.dbo.NashvilleHousing$
ADD OwnerSplitCity nvarchar(255)

UPDATE PortfolioProjects.dbo.NashvilleHousing$
SET OwnerSplitCity = PARSENAME(REPLACE(OwnerAddress,',' , '.'),2)

ALTER TABLE PortfolioProjects.dbo.NashvilleHousing$
ADD OwnerSplitState nvarchar(255)

UPDATE PortfolioProjects.dbo.NashvilleHousing$
SET OwnerSplitState= PARSENAME(REPLACE(OwnerAddress,',' , '.'),1)

-- Changing Y and N into Yes and No in 'Sold As Vacant' Column

SELECT Distinct(SoldAsVacant), COUNT(SoldAsVacant) 
FROM PortfolioProjects.dbo.NashvilleHousing$
GROUP BY SoldAsVacant
ORDER BY 2

SELECT SoldAsVacant
,Case
	WHEN SoldASVacant = 'Y' THEN 'Yes'
	WHEN SoldASVacant = 'N' THEN 'No'
	ELSE SoldASVacant
End
FROM PortfolioProjects.dbo.NashvilleHousing$

UPDATE PortfolioProjects.dbo.NashvilleHousing$
SET SoldAsVacant = Case
	WHEN SoldASVacant = 'Y' THEN 'Yes'
	WHEN SoldASVacant = 'N' THEN 'No'
	ELSE SoldASVacant
End


-- Remove Duplicates

WITH RowNumCTE AS (
SELECT *,
	ROW_NUMBER() OVER (
	Partition By ParcelID,
				PropertyAddress,
				SalePrice,
				SaleDate,
				LegalReference
				ORDER BY
				UniqueID
				) row_num
FROM PortfolioProjects.dbo.NashvilleHousing$
)
DELETE
FROM RowNumCTE
WHERE row_num > 1

WITH RowNumCTE AS (
SELECT *,
	ROW_NUMBER() OVER (
	Partition By ParcelID,
				PropertyAddress,
				SalePrice,
				SaleDate,
				LegalReference
				ORDER BY
				UniqueID
				) row_num
FROM PortfolioProjects.dbo.NashvilleHousing$
)
SELECT *
FROM RowNumCTE
WHERE row_num > 1


-- Deleting Unuseful Columns

ALTER TABLE PortfolioProjects.dbo.NashvilleHousing$
DROP COLUMN PropertyAddress, OwnerAddress, TaxDistrict

ALTER TABLE PortfolioProjects.dbo.NashvilleHousing$
DROP COLUMN SaleDate

