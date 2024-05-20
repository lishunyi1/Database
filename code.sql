--建立数据库
create database CarSales  
on(name= 'CarSales_data',
filename='E:\DataBaseCourse\CarSales_mdf',
size=200,
maxsize=unlimited,
filegrowth=5%)
log on(name= 'CarSales_log',
filename='E:\DataBaseCourse\CarSales_ldf',
size=50,
maxsize=unlimited,
filegrowth=5mb
)
go

use CarSales;
go
--建立表结构
create table Customer   --顾客表
(cuId char(6)primary key,
cuName nvarchar(10),
cuAddress nvarchar(10),
cuPhone char(11),
cuSex char(2)check(cuSex in('男','女'))
)
 
create table Business   --商家表
(bId char(6)primary key,
bName nvarchar(10),
bAddress nvarchar(5),
bPhone char(10)
)

create table Repair   --修理厂表
(rId char(6)primary key,
rName nvarchar(10),
rAddress nvarchar(10),
rPhone char(10)
)

create table Car   --车辆信息表
(cId char(6)primary key,
cName nvarchar(10),
cType nvarchar(5),
cPrice float,
cDate datetime not null
)
 
create table cOrder   --订单表
(oId char(6)primary key,
cuId char(6),
bId char(6),
cId char(6),
oQuantity int,
oDate datetime not null,
operiod int,
FOREIGN KEY (cuId) REFERENCES Customer(cuId),
FOREIGN KEY (bId) REFERENCES Business(bId),
FOREIGN KEY (cId) REFERENCES Car(cId)
)

create table Supply   --供给表
(bId char(6),
cId char(6),
cQuantity int,
cCondition image,
cIsSecond char(2)check(cIsSecond in('是','否')),
primary key(bId,cId),
FOREIGN KEY (bId) REFERENCES Business(bId),
FOREIGN KEY (cId) REFERENCES Car(cId)
)

create table AfterSales   --售后表
(aId char(6)primary key,
cuId char(6),
bId char(6),
rId char(6),
cId char(6),
aDate datetime not null,
aEvent nvarchar(10),
aFees float,
aState char(2)check(aState in('是','否')),
FOREIGN KEY (cuId) REFERENCES Customer(cuId),
FOREIGN KEY (bId) REFERENCES Business(bId),
FOREIGN KEY (rId) REFERENCES Repair(rId),
FOREIGN KEY (cId) REFERENCES Car(cId)
)
go

--插入图片信息
update Supply
set cCondition=(select * from openrowset(BULK N'C:\Users\30124\Desktop\R-C.jpg',SINGLE_BLOB)AS IMAGE)

--为车辆表建立索引
create unique index Price on Car(cPrice desc,cId,cName,cType,cDate desc)
select *
from Car
--drop index Car.Price

--供给表建立索引
create unique index CQ on Supply(cQuantity desc,cId,bId,cIsSecond)
select *
from Supply

--实现对车辆基本信息的管理
--定义一个存储过程向车辆信息表中添加刚生产出来的车辆
create proc  addCar @cId char(6),@cName nvarchar(10),@cType nvarchar(5),@cPrice float,@cDate datetime
as
begin
	insert into Car
	values(@cId,@cName,@cType,@cPrice,@cDate )
end

exec addCar '412056','奔驰Ss3','跑车',1000000,'2025-12-23'
--drop proc addCar
go

--定义一个触发器，检查在添加车辆信息时，若出厂时间大于当下时间，则取消添加
create trigger CheckCar
on Car for insert,update
as
begin
	declare @cId  char(6),@date1 datetime,@date2 datetime
	select @cId=cId,@date1=cDate
	from inserted

	select @date2=getdate()

	if @date1>@date2
	begin
		print '操作失败！出厂时间有误！'
		rollback
	end 
	else
	begin
		print '操作成功！'
	end
end

--drop trigger CheckCar
go


--定义一个函数实现根据车辆名称获取车辆信息。
create function findCarInfo (@cName nvarchar(10))
returns table
as
return select * from Car where cName like '%'+@cName+'%';
go

select * from dbo.findCarInfo('宝马')
--drop function findCarInfo
go


--实现对修理厂基本信息的管理
--定义一个存储过程向修理厂信息表中添加新注册的修理厂
create proc  addRepair @rId char(6),@rName nvarchar(10),@rAddress nvarchar(10),@rPhone char(10)
as
begin
	insert into Repair
	values(@rId,@rName,@rAddress,@rPhone)
