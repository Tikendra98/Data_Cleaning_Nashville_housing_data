/*Data Cleaning-Nashville Housing data*/ 

SELECT *
FROM [Portfolio Project].dbo.NashvilleHousing

--Standarise Date Format

SELECT SaleDate, Convert(Date,SaleDate)
FROM [Portfolio Project].dbo.NashvilleHousing

UPDATE NashvilleHousing
SET SaleDate=Convert(Date,SaleDate)

ALTER TABLE  NashvilleHousing
ADD SaleDateConverted Date;

UPDATE NashvilleHousing
SET SaleDateConverted=Convert(Date,SaleDate)

SELECT SaleDateConverted
FROM [Portfolio Project].dbo.NashvilleHousing

-------------------------------------------------------------------------------------------------------------

--Populate Property Address Data

SELECT *
FROM [Portfolio Project].dbo.NashvilleHousing
ORDER BY ParcelID

SELECT a.ParcelID, a.PropertyAddress,b.ParcelID,b.PropertyAddress,ISNULL(a.PropertyAddress,b.PropertyAddress)
From [Portfolio Project].dbo.NashvilleHousing a
JOIN [Portfolio Project].dbo.NashvilleHousing b
     ON a.ParcelID=b.ParcelID
	 AND a.UniqueID <> b.UniqueID
WHERE a.PropertyAddress IS NULL

UPDATE a
SET PropertyAddress=ISNULL(a.PropertyAddress,b.PropertyAddress)
From [Portfolio Project].dbo.NashvilleHousing a
JOIN [Portfolio Project].dbo.NashvilleHousing b
     ON a.ParcelID=b.ParcelID
	 AND a.UniqueID <> b.UniqueID
WHERE a.PropertyAddress IS NULL

-------------------------------------------------------------------------------------------------------------

--Breaking Address into Indivisual Columns(Address,city,State)

SELECT PropertyAddress
FROM [Portfolio Project].dbo.NashvilleHousing

SELECT
SUBSTRING(PropertyAddress,1,CHARINDEX(',',PropertyAddress)-1) AS Address,
SUBSTRING(PropertyAddress,CHARINDEX(',',PropertyAddress)+1,len(PropertyAddress)) AS City
FROM [Portfolio Project].dbo.NashvilleHousing

ALTER TABLE  NashvilleHousing
ADD PropertySplitAddress nvarchar(255);

UPDATE NashvilleHousing
SET PropertySplitAddress=SUBSTRING(PropertyAddress,1,CHARINDEX(',',PropertyAddress)-1)

ALTER TABLE  NashvilleHousing
ADD PropertySplitCity nvarchar(255);


UPDATE NashvilleHousing
SET PropertySplitCity=SUBSTRING(PropertyAddress,CHARINDEX(',',PropertyAddress)+1,len(PropertyAddress)) 

SELECT *
FROM [Portfolio Project].dbo.NashvilleHousing

SELECT
PARSENAME(REPLACE(OwnerAddress,',','.'),3),
PARSENAME(REPLACE(OwnerAddress,',','.'),2),
PARSENAME(REPLACE(OwnerAddress,',','.'),1)
FROM [Portfolio Project].dbo.NashvilleHousing

ALTER TABLE  NashvilleHousing
ADD OwnerSplitAddress nvarchar(255);

UPDATE NashvilleHousing
SET OwnerSplitAddress=PARSENAME(REPLACE(OwnerAddress,',','.'),3)

ALTER TABLE  NashvilleHousing
ADD OwnerSplitCity nvarchar(255);


UPDATE NashvilleHousing
SET OwnerSplitCity=PARSENAME(REPLACE(OwnerAddress,',','.'),2)

ALTER TABLE  NashvilleHousing
ADD OwnerSplitState nvarchar(255);

UPDATE NashvilleHousing
SET OwnerSplitState=PARSENAME(REPLACE(OwnerAddress,',','.'),1)

SELECT *
FROM [Portfolio Project].dbo.NashvilleHousing

-------------------------------------------------------------------------------------------------------------

-- Change Y and N to Yes and No in SoldAsVacant

SELECT DISTINCT(SoldAsVacant), COUNT(SoldAsVacant)
FROM [Portfolio Project].dbo.NashvilleHousing
GROUP BY SoldAsVacant
ORDER BY 2

SELECT SoldAsVacant,
  CASE WHEN SoldAsVacant='Y' THEN 'YES'
       WHEN SoldAsVacant='N' THEN 'NO'
	   ELSE SoldAsVacant
	   END
FROM [Portfolio Project].dbo.NashvilleHousing

UPDATE NashvilleHousing
SET SoldAsVacant=CASE WHEN SoldAsVacant='Y' THEN 'YES'
       WHEN SoldAsVacant='N' THEN 'NO'
	   ELSE SoldAsVacant
	   END

-------------------------------------------------------------------------------------------------------------

--Remove the duplicates
WITH RowNumCte AS
(SELECT*,
      ROW_NUMBER() OVER(
	  PARTITION BY ParcelID,
	               PropertyAddress,
				   SaleDate,
				   SalePrice,
				   LegalReference
				   ORDER BY UniqueID) As row_num
From [Portfolio Project].dbo.NashvilleHousing
)
SELECT *
FROM RowNumCte
WHERE row_num>1
ORDER BY PropertyAddress
