create database housing character set utf8mb4 collate utf8mb4_unicode_ci;

use housing;
drop table nashville_housing;

create table nashville_housing (
	UniqueID int, 	
    ParcelID varchar(20),	
    LandUse varchar(80),
    PropertyAddress varchar (150),	
    SaleDate date,	
    SalePrice int,	
    LegalReference varchar(20),	
    SoldAsVacant varchar(3),
    OwnerName varchar(150),
    OwnerAddress varchar(150),	
    Acreage double,	
    TaxDistrict varchar(150),	
    LandValue int,	
    BuildingValue int,	
    TotalValue int,	
    YearBuilt int,	
    Bedrooms int,	
    FullBath int,	
    HalfBath int
);

load data infile 'C:\\wamp64\\tmp\\Nashville Housing Data for Data Cleaning.csv'
into table nashville_housing
fields terminated by ','
ignore 1 rows;


select * from nashville_housing;

delete from nashville_housing where SoldAsVacant !=  'Yes' and  SoldAsVacant != 'No';
delete from nashville_housing where UniqueID is null or UniqueID = '';
delete from nashville_housing where UniqueID is null or UniqueID = '';
delete from nashville_housing where PropertyAddress = '' or PropertyAddress is null;
delete from nashville_housing where OwnerName is null or OwnerName = '';


/* Standardize Sale Date */
select SaleDate, convert(saledate,date) from nashville_housing;
update nashville_housing
set SaleDate = convert(saledate,date);

/* Property Address */
select PropertyAddress from nashville_housing where PropertyAddress = '';
select * from nashville_housing where PropertyAddress = '';
select * from nashville_housing order by ParcelID;
/*ParcelID  repeated in sequence tends to have first one with PropertyAddress and following ones without*/

/*Fill the missing data -self joiin*/
select a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress
from nashville_housing a join nashville_housing b on a.ParcelID = b.ParcelID and a.UniqueID != b.UniqueID
where a.PropertyAddress = ''; 

update nashville_housing set PropertyAddress = null where PropertyAddress = '';

select a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, isnull(b.PropertyAddress)
from nashville_housing a join nashville_housing b on a.ParcelID = b.ParcelID and a.UniqueID != b.UniqueID
where a.PropertyAddress is not null;

update nashville_housing a inner join nashville_housing b on a.ParcelID = b.ParcelID and a.UniqueID != b.UniqueID
set a.PropertyAddress = isnull(b.PropertyAddress)
where a.PropertyAddress is null; 

/*Breaking out the address into  Address, City, State*/

select PropertyAddress from nashville_housing;

select substring(PropertyAddress,1,locate(';',PropertyAddress)-1) as Address,
substring(PropertyAddress,locate(';',PropertyAddress) + 1, length(PropertyAddress)) as city
from nashville_housing;


alter table Nashville_housing
add Address varchar(100); 

alter table Nashville_housing
add City varchar(100); 

update nashville_housing
set Address = substring(PropertyAddress,1,locate(';',PropertyAddress)-1);
 
update nashville_housing
set City = substring(PropertyAddress,locate(';',PropertyAddress) + 1, length(PropertyAddress));

select * from nashville_housing;

/*Split Owner Address*/
select owneraddress from nashville_housing;

select substring(OwnerAddress,1,locate(';',OwnerAddress)-1) as Address,
substring(OwnerAddress,locate(';',OwnerAddress) + 1, length(OwnerAddress)) as citystate,
substring(substring(OwnerAddress,locate(';',OwnerAddress) + 1, length(OwnerAddress)),1,locate(';',substring(OwnerAddress,locate(';',OwnerAddress) + 1, length(OwnerAddress)))-1) as city,
substring(substring(OwnerAddress,locate(';',OwnerAddress) + 1, length(OwnerAddress)),locate(';',substring(OwnerAddress,locate(';',OwnerAddress) + 1, length(OwnerAddress))) + 1, length(substring(OwnerAddress,locate(';',OwnerAddress) + 1, length(OwnerAddress)))) as state
from nashville_housing;

alter table Nashville_housing
add OwnerStreetAddress varchar(100); 

alter table Nashville_housing
add OwnerCity varchar(100); 

alter table Nashville_housing
add OwnerState varchar(100); 

update nashville_housing
set OwnerStreetAddress = substring(OwnerAddress,1,locate(';',OwnerAddress)-1);
 
update nashville_housing
set OwnerCity = substring(substring(OwnerAddress,locate(';',OwnerAddress) + 1, length(OwnerAddress)),1,locate(';',substring(OwnerAddress,locate(';',OwnerAddress) + 1, length(OwnerAddress)))-1);

update nashville_housing
set OwnerState = substring(
substring(OwnerAddress,locate(';',OwnerAddress) + 1, length(OwnerAddress)),locate(';',substring(OwnerAddress,locate(';',OwnerAddress) + 1, length(OwnerAddress))) + 1, length(substring(OwnerAddress,locate(';',OwnerAddress) + 1, length(OwnerAddress))));

select * from nashville_housing;

/**/
select distinct SoldAsVacant from nashville_housing;
select distinct(SoldAsVacant), count(SoldAsVacant) from nashville_housing group by SoldAsVacant order by 2;

select soldasvacant,
case
when soldasvacant = 'Y' then 'Yes'
when soldasvacant = 'N' then 'No'
else soldasvacant
end
from nashville_housing;

update nashville_housing
set soldasvacant  = case
when soldasvacant = 'Y' then 'Yes'
when soldasvacant = 'N' then 'No'
else soldasvacant
end;



/*Remove Duplicates considering that there is data that represent the actual same record*/
/*Could not find a proper resolution for this duplicate in MySQL. CTE Does not work and other deletions are not working*/
with row_num_cte as(
select *, row_number() 
over(partition by parcelID,PropertyAddress,SalePrice, SaleDate,LegalReference order by UniqueID) row_num
from nashville_housing order by ParcelID) select * from row_num_cte where row_num > 1 order by PropertyAddress;


select count(*) from nashville_housing;
select count(*) from housing.nashville_housing
where uniqueID in (select a1.uniqueID from housing.nashville_housing a1 join housing.nashville_housing a2
on 
a2.parcelID  = a1.parcelID /*and 
a2.PropertyAddress = a1.PropertyAddress and
a2.SalePrice = a1.SalePrice and 
a2.SaleDate = a1.SaleDate and
a2.LegalReference = a1.LegalReference and
a2.UniqueID = a1.UniqueID*/);


create temporary table tempNH (parcelID int,PropertyAddress varchar(100),SalePrice float, SaleDate datetime,LegalReference varchar(100));
insert into tempNH (parcelID,PropertyAddress,SalePrice, SaleDate,LegalReference)
select parcelID,PropertyAddress,SalePrice, SaleDate,LegalReference from nashville_housing nh where
exists (select * from nashville_housing nh2 where
nh2.parcelID  = nh.parcelID and 
nh2.PropertyAddress = nh.PropertyAddress and
nh2.SalePrice = nh.SalePrice and 
nh2.SaleDate = nh.SaleDate and
nh2.LegalReference = nh.LegalReference);  
DELETE FROM nashville_housing USING nashville_housing, tempNH WHERE nashville_housing.parcelid = tempNH.parcelID;

/*Delete Unused Columns */
alter table nashville_housing
drop column OwnerAddress;
alter table nashville_housing
drop column TaxDistrict;
alter table nashville_housing
drop column PropertyAddress;
