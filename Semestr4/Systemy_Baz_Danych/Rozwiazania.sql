---------------------------------PS2----------------------------------------------------
SET SERVEROUTPUT ON;
--1. Napisa� anonimowy blok PL/SQL wy�wietlaj�cy komunikat.
BEGIN 
dbms_output.put_line('Systemy Baz Danych 2023');
END;

--2. U�ywaj�c prostej konstrukcji IF...THEN...ELSE, wy�wietli� odpowiedni komunikat w
--zale�no�ci od warto�ci zmiennej x.
DECLARE x NUMBER := &liczba;
BEGIN
  IF MOD(x,2)=0 THEN
    DBMS_OUTPUT.PUT_LINE('Liczba ' || x || ' jest parzysta.');
  ELSE
    DBMS_OUTPUT.PUT_LINE('Liczba ' || x || ' jest nieparzysta.');
  END IF;
END;
--3. Napisa� anonimowy bloku PL/SQL podaj�cy np. �rednie dochody pracownik�w.
DECLARE srednia NUMBER (6,2);
BEGIN 
SELECT round(avg(sal+nvl(comm,0)+bonus),2) INTO srednia
FROM emp e, bonus b
WHERE e.empno=b.empno;
dbms_output.put_line('Srednie zarobki pracownikow wynosza: '||srednia);
END;

--4. Napisa� anonimowy bloku PL/SQL podaj�cy np. liczb� pracownik�w na stanowisku
--sprzedawca.
DECLARE liczba_pracownikow NUMBER;
BEGIN
SELECT COUNT(1) into liczba_pracownikow
from emp
where upper(job)='SALESMAN';
dbms_output.put_line('Liczba sprzedawcow wynosi: '||liczba_pracownikow);
END;

--5. Napisa� blok, kt�ry zwr�ci np. nazw� projektu najwi�cej razy realizowanego.
DECLARE projekt project.proname%type;
realizacje number;
BEGIN 
select * into projekt, realizacje
from(select proname, count(impl)
     from project p, implproject imp
     where p.prono=imp.prono
     group by p.proname
     having (count(impl)>=all(select count(impl)
                              from implproject
                              group by prono)))
                              where rownum=1;
dbms_output.put_line('Projekt '||projekt||' byl realizowany najwiecej razy. A liczba jego realizacji to: '|| realizacje);
END;

--6. Je�li ilo�� pracownik�w na stanowisku sprzedawca przekracza 3 osoby wypisa� ilo��
--powi�kszon� o 15%, w przeciwnym razie wypisa� ilo�� pomniejszon� o 40%.
Declare liczba number;
begin
select count(empno) into liczba 
from emp
where upper(job)='SALESMAN';
if(liczba>3) then
dbms_output.put_line('Ilosc sprzedawcow to: '||1.15*liczba);
else 
dbms_output.put_line('Ilosc sprzdawcow to:'||0.6*liczba);
end if;
end;

--7. Utworzy� tabel� pomocnicz� z jednym polem numerycznym i jednym tekstowym (20
--znak�w).
create table pomocnicza1 
(
numer number(3),
tekst varchar2(20)
);
--8. Za pomoc� p�tli for wprowadzi� warto�ci od 6 do 1 do pola numerycznego i warto��
--�6...warto�� 1� do pola tekstowego.
declare x number:=1;  y number:=1;
begin
for x in reverse 1..6 loop
insert into pomocnicza1
values(x, to_char(x)||' wartosc ' ||to_char(y));
y:=y+1;
end loop;
end;
select * from pomocnicza1;
------------------------------PS3--------------------------------------
--1. Utworzy� tabel� pomocnicz� Pom2_1 na bazie tabeli Pracownicy. W bloku
--anonimowym usun�� informacje o pracownikach ze stopniem zaszeregowania 1. Poda�
--liczb� usuni�tych rekord�w.
create table pom2_1 as select * from emp;

declare usuniete number;
begin
delete from pom2_1
where empno in (select empno 
                from emp, salgrade
                where sal between losal and hisal and grade=1);
if sql%notfound then 
dbms_output.put_line('brak pracownikow');
elsif sql%found then
usuniete:=sql%rowcount;
dbms_output.put_line('Usuniete wiersze: '||usuniete);
end if;
end;

