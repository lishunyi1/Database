--�������ݿ�
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
--������ṹ
create table Customer   --�˿ͱ�
(cuId char(6)primary key,
cuName nvarchar(10),
cuAddress nvarchar(10),
cuPhone char(11),
cuSex char(2)check(cuSex in('��','Ů'))
)
 
create table Business   --�̼ұ�
(bId char(6)primary key,
bName nvarchar(10),
bAddress nvarchar(5),
bPhone char(10)
)

create table Repair   --������
(rId char(6)primary key,
rName nvarchar(10),
rAddress nvarchar(10),
rPhone char(10)
)

create table Car   --������Ϣ��
(cId char(6)primary key,
cName nvarchar(10),
cType nvarchar(5),
cPrice float,
cDate datetime not null
)
 
create table cOrder   --������
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

create table Supply   --������
(bId char(6),
cId char(6),
cQuantity int,
cCondition image,
cIsSecond char(2)check(cIsSecond in('��','��')),
primary key(bId,cId),
FOREIGN KEY (bId) REFERENCES Business(bId),
FOREIGN KEY (cId) REFERENCES Car(cId)
)

create table AfterSales   --�ۺ��
(aId char(6)primary key,
cuId char(6),
bId char(6),
rId char(6),
cId char(6),
aDate datetime not null,
aEvent nvarchar(10),
aFees float,
aState char(2)check(aState in('��','��')),
FOREIGN KEY (cuId) REFERENCES Customer(cuId),
FOREIGN KEY (bId) REFERENCES Business(bId),
FOREIGN KEY (rId) REFERENCES Repair(rId),
FOREIGN KEY (cId) REFERENCES Car(cId)
)
go

--����ͼƬ��Ϣ
update Supply
set cCondition=(select * from openrowset(BULK N'C:\Users\30124\Desktop\R-C.jpg',SINGLE_BLOB)AS IMAGE)

--Ϊ������������
create unique index Price on Car(cPrice desc,cId,cName,cType,cDate desc)
select *
from Car
--drop index Car.Price

--������������
create unique index CQ on Supply(cQuantity desc,cId,bId,cIsSecond)
select *
from Supply

--ʵ�ֶԳ���������Ϣ�Ĺ���
--����һ���洢����������Ϣ������Ӹ����������ĳ���
create proc  addCar @cId char(6),@cName nvarchar(10),@cType nvarchar(5),@cPrice float,@cDate datetime
as
begin
	insert into Car
	values(@cId,@cName,@cType,@cPrice,@cDate )
end

exec addCar '412056','����Ss3','�ܳ�',1000000,'2025-12-23'
--drop proc addCar
go

--����һ�����������������ӳ�����Ϣʱ��������ʱ����ڵ���ʱ�䣬��ȡ�����
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
		print '����ʧ�ܣ�����ʱ������'
		rollback
	end 
	else
	begin
		print '�����ɹ���'
	end
end

--drop trigger CheckCar
go


--����һ������ʵ�ָ��ݳ������ƻ�ȡ������Ϣ��
create function findCarInfo (@cName nvarchar(10))
returns table
as
return select * from Car where cName like '%'+@cName+'%';
go

select * from dbo.findCarInfo('����')
--drop function findCarInfo
go


--ʵ�ֶ�����������Ϣ�Ĺ���
--����һ���洢������������Ϣ���������ע�������
create proc  addRepair @rId char(6),@rName nvarchar(10),@rAddress nvarchar(10),@rPhone char(10)
as
begin
	insert into Repair
	values(@rId,@rName,@rAddress,@rPhone)
end

exec addRepair '310022','˳����������','��������','2023-13123'
--drop proc  addRepair
go

--����һ��������ѯ����������Ϣ
create function findRepair (@rName nvarchar(10))
returns table
as
return select *
from Repair
where rName like '%'+@rName+'%' 
go

--����һ���洢���̶�����������Ϣ�����޸�
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
		print '�����ɹ���'
		end 
	else 
		print '����ʧ�ܣ�'
end

exec alterRepair '310001','','����'
go


--ʵ�ֶԹ˿ͻ�����Ϣ�Ĺ���
--�ô洢������ͻ������������
create proc  addCustomer @cuId char(6),@cuName nvarchar(10), @cuAddress nvarchar(10),@cuPhone char(11),@cuSex char(2)
as
begin
	insert into Customer
	values(@cuId,@cuName,@cuAddress,@cuPhone,@cuSex)
end

exec addCustomer '100301','����','���ݶ���','19819695029','Ů'
go

--����һ���洢���̶Թ˿ͻ�����Ϣ�����޸�
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
		print '�����ɹ���'
		end 
	else 
		print '����ʧ�ܣ�'
end
exec alterCustomer '100001','����ɭ'
--drop proc alterCustomer
go

