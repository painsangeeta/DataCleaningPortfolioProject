/* Cleaning Data in SQL Queries */

select * from NashvilleHousing;

-- Standardize Date Format

select convert(datetime, saledate) from NashvilleHousing;

update NashvilleHousing
set saledate = convert(datetime, saledate);

alter table NashvilleHousing
add saledateconverted datetime;

update NashvilleHousing
set saledateconverted = convert(datetime, saledate);

select saledateconverted, convert(datetime, saledate) from NashvilleHousing;

select saledateconverted, saledate from NashvilleHousing;



-- Populate Property Address Data

select propertyaddress from NashvilleHousing where propertyaddress is null;

select * from NashvilleHousing where propertyaddress is null;

select * from NashvilleHousing order by parcelid;


select a.parcelid, a.propertyaddress, b.parcelid, b.propertyaddress, isnull(a.propertyaddress, b.propertyaddress) from NashvilleHousing a join NashvilleHousing b 
on a.parcelid = b.parcelid and a.[uniqueid] <> b.[uniqueid] where a.propertyaddress is null;

update a
set propertyaddress = isnull(a.propertyaddress, b.propertyaddress)
from NashvilleHousing a join NashvilleHousing b 
on a.parcelid = b.parcelid and a.[uniqueid] <> b.[uniqueid]
where a.propertyaddress is null;

update a
set propertyaddress = isnull(a.propertyaddress, 'No Address')
from NashvilleHousing a join NashvilleHousing b 
on a.parcelid = b.parcelid and a.[uniqueid] <> b.[uniqueid]
where a.propertyaddress is null;



-- Breaking out Address into Individual Columns (Address, City, State)

select propertyaddress from NashvilleHousing;

select propertyaddress, charindex(',', propertyaddress), substring(propertyaddress, 1, charindex(',', propertyaddress)) as address
from NashvilleHousing;

-- 1st try (very very important part of cleaning) Accessing first two things (pin, next word) from the string
select PropertyAddress, new_address, 
substring(new_address, 1, charindex(' ', new_address)),
right(new_address, len(new_address) - charindex(' ', new_address)),
substring(right(new_address, len(new_address) - charindex(' ', new_address)), 1, charindex(' ', right(new_address, len(new_address) - charindex(' ', new_address)))),
concat(substring(new_address, 1, charindex(' ', new_address)),' ',substring(right(new_address, len(new_address) - charindex(' ', new_address)), 1, charindex(' ', right(new_address, len(new_address) - charindex(' ', new_address)))))
from
(select propertyaddress, REPLACE(PropertyAddress, '  ', ' ') new_address
from NashvilleHousing) a;

 select right(new_address, len(new_address) - charindex(' ', new_address)) from 
(select propertyaddress, REPLACE(PropertyAddress, '  ', ' ') new_address
from NashvilleHousing) a;

-- Cleaning propertyaddress (dirty data) properly

select PropertyAddress, REPLACE(PropertyAddress, '  ', ' ') new_address from NashvilleHousing



select substring(propertyaddress, 1, charindex(',', propertyaddress) - 1) as address from NashvilleHousing;

select propertyaddress, substring(propertyaddress, 1, charindex(' ', propertyaddress)) as pinaddress from NashvilleHousing;

select substring(propertyaddress, 1, charindex(',', propertyaddress)-1) as address,
substring(propertyaddress, charindex(',', propertyaddress)+1, len(propertyaddress)) as address
from NashvilleHousing;

alter table NashvilleHousing
add propertysplitaddress nvarchar(255); 

update NashvilleHousing
set propertysplitaddress = substring(propertyaddress, 1, charindex(',', propertyaddress)-1)

alter table NashvilleHousing
add propertysplitcity nvarchar(255);

update NashvilleHousing
set propertysplitcity = substring(propertyaddress, charindex(',', propertyaddress)+1, len(propertyaddress))

select * from NashvilleHousing;

select owneraddress, concat(substring(owneraddress, 1, charindex(' ', owneraddress)), substring(owneraddress, charindex(' ', owneraddress)+1, charindex(' ', owneraddress)))
from NashvilleHousing;

-- Using Parsename

select owneraddress from NashvilleHousing;

select owneraddress, parsename(replace(owneraddress, ',', '.'), 1) from NashvilleHousing;

select owneraddress, parsename(replace(owneraddress, ',', '.'), 2) from NashvilleHousing;

select owneraddress, parsename(replace(owneraddress, ',', '.'), 3) from NashvilleHousing;

select owneraddress, parsename(replace(owneraddress, ',', '.'), 4) from NashvilleHousing;

select
parsename(replace(owneraddress, ',', '.'), 3) as address,
parsename(replace(owneraddress, ',', '.'), 2) as city,
parsename(replace(owneraddress, ',', '.'), 1) as state
from NashvilleHousing;


select owneraddress,  substring(owneraddress, 1, charindex(' ', owneraddress)) from NashvilleHousing;

alter table NashvilleHousing
add ownersplitaddress nvarchar(255);

update NashvilleHousing
set ownersplitaddress = parsename(replace(owneraddress, ',', '.'), 3)

alter table NashvilleHousing
add ownersplitcity nvarchar(255);

update NashvilleHousing
set ownersplitcity = parsename(replace(owneraddress, ',', '.'), 2)

alter table NashvilleHousing
add ownersplitstate nvarchar(255);

update NashvilleHousing
set ownersplitstate = parsename(replace(owneraddress, ',', '.'), 1)



select * from NashvilleHousing;



-- Change Y and N to Yes and No in "Sold as Vacant" field

select soldasvacant,
case
   when soldasvacant = '0' then 'No'
   else 'Yes'
end
from NashvilleHousing;

select distinct
( case
   when soldasvacant = '0' then 'No'
   else 'Yes'
end
)
from NashvilleHousing;

select distinct
( case
   when soldasvacant = '0' then 'No'
   else 'Yes'
end
), count(soldasvacant) as countofsoldasvacant
from NashvilleHousing group by soldasvacant order by 2;





-- Remove Duplicates

select *, row_number() over(
partition by parcelid,
             propertyaddress,
			 saleprice,
			 saledate,
			 legalreference
			 order by
			     uniqueid
				 ) row_num
from NashvilleHousing order by parcelid;

with rownumcte as(
select *, row_number() over(
partition by parcelid,
             propertyaddress,
			 saleprice,
			 saledate,
			 legalreference
			 order by
			     uniqueid
				 ) row_num
from NashvilleHousing
)
select * from rownumcte where row_num > 1 order by propertyaddress;



-- Delete Unused Columns

select * from NashvilleHousing;

alter table NashvilleHousing
drop column owneraddress, taxdistrict, propertyaddress

alter table NashvilleHousing
drop column saledate



 