--2. W bloku anonimowym w tabeli Pom2_1 podnie�� o 15% wynagrodzenia pracownik�w
--na stanowisku sprzedawca. Poda� liczb� zmodyfikowanych rekord�w.
declare zmodyfikowane number;
begin
update pom2_1 set
sal=sal*1.15
where upper(job)='SALESMAN';
zmodyfikowane:=sql%rowcount;
dbms_output.put_line('Liczba zmodyfikowanych wierszy: '||zmodyfikowane);
end;

--3. W kursorze jawnym poda� nazwiska pracownik�w oraz daty pocz�tkowe i ko�cowe
--projekt�w przez nich realizowanych w 2016 roku.
declare
nazwisko emp.ename%type;
data_start date;
data_end date;
cursor nazwiska_daty is select ename, start_date,end_date 
from emp e, implemp ime, implproject imp
where e.empno=ime.empno and ime.impl=imp.impl and extract(year from start_date)=2015
and extract(year from end_date)=2015;
begin
open nazwiska_daty;
loop
fetch nazwiska_daty into nazwisko, data_start, data_end;
exit when (nazwiska_daty%notfound);
dbms_output.put_line(nazwisko||' '||data_start||' '||data_end);
end loop;
close nazwiska_daty;
end;
--4. Do tabeli pomocniczej Pom2_4 (utworzonej na bazie tabeli Pracownicy) wprowadzi�
--wszystkie informacje o pracownikach z nazwy departamentu podanej jako parametr
--kursora.
create table pom2_4 as select * from emp;
select * from pom2_4;

declare
cursor pracownik_departamentu( nazwa varchar2)
is select e.empno empno, e.ename ename, e.job job, e.mgr mgr, e.hiredate hiredate, e.sal sal, e.comm comm, e.deptno deptno
from emp e, dept d
where e.deptno=d.deptno and dname=nazwa;
begin
for x in pracownik_departamentu ('SALES')
loop 
insert into pom2_4 values(x.empno, x.ename, x.job, x.mgr, x.hiredate, x.sal, x.comm, x.deptno);
end loop;
end;

--5. W p�tli FOR kursora poda� nazwiska pracownik�w kt�rych p�ace (z premi� i bonusem)
--przekraczaj� 4000.
declare
cursor zarobki is select ename from emp e, bonus b
where (e.sal+nvl(comm,0)+bonus)>4000 and e.empno=b.empno;
begin
for x in zarobki
loop
dbms_output.put_line(x.ename);
end loop;
end;

--6. W anonimowej p�tli FOR kursora poda� nazwiska pracownik�w, kt�rzy realizowali
--wi�cej ni� dwa projekty.
begin 
for dwa_projekty in (select ename from emp e, implemp ie
                     where e.empno=ie.empno
                     group by ename
                     having (count(impl)>2))
loop
dbms_output.put_line(dwa_projekty.ename);
end loop;
end;

--7. W tabeli pomocniczej Pom2_7 (utworzonej na tabeli pracownicy) u�ywaj�c kursor
--SELECT FOR UPDATE zmodyfikowa� nazwiska pracownik�w na pisane z du�ej litery.
create table pom2_7 as select * from emp;
declare
cursor duza_litera is select * from pom2_7
for update of ename;
nazwisko emp.ename%type;
begin
for x in duza_litera
loop
nazwisko:=initcap(x.ename);
update pom2_7 set ename=nazwisko
where current of duza_litera;
end loop;
commit;
end;
select * from pom2_7;

--8. W kursorze podnie�� p�ace, w tabeli Pom2_7, pracownik�w o 1000, dla podanego
--w parametrze nazwiska zwierzchnika. U�y� ROWID podczas modyfikacji.
declare
cursor wieksza_kasa(n_szefa varchar2) is 
select p.empno, p.sal, p.rowid 
from pom2_7 p, pom2_7 s
where p.mgr=s.empno and s.ename=n_szefa;
pensja number;
begin 
for x in wieksza_kasa('Blake') loop
pensja:=x.sal+1000;
update pom2_7 set sal=pensja where rowid=x.rowid;
end loop;
end;
select * from pom2_7;

