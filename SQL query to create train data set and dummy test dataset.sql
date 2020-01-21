select * from petdata where PEtID='1005' order by PEtID,ClaimDate

select * from claimdata order by PetID,ClaimDate

select *,DATEPART(month,ClaimDate) [Cmonth],DATEPART(year,ClaimDate) [Cyear] into #temp1 from claimdata

select SUM(CAST(ClaimAmount as Float)) as [ClaimPerMonth],[Cyear],[Cmonth],PetId into #temp2 from #temp1 group by [Cyear],[Cmonth],PetId order by PEtID

select ClaimPerMonth,PetID,DATEFROMPARTS([Cyear],[Cmonth],1) as [ClaimDate]  into #tempClaim from #temp2

select * from #tempClaim order by PetID,ClaimDate

with cte as
(select LAG(ClaimPerMonth,1) Over (partition by PetID order by ClaimDate) as [Prev1Claim],LAG(ClaimPerMonth,2) Over (partition by PetID order by ClaimDate) as [Prev2Claim],
SUM(CAST(ClaimPerMonth as float)) OVer(partition by PetID order by ClaimDate) as [ClaimRSum],
ClaimPerMonth,ClaimDate,PetId from #tempClaim)
select * into #tempClaimData from cte order by PEtID,ClaimDate 

select * from petdata

select A.*,B.Prev1Claim,B.Prev2Claim,B.ClaimRSum,B.ClaimPerMonth,B.ClaimDate,DateDiff(month,EnrollDate,ClaimDate) as [MonthAfterEnroll] into #temp4 from petdata A
join #tempClaimData B
on A.PetId=B.PetId order by A.PetID,ClaimDate

select *,LAG(MonthAfterEnroll,1) OVER (partition by PetID order by ClaimDate) as [PerClaimMonthAfterEnroll],LAG(MonthAfterEnroll,2) OVER (partition by PetID order by ClaimDate) as [PerPerClaimMonthAfterEnroll] into #temp5 from #temp4 order by Species,Breed,AgeAtEnroll,PetID

select PetID,DATEFROMPARTS(Year(EnrollDate),Month(EnrollDate),1) as [EnrollDate],CancelDate,Species,Breed,AgeAtEnroll,Prev1Claim,Prev2Claim,ClaimRSum,ClaimPerMonth,MonthAfterEnroll,ClaimDate
,MonthAfterEnroll-PerClaimMonthAfterEnroll as [PreClaimMonthDiff],MonthAfterEnroll-PerPerClaimMonthAfterEnroll as [PrePreClaimMonthDiff] into #tempom from #temp5 
--and 
--ClaimDate>'2019-06-30'
order by PetID,ClaimDate

select * from petdata where 
(CancelDate='' or CancelDate>'2019-06-30') order by PetID

select distinct PetID,0 as [ClaimID],'2019-07-01' as [ClaimDate],0 as [ClaimAmount] into #temp8 from #temp7

select * from #temp8

insert into claimdata(ClaimId,ClaimDate,PetId,ClaimAmount)
select ClaimId,ClaimDate,PetId,ClaimAmount from #temp8

with cte1 as
(select *,ROW_NUMBER() OVER(partition by PetID order by ClaimId asc) as RN from claimdata)
select distinct PetID into #temp10 from cte1 where PetID not in (select PetID from cte1 where RN=2) and ClaimAmount='0' order by PetID

--737241


select *,SUM(Prev1Claim) Over(partition by PetID order by ClaimDate) as [RollingSum],isNULL(Prev1Claim,0)-IsNULL(Prev2Claim,0) as [DiffInClaim] from #tempom order by PetID,ClaimDate