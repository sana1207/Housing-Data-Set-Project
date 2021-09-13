/*
Cleaning Data in SQL Queries
*/

Select *
From Housing..Data

--------------------------------------------------------------------------------------------------------------------------

---- 1) Standardize Date Format


Select SaleDate, CONVERT(Date,SaleDate) as Std_Date
From Housing..Data


Update Housing..Data
SET SaleDate = CONVERT(Date,SaleDate)


ALTER TABLE Housing..Data
Add Std_Date Date;

Update Housing..Data
SET Std_Date = CONVERT(Date,SaleDate)


 --------------------------------------------------------------------------------------------------------------------------

---- 2) Populate Property Address data

Select *
From Housing..Data
--Where PropertyAddress is null
order by ParcelID



Select a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, ISNULL(a.PropertyAddress,b.PropertyAddress)
From Housing..Data a
JOIN Housing..Data b
	on a.ParcelID = b.ParcelID
	AND a.[UniqueID ] <> b.[UniqueID ]
Where a.PropertyAddress is null



Update a
SET PropertyAddress = ISNULL(a.PropertyAddress,b.PropertyAddress)
From Housing..Data a
JOIN Housing..Data b
	on a.ParcelID = b.ParcelID
	AND a.[UniqueID ] <> b.[UniqueID ]
Where a.PropertyAddress is null


--------------------------------------------------------------------------------------------------------------------------

---- 3) Breaking out Address into Individual Columns (Address, City, State)


Select PropertyAddress
From Housing..Data
--Where PropertyAddress is null
--order by ParcelID

SELECT SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1 ) as Address
, SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) + 1 , LEN(PropertyAddress)) as Address
From Housing..Data

Select *
From Housing..Data


ALTER TABLE Housing..Data
Add PropertySplitAddress Nvarchar(255);


Update Housing..Data
SET PropertySplitAddress = SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1 )


ALTER TABLE Housing..Data
Add PropertySplitCity Nvarchar(255);

Update Housing..Data
SET PropertySplitCity = SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) + 1 , LEN(PropertyAddress))




Select OwnerAddress
From Housing..Data


Select
PARSENAME(REPLACE(OwnerAddress, ',', '.') , 3)
,PARSENAME(REPLACE(OwnerAddress, ',', '.') , 2)
,PARSENAME(REPLACE(OwnerAddress, ',', '.') , 1)
From Housing..Data


ALTER TABLE Housing..Data
Add OwnerSplitAddress Nvarchar(255);

Update Housing..Data
SET OwnerSplitAddress = PARSENAME(REPLACE(OwnerAddress, ',', '.') , 3)


ALTER TABLE Housing..Data
Add OwnerSplitCity Nvarchar(255);


Update Housing..Data
SET OwnerSplitCity = PARSENAME(REPLACE(OwnerAddress, ',', '.') , 2)



ALTER TABLE Housing..Data
Add OwnerSplitState Nvarchar(255);


Update Housing..Data
SET OwnerSplitState = PARSENAME(REPLACE(OwnerAddress, ',', '.') , 1)



Select *
From Housing..Data




--------------------------------------------------------------------------------------------------------------------------


---- 4) Change Y and N to Yes and No in "Sold as Vacant" field


Select Distinct(SoldAsVacant), Count(SoldAsVacant) as count
From Housing..Data
Group by SoldAsVacant
order by 2


Select SoldAsVacant
, CASE When SoldAsVacant = 'Y' THEN 'Yes'
	   When SoldAsVacant = 'N' THEN 'No'
	   ELSE SoldAsVacant
	   END
From Housing..Data


Update Housing..Data
SET SoldAsVacant = CASE When SoldAsVacant = 'Y' THEN 'Yes'
	   When SoldAsVacant = 'N' THEN 'No'
	   ELSE SoldAsVacant
	   END



Select *
From Housing..Data



-----------------------------------------------------------------------------------------------------------------------------------------------------------

----5) Remove Duplicates

WITH RowNumCTE AS(
Select *,
	ROW_NUMBER() OVER (
	PARTITION BY ParcelID,
				 PropertyAddress,
				 SalePrice,
				 SaleDate,
				 LegalReference
				 ORDER BY
					UniqueID
					) row_num

From Housing..Data
--order by ParcelID
)
Select *
From RowNumCTE
Where row_num > 1
Order by PropertyAddress



Select *
From Housing..Data




---------------------------------------------------------------------------------------------------------

---- 6) Delete Unused Columns



Select *
From Housing..Data


ALTER TABLE Housing..Data
DROP COLUMN OwnerAddress, TaxDistrict, PropertyAddress, SaleDate


-----------------------------------------------------------------------------------------------

