--9. U�ywaj�c zmiennej kursora oraz rekordu poda� pe�ne informacje o pracownikach,
--z p�ac� mniejsz� ni� 1500.
declare type zmienna_kursora is ref cursor;
Z_K zmienna_kursora;
wiersz emp%rowtype;
begin
open Z_K for 'select * from emp where sal<1500';
loop
fetch Z_K into wiersz;
exit when Z_K%notfound;
dbms_output.put_line(WIERSZ.EMPNO||' '||WIERSZ.ENAME||' '||WIERSZ.JOB||' '||WIERSZ.MGR||' '||WIERSZ.HIREDATE||' '||WIERSZ.SAL||' '||WIERSZ.COMM||' '||WIERSZ.DEPTNO);
end loop;
close Z_K;
end;

--10. Utworzy� kursor zwracaj�cy: minimalne, maksymalne i �rednie zarobki
--w poszczeg�lnych departamentach na poszceg�lnych stanowiskach.
begin
for x in (select deptno, job, min(sal) minimalne, max(sal) maksymalne, round(avg(sal),2)srednie
          from emp
          group by deptno, job
          order by deptno)
loop
dbms_output.put_line('NUMER DEPARTAMENTU: '||x.DEPTNO||' STANOWISKO: '||x.JOB||' MINIMALNA PENSJA: '||x.minimalne||' MAKSYMALNA PENSJA: '||x.maksymalne||' SREDNIA PENSJA: '||x.srednie);
end loop;
end;

-----------------------------------PS5------------------------------------------------

--1. Zaimplementowa� procedur�, kt�ra dla podanych parametr�w przy ka�dym wywo�aniu
--wprowadzi nowy rekord do tabeli projekty
create table projekt_kopia as select * from project;
select * from projekt_kopia;
create or replace procedure dodaj_projekt(nazwa in projekt_kopia.proname%type, kasa in projekt_kopia.budget%type)
is
numer projekt_kopia.prono%type;
begin
select nvl(max(prono)+1,1) into numer
from projekt_kopia;
insert into projekt_kopia values (numer, nazwa, kasa);
end;
execute dodaj_projekt('BOJAN LOVE',100000);

--2. Zaimplementowa� procedur�, kt�ra dla podanego identyfikatora pracownika zwi�kszy
--p�ac� o podany w parametrze procent
create or replace procedure zmien_place(numer in pom2_7.empno%type, procent number)
is 
begin
update pom2_7 set sal=sal*(procent/100+1) where empno=numer;
end;
select * from pom2_7;
--3. Wywo�a� utworzon� procedur�
execute zmien_place(7839,10);
--5. Utworzy� procedur� z kursorem pobieraj�cym informacje o pracownikach i nazwach
--realizowanych projekt�w
create or replace procedure pracownik_projekt
as
cursor wypisz is 
select e.empno, e.ename, p.proname
from emp e, implemp ime, implproject imp, project p
where e.empno=ime.empno and ime.impl=imp.impl and imp.prono=p.prono
order by e.empno;
begin 
for x in wypisz 
loop
dbms_output.put_line(x.empno||' '||x.ename||' '||x.proname);
end loop;
end;
--6. Wywo�a� procedur�
execute pracownik_projekt;
--7. Zaimplementowa� funkcj� zwracaj�c� sumaryczn� warto�� p�ac pracownik�w podanego w
--parametrze departamentu
create or replace function suma_plac (nazwa dept.dname%type)
return number
as
suma number:=0;
begin 
select sum(sal+nvl(comm,0)) into suma
from emp e, dept d
where e.deptno=d.deptno and dname=nazwa;
return suma;
end;

declare sumka number;
begin 
sumka:=suma_plac('SALES');
dbms_output.put_line(sumka);
end;


--8. Zaimplementowa� funkcj� zwracaj�c� �redni� p�ac� podanego w parametrze departamentu
create or replace function srednia_plac (nazwa dept.dname%type)
return number
as
srednia number:=0;
begin 
select round(avg(sal+nvl(comm,0)),2) into srednia
from emp e, dept d
where e.deptno=d.deptno and dname=nazwa;
return srednia;
end;

declare sr number;
begin 
sr:=srednia_plac('SALES');
dbms_output.put_line(sr);
end;

-----------------------PS6--------------------

