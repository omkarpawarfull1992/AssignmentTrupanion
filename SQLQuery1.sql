select * from claimdata where PEtID='5' order by PEtID,ClaimDate

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

select PetID,DATEFROMPARTS(Year(EnrollDate),Month(EnrollDate),1) as [EnrollDate],Species,Breed,AgeAtEnroll,Prev1Claim,Prev2Claim,ClaimRSum,ClaimPerMonth,MonthAfterEnroll
,MonthAfterEnroll-PerClaimMonthAfterEnroll as [PreClaimMonthDiff],MonthAfterEnroll-PerPerClaimMonthAfterEnroll as [PrePreClaimMonthDiff] from #temp5 order by PEtID,ClaimDate