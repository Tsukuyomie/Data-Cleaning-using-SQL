select *
from COVID.dbo.nashvillehousing

--Standardizing Date format

select SaleDate, convert(Date,Saledate)
from COVID.dbo.nashvillehousing



Alter table nashvillehousing
add saledateconverted Date;
Update nashvillehousing
SET saledateconverted = convert(Date,saledate)

--Populating Property address data


select *
from COVID.dbo.nashvillehousing
--where propertyAddress is NULL
order by parcelid

--so i will populate the property address by keeping the parcelID as reference

Select a.parcelID, a.propertyaddress, b.parcelID, b.propertyaddress, isnull(a.propertyaddress,b.propertyaddress)
from COVID.dbo.nashvillehousing a 
join COVID.dbo.nashvillehousing b
  on a.parcelID = b.parcelid
  and a.[uniqueID] <> b.[uniqueID]
  where a.propertyaddress is null


update a
set propertyaddress = isnull(a.propertyaddress,b.propertyaddress)
from COVID.dbo.nashvillehousing a 
join COVID.dbo.nashvillehousing b
  on a.parcelID = b.parcelid
  and a.[uniqueID] <> b.[uniqueID]
  where a.propertyaddress is null



--Sorting address into city and state

select propertyaddress
from COVID.dbo.nashvillehousing

select
substring(propertyaddress,1,charindex(',', propertyaddress)-1) as Address,
substring(propertyaddress,charindex(',', propertyaddress)+1 , LEN(propertyaddress)) as Addrss

from COVID.dbo.nashvillehousing

Alter table nashvillehousing
add Propertyspiltaddress NVARCHAR(255),
propertysplitcity NVARCHAR(255)

UPDATE nashvillehousing
SET Propertyspiltaddress = substring(propertyaddress,1,charindex(',', propertyaddress)-1),
propertysplitcity =substring(propertyaddress,charindex(',', propertyaddress)+1 , LEN(propertyaddress))


Alter table nashvillehousing
Add SplitOwnerAddress NVARCHAR(255),
SplitOwnerCity NVARCHAR(255),
SplitOwnerState NVARCHAR(255)

UPDATE nashvillehousing
SET SplitOwnerAddress = PARSENAME(REPLACE(ownerAddress, ',' , '.'), 3),
SplitOwnerCity = PARSENAME(REPLACE(ownerAddress, ',' , '.'), 2),
SplitOwnerState = PARSENAME(REPLACE(ownerAddress, ',' , '.'), 1) 

Select *
from COVID.dbo.nashvillehousing


--Uniforming the data present on column SoldAsVacant

select distinct(soldasvacant), count(soldasvacant)
from COVID.dbo.nashvillehousing
group by soldasVacant
order by 2


update nashvillehousing
SET soldasvacant = case when soldasvacant = 'Y' then 'Yes'
when soldasvacant = 'N' then 'No'
else Soldasvacant
end
from COVID.dbo.nashvillehousing


--Removing the duplicates

select *,
ROW_NUMBER() over (
   partition by parcelID,
                propertyaddress,
				SaleDate,
				LegalReference,
				saleprice
				ORDER BY
				uniqueID
				) row_num
from COVID.dbo.nashvillehousing


WITH ROWNUMCTE AS (
select *,
   ROW_NUMBER() over (
   partition by parcelID,
                propertyaddress,
				SaleDate,
				LegalReference,
				saleprice
				ORDER BY
				uniqueID
				) row_num
from COVID.dbo.nashvillehousing
)

DELETE
from ROWNUMCTE
where row_num >1



--DELETING UNUSED COLUMNS

ALter table nashvillehousing
drop column propertyaddress, owneraddress, Taxdistrict

select *
from COVID.dbo.nashvillehousing
