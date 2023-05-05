--Selecting everything

Select *
From portfolio_project..NashvilleHousing
order by 1,2



--Standardise Date Format: converting existing date format

Select SaleDate, new_date
From portfolio_project..NashvilleHousing

Select SaleDate, CONVERT(date, SaleDate) as new_date
From portfolio_project..NashvilleHousing

--updating in table:

alter table portfolio_project..NashvilleHousing
add new_date date;

update portfolio_project..NashvilleHousing
SET new_date = CONVERT(date, SaleDate)

/* here we 1st checked the SaleDate column then we use alter table (used to add, delete, or modify columns in an existing table.)
   to add new column. Then we update our table by using set and convert to convert the date format. This will allow us to
   add a new column in our table "portfolio_project..NashvilleHousing" */



--Populate Property Address::
--initially it is null
Select *
From portfolio_project..NashvilleHousing
Where PropertyAddress is Null

Select *
From portfolio_project..NashvilleHousing
---Where PropertyAddress is Null
order by ParcelID

--we have to self join tables to check parcelid = propertyaddress unique for each person
--if expression is null, what do we want to populate which is b.propertyaddress

Select a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, ISNULL(a.PropertyAddress, b.PropertyAddress)
From portfolio_project..NashvilleHousing a
join portfolio_project..NashvilleHousing b
	on a.ParcelID = b.ParcelID
	AND a.[UniqueID ] <> b.[UniqueID ] -- <> is not equal to
Where a.PropertyAddress is null


--This is what we want to update in our table

update a
SET PropertyAddress = ISNULL(a.PropertyAddress, b.PropertyAddress)
From portfolio_project..NashvilleHousing a
join portfolio_project..NashvilleHousing b
	on a.ParcelID = b.ParcelID
	AND a.[UniqueID ] <> b.[UniqueID ] -- <> is not equal to
Where a.PropertyAddress is null

/*so what happened is that we updated our table with the propertyaddress which were null that's why when we run that sql code with
"Where a.PropertyAddress is null" it gives us black table as all null values are updated */



--Breaking Address into Individual Column (Address, City, State)
--here only address and state is given

Select PropertyAddress
From portfolio_project..NashvilleHousing
--Where PropertyAddress is Null
--order by ParcelID

--This is used to seperate column value from comma then select 1st value . -1 is to remove comma

Select
SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1) as Address
, SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) +1, LEN(PropertyAddress)) as City
From portfolio_project..NashvilleHousing

--now we create 2 new columns and add these values

alter table portfolio_project..NashvilleHousing
add Property_Address varchar(255);

update portfolio_project..NashvilleHousing
SET Property_Address = SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1)


alter table portfolio_project..NashvilleHousing
add Property_City varchar(255);

update portfolio_project..NashvilleHousing
SET Property_City = SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) +1, LEN(PropertyAddress))


Select PropertyAddress, Property_Address, Property_City
From portfolio_project..NashvilleHousing

--Now Owner Address: using parsename, easier than above substring method
/*since we are dividing column in 3 parts, for some reason it divides in backwards so we write in 3,2,1 style**/

select OwnerAddress
from portfolio_project..NashvilleHousing

select 
PARSENAME(REPLACE(OwnerAddress, ',', '.') , 3),
PARSENAME(REPLACE(OwnerAddress, ',', '.') , 2),
PARSENAME(REPLACE(OwnerAddress, ',', '.') , 1)
From portfolio_project..NashvilleHousing

--now add columns in our table:

alter table portfolio_project..NashvilleHousing
add OwnerSplitAddress varchar(255);

update portfolio_project..NashvilleHousing
SET OwnerSplitAddress = PARSENAME(REPLACE(OwnerAddress, ',', '.') , 3)

alter table portfolio_project..NashvilleHousing
add OwnerSplitCity varchar(255);

update portfolio_project..NashvilleHousing
SET OwnerSplitCity = PARSENAME(REPLACE(OwnerAddress, ',', '.') , 2)

alter table portfolio_project..NashvilleHousing
add OwnerSplitState varchar(255);

update portfolio_project..NashvilleHousing
SET OwnerSplitState = PARSENAME(REPLACE(OwnerAddress, ',', '.') , 1)

Select OwnerAddress, OwnerSplitAddress, OwnerSplitCity, OwnerSplitState
From portfolio_project ..NashvilleHousing



--Change 'Y' and 'N' to 'Yes' and 'No'in Sold as Vacant:

Select Distinct(SoldAsVacant)
From portfolio_project..NashvilleHousing

--using case statement:

Select SoldAsVacant, 
	CASE 
		 When SoldAsVacant = 'Y' Then 'Yes'
		 When SoldAsVacant = 'N' Then 'No'
	Else SoldAsVacant
	END
From portfolio_project..NashvilleHousing

Update portfolio_project..NashvilleHousing
Set SoldAsVacant = CASE When SoldAsVacant = 'Y' Then 'Yes'
		 When SoldAsVacant = 'N' Then 'No'
		 Else SoldAsVacant
		 END

Select Distinct(SoldAsVacant), COUNT(SoldAsVacant)
From portfolio_project..NashvilleHousing
group by SoldAsVacant
order by 2



--Remove Duplicates:
--1st we have to identify duplicates rows using rank, row number etc.

Select *
From portfolio_project..NashvilleHousing

--duplicates in our table: 

With RowNumCTE as(
select *,
	ROW_NUMBER() OVER ( 
	Partition by ParcelID,
				 PropertyAddress, 
				 SalePrice, 
				 SaleDate,
				 LegalReference
				 Order By
					UniqueID) row_num

From portfolio_project..NashvilleHousing
)
Select *
--Delete
From RowNumCTE
Where row_num > 1 
Order by PropertyAddress

--now to delete, just write delete instead of select



--delete unused columns:

select *
from portfolio_project..NashvilleHousing

alter table portfolio_project..NashvilleHousing
drop column OwnerAddress, PropertyAddress, TaxDistrict, SaleDate

alter table portfolio_project..NashvilleHousing
drop column SaleDate

--finally our table is "Clean" for Analysis.