--1. Utworzy� specyfikacj� pakietu z nag��wkami podprogram�w z zada� 1, 2, 5, 7 z
--poprzedniego PS5
create or replace package pakiet_PS5 as
procedure dodaj_projekt(nazwa in projekt_kopia.proname%type, kasa in projekt_kopia.budget%type);
procedure zmien_place(numer in pom2_7.empno%type, procent number);
procedure pracownik_projekt;
function suma_plac (nazwa dept.dname%type) return number;
end pakiet_PS5;

--2. Utworzy� cia�o pakietu
create or replace package body pakiet_PS5 as
procedure dodaj_projekt(nazwa in projekt_kopia.proname%type, kasa in projekt_kopia.budget%type)
is
numer projekt_kopia.prono%type;
begin
select nvl(max(prono)+1,1) into numer
from projekt_kopia;
insert into projekt_kopia values (numer, nazwa, kasa);
end;

procedure zmien_place(numer in pom2_7.empno%type, procent number)
is 
begin
update pom2_7 set sal=sal*(procent/100+1) where empno=numer;
end;

procedure pracownik_projekt
as
cursor wypisz is 
select e.empno, e.ename, p.proname
from emp e, implemp ime, implproject imp, project p
where e.empno=ime.empno and ime.impl=imp.impl and imp.prono=p.prono
order by e.empno;
begin 
for x in wypisz 
loop
dbms_output.put_line(x.empno||' '||x.ename||' '||x.proname);
end loop;
end;

function suma_plac (nazwa dept.dname%type)
return number
as
suma number:=0;
begin 
select sum(sal+nvl(comm,0)) into suma
from emp e, dept d
where e.deptno=d.deptno and dname=nazwa;
return suma;
end;
end pakiet_PS5;
--3. Wywo�a� podprogramy z utworzonego pakietu
execute pakiet_PS5.dodaj_projekt('KAARIJA LOVE', 50000);
--select * from projekt_kopia;
--select * from pom2_7;
execute pakiet_PS5.zmien_place(1111,50);
execute pakiet_PS5.pracownik_projekt;

--4. Wywo�a� funkcje pakietowe w zapytaniu
declare suma number:=0;
begin
suma:=pakiet_PS5.suma_plac('SALES');
dbms_output.put_line(suma);
end;

--5. Do utworzonego pakietu doda� kursor globalny podaj�cy liczb� pracownik�w w
--poszczeg�lnych departamentach. Wykorzysta� kursor w nowej procedurze globalnej
create or replace package pakiet_PS5 as
procedure dodaj_projekt(nazwa in projekt_kopia.proname%type, kasa in projekt_kopia.budget%type);
procedure zmien_place(numer in pom2_7.empno%type, procent number);
procedure pracownik_projekt;
function suma_plac (nazwa dept.dname%type) return number;
procedure liczenie;
cursor departamenty_pracownicy is select deptno, count(empno)co from emp group by deptno;
end pakiet_PS5;
/
create or replace package body pakiet_PS5 as
procedure dodaj_projekt(nazwa in projekt_kopia.proname%type, kasa in projekt_kopia.budget%type)
is
numer projekt_kopia.prono%type;
begin
select nvl(max(prono)+1,1) into numer
from projekt_kopia;
insert into projekt_kopia values (numer, nazwa, kasa);
end;

procedure zmien_place(numer in pom2_7.empno%type, procent number)
is 
begin
update pom2_7 set sal=sal*(procent/100+1) where empno=numer;
end;

procedure pracownik_projekt
as
cursor wypisz is 
select e.empno, e.ename, p.proname
from emp e, implemp ime, implproject imp, project p
where e.empno=ime.empno and ime.impl=imp.impl and imp.prono=p.prono
order by e.empno;
begin 
for x in wypisz 
loop
dbms_output.put_line(x.empno||' '||x.ename||' '||x.proname);
end loop;
end;

function suma_plac (nazwa dept.dname%type)
return number
as
suma number:=0;
begin 
select sum(sal+nvl(comm,0)) into suma
from emp e, dept d
where e.deptno=d.deptno and dname=nazwa;
return suma;
end;

procedure liczenie is
begin 
for x in departamenty_pracownicy
loop
dbms_output.put_line(x.deptno||' '||x.co);
end loop;
end;
end pakiet_PS5;
/
--6. Poda� przyk�ad wywo�ania nowej procedury
execute pakiet_PS5.liczenie;

----------------------PS7-----------------

