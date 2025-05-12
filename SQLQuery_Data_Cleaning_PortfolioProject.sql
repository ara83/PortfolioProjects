--Data cleaning portfolio project

Select *
From PortfolioProject..NashvilleHousing


--Standardize date format

Select SaleDateConverted, CONVERT(Date,SaleDate)
From PortfolioProject..NashvilleHousing

Update PortfolioProject.dbo.NashvilleHousing
SET SaleDate = CONVERT(Date,SaleDate)

Alter table PortfolioProject.dbo.NashvilleHousing
Add SaleDateConverted Date;

Update PortfolioProject.dbo.NashvilleHousing
SET SaleDateConverted = CONVERT(Date,SaleDate)

----------------------------------------------------------------------
---Populate property address data

Select *
From PortfolioProject.dbo.NashvilleHousing
---Where PropertyAddress is null
order by ParcelID

Select a.ParcelID,a.PropertyAddress,b.ParcelID,b.PropertyAddress, ISNULL(a.PropertyAddress,b.PropertyAddress)
From PortfolioProject..NashvilleHousing a
JOIN PortfolioProject..NashvilleHousing b
	On a.ParcelID = b.ParcelID
	AND a.[UniqueID ] <> b.[UniqueID ]
where a.PropertyAddress is null

Update a
SET PropertyAddress = ISNULL(a.PropertyAddress,b.PropertyAddress)
From PortfolioProject..NashvilleHousing a
JOIN PortfolioProject..NashvilleHousing b
	On a.ParcelID = b.ParcelID
	AND a.[UniqueID ] <> b.[UniqueID ]
where a.PropertyAddress is null


-----------------------------------------------------
--Breaking out address into individual columns

Select PropertyAddress
From PortfolioProject.dbo.NashvilleHousing


Select
SUBSTRING(PropertyAddress, 1, CHARINDEX(',',PropertyAddress)-1) as Address
, SUBSTRING(PropertyAddress,CHARINDEX(',',PropertyAddress)+1, LEN(PropertyAddress)) as Address
From PortfolioProject.dbo.NashvilleHousing


Alter table PortfolioProject.dbo.NashvilleHousing
Add PropertySplitAddress nvarchar(255);

Update PortfolioProject.dbo.NashvilleHousing
SET PropertySplitAddress = SUBSTRING(PropertyAddress, 1, CHARINDEX(',',PropertyAddress)-1)


Alter table PortfolioProject.dbo.NashvilleHousing
Add PropertySplitcity nvarchar(255);

Update PortfolioProject.dbo.NashvilleHousing
SET PropertySplitcity = SUBSTRING(PropertyAddress,CHARINDEX(',',PropertyAddress)+1, LEN(PropertyAddress))


Select *
From PortfolioProject.dbo.NashvilleHousing

Select OwnerAddress
From PortfolioProject.dbo.NashvilleHousing


Select
PARSENAME(REPLACE(OwnerAddress, ',', '.'), 3),
PARSENAME(REPLACE(OwnerAddress, ',', '.'), 2),
PARSENAME(REPLACE(OwnerAddress, ',', '.'), 1)
From PortfolioProject.dbo.NashvilleHousing

Alter table PortfolioProject.dbo.NashvilleHousing
Add OwnerSplitAddress nvarchar(255);

Update PortfolioProject.dbo.NashvilleHousing
SET OwnerSplitAddress = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 3)


Alter table PortfolioProject.dbo.NashvilleHousing
Add OwnerSplitcity nvarchar(255);

Update PortfolioProject.dbo.NashvilleHousing
SET OwnerSplitcity = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 2)


Alter table PortfolioProject.dbo.NashvilleHousing
Add OwnerSplitState nvarchar(255);

Update PortfolioProject.dbo.NashvilleHousing
SET OwnerSplitState = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 1)



---------------------------------------------------------------------------------------

--Change Y and N to Yes and No in "Sold as vacant" field

Select Distinct(SoldAsVacant)
From PortfolioProject.dbo.NashvilleHousing


Select SoldAsVacant,
	CASE when SoldAsVacant = 'Y' then 'Yes'
		 when SoldAsVacant = 'N'then 'No'
		 else SoldAsVacant
		 end
From PortfolioProject.dbo.NashvilleHousing


Update PortfolioProject.dbo.NashvilleHousing
SET SoldAsVacant =  CASE when SoldAsVacant = 'Y' then 'Yes'
		 when SoldAsVacant = 'N'then 'No'
		 else SoldAsVacant
		 end

-------------------------------------------------------------------------------

--Remove Duplicates


WITH RowNumCte AS(
Select *,
ROW_NUMBER() OVER(
PARTITION BY ParcelID,
			 PropertyAddress,
			 SalePrice,
			 SaleDate,
			 LegalReference
			 ORDER BY
			 UniqueID
			 ) row_num

From PortfolioProject.dbo.NashvilleHousing
)
Select * 
From RowNumCte
Where row_num >1
--Order By PropertyAddress




--------------------------------------------------------------------------------

--Delete unused columns
Select *
From PortfolioProject.dbo.NashvilleHousing


ALTER TABLE PortfolioProject.dbo.NashvilleHousing
DROP COLUMN OwnerAddress, TaxDistrict, PropertyAddress, SaleDate