--���庯������������ѯ�绰�͵�ַ
create function findCustomer (@cuName nvarchar(10))
returns table
as
return select cuName,cuAddress,cuPhone 
from Customer
where cuName like '%'+@cuName+'%'
go

select * from dbo.findCustomer('��˳��')
--drop function findCustomer
go


--ʵ�ֶ��̼һ�����Ϣ�Ĺ���
--�ô洢�������̼ұ����������
create proc  addBusiness @bId char(6),@bName nvarchar(10),@bAddress nvarchar(5),@bPhone char(10)
as
begin
	insert into Business
	values(@bId ,@bName,@bAddress,@bPhone)
end

exec addBusiness '201021','˳�弯������','��������','0000-10101'
go

--����һ���洢���̶��̼һ�����Ϣ�����޸�
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
		print '�����ɹ���'
		end 
	else 
		print '����ʧ�ܣ�'
end
exec  alterBusiness '201000','һ��'
go

--����һ��������ѯ�̼һ�����Ϣ
create function findBnsiness (@bName nvarchar(10))
returns table
as
return select *
from Business
where bName like '%'+@bName+'%' 
go


--ʵ�ֶԹ�����Ϣ�Ĺ���
--�ô洢�����򹩸������������
create proc  addSupply @bId char(6),@cId char(6),@cQuantity int,@cCondition image,@cIsSecond char(2)
as
begin
	insert into Supply 
	values(@bId ,@cId ,@cQuantity,@cCondition,@cIsSecond)
end
go
--drop proc  addSupply
exec addSupply '201001','412010',100,'','��'
update Supply
set cCondition=(select * from openrowset(BULK N'C:\Users\30124\Desktop\R-C.jpg',SINGLE_BLOB)AS IMAGE)
where bId='bId' and cId='412010'
go

--����һ���洢���̶Թ�����Ϣ�����޸�,�����г������ӻ���ٿ��
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
		print '�����ɹ���'
		end 
	else 
		print '����ʧ�ܣ�'
end
exec   alterSupply '201000','412013',1000
--drop proc  alterSupply
go

--����һ�������������ڲ������¹���������ʱ����������½��Ϊ��������ȡ�����������ز���ʧ��
create trigger CheckSupply
on Supply for insert,update
as
begin
	declare @bId  char(6),@cId char(6),@m int
	select @bId=bId ,@cId=cId,@m=cQuantity
	from inserted

	if @m<0
	begin
		print '�������󣡣���'
		rollback
	end 
	else
	begin
		print '�����ɹ�������'
	end
end
go

--����һ���������ݳ������Ʋ�ѯ�����Ĺ���״��
create function findCar (@cName nvarchar(10))
returns table
as
return select cName ,Car.cId,cType,cPrice,cDate,bId,cQuantity,cCondition,cIsSecond
from Supply,Car
where Supply.cId=Car.cId and cName like '%'+@cName+'%' 
go
select * from dbo.findCar('����')
--drop function findCar
go

--����һ��������ѯ������ĳ��˾�Ŀ��״��
create function CarQuantity(@cName nvarchar(10),@bName nvarchar(10))
returns table
as
return select cName ,bName,cQuantity
from Supply,Car,Business
where Supply.cId=Car.cId and cName like '%'+@cName+'%' and bName like '%'+@bName+'%'
go
select * from dbo.CarQuantity('����','һ��')
--drop function CarQuantity
go

--��ѯ�̼Ҽ��乩����Ϣ
create function Bus(@bName nvarchar(10))
returns table
as
return select Supply.bId,bName,bAddress,Car.cId,cName,cCondition,cDate,cPrice
from Business,Supply,Car
where Supply.bId=Business.bId and Car.cId=Supply.cId and bName like '%'+@bName+'%'
go
select * from dbo.Bus('һ��')
--drop function Bus
go


--�Զ�����Ϣ�Ĺ���
--����һ���洢�����򶩵������������
create proc  addOrder @oId char(6),@cuId char(6),@bId char(6),@cId char(6),@oQuantity int,@operiod int
as
begin
	insert into cOrder
	values(@oId ,@cuId ,@bId,@cId ,@oQuantity ,getdate(),@operiod )
end

exec addOrder '240056','100001','201001','412011',1000,3
--drop  proc  addOrder
go

--����һ�������������ͻ���������ĳ������Ϊ0����С�ڹ˿���Ҫ����ĳ�������ʱ��Ӧȡ�����롣
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
		print '��治��'
		rollback
	end 
	else
	begin
		update Supply  WITH (ROWLOCK, UPDLOCK)
		set cQuantity=cQuantity-@m
		where bId=@bId and cId=@cId
		print '����ɹ�������'
	end
end

--drop trigger CheckOrder
go

--����һ���洢���̶Զ�����Ϣ�����޸�
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
		print '�����ɹ���'
		end 
	else 
		print '����ʧ�ܣ�'