end

exec addRepair '310022','顺义修理中心','贵州遵义','2023-13123'
--drop proc  addRepair
go

--定义一个函数查询修理厂基本信息
create function findRepair (@rName nvarchar(10))
returns table
as
return select *
from Repair
where rName like '%'+@rName+'%' 
go

--定义一个存储过程对修理厂基本信息进行修改
create proc  alterRepair @rId char(6),@rName nvarchar(10)='',@rAddress nvarchar(10)='',@rPhone char(10)=''
as
begin
declare @flag int 
set @flag=0
	if @rName!=''
	begin
		UPDATE Repair
		SET rName = @rName
		WHERE rId = @rId
		set @flag=1
	 end
	if @rAddress!=''
	begin
		UPDATE Repair
		SET rAddress = @rAddress
		WHERE rId = @rId
		set @flag=1
	 end
	 if @rPhone!=''
	begin
		UPDATE Repair
		SET rPhone = @rPhone
		WHERE rId = @rId
		set @flag=1
	 end
	 if @flag=1
		begin
		print '操作成功！'
		end 
	else 
		print '操作失败！'
end

exec alterRepair '310001','','贵州'
go


--实现对顾客基本信息的管理
--用存储过程向客户表中添加数据
create proc  addCustomer @cuId char(6),@cuName nvarchar(10), @cuAddress nvarchar(10),@cuPhone char(11),@cuSex char(2)
as
begin
	insert into Customer
	values(@cuId,@cuName,@cuAddress,@cuPhone,@cuSex)
end

exec addCustomer '100301','徐瑞纯','贵州都匀','19819695029','女'
go

--定义一个存储过程对顾客基本信息进行修改
create proc  alterCustomer @cuId char(6),@cuName nvarchar(10)='', @cuAddress nvarchar(10)='',@cuPhone char(11)='',@cuSex char(2)=''
as
begin
declare @flag int 
set @flag=0
	if @cuName!=''
	begin
		UPDATE Customer
		SET cuName = @cuName
		WHERE cuId = @cuId
		set @flag=1
	 end
	if @cuAddress!=''
	begin
		UPDATE Customer
		SET cuAddress = @cuAddress
		WHERE cuId = @cuId
		set @flag=1
	 end
	 if @cuPhone!=''
	begin
		UPDATE Customer
		SET cuPhone = @cuPhone
		WHERE cuId = @cuId
		set @flag=1
	 end
	 if @cuSex!=''
	begin
		UPDATE Customer
		SET cuSex = @cuSex
		WHERE cuId = @cuId
		set @flag=1
	 end
	 if @flag=1
		begin
		print '操作成功！'
		end 
	else 
		print '操作失败！'
end
exec alterCustomer '100001','张万森'
--drop proc alterCustomer
go

--定义函数根据姓名查询电话和地址
create function findCustomer (@cuName nvarchar(10))
returns table
as
return select cuName,cuAddress,cuPhone 
from Customer
where cuName like '%'+@cuName+'%'
go

select * from dbo.findCustomer('李顺义')
--drop function findCustomer
go


--实现对商家基本信息的管理
--用存储过程向商家表中添加数据
create proc  addBusiness @bId char(6),@bName nvarchar(10),@bAddress nvarchar(5),@bPhone char(10)
as
begin
	insert into Business
	values(@bId ,@bName,@bAddress,@bPhone)
end

exec addBusiness '201021','顺义集团中心','贵州遵义','0000-10101'
go

--定义一个存储过程对商家基本信息进行修改
create proc  alterBusiness @bId char(6),@bName nvarchar(10)='',@bAddress nvarchar(5)='',@bPhone char(10)=''
as
begin
declare @flag int 
set @flag=0
	if @bName!=''
	begin
		UPDATE Business
		SET bName = @bName
		WHERE bId = @bId
		set @flag=1
	 end
	if @bAddress!=''
	begin
		UPDATE Business
		SET bAddress = @bAddress
		WHERE bId = @bId
		set @flag=1
	 end
	 if @bPhone!=''
	begin
		UPDATE Business
		SET bPhone = @bPhone
		WHERE bId = @bId
		set @flag=1
	 end
	 if @flag=1
		begin
		print '操作成功！'
		end 
	else 
		print '操作失败！'
end
exec  alterBusiness '201000','一汽'
go

