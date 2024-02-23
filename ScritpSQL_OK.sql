CREATE TABLE IF NOT EXISTS public.Model (
    modelID SERIAL PRIMARY KEY,
    modelType VARCHAR(50)
);

CREATE TABLE IF NOT EXISTS public.Machine (
    machineID SERIAL PRIMARY KEY,
    age INTEGER,
    modelID INTEGER REFERENCES public.Model(modelID)
);

CREATE TABLE IF NOT EXISTS public.ErrosTipo (
    errosID SERIAL PRIMARY KEY,
    errostipoID VARCHAR(50)
);

CREATE TABLE IF NOT EXISTS public.Errors (
    datetime TIMESTAMP,
    machineID INTEGER,
    errorID INTEGER REFERENCES public.ErrosTipo(errosID),
    FOREIGN KEY (machineID) REFERENCES public.Machine(machineID)
);

CREATE TABLE IF NOT EXISTS public.Component (
    componentID SERIAL PRIMARY KEY,
    componentType VARCHAR(50)
);

CREATE TABLE IF NOT EXISTS public.Failure (
    datetime TIMESTAMP,
    componentID INTEGER,
    machineID INTEGER,
    FOREIGN KEY (componentID) REFERENCES public.Component(componentID),
    FOREIGN KEY (machineID) REFERENCES public.Machine(machineID)
);

CREATE TABLE IF NOT EXISTS public.Maints (
    datetime TIMESTAMP,
    machineID INTEGER,
    componentID INTEGER,
    FOREIGN KEY (machineID) REFERENCES public.Machine(machineID),
    FOREIGN KEY (componentID) REFERENCES public.Component(componentID)
);

CREATE TABLE IF NOT EXISTS public.Telemetry (
    datetime TIMESTAMP,
    machineID INTEGER,
    volt NUMERIC,
    rotate NUMERIC,
    pressure NUMERIC,
    vibration NUMERIC,
    FOREIGN KEY (machineID) REFERENCES public.Machine(machineID)
);
---Inserindo dados na tabela Component
 insert into public.component (componentType)
SELECT distinct failure as componentType FROM kaggle.failures order by failure 

---Inserindo dado na tabela Model
insert into public.model (modelType)
SELECT distinct model as modelType FROM kaggle.machines order by model

--- Inserindo dados na tabela ErrosTipo
insert into public.ErrosTipo (errostipoID)
SELECT distinct errorid as errostipoID FROM kaggle.errors order by errorid

---Inserindo dados na tabela Machine
Insert into public.Machine(machineID,age,modelID )
select machineid as machineID, age, modelid as modelID from kaggle.machines as m 
inner join public.Model as mo on m.model= mo.modelType

---- Inserido dados na tabela Errors
Insert into public.Errors(datetime,machineID,errorID)
select datetime, machineid as machineID, errosid as errorID from kaggle.errors as e inner join public.ErrosTipo as et on et.errostipoID= e.errorid 


---- Inseridos dados na tabela failures
Insert into public.Failure (datetime, componentID, machineID )
select datetime, componentid as compenentID, machineid as machineID from kaggle.failures f 
inner join component c on f.failure = c.componentType 

----Inserindo dados na tabela maints
Insert into public.maints (datetime, componentID, machineID )
select datetime, componentid as compenentID, machineid as machineID 
from kaggle.maint m 
inner join component c on m.component = c.componentType 

--- Inserindo dados na tabela telemtria
select *from kaggle.Telemetry
Insert into public.Telemetry(datetime,machineID, volt, rotate,pressure, vibration)
select  datetime, machineid as machineID, volt, rotate, pressure, vibration from kaggle.Telemetry



---Qual modelo de máquina apresenta mais falhas?
SELECT mo.modelType, COUNT(*) AS num_failures
FROM public.Failure f
INNER JOIN public.Machine ma ON f.machineID = ma.machineID
INNER JOIN public.Model mo ON ma.modelID = mo.modelID
GROUP BY mo.modelType
ORDER BY num_failures DESC
LIMIT 1;

---Qual a quantidade de falhas por idade da máquina?
SELECT ma.age, COUNT(*) AS num_failures
FROM public.Failure f
INNER JOIN public.Machine ma ON f.machineID = ma.machineID
GROUP BY ma.age
ORDER BY ma.age;


--Qual componente apresenta maior quantidade de falhas por máquina?
SELECT ma.machineID, c.componentType, COUNT(*) AS num_failures
FROM public.Failure f
INNER JOIN public.Machine ma ON f.machineID = ma.machineID
INNER JOIN public.Component c ON f.componentID = c.componentID
GROUP BY ma.machineID, c.componentType
ORDER BY ma.machineID, num_failures DESC
LIMIT 1;


---A média da idade das máquinas por modelo?
SELECT mo.modelType, AVG(ma.age) AS avg_age
FROM public.Machine ma
INNER JOIN public.Model mo ON ma.modelID = mo.modelID
GROUP BY mo.modelType;


--Quantidade de erro por tipo de erro e modelo da máquina?
SELECT mo.modelType, et.errostipoID, COUNT(*) AS num_errors
FROM public.Errors e
INNER JOIN public.Machine ma ON e.machineID = ma.machineID
INNER JOIN public.Model mo ON ma.modelID = mo.modelID
INNER JOIN public.ErrosTipo et ON e.errorID = et.errosID
GROUP BY mo.modelType, et.errostipoID
ORDER BY mo.modelType, num_errors DESC;