end
go
exec   alterOrder '240001','100002'
--drop proc  alterOrder
go

--����һ�����������������Ӷ�����Ϣʱ����ʱ����ڵ���ʱ�䣬��ȡ���������������ʧ��
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
		print '����ʧ�ܣ�ʱ������'
		rollback
	end 
	else
	begin
		print '�����ɹ���'
	end
end

--drop trigger CheckCar
go

--��ѯ�ͻ�����
create function CustomerOrder (@cuName nvarchar(10))
returns table
as
return select oId,cuName,Customer.cuId,bId,cId,oQuantity,oDate,operiod
from Customer,cOrder
where Customer.cuId=cOrder.cuId and cuName like '%'+@cuName+'%'
go
select * from dbo.CustomerOrder('��')
--drop function CustomerOrder
go

--�����̼�������ͼ
create view Sales
as
select bName as �̼���,sum(oQuantity) as ������
from dbo.cOrder,dbo.Business
where cOrder.bId=Business.bId
group by cOrder.bId,bName
go
select * from Sales  order by ������ desc
go
--drop view Sales


--ʵ�ֶ��ۺ���Ϣ�Ĺ���
--��ѯ�ͻ��ۺ���
create function CustomerAfter (@cuName nvarchar(10))
returns table
as
return select cuName,bId,cId,rId,aEvent,aDate,aFees
from Customer,AfterSales
where Customer.cuId=AfterSales.cuId and cuName like '%'+@cuName+'%'
go
select * from dbo.CustomerAfter('��')
--drop function CustomerAfter
go

--����һ���洢�������ۺ�����������
create proc  addAfter @aId char(6),@cuId char(6),@bId char(6),@rId char(6),@cId char(6),@aEvent nvarchar(10),@aFees float,@aState char(2)
as
begin
	insert into AfterSales
	values(@aId,@cuId,@bId ,@rId,@cId,getdate(),@aEvent,@aFees,@aState)
end
exec addAfter '601021','100001','201000','310002','412001','������',100,'��'
go

--����һ���洢�����޸��ۺ��������
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
		print '����ʧ�ܣ�'
end
go
exec   alterAfter  '601001','','','','','2026-1-2','',200
--drop proc  alterAfter
go

--����һ����������������޸��ۺ���Ϣʱ��������ʱ����ڵ���ʱ�䣬��ȡ�����
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
		print '����ʧ�ܣ�ʱ��������ȡ���޸�'
		rollback
	end 
	else
	begin
		print '�����ɹ���'
	end
end

--drop trigger CheckCar
go

--����һ�������ͻ���ѯ�����Ƿ��Ѿ��������
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


--���ݿⰲȫ��
--�����ͻ���ɫ����������ý�ɫ�Թ������̼ұ��������������Ĳ�ѯȨ�ޣ��ͶԿͻ���Ĳ�ѯ������Ȩ��
create role CustomerRole
grant select on Supply to CustomerRole
grant select on Repair to CustomerRole
grant select on Car to CustomerRole
grant select on Business to CustomerRole
grant update,select on Customer to CustomerRole

--�����̼ҽ�ɫ����������ý�ɫ���̼ұ�Ĳ�ѯ������Ȩ�ޣ��Գ�����͹�����Ͷ�����Ĳ�ѯ����ӡ�ɾ��������Ȩ�ޣ���������͹˿ͱ�Ĳ�ѯȨ��
create role BusinessRole
grant select,update on Business to CustomerRole
grant select,update,delete,insert on Car to CustomerRole
grant select,update,delete,insert on Supply to CustomerRole
grant select,update,delete,insert on cOrder to CustomerRole
grant select on Repair to CustomerRole
grant select on Customer to CustomerRole

--����������ɫ����������ý�ɫ��������Ĳ�ѯ������Ȩ�ޣ����ۺ��Ĳ�ѯ����ӡ�ɾ��������Ȩ�ޣ��Թ˿ͱ�Ĳ�ѯȨ��
create role RepairRole
grant select,update on Repair to CustomerRole
grant select,update,delete,insert on AfterSales to CustomerRole
grant select on Customer to CustomerRole
go


--����һ������������������˿ͱ����������ʱ���Ͷ���һ���û����������û���ӵ��˿ͽ�ɫ
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

--����һ�������������������̼ұ����������ʱ���Ͷ���һ���û����������û���ӵ��̼ҽ�ɫ
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

--����һ���������������������������������ʱ���Ͷ���һ���û����������û���ӵ�������ɫ
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


--����һ�����ݿ�ӵ���߾�������Ȩ��
CREATE LOGIN [lsy] WITH PASSWORD = '123456';
USE [CarSales];
CREATE USER [lsy] FOR LOGIN [lsy];
CREATE ROLE db_owner_role;
EXEC sp_addrolemember 'db_owner', 'lsy';
GRANT CONTROL ON DATABASE::CarSales TO db_owner_role;