--定义一个函数查询商家基本信息
create function findBnsiness (@bName nvarchar(10))
returns table
as
return select *
from Business
where bName like '%'+@bName+'%' 
go


--实现对供给信息的管理
--用存储过程向供给表中添加数据
create proc  addSupply @bId char(6),@cId char(6),@cQuantity int,@cCondition image,@cIsSecond char(2)
as
begin
	insert into Supply 
	values(@bId ,@cId ,@cQuantity,@cCondition,@cIsSecond)
end
go
--drop proc  addSupply
exec addSupply '201001','412010',100,'','否'
update Supply
set cCondition=(select * from openrowset(BULK N'C:\Users\30124\Desktop\R-C.jpg',SINGLE_BLOB)AS IMAGE)
where bId='bId' and cId='412010'
go

--定义一个存储过程对供给信息进行修改,对已有车辆增加或减少库存
create proc  alterSupply @bId char(6),@cId char(6),@cQuantity int=0,@cIsSecond char(2)=''
as
begin
declare @flag int 
set @flag=0
	if @cQuantity!=0
	begin
		UPDATE Supply  WITH (ROWLOCK, UPDLOCK)
		SET cQuantity =cQuantity+ @cQuantity
		WHERE bId = @bId and cId=@cId
		set @flag=1
	 end
	 if @cIsSecond!=''
	begin
		UPDATE Supply  WITH (ROWLOCK, UPDLOCK)
		SET cIsSecond =@cIsSecond
		WHERE bId = @bId and cId=@cId
		set @flag=1
	 end
	 if @flag=1
		begin
		print '操作成功！'
		end 
	else 
		print '操作失败！'
end
exec   alterSupply '201000','412013',1000
--drop proc  alterSupply
go

--定义一个触发器，当在插入或更新供给表数据时，若结果更新结果为负数，则取消操作，返回操作失败
create trigger CheckSupply
on Supply for insert,update
as
begin
	declare @bId  char(6),@cId char(6),@m int
	select @bId=bId ,@cId=cId,@m=cQuantity
	from inserted

	if @m<0
	begin
		print '操作错误！！！'
		rollback
	end 
	else
	begin
		print '操作成功！！！'
	end
end
go

--定义一个函数根据车辆名称查询车辆的供给状况
create function findCar (@cName nvarchar(10))
returns table
as
return select cName ,Car.cId,cType,cPrice,cDate,bId,cQuantity,cCondition,cIsSecond
from Supply,Car
where Supply.cId=Car.cId and cName like '%'+@cName+'%' 
go
select * from dbo.findCar('宝马')
--drop function findCar
go

--定义一个函数查询车辆在某公司的库存状况
create function CarQuantity(@cName nvarchar(10),@bName nvarchar(10))
returns table
as
return select cName ,bName,cQuantity
from Supply,Car,Business
where Supply.cId=Car.cId and cName like '%'+@cName+'%' and bName like '%'+@bName+'%'
go
select * from dbo.CarQuantity('宝马','一汽')
--drop function CarQuantity
go

--查询商家及其供货信息
create function Bus(@bName nvarchar(10))
returns table
as
return select Supply.bId,bName,bAddress,Car.cId,cName,cCondition,cDate,cPrice
from Business,Supply,Car
where Supply.bId=Business.bId and Car.cId=Supply.cId and bName like '%'+@bName+'%'
go
select * from dbo.Bus('一汽')
--drop function Bus
go


--对订单信息的管理
--定义一个存储过程向订单表中添加数据
create proc  addOrder @oId char(6),@cuId char(6),@bId char(6),@cId char(6),@oQuantity int,@operiod int
as
begin
	insert into cOrder
	values(@oId ,@cuId ,@bId,@cId ,@oQuantity ,getdate(),@operiod )
end

exec addOrder '240056','100001','201001','412011',1000,3
--drop  proc  addOrder
go

--建立一个触发器，若客户订单加入的车辆库存为0或者小于顾客需要购入的车辆数量时，应取消加入。
create trigger CheckOrder
on cOrder for insert,update
as
begin
	declare @bId  char(6),@cId char(6),@m int,@n int
	select @bId=bId ,@cId=cId,@m=oQuantity
	from inserted

	select @n=cQuantity
	from Supply
	where @bId=bId and @cId=cId

	if @m>@n
	begin
		print '库存不足'
		rollback
	end 
	else
	begin
		update Supply  WITH (ROWLOCK, UPDLOCK)
		set cQuantity=cQuantity-@m
		where bId=@bId and cId=@cId
		print '购买成功！！！'
	end
