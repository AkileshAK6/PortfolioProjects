/*

Cleaning data in SQL Queries

*/

SELECT * 
from PortfolioProject..NashvilleHousing

-- Standardize date format 

SELECT SaleDateConverted, CONVERT(Date,SaleDate) 
from PortfolioProject..NashvilleHousing     

UPDATE NashvilleHousing
SET SaleDate = CONVERT(Date,SaleDate)

ALTER TABLE NashvilleHousing
Add SaleDateConverted Date

UPDATE NashvilleHousing
SET SaleDateConverted = CONVERT(Date,SaleDate)


--Populate Property address data

SELECT * 
from PortfolioProject..NashvilleHousing
--where PropertyAddress is null
order by ParcelID

SELECT a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, isnull(a.PropertyAddress,b.PropertyAddress)
from PortfolioProject..NashvilleHousing a
JOIN PortfolioProject..NashvilleHousing b
ON a.ParcelID = b.ParcelID
AND a.[UniqueID ] <> b.[UniqueID ]
where a.PropertyAddress is null

UPDATE a
set PropertyAddress = isnull(a.PropertyAddress,b.PropertyAddress)
from PortfolioProject..NashvilleHousing a
JOIN PortfolioProject..NashvilleHousing b
ON a.ParcelID = b.ParcelID
AND a.[UniqueID ] <> b.[UniqueID ]
where a.PropertyAddress is null

--Breaking down Property Address, City and state into seperate columns

SELECT PropertyAddress 
from PortfolioProject..NashvilleHousing

SELECT 
SUBSTRING(PropertyAddress, 1, CHARINDEX(',',PropertyAddress)-1) as Address,
SUBSTRING(PropertyAddress, CHARINDEX(',',PropertyAddress)+1, LEN(PropertyAddress)) as City
from PortfolioProject..NashvilleHousing 

ALTER TABLE NashvilleHousing
Add PropertySplitAddress Nvarchar(255)

UPDATE NashvilleHousing
SET PropertySplitAddress = SUBSTRING(PropertyAddress, 1, CHARINDEX(',',PropertyAddress)-1)

ALTER TABLE NashvilleHousing
Add PropertySplitCity Nvarchar(255)

UPDATE NashvilleHousing
SET PropertySplitCity = SUBSTRING(PropertyAddress, CHARINDEX(',',PropertyAddress)+1, LEN(PropertyAddress))


SELECT *
from PortfolioProject..NashvilleHousing

SELECT OwnerAddress
from PortfolioProject..NashvilleHousing

SELECT 
PARSENAME(REPLACE (OwnerAddress,',','.'),3),
PARSENAME(REPLACE (OwnerAddress,',','.'),2),
PARSENAME(REPLACE (OwnerAddress,',','.'),1)
from PortfolioProject..NashvilleHousing

ALTER TABLE NashvilleHousing
Add OwnerSplitAddress Nvarchar(255)

UPDATE NashvilleHousing
SET OwnerSplitAddress = PARSENAME(REPLACE (OwnerAddress,',','.'),3)

ALTER TABLE NashvilleHousing
Add OwnerSplitCity Nvarchar(255)

UPDATE NashvilleHousing
SET OwnerSplitCity = PARSENAME(REPLACE (OwnerAddress,',','.'),2)

ALTER TABLE NashvilleHousing
Add OwnerSplitState Nvarchar(255)

UPDATE NashvilleHousing
SET OwnerSplitState = PARSENAME(REPLACE (OwnerAddress,',','.'),1)       


--Change 'Y' and 'N' into 'Yes' and 'No'

SELECT Distinct(SoldAsVacant), Count(SoldAsVacant)
from PortfolioProject..NashvilleHousing
Group by SoldAsVacant
order by 2

SELECT SoldAsVacant,
CASE WHEN SoldAsVacant= 'Y' THEN 'Yes'
	 when SoldAsVacant= 'N' THEN 'No'
	 ELSE SoldAsVacant
	 END
from PortfolioProject..NashvilleHousing

UPDATE PortfolioProject..NashvilleHousing
SET SoldAsVacant = CASE WHEN SoldAsVacant= 'Y' THEN 'Yes'
	 when SoldAsVacant= 'N' THEN 'No'
	 ELSE SoldAsVacant
	 END

--Remove duplicates
WITH RowNumCTE AS
(
SELECT *,
 ROW_NUMBER() OVER (
 PARTITION BY ParcelID,
 PropertyAddress,
 SaleDate,
 SalePrice,
 LegalReference
 order by 
 UniqueID
 ) as row_num
 From NashvilleHousing
 --order by ParcelID
 )
 SELECT *
 FROM RowNumCTE
 where row_num > 1

  SELECT *
  FROM PortfolioProject..NashvilleHousing

  --Delete unused columns

SELECT *
FROM PortfolioProject..NashvilleHousing

ALTER TABLE PortfolioProject..NashvilleHousing
drop column PropertyAddress, Saledate, OwnerAddress, TaxDistrict