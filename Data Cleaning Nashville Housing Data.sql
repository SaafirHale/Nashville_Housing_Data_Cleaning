/* 
Data cleaning NashvilleHousing data (2013-2019). Dataset is missing data from 2017 and 2018. 
Dataset is from Alex Freburg.
*/

Select *
From PortfolioProject..NashvilleHousing


-- Converting the Sales Date format from (yyyy-MM-dd HH:mm:ss.SSS) to (yyy-MM-dd)

Alter Table NashvilleHousing
Add SaleDateConversion Date;

Update NashvilleHousing
Set SaleDateConversion = Convert(Date, SaleDate)

Select SaleDate, SaleDateConversion
From PortfolioProject..NashvilleHousing


-- Populating missing PropertyAddress data using ParcelID

Select PropertyAddress
From PortfolioProject..NashvilleHousing
Where PropertyAddress is null

Select Original.ParcelID, Original.PropertyAddress, Duplicate.ParcelID, Duplicate.PropertyAddress, Isnull(Original.PropertyAddress, Duplicate.PropertyAddress)
From PortfolioProject..NashvilleHousing as Original
Join PortfolioProject..NashvilleHousing as Duplicate
	On Original.ParcelID = Duplicate.ParcelID
	And Original.[UniqueID ] <> Duplicate.[UniqueID ]
Where Original.PropertyAddress is null

Update Original
Set PropertyAddress = Isnull(Original.PropertyAddress, Duplicate.PropertyAddress)
From PortfolioProject..NashvilleHousing as Original
Join PortfolioProject..NashvilleHousing as Duplicate
	On Original.ParcelID = Duplicate.ParcelID
	And Original.[UniqueID ] <> Duplicate.[UniqueID ]
Where Original.PropertyAddress is null


-- Seperating the PropertyAddress into individual columns (Address, City). Then Seperating OwnerAddress into individual columns (Address, City, State)
-- PropertyAddress
Select PropertyAddress
From PortfolioProject..NashvilleHousing

Select Substring(PropertyAddress, 1, Charindex(',', PropertyAddress) -1) as Address,
	Substring(PropertyAddress, Charindex(',', PropertyAddress) + 1, Len(PropertyAddress)) as City
From PortfolioProject..NashvilleHousing

Alter Table NashvilleHousing
Add PropertyAddressSep Nvarchar(255);

Update NashvilleHousing
Set PropertyAddressSep = Substring(PropertyAddress, 1, Charindex(',', PropertyAddress) -1) -- Address

Alter Table NashvilleHousing
Add PropertyCitySep Nvarchar(255);

Update NashvilleHousing
Set PropertyCitySep = Substring(PropertyAddress, Charindex(',', PropertyAddress) + 1, Len(PropertyAddress)) -- City

-- OwnerAddress
Select OwnerAddress
From PortfolioProject..NashvilleHousing

Select Parsename(Replace(OwnerAddress, ',', '.'), 3) as Address,
	Parsename(Replace(OwnerAddress, ',', '.'), 2) as City,
	Parsename(Replace(OwnerAddress, ',', '.'), 1) as State
From PortfolioProject..NashvilleHousing

Alter Table NashvilleHousing 
Add OwnerAddressSep Nvarchar(255);

Update NashvilleHousing
Set OwnerAddressSep = Parsename(Replace(OwnerAddress, ',', '.'), 3) -- Address

Alter Table NashvilleHousing
Add OwnerCitySep Nvarchar(255);

Update NashvilleHousing
Set OwnerCitySep = Parsename(Replace(OwnerAddress, ',', '.'), 2) -- City

Alter Table NashvilleHousing
Add OwnerStateSep Nvarchar(255);

Update NashvilleHousing
Set OwnerStateSep = Parsename(Replace(OwnerAddress, ',', '.'), 1) -- State


-- Making Yes and No consistent in SoldAsVacant. I.e. Changing "Y" and "N" to "Yes" and "No"

Select Distinct(SoldAsVacant), Count(SoldAsVacant)
From PortfolioProject..NashvilleHousing
Group By SoldAsVacant
Order By 2

Select SoldAsVacant, 
	Case When SoldAsVacant = 'Y' Then 'Yes'
		 When SoldAsVacant = 'N' Then 'No'
		 Else SoldAsVacant
		 End
From PortfolioProject..NashvilleHousing

Update NashvilleHousing
Set SoldAsVacant = Case When SoldAsVacant = 'Y' Then 'Yes'
		 When SoldAsVacant = 'N' Then 'No'
		 Else SoldAsVacant
		 End


-- Removing duplicate values from the NashvilleHousing data

With RowNumCTE As (
Select *,
	Row_number() Over (
	Partition By ParcelID,
		PropertyAddress,
		SalePrice,
		SaleDate,
		LegalReference
		Order By UniqueID) row_num
From PortfolioProject..NashvilleHousing
)
Delete
From RowNumCTE
Where row_num > 1


-- Dropping repetitive/unused columns

Alter Table PortfolioProject..NashvilleHousing
Drop Column OwnerAddress, TaxDistrict, PropertyAddress, SaleDate

Select *
From PortfolioProject..NashvilleHousing