--1. W bloku anonimowym przy ka�dym uruchomianiu poda� warto�ci dw�ch zmiennych.
--Obs�u�y� wyj�tek je�li b�dzie dzielenie przez zero.
declare
x number;
y number;
z number;
begin
x:=&x;
y:=&y;
z:=x/y;
if(y!=0) then dbms_output.put_line('wynik dzielenia: '||z);
end if;
exception 
when zero_divide then dbms_output.put_line('Debilu nie dziel przez 0!!!');
end;
--2. Utworzy� funkcj� z parametrem, w kt�rym podajemy nazw� projektu oraz w drugim rok
--realizacji projektu. W zale�no�ci od tego czy projekt by� realizowany czy nie obs�u�y�
--wyj�tki.
create or replace function nazwa_data (nazwa project.proname%type, rok number) return number
as 
nie_realizowany exception;
liczba number:=0;
begin
select count(impl) into liczba from implproject imp, project p
where p.prono=imp.prono and p.proname=nazwa and extract(year from imp.start_date)=rok group by imp.prono;
return liczba;
exception
when no_data_found then dbms_output.put_line('Projekt nie byl realizowany');
return liczba;
end;

declare
x number;
begin
x:=nazwa_data('VPN', 2015);
dbms_output.put_line(x);
end;

--3. Utworzy� procedur� z kursorem pobieraj�cym informacje o pracownikach realizuj�cych
--projekt o podanej nazwie w parametrze procedury. Obs�u�y� wyj�tek je�eli nikt nie
--realizowa� projektu o podanej nazwie.
create or replace procedure podana_nazwa (nazwa project.proname%type)
as 
cursor kursor is select e.empno, e.ename from emp e, implemp ime, implproject imp, projekt_kopia p
where e.empno=ime.empno and ime.impl=imp.impl and imp.prono=p.prono and p.proname=nazwa;
begin
for x in kursor 
loop
dbms_output.put_line(x.empno||' '||x.ename);
end loop;
exception when no_data_found then
dbms_output.put_line('Nikt nie realizowal projektu');
end;

execute podana_nazwa('VPN');
execute podana_nazwa('BOJAN LOVE');
select * from projekt_kopia;

--------------------------PS8--------------------------------------

--1. Na bazie tabeli EMP utworzy� now� tabel� EMP_N. Utworzy� wyzwalacz do generowania
--jednoznacznego identyfikatora pola tabeli, wstawianego przy wykonywaniu instrukcji INSERT. Do
--generowania identyfikatora u�y� sekwencji.
create table emp_n as select * from emp;
create sequence sekwencja
minvalue 8000
maxvalue 9999
start with 8000
increment by 1
cache 20;

create or replace trigger wyzwalacz
before insert on emp_n for each row
begin
:new.empno:=sekwencja.nextval;
end;

insert into emp_n values(1,'Bida','NAPASTNIK',3131,to_date('21-02-2001','dd-mm-yyyy'),4000,500,20);
SELECT * FROM EMP_N WHERE ENAME='Bida';
--2. Na bazie tabeli DEPT utworzy� now� tabel� DEPT_N. Utworzy� wyzwalacz, kt�ry b�dzie
--aktywowany po zmianie warto�ci pola klucza g��wnego tabeli DEPT_N i b�dzie modyfikowa�
--klucz obcy tabeli EMP_N, z ni� powi�zanej.
create table dept_n as select * from dept;
create or replace trigger wyzwalacz2
after update of deptno on dept_n for each row
begin
update emp_n
set deptno=:new.deptno where deptno=:old.deptno;
end;
update dept_n
set deptno=5
where deptno=10;

select * from dept_n;
select * from emp_n;

--3. Napisa� wyzwalacz, kt�ry b�dzie aktywowany przed wykonaniem polecenia wstawiania
--rekord�w do tabeli EMP_N z kluczem obcym deptno. Wyzwalacz powinien sprawdzi� czy
--wprowadzana warto�� jest ze zbioru warto�ci pola klucza g��wnego tabeli DEPT_N.
create or replace trigger wyzwalacz3
before insert on emp_n for each row
declare liczba number(2);
begin 
select count(1) into liczba
from dept_n
where deptno=:new.deptno;
if(liczba=0) then dbms_output.put_line('BRAK NUMERU DEPARTAMENTU W TABELI DEPT: '|| :NEW.DEPTNO);
raise_application_error(-20002,'blad');
end if;
end;
INSERT INTO EMP_N VALUES (1,'Brandon','SALESMAN',1112,TO_DATE('30-04-2014','dd-mm-yyyy'),4000,500,9);