end

--drop trigger CheckOrder
go

--定义一个存储过程对订单信息进行修改
create proc  alterOrder  @oId char(6),@cuId char(6)='',@bId char(6)='',@cId char(6)='',@oQuantity int=0,@oDate datetime ='',@operiod int=0
as
begin
declare @flag int 
set @flag=0
	if @cuId!=''
	begin
		UPDATE cOrder
		SET cuId=@cuId
		WHERE oId = @oId
		set @flag=1
	 end
	if @bId!=''
	begin
		UPDATE cOrder
		SET bId=@bId
		WHERE oId = @oId
		set @flag=1
	 end
	 if @cId!=''
	begin
		UPDATE cOrder
		SET cId=@cId
		WHERE oId = @oId
		set @flag=1
	 end
	 if @oQuantity!=0
	begin
		UPDATE cOrder
		SET oQuantity=@oQuantity
		WHERE oId = @oId
		set @flag=1
	 end
	 if @oDate!=''
	begin
		UPDATE cOrder
		SET oDate=@oDate
		WHERE oId = @oId
		set @flag=1
	 end
	 if @operiod!=''
	begin
		UPDATE cOrder
		SET operiod=@operiod
		WHERE oId = @oId
		set @flag=1
	 end
	 if @flag=1
		begin
		print '操作成功！'
		end 
	else 
		print '操作失败！'
end
go
exec   alterOrder '240001','100002'
--drop proc  alterOrder
go

--定义一个触发器，检查在添加订单信息时，若时间大于当下时间，则取消操作，输出操作失败
create trigger CheckDate
on cOrder for insert,update
as
begin
	declare @oId  char(6),@date1 datetime,@date2 datetime
	select @oId=oId,@date1=oDate
	from inserted

	select @date2=getdate()

	if @date1>@date2
	begin
		print '操作失败！时间有误！'
		rollback
	end 
	else
	begin
		print '操作成功！'
	end
end

--drop trigger CheckCar
go

--查询客户订单
create function CustomerOrder (@cuName nvarchar(10))
returns table
as
return select oId,cuName,Customer.cuId,bId,cId,oQuantity,oDate,operiod
from Customer,cOrder
where Customer.cuId=cOrder.cuId and cuName like '%'+@cuName+'%'
go
select * from dbo.CustomerOrder('张')
--drop function CustomerOrder
go

--建立商家销量视图
create view Sales
as
select bName as 商家名,sum(oQuantity) as 总销量
from dbo.cOrder,dbo.Business
where cOrder.bId=Business.bId
group by cOrder.bId,bName
go
select * from Sales  order by 总销量 desc
go
--drop view Sales


--实现对售后信息的管理
--查询客户售后处理
create function CustomerAfter (@cuName nvarchar(10))
returns table
as
return select cuName,bId,cId,rId,aEvent,aDate,aFees
from Customer,AfterSales
where Customer.cuId=AfterSales.cuId and cuName like '%'+@cuName+'%'
go
select * from dbo.CustomerAfter('张')
--drop function CustomerAfter
go

--定义一个存储过程向售后表中添加数据
create proc  addAfter @aId char(6),@cuId char(6),@bId char(6),@rId char(6),@cId char(6),@aEvent nvarchar(10),@aFees float,@aState char(2)
as
begin
	insert into AfterSales
	values(@aId,@cuId,@bId ,@rId,@cId,getdate(),@aEvent,@aFees,@aState)
end
exec addAfter '601021','100001','201000','310002','412001','换车轮',100,'是'
go

--定义一个存储过程修改售后表中数据
create proc  alterAfter @aId char(6),@cuId char(6)='',@bId char(6)='',@rId char(6)='',@cId char(6)='',@aDate datetime='',@aEvent nvarchar(10)='',@aFees float=0,@aState char(2)=''
as
begin
declare @flag int 
set @flag=0
	if @cuId!=''
	begin
		UPDATE AfterSales
		SET cuId =@cuId
		WHERE aId = @aId
		set @flag=1
	 end
	 if @bId!=''
	begin
		UPDATE AfterSales
		SET bId =@bId
		WHERE aId = @aId
		set @flag=1
	 end
	 if @rId!=''
	begin
		UPDATE AfterSales
		SET rId =@rId
		WHERE aId = @aId
		set @flag=1
	 end
	 if @cId!=''
	begin
		UPDATE AfterSales
		SET cId =@cId
		WHERE aId = @aId
		set @flag=1
	 end
	 if @aDate!=''
	begin
		UPDATE AfterSales
		SET aDate =@aDate
		WHERE aId = @aId
		set @flag=1
	 end
	 if @aEvent!=''
	begin
		UPDATE AfterSales
		SET aEvent =@aEvent
		WHERE aId = @aId
		set @flag=1
	 end
	 if @aFees!=0
	begin
		UPDATE AfterSales
		SET aFees =@aFees
		WHERE aId = @aId
		set @flag=1
	 end
	  if @aState!=0
	begin
		UPDATE AfterSales
		SET aState =@aState
		WHERE aId = @aId
		set @flag=1
	 end
	 if @flag=0
		print '操作失败！'
