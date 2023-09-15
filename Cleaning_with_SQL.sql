/*
cleaning data  in sql queries
*/

select *
from dbo.Nashville_Housing


/*
standardize date format
*/

select SaleDateConverted, convert(date,SaleDate) 
from dbo.Nashville_Housing


Alter Table dbo.Nashville_Housing
add SaleDateConverted Date;

update dbo.Nashville_Housing
set SaleDateConverted = convert(date,SaleDate)




/*
populate property addres data
*/
---note that same parcelID for a property Address connotes that they are linked , we can use this logic to locate property addresses that are null
--- to do this we will do a self join of the table on  unique id and parcel id

select *
from dbo.Nashville_Housing
--where PropertyAddress is NULL
order by 2


select a.ParcelID, a.PropertyAddress,b.ParcelID,b.PropertyAddress, ISNULL(a.PropertyAddress,b.PropertyAddress)--- this replaces the first argument with the second if NULL
from dbo.Nashville_Housing a
join dbo.Nashville_Housing b
	ON a.ParcelID = b.ParcelID
	AND a.UniqueID <> b.UniqueID
where a.PropertyAddress is NULL

Update a
SET PropertyAddress = ISNULL(a.PropertyAddress,b.PropertyAddress)
from dbo.Nashville_Housing a
join dbo.Nashville_Housing b
	ON a.ParcelID = b.ParcelID
	AND a.UniqueID <> b.UniqueID
where a.PropertyAddress is NULL



/*
Breaking our address columns into other columns ( Address, City, State)
*/

select *
from dbo.Nashville_Housing
--where PropertyAddress is NULL
--order by 2

Select
Substring(PropertyAddress, 1,CHARINDEX(',',PropertyAddress)-1) as 'Address',
Substring(PropertyAddress,CHARINDEX(',',PropertyAddress)+1,LEN(PropertyAddress)) as 'City'
from dbo.Nashville_Housing
--where PropertyAddress is NULL
--order by 2

Alter Table dbo.Nashville_Housing
add PropertySplitAddress nvarchar(255);

update dbo.Nashville_Housing
set PropertySplitAddress = Substring(PropertyAddress, 1,CHARINDEX(',',PropertyAddress)-1) 

Alter Table dbo.Nashville_Housing
add PropertySplitCity nvarchar(255);

update dbo.Nashville_Housing
set PropertySplitCity = Substring(PropertyAddress,CHARINDEX(',',PropertyAddress)+1,LEN(PropertyAddress))

--select PropertyAddress
--from dbo.Nashville_Housing

--Select
--PARSENAME(REPLACE(PropertyAddress, ',', '.') , 2)
--,PARSENAME(REPLACE(PropertyAddress, ',', '.') , 1)
--from dbo.Nashville_Housing


select OwnerAddress
from dbo.Nashville_Housing

Select
PARSENAME(REPLACE(OwnerAddress, ',', '.') , 3)
,PARSENAME(REPLACE(OwnerAddress, ',', '.') , 2)
,PARSENAME(REPLACE(OwnerAddress, ',', '.') , 1)
from dbo.Nashville_Housing


Alter Table dbo.Nashville_Housing
add OwnerSplitAddress nvarchar(255);

update dbo.Nashville_Housing
set OwnerSplitAddress = PARSENAME(REPLACE(OwnerAddress, ',', '.') , 3)

Alter Table dbo.Nashville_Housing
add OwnerSplitCity nvarchar(255);

update dbo.Nashville_Housing
set OwnerSplitCity = PARSENAME(REPLACE(OwnerAddress, ',', '.') , 2)


Alter Table dbo.Nashville_Housing
add OwnerSplitState nvarchar(255);

update dbo.Nashville_Housing
set OwnerSplitState = PARSENAME(REPLACE(OwnerAddress, ',', '.') , 1)



/*
 replace YES and NO with Y and N  in "Sold as Vacant" Column using the CASE function
*/

select Distinct(SoldAsVacant), COUNT(SoldAsVacant)
from dbo.Nashville_Housing
group by SoldAsVacant
order by 2


Select SoldAsVacant
,CASE when SoldAsVacant = 'Y' then 'Yes'
	  when SoldAsVacant = 'N' then 'No'
	  Else SoldAsVacant
	  END
from dbo.Nashville_Housing

update Nashville_Housing
SET SoldAsVacant = CASE when SoldAsVacant = 'Y' then 'Yes'
	  when SoldAsVacant = 'N' then 'No'
	  Else SoldAsVacant
	  END


 /*
 remove duplicates
*/
with RowNumCTE as (
select *,
	ROW_NUMBER() OVER (
	PARTITION BY ParcelID,
			     PropertyAddress,
				 SalePrice,
				 SaleDate,
				 LegalReference
				 ORDER BY
				 UniqueID
				 ) row_num
from dbo.Nashville_Housing
)
SELECT *
from RowNumCTE
where row_num>1
--order by ParcelID


/*
delete unused columns
*/
select *
from dbo.Nashville_Housing

AlTER TABLE dbo.Nashville_Housing
DROP COLUMN OwnerAddress,
			PropertyAddress,
			TaxDistrict,
			SaleDate


/*
delete unused columns
*/