--4. Utworzy� wyzwalacz, kt�ry b�dzie aktywowany gdy warto�� pola salary w tabeli EMP_N,
--zwr�cona przez kursor, b�dzie mniejsza od za�o�onej (np. 1500). Wys�a� odpowiedni komunikat.
create or replace trigger wyzwalacz4
after delete or update of sal or insert on emp_n
begin 
for x in (select ename, sal from emp_n)
loop
if(x.sal<1500) then
dbms_output.put_line('placa '||x.sal||' pracownka '||x.ename||' jest niska');
end if;
end loop;
end;
SELECT * FROM EMP_N;
UPDATE EMP_N SET SAL=1800 WHERE EMPNO=7782;
DELETE FROM EMP_N WHERE EMPNO=1234;
BEGIN
DBMS_OUTPUT.PUT_LINE('TEKST');
END;

-----------------PS9---------------------

--1. Napisa� anonimowy bloku PL/SQL podaj�cy na ekranie nazw� dzia�u z najmniejsz� liczb�
--pracownik�wk�w. Nazw� wypisa� z du�ej litery.
declare
nazwa dept.dname%type;
begin
select initcap(dname) into nazwa
from dept d, emp e
where d.deptno=e.deptno
group by dname
having(count(empno)<=all(select count(empno)
                         from emp pr, dept de
                         where pr.deptno=de.deptno
                         group by dname));
dbms_output.put_line(nazwa);
end;

--2. Utworzy� kopi� tabeli dzia�y o nazwie dzialy_Nazwisko. W procedurze zmodyfikowa� w tabeli
--dzialy_Nazwisko nazw� dzia�u dla kt�rego warto�� w polu deptno jest zgodna z warto�ci�
--parametru procedury. Poda� wywo�anie procedury.
create table dzialy_Nazwisko as select * from dept;
create or replace procedure zmiana_nazwy(numer dept.deptno%type)
as begin
update dzialy_Nazwisko set dname=lower(dname) where deptno=numer;
end;
execute zmiana_nazwy(30);
select * from dzialy_Nazwisko;

--3. Napisa� funkcj�, kt�ra zwr�ci liczb� stanowisk w dziale o podanej jako parametr nazwie. Poda�
--wywo�anie funkcji.
create or replace function stanowiska (nazwa dept.dname%type) return number
as
liczba number;
begin
select count(distinct job) into liczba
from emp
where deptno=(select deptno 
              from dept
              where dname=nazwa);
return liczba;
end;

declare x number;
begin
x:=stanowiska('SALES');
dbms_output.put_line(x);
end;
--4. W p�tli For kursora poda� nazwiska i stanowiska pracownik�w ze stopniem wynagrodzenia 1.

declare 
cursor kursorek is select e.nazwisko, e.stanowisko from pracownik e, poziom_zarobkow pz
where pensja+nvl(premia,0)between dolna_granica and gorna_granica and nr_przedzialu=1;
begin
for x in kursorek
loop
dbms_output.put_line(x.nazwisko||' '||x.stanowisko);
end loop;
end;

--5. Utworzy� kopi� tabeli SALGRADE i usun�� wszystkie rekordy z kopii. Utworzy� sekwencj�
--generuj�c� warto�ci od 1 do 20, wzrastaj�ce o 2. U�y� wyzwalacza do generowania
--jednoznacznego identyfikatora, wstawianego do pola grade przy wykonywaniu instrukcji INSERT
--na kopii tabeli.
select * from salgrade;
create table salgrade_kopia as select * from salgrade;
delete from salgrade_kopia;
select * from salgrade_kopia;

create sequence sekwencja2
minvalue 1
maxvalue 20
start with 1
increment by 2
cache 20;

create or replace trigger wyzwalaczek
before insert on salgrade_kopia for each row
begin
:new.grade:=sekwencja2.nextval;
end;

insert into salgrade_kopia values(null,1000,2000);
insert into salgrade_kopia values(null,2001,3000);
insert into salgrade_kopia values(null,3001,4000);
SELECT * FROM salgrade_kopia;