end
go
exec   alterAfter  '601001','','','','','2026-1-2','',200
--drop proc  alterAfter
go

--定义一个触发器，检查在修改售后信息时，若处理时间大于当下时间，则取消添加
create trigger CheckAfter
on AfterSales for update
as
begin
	declare @aId char(6),@date1 datetime,@date2 datetime
	select @aId=aId,@date1=aDate
	from inserted

	select @date2=getdate()

	if @date1>@date2
	begin
		print '操作失败！时间有误！已取消修改'
		rollback
	end 
	else
	begin
		print '操作成功！'
	end
end

--drop trigger CheckCar
go

--定义一个函数客户查询车辆是否已经修理完毕
create function Condition (@aId char(6))
returns char(2)
as
begin
declare @state char(2)
select @state=aState
from AfterSales
where aId=@aId
return @state
end
go
select dbo.Condition('601001')
--drop function Condition
go


--数据库安全性
--创建客户角色，并分配给该角色对供给表、商家表、车辆表和修理厂表的查询权限，和对客户表的查询、更新权限
create role CustomerRole
grant select on Supply to CustomerRole
grant select on Repair to CustomerRole
grant select on Car to CustomerRole
grant select on Business to CustomerRole
grant update,select on Customer to CustomerRole

--创建商家角色，并分配给该角色对商家表的查询、更新权限，对车辆表和供给表和订单表的查询、添加、删除、更新权限，对修理厂表和顾客表的查询权限
create role BusinessRole
grant select,update on Business to CustomerRole
grant select,update,delete,insert on Car to CustomerRole
grant select,update,delete,insert on Supply to CustomerRole
grant select,update,delete,insert on cOrder to CustomerRole
grant select on Repair to CustomerRole
grant select on Customer to CustomerRole

--创建修理厂角色，并分配给该角色对修理厂表的查询、更新权限，对售后表的查询、添加、删除、更新权限，对顾客表的查询权限
create role RepairRole
grant select,update on Repair to CustomerRole
grant select,update,delete,insert on AfterSales to CustomerRole
grant select on Customer to CustomerRole
go


--创建一个出发触发器，当向顾客表里添加数据时，就定义一个用户，并将该用户添加到顾客角色
create trigger addCustomer1
on Customer for insert
as
begin
declare @cuId char(6)
select @cuId=cuId from inserted 
	create login [@cuId] with password = '000000';
	create user [@cuId] for login [@cuId]
	exec sp_addrolemember CustomerRole,[@cuId]
end
go

--创建一个出发触发器，当向商家表里添加数据时，就定义一个用户，并将该用户添加到商家角色
create trigger addBusiness1
on Business for insert
as
begin
declare @bId char(6)
select @bId=bId from inserted 
	create login [@bId] with password = '000000';
	create user [@bId] for login [@bId]
	exec sp_addrolemember BusinessRole,[@bId]
end
go

--创建一个出发触发器，当向修理厂表里添加数据时，就定义一个用户，并将该用户添加到修理厂角色
create trigger addRepair1
on Repair for insert
as
begin
declare @rId char(6)
select @rId=rId from inserted 
	create login [@rId] with password = '000000';
	create user [@rId] for login [@rId]
	exec sp_addrolemember RepairRole,[@rId]
end


--创建一个数据库拥有者具有所有权限
CREATE LOGIN [lsy] WITH PASSWORD = '123456';
USE [CarSales];
CREATE USER [lsy] FOR LOGIN [lsy];
CREATE ROLE db_owner_role;
EXEC sp_addrolemember 'db_owner', 'lsy';
GRANT CONTROL ON DATABASE::CarSales TO db_owner_role;
