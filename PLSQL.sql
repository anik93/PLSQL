--wyswietlic nazwe wydzialu ktory aktualnie zatrudnia najwieksza liczbe kobiet
with widok_liczba_kobiet as
	(select count(o.id_os) liczba_kobiet, w.nazwa wydzial
	from osoby o JOIN zatrudnienia z on o.id_os=z.id_os JOIN wydzialy w on z.id_w=w.id_w
	where o.plec='K' and z.do is null
	group by w.nazwa)
select wydzial, liczba_kobiet 
from widok_liczba_kobiet 
where liczba_kobiet=(select max(liczba_kobiet) 
					from widok_liczba_kobiet);

--wyswietlic dane najstarszej osoby ktora kiedykolwie zatrudniona na kazdym ze stanowisk
select distinct o.d_ur, s.nazwa nazwa_st, o.nazwisko, o.imie1 
from OSOBY o join zatrudnienia z on o.id_os=z.id_os join stanowiska s on z.id_s=s.id_s
where o.d_ur=(select min(o1.d_ur) 
			from osoby o1 join zatrudnienia z1 on o1.id_os=z1.id_os join stanowiska s1 on z1.id_s=s1.id_s
			where s.nazwa=s1.nazwa);

--dla poszczegolnych liter alfabetu pisanych duza litera wyswietlic dane osoby o najdluzszym imieniu zaczynajacym sie na ta litere
select UPPER(SUBSTR(imie1, 1, 1)), IMIE1||''||nazwisko 
from OSOBY o
where length(o.imie1)=(select max(length(o1.imie1)) 
                      from osoby o1
                      where upper(substr(o.imie1,1,1))=upper(substr(o1.imie1,1,1)));

--1) wyswietlic dla kazdej plci drugie co do wieku osoby z tabeli osoby.
--2) wyswietlic nazwe wydzialow i srednia z aktualnie pobieranych pensji przy czym nie wyswietlac wydzialu na ktorym ta srednia jest najwieksza
--3) |^ nie wyswietlac 2 wydzialow z najwiekszymi srednimi

--wyswietlic nazwe wydzialow i srednia z aktualnie pobieranych pensji przy czym nie wyswietlac wydzialu na ktorym ta srednia jest najwieksza nie wyswietlac 2 wydzialow z najwiekszymi srednimi
create or replace view srednia as 
	Select w.nazwa naz, avg(z.pensja) sred 
	from wydzialy w join zatrudnienia z on z.id_w=w.id_w
	where z.do is null
	group by w.nazwa;
with srednia2 as(
	select naz, sred
	from srednia
	where sred<>(select max(srednia)
				from srednia)
	select naz, sred
	from srednia2 
	where sred<>(select max(srednia)
				from srednia2)

--wyswietlic dla kazdej plci drugie co do wieku osoby z tabeli osoby.
with wiek as(
	select o.plec, o.nazwisko||' '||o.imie1 osoba, o.d_ur
	from osoby o
	where o.d_ur<>(select min(o1.d_ur)
				   from osoby o1
				   where o1.plec=o.plec)
)
select w.plec, w.osoba, w.d_ur
from wiek w
where w.d_ur=(Select min(w1.d_ur)
				from wiek w1
				where w1.plec=w.plec);



--wyswietlic dla kazdej plci drugie co do wieku osoby z tabeli osoby.
with wiek as(
	select o.plec, o.nazwisko||' '||o.imie1 osoba, o.d_ur
	from osoby o
	where o.d_ur<>(select min(o1.d_ur)
				   from osoby o1
				   where o1.plec=o.plec)
)
select w.plec, w.osoba, w.d_ur
from wiek w
where w.d_ur=(Select min(w1.d_ur)
			from wiek w1
			where w1.plec=w.plec);


--222) bloki anonimowe
--napisac kod bloku anonimowego pl/sql za pomoca ktorego tabeli osoby bedzie mozna wybrac osobe o okreslonym nazwisku i imieniu (nazwisko lis, imie1 jan) ktore to dane beda zadeklarowane poprzez zainicjowanie sekcji deklaracji odpowiednich zmiennych pl/sql. wykonanie bloku powinno wyswietlic komunikat tresci: osoba lis jan ma id = ?
SET SERVEROUTPUT ON
DECLARE
	o_Id NUMBER;
	o_Imie1 VARCHAR(50):='JAN';
	o_Nazwisko VARCHAR(50):='lis';
BEGIN
	SELECT id_os, nazwisko, imie1
	INTO o_Id, o_Imie1, o_Nazwisko
	FROM osoby
	WHERE nazwisko=o_Nazwisko and imie1=o_Imie1;
	DBMS_OUTPUT.PUT_LINE('osoba '||o_Nazwisko||' '||o_Imie1||' ma id = '||o_Id);
END;


--ZA POMOCA KTORE WYSWIETLI SIE NASTEPUJACY KOMUNIKAT najmlodszym  kierownikiem jest '?nazwisko ?imie1 kierwonik wydzialu ?wydzial

SET SERVEROUTPUT ON
DECLARE
	y_nazwa VARCHAR(50);
	y_nazwisko VARCHAR(54);
	y_imie1 VARCHAR(40);
BEGIN
	SELECT o.nazwisko, o.imie1, w.nazwa
	INTO y_nazwisko, y_imie1, y_nazwa
	FROM wydzialy w join KIEROWNICY ki on w.id_w=ki.ID_W join OSOBY o on ki.ID_OS=o.ID_OS
	where ki.do is null and o.d_ur=(select max(o1.d_ur)
									from OSOBY o1 join KIEROWNICY k2 on o1.id_os=k2.id_os
									where k2.do is null);
	DBMS_OUTPUT.PUT_LINE('najmlodszy kierownik '||y_nazwisko||' '||y_imie1||' kierwonik wydzialu '||y_nazwa);
EXCEPTION
	WHEN NO_DATA_FOUND THEN
		DBMS_OUTPUT.PUT_LINE('osoby brak');
END;

--333) rekordy
--zdefiniowac rekord t_RekordOsoba przy wykorzystaniu ktorego dla osoby ktorej id jest podane poprzez zainicjowanie odpowiedniej zmiennej plsql zostanie wyswietlony komunikat Osoba o id = :id to :nazwisko :imie ur w dniu :d_ur

--zdefiniowac 2 typy rekordowe t_RekordOsoba1 i t_RekordOsoba2 zawierajace nastepujace pola z_id_os, z_nawisko, z_imie1, z_d_ur Nastepnie zadeklarowac po dwie zmienne tych typow r_osoba11, R_osoba 12, r_osoba21, r_osoba22 Do zmiennej r_osoba11 przypisac dane: z_id_os=20, z_nazwisko='Kowalska', z_imie1='Maria', z_d_ur=05/05/1990 Wykonac operacje przypisania tych danych pozosalych zmiennych  Sprawdz najpierw przypisanei agregujace

SET SERVEROUTPUT ON
DECLARE
	TYPE t_rekordOsoba1 is RECORD(
		z_id_os OSOBY.ID_OS%TYPE,
		z_nazwisko OSOBY.NAZWISKO%TYPE,
		z_imie1 OSOBY.IMIE1%TYPE,
		z_d_ur OSOBY.D_UR%TYPE
	);
	TYPE t_rekordOsoba2 is RECORD(
		z_id_os OSOBY.ID_OS%TYPE,
		z_nazwisko OSOBY.NAZWISKO%TYPE,
		z_imie1 OSOBY.IMIE1%TYPE,
		z_d_ur OSOBY.D_UR%TYPE
	);
	r_osoba11 t_rekordOsoba1;
	r_osoba12 t_rekordOsoba1;
	r_osoba21 t_rekordOsoba2;
	r_osoba22 t_rekordOsoba2;
BEGIN
	r_osoba11.z_id_os:=31;
	r_osoba11.z_nazwisko:='Kowalska';
	r_osoba11.z_imie1:='Maria';
	r_osoba11.z_d_ur:=TO_DATE('05/05/1990','DD/MM/YYYY');
	r_osoba12:=r_osoba11;
	DBMS_OUTPUT.PUT_LINE('Osoba o id = ' ||r_osoba12.z_id_os|| ' to '||r_osoba12.z_nazwisko||' '||r_osoba12.z_imie1|| ' d_ur '||r_osoba12.z_d_ur);
END;

--wstawic do tabeli osoby nastepujcy rekord danych id_os=31 nazwisko='Pawlowska' imie1='Monika' d_ur=23/05/1992 plec='K' Wstawianie wiersza danych do tabeli sql przeprowadzic za pomoca typu rekordowego Zatwierdzic w sposob jawny powyzsza operacje

SET SERVEROUTPUT ON
DECLARE
	TYPE t_rekordOsoba1 is RECORD(
		z_id_os OSOBY.ID_OS%TYPE,
		z_nazwisko OSOBY.NAZWISKO%TYPE,
		z_imie1 OSOBY.IMIE1%TYPE,
		z_imie2 OSOBY.IMIE2%TYPE,
		z_d_ur OSOBY.D_UR%TYPE,
		z_plec OSOBY.PLEC%TYPE
	);

	r_osoba11 t_rekordOsoba1;
BEGIN
	r_osoba11.z_id_os:=31;
	r_osoba11.z_nazwisko:='Pawlowska';
	r_osoba11.z_imie1:='Monika';
	r_osoba11.z_imie2:='';
	r_osoba11.z_d_ur:=TO_DATE('23/05/1992','DD/MM/YYYY');
	r_osoba11.z_plec:='K';
	INSERT INTO OSOBY VALUES r_osoba11;
	COMMIT;
END;

--z wykorzystaniem typu rekordowego poprawic bledny rekord danych wstawiony do tabeli osoby nazwisko:=pelczewska imie:=marta

SET SERVEROUTPUT ON
DECLARE
	TYPE t_rekordOsoba1 is RECORD(
		z_id_os OSOBY.ID_OS%TYPE,
		z_nazwisko OSOBY.NAZWISKO%TYPE,
		z_imie1 OSOBY.IMIE1%TYPE,
		z_imie2 OSOBY.IMIE2%TYPE,
		z_d_ur OSOBY.D_UR%TYPE,
		z_plec OSOBY.PLEC%TYPE
	);

	r_osoba11 t_rekordOsoba1;

BEGIN
	r_osoba11.z_id_os:=31;
	r_osoba11.z_nazwisko:='Pelczewska';
	r_osoba11.z_imie1:='Marta';
	r_osoba11.z_imie2:='';
	r_osoba11.z_d_ur:=TO_DATE('23/05/1994','DD/MM/YYYY');
	r_osoba11.z_plec:='K';
	UPDATE OSOBY SET ROW = r_osoba11 where ID_OS=r_osoba11.z_id_os;
	COMMIT;
END;

--napisac kod bloku anonimowego plsql w ktorym wyswietli sie nastepujacy komunikat : Osoba o id=1 to :lis :jan ktory ma inicjaly L.J. Nalezy zdefiniowac odpowiedni podtyp do przechowywania inicjalow osoby
SET SERVEROUTPUT ON
DECLARE
	TYPE t_rekordOsoba1 is RECORD(
		z_id_os OSOBY.ID_OS%TYPE,
		z_nazwisko OSOBY.NAZWISKO%TYPE,
		z_imie1 OSOBY.IMIE1%TYPE,
		z_imie2 OSOBY.IMIE2%TYPE,
		z_d_ur OSOBY.D_UR%TYPE,
		z_plec OSOBY.PLEC%TYPE
	);
	SUBTYPE t_inicjaly is Varchar(4);
	r_osoba11 t_rekordOsoba1;
	r_inicjaly t_inicjaly;
BEGIN
	r_osoba11.z_id_os:=1;
	Select nazwisko, imie1, UPPER(SUBSTR(nazwisko, 1, 1))||'.'||UPPER(SUBSTR(imie1, 1, 1))||'.'
	INTO r_osoba11.z_nazwisko, r_osoba11.z_imie1, r_inicjaly
	FROM OSOBY
	WHERE r_osoba11.z_id_os=id_os;
	DBMS_OUTPUT.PUT_LINE('osoba o id '||r_osoba11.z_id_os||' imie'||r_osoba11.z_imie1||' ma inicjaly '||r_inicjaly);
END;

--444) if case
--napisac kod bloku anonimowegho w jezyku plsql za pomoca ktorego dla osoby ktore id jest zainicjowane wartoscia zmiennej plsql zostanie wyswietlony komunikat dotyczacy sumy dlogosci jej nazwiska i imienia a mianowcie gdy ta suma dlugosci mniejsza od 10 komunikat brzmi "osoba o malej sumie dlugosci nazwiska i imienia" gdy od 10 do 15 "osoba o duzej dlugosci nazwiska i imienia" a ponad " osoba o bardzo duzej dlugosci nazwiska i imienia"

SET SERVEROUTPUT ON
DECLARE
	z_Id NUMBER;
	z_length number;
	z_osoba VARCHAR(100);
BEGIN
	z_id:=1;
	SELECT LENGTH(nazwisko||''||imie1), INITCAP(nazwisko)||' '||INITCAP(imie1)
	INTO z_length, z_osoba
	FROM osoby
	WHERE id_os=z_id;
	if z_length<10 then
		DBMS_OUTPUT.PUT_LINE('osoba o malej sumie dlugosci nazwiska i imienia '||z_osoba||' o id '||z_Id);
	elsif z_length>=10 and z_length<=15 then
		DBMS_OUTPUT.PUT_LINE('osoba o duzej dlugosci nazwiska i imienia '||z_osoba||' o id '||z_Id);
	else
		DBMS_OUTPUT.PUT_LINE('osoba o bardzo duzej dlugosci nazwiska i imienia '||z_osoba||' o id '||z_Id);
	end if;
END;

--napisac program w plsql ktory dla wybranej osoby podanej poprzez zainicjowanie zmiennej plsqsl wartosc jej id wyswietli komunikat wykorzystac case sprawdzajacy

SET SERVEROUTPUT ON
DECLARE
	z_Id NUMBER;
	z_date VARCHAR(2);
	z_osoba VARCHAR(100);
BEGIN
	z_id:=1;
	SELECT INITCAP(nazwisko)||' '||INITCAP(imie1), TO_CHAR(D_UR, 'mm')
	INTO z_osoba, z_date
	FROM osoby
	WHERE id_os=z_id;
	CASE z_date
	when '01' then
		DBMS_OUTPUT.PUT_LINE('osoba '||z_osoba||' styczniu');
	when '02' then
		DBMS_OUTPUT.PUT_LINE('osoba '||z_osoba||' lutym');
	when '03' then
		DBMS_OUTPUT.PUT_LINE('osoba '||z_osoba||' marcu');
	when '04' then
		DBMS_OUTPUT.PUT_LINE('osoba '||z_osoba||' kwietniu');
	when '05' then
		DBMS_OUTPUT.PUT_LINE('osoba '||z_osoba||' maju');
	when '06' then
		DBMS_OUTPUT.PUT_LINE('osoba '||z_osoba||' czerwcu');
	when '07' then
		DBMS_OUTPUT.PUT_LINE('osoba '||z_osoba||' lipcu');
	when '08' then
		DBMS_OUTPUT.PUT_LINE('osoba '||z_osoba||' sierpniu');
	when '09' then
		DBMS_OUTPUT.PUT_LINE('osoba '||z_osoba||' wrzesniu');
	when '10' then
		DBMS_OUTPUT.PUT_LINE('osoba '||z_osoba||' pazdzierniku');
	when '11' then
		DBMS_OUTPUT.PUT_LINE('osoba '||z_osoba||' listopadzie');
	else
		DBMS_OUTPUT.PUT_LINE('osoba '||z_osoba||' grudzieniu');
	end case;
END;

--napisac program w plsql ktory dla wybranej osoby podanej poprzez zainicjowanie zmiennej plsqsl wartosc jej id wyswietli komunikat wykorzystac case sprawdzajacy case wyszukujacy 1: pensja ponizej 1000, 2: 1001-1500, 3: 1501-2000; ... 12: >6000

SET SERVEROUTPUT ON
DECLARE
	z_Id NUMBER;
	z_osoba VARCHAR(100);
	z_pensja ZATRUDNIENIA.PENSJA%TYPE;
	z_grupa VARCHAR(1);
BEGIN
	z_id:=2;
	SELECT INITCAP(o.nazwisko)||' '||INITCAP(o.imie1), PENSJA
	INTO z_osoba, z_pensja
	FROM osoby o join zatrudnienia z on o.id_os=z.id_os
	WHERE o.id_os=z_id and z.do is null;
	CASE 
	when z_pensja<=1000 then
		z_grupa:='1';
	when z_pensja>1000 and z_pensja<=1500 then
		z_grupa:='2';
	when z_pensja>1500 and z_pensja<=2000 then
		z_grupa:='3';
	when z_pensja>2000 and z_pensja<=3000 then
		z_grupa:='4';
	else
		DBMS_OUTPUT.PUT_LINE('inna grupa');
	end case;
	DBMS_OUTPUT.PUT_LINE(z_grupa||' grupa');
END;

--napisac kod bloku anonimowego plsql ktory wyswietli lis jan inicjaly L.J.
SET SERVEROUTPUT ON
DECLARE
	z_Id NUMBER:=1;
	z_osoba VARCHAR(100);
	z_pensja ZATRUDNIENIA.PENSJA%TYPE;
	z_grupa VARCHAR(1);
	SUBTYPE t_inicjaly is Varchar(4);
	z_inicjaly t_inicjaly;
	z_count number;
BEGIN
	select count(id_os)
	into z_count
	from osoby;
	LOOP
		SELECT UPPER(SUBSTR(nazwisko, 1, 1))||'.'||UPPER(SUBSTR(imie1, 1, 1))||'.', INITCAP(nazwisko)||' '||INITCAP(imie1)
		INTO z_inicjaly, z_osoba
		FROM osoby
		WHERE id_os=z_id;
		DBMS_OUTPUT.PUT_LINE(z_id||' '||z_osoba||' inicjaly '||z_inicjaly);
		z_id:=z_id+1;
		exit when z_id>z_count;
	end Loop;  
END;

--555) kursor z petla prosta

--wyswieltic alfabetyczna liczbe osob z tabeli osoby wraz z ich inicjalami wykorzystujac kursor jawnyi petle prosta
SET SERVEROUTPUT ON
DECLARE
	SUBTYPE t_inicjaly is VARCHAR2(4);
	z_inicjaly t_inicjaly;
	z_imie1 VARCHAR2(200);
	z_nazwisko VARCHAR2(200);
	CURSOR osoby IS
		SELECT UPPER(SUBSTR(nazwisko, 1, 1))||'.'||UPPER(SUBSTR(imie1, 1, 1))||'.', nazwisko, imie1
		FROM OSOBY
		ORDER BY NAZWISKO ASC;
BEGIN
	OPEN osoby;
	LOOP
		FETCH osoby INTO z_inicjaly, z_nazwisko, z_imie1;
		EXIT WHEN osoby%NOTFOUND;
		DBMS_OUTPUT.PUT_LINE(z_nazwisko||' '||z_imie1||' inicjaly '||z_inicjaly);
	END LOOP;
	CLOSE osoby;
END;

--Z PETLA WHILE TO GORNE
SET SERVEROUTPUT ON
DECLARE
	SUBTYPE t_inicjaly is VARCHAR2(4);
	z_inicjaly t_inicjaly;
	z_imie1 VARCHAR2(200);
	z_nazwisko VARCHAR2(200);
	CURSOR osoby IS
		SELECT UPPER(SUBSTR(nazwisko, 1, 1))||'.'||UPPER(SUBSTR(imie1, 1, 1))||'.', nazwisko, imie1
		FROM OSOBY
		ORDER BY NAZWISKO ASC;
BEGIN
	OPEN osoby;
	FETCH osoby INTO z_inicjaly, z_nazwisko, z_imie1;
	WHILE osoby%FOUND LOOP
		DBMS_OUTPUT.PUT_LINE(z_nazwisko||' '||z_imie1||' inicjaly '||z_inicjaly);
		FETCH osoby INTO z_inicjaly, z_nazwisko, z_imie1;
	END LOOP;
	CLOSE osoby;
END;

--NAPISAC BLOK ANONIMOWY Z KUIRSOREM JAWNYM UMOZLIWIAJACYM WYSWITLENIE NAZWY WYDZIALU LITERY ALFABETU ORAZ LISCZBY OSOB AKTUALNIE ZATRUDNIONYCH NA POSZCZEGOLNYCH WYDZIALACH ktorych imie zaczyna sie na dana litere

SET SERVEROUTPUT ON
DECLARE
	z_wydzial VARCHAR2(200);
	z_liter char(1);
	z_count int;
	CURSOR wydzialy IS
		SELECT INITCAP(w.nazwa), UPPER(SUBSTR(o.IMIE1, 1, 1)), count(z.id_os)
		FROM OSOBY o join ZATRUDNIENIA z on o.id_os=z.id_os join WYDZIALY w on z.id_w=w.id_w
		WHERE z.do is null
		GROUP BY w.nazwa, UPPER(SUBSTR(o.IMIE1, 1, 1));
BEGIN
	OPEN wydzialy;
	FETCH wydzialy INTO z_wydzial, z_liter, z_count;
	WHILE wydzialy%FOUND LOOP
		DBMS_OUTPUT.PUT_LINE(z_wydzial||' '||z_liter||' '||z_count);
		FETCH wydzialy INTO z_wydzial, z_liter, z_count;
	END LOOP;
	CLOSE wydzialy;
END;

--NAPISAC BLOK ANONIMOWY Z KUIRSOREM JAWNYM UMOZLIWIAJACYM wyswieltanie do tabeli osoby_short osob ktore zostaly najpozniej zatrudnione na nazdym z wydzialowCREATE TABLE osoby_short as 
select w.nazwa, o.id_os, o.nazwisko, o.imie1, o.imie2, d_ur, plec, z.od
from osoby o join zatrudnienia z on o.id_os=z.id_os join wydzialy w on z.ID_W=w.ID_W;


SET SERVEROUTPUT ON
DECLARE
	type osoba is record(
	z_nawa VARCHAR2(255),
	z_nazwisko VARCHAR2(255),
	z_imie VARCHAR2(255),
	z_imie2 VARCHAR2(255),
	z_ur DATE,
	z_od DATE,
	z_id_os INT);
	z_osoba osoba;
	CURSOR osoby_s IS
		select w.nazwa, o.id_os, o.nazwisko, o.imie1, o.imie2, d_ur, plec, z.od
		FROM OSOBY o join ZATRUDNIENIA z on o.id_os=z.id_os join WYDZIALY w on z.id_w=w.id_w
		WHERE z.od = ( SELECT max(z.od)
					  FROM wydzialy w join ZATRUDNIENIA z1 on o1.id_os=z1.id_os
					  WHERE z.na);
BEGIN
	OPEN wydzialy;
	FOR z_osoba in osoby_s LOOP
		DBMS_OUTPUT.PUT_LINE(z_wydzial||' '||z_liter||' '||z_count);
		FETCH wydzialy INTO z_wydzial, z_liter, z_count;
	END LOOP;
	CLOSE wydzialy;
END;

--666) kursor petli for 
--napisac kod bloku anonimowego plsql z kursorem jawnym liwiajacy wyswietlanie dla poszczegolnych wydzialow komunikatu "aktualnym kierownikiem wydzialu matematyki od dnia 1.2.2222 jest janek"	
SET SERVEROUTPUT ON
DECLARE
	CURSOR kier IS
		SELECT w.nazwa, k1.od, INITCAP(o.imie1)||' '||INITCAP(o.nazwisko) osoba, w.ID_W
		FROM OSOBY o join KIEROWNICY k1 on o.id_os=k1.id_os join WYDZIALY w on k1.id_w=w.id_w
		WHERE do is null
		ORDER BY w.nazwa ASC;
	z_nazwa WYDZIALY.NAZWA%TYPE;
BEGIN
	FOR z_kierownik in kier LOOP
		CASE z_kierownik.id_w
			WHEN '1' THEN z_nazwa:='Matematyki';
			WHEN '2' THEN z_nazwa:='Fizyki';
			WHEN '3' THEN z_nazwa:='Prawa';
			WHEN '4' THEN z_nazwa:='Ekonomii';
			WHEN '5' THEN z_nazwa:='Filologi';
			WHEN '6' THEN z_nazwa:='Biologi';
			ELSE z_nazwa:='BRAK';
		END CASE;
		DBMS_OUTPUT.PUT_LINE('aktualnym kierownikiem wydzialu '||z_nazwa||' od dnia '||z_kierownik.od||' jest '||z_kierownik.osoba);
	END LOOP;
END;

--NAPISAC BLOK ANONIMOWY Z KUIRSOREM JAWNYM UMOZLIWIAJACYM wyswieltanie do tabeli osoby_short osob ktore zostaly najpozniej zatrudnione na nazdym z wydzialow

CREATE TABLE osoby_short as
select w.nazwa, o.id_os, o.nazwisko, o.imie1, plec, z.od
from osoby o join zatrudnienia z on o.id_os=z.id_os join wydzialy w on z.ID_W=w.ID_W;

SET SERVEROUTPUT ON
DECLARE
	CURSOR osoby_s IS
		select w.nazwa, o.id_os, o.nazwisko, o.imie1, o.imie2, d_ur, plec, z.od
		FROM OSOBY o join ZATRUDNIENIA z on o.id_os=z.id_os join WYDZIALY w on z.id_w=w.id_w
		WHERE z.od = ( SELECT max(z1.od)
					  FROM wydzialy w1 join ZATRUDNIENIA z1 on w1.id_w=z1.id_w
					  WHERE w.nazwa=w1.nazwa and do is null);
BEGIN
	DELETE FROM OSOBY_SHORT;
	FOR z_osoba in osoby_s LOOP
		INSERT INTO OSOBY_SHORT VALUES z_osoba;
	END LOOP;
END;

--napisac kod bloku anonimowego plsql z kursorem jawnym z blokada ktorego zadaniem jest podniesienie pensji wszystkim aktualnie zatrudnionym mezczyzna o 10% jawnie zatwierdzic
SET SERVEROUTPUT ON
DECLARE
	CURSOR osoby_s IS
		select z.pensja
		FROM osoby o join zatrudnienia z on o.ID_OS=z.ID_OS
		where z.do is null and o.plec='M'
		FOR UPDATE of z.pensja;
BEGIN
	FOR z_osoba in osoby_s LOOP
		UPDATE zatrudnienia 
		  SET pensja = pensja * 1.1
		  WHERE CURRENT OF osoby_s;
	END LOOP;
	COMMIT;
END;
lub select 
	select z.id_os, z.pensja
	FROM zatrudnienia z
	where z.id_os in (select z.pensja
						from osoby o1 join zatrudnienia z1 on o1.id_os=z1.id_os
						where o.plec='M' and z1.do is null)
		FOR UPDATE of z.pensja;

--napisac kod bloku anonimowego plsql z kursorem jawnym z uzyciem for z etykietami za pomoca ktoerego bedzie wyswietlona lista osob na wydzialach w nastepujacy sposob "lista osob zatrudnionych na wydziale matematyki 
--1. lis jan 2.zenek itd"

--mamy 10tys zl na podwyzke dla wszystkich aktualnie zatrudnionych osob przy czym kazda z nich ma otrzymac te sama kwote podwyzki zaprojektowac blok kodu anonimowegho plsql z kursorem jawnym z blokada ktory zrealizuje te operacje. operacje nalezy w sposob jawny zatwierdzic

SET SERVEROUTPUT ON
DECLARE
	CURSOR pensje IS
		select pensja 
		from zatrudnienia 
		where do is null
		for update of pensja;
	liczba number;
BEGIN
	select count(id_os)
	into liczba
	from ZATRUDNIENIA
	where do is null;
	liczba := 10000/liczba;
	DBMS_OUTPUT.PUT_LINE(liczba);
	FOR z_osoba in pensje loop
		update zatrudnienia 
		set pensja = pensja + liczba
		where current of pensje;
	end loop;
	commit;
end;

--mamy dokonac podwyzki pensji wszystkim osobom aktualnie zatrudnionym na kazdym z wydzialow kazda z nich ma otrzymac taka kwote podwyzki jaka wynika z okresu jej pracy w aktualnym miejscu zatrudnienia (tzn za kazdy pelny przepracowany rok ktualnym miejscu zatrudnienia osoba dostaje podwyzke w wysokosci 0,5% kwotty aktualnej pensji)

SET SERVEROUTPUT ON
DECLARE
	CURSOR pensje IS
		select pensja, TRUNC(MONTHS_BETWEEN(SYSDATE, od)/12) rok
		from zatrudnienia 
		where do is null
		for update of pensja;
BEGIN
	FOR z_pensje in pensje loop
		if z_pensje.rok>=1 then     
			update zatrudnienia 
			set pensja = pensja + pensja * (z_pensje.rok * 0.05)
			where current of pensje;
		end if;
	end loop;
	commit;
end;

--napisac kod bloku anonimowego plsql ktory umozliwi wykorzystanie wewnetrznego rowid-a poszczegolnych przetwarzanych rokordow
--a) wprowadzic do tabeli osoby przykladowy rekord danych 32 tomczyk monika 21.05.1987 k i wydrukowac rowid tego rekordu
--b) wykorzystujac rowid tego rekordu dokonac jego aktualizacji tj blednie wstawionej daty urodzenia 12.05.1987 i wydrukowac dane osoby przetwarzanej kursorem niejawnym update
--c) wykorzystujac rowid usunac wprowadzony wiersz drukujac id osoby usuwanej
SET SERVEROUTPUT ON
DECLARE
	z_rowid ROWID;
	data_ur date;
	z_id number;
BEGIN
	insert into osoby(id_os, nazwisko, imie1, d_ur, plec)
	values(32, 'tomczyk', 'monika', TO_DATE('21/05/1987','DD/MM/RRRR'), 'K')
	returning rowid into z_rowid;
	DBMS_OUTPUT.PUT_LINE('Identyfikator rowid nowego wiersza to: '||z_rowid);
	
	update osoby 
	set d_ur=TO_DATE('12/05/1987','DD/MM/RRRR')
	where rowid = z_rowid
	returning d_ur into data_ur;
	DBMS_OUTPUT.PUT_LINE('zmieniopno na '||data_ur);

	delete from osoby 
	where ROWID=z_rowid
	returning id_os into z_id;
	DBMS_OUTPUT.PUT_LINE('usunieto '||z_id);
end;

--777) exception
SET SERVEROUTPUT ON
DECLARE
	nazwisko osoby.nazwisko%type;
	imie1 osoby.imie1%type;
	lata number;
	x number:=50;
BEGIN
	select nazwisko, imie1, TRUNC(MONTHS_BETWEEN(SYSDATE, od)/12) rok
	into nazwisko, imie1, lata
	from OSOBY o join zatrudnienia z on o.id_os=z.id_os
	where do is null and x<TRUNC(MONTHS_BETWEEN(SYSDATE, od)/12);
EXCEPTION
	when No_Data_found then
		DBMS_OUTPUT.PUT_LINE('nie znaleziono');
	when too_many_rows then
		DBMS_OUTPUT.PUT_LINE('za duzo wynikow');
	when others then 
		DBMS_OUTPUT.PUT_LINE('blad '||SQLCODE||' '||SQLERRM);
end;

--zaprojektowac kod bloku anonimowego plsql w ktorym nalezy sprawdzic czy maksymalna aktualnie wyplacana pensja nie przekracza dopuszczalnego progu jezeli przekracza ma sie pojawic komunikat

SET SERVEROUTPUT ON
DECLARE
	zaDuzaPensja exception;
	zpensja number;
	x number:=50;
BEGIN
	select max(pensja) 
	into zpensja
	from zatrudnienia
	where do is null;
	if zpensja>3000 then 
		RAISE zaDuzaPensja;
	end if;
EXCEPTION
	when zaDuzaPensja then
		DBMS_OUTPUT.PUT_LINE('za duza pensja '|| zpensja);
	when others then 
		DBMS_OUTPUT.PUT_LINE('blad '||SQLCODE||' '||SQLERRM);
end;

--do bazy zostala wprowadzona osoba o id 31 karp janus 15/03/1971 m i jej zatrudnienie 31 31 21/03/1970 21/01/1969 3500 2 2 nalezy zaprojektowa obsluge wyjatkow za pomoca komunikatow jak stale ktore obsluza nam pojawiace sie bledy a)data urodzenia jest pozniejsza niz zatrudnienia b) data urodzenia jest pozniejsza niz zwolnienia c) data urodzenia jest pozniejsza niz zatrudnienia i data zatrudnienia jest pozniejsza niz data zatrudnienia

insert into OSOBY(id_os, nazwisko, imie1, d_ur, plec) values (31, 'karp', 'janek', TO_DATE('15/03/1971', 'DD/MM/RRRR'), 'M');
insert into zatrudnienia(id_z, ID_OS, od, do, id_w, pensja, id_s) values (38, 31, TO_DATE('21/03/1970', 'DD/MM/RRRR'), TO_DATE('21/03/1969', 'DD/MM/RRRR'), 2, 3500, 2);

SET SERVEROUTPUT ON
DECLARE
	data_ur_ex exception;
	od_ex exception;
	daty_ex EXCEPTION;
	zod date;
	zdo date;
	zD_ur date;
BEGIN
	select z.od, z.do, o.d_ur
	into zod, zdo, zD_ur
	from osoby o join zatrudnienia z on o.id_os=z.id_os
	where o.id_os=31;
	if zD_ur>zod and zD_ur>zdo then
		raise daty_ex;
	elsif zD_ur>zdo then
		raise od_ex;
	elsif zD_ur>zod then
		raise do_ex;
	end if;
EXCEPTION
	when daty_ex then
		DBMS_OUTPUT.PUT_LINE('');
	when od_ex then
		DBMS_OUTPUT.PUT_LINE('');
	when do_ex then
		DBMS_OUTPUT.PUT_LINE('');
	when others then 
		DBMS_OUTPUT.PUT_LINE('blad '||SQLCODE||' '||SQLERRM);
end;

--za pomoca ktore na poszczegolnych wydzialach ustawionych alfabetycznie wyswietli nam sie dla kazdej litery alfabetu liczba osob o imieniu na dana litere ktore te osoby sa zatrudniona na danym wydziale w razie braku powinno sie wyswietlic 0 
--888) podprogramy

SET SERVEROUTPUT ON
CREATE OR REPLACE procedure p_licznik(
	z_licznik out number,
	z_plec in OSOBY.plec%TYPE
) as
begin
	Select count(id_os)
	into z_licznik
	from osoby
	where PLEC=z_plec;
end p_licznik;

CREATE OR REPLACE FUNCTION f_licznik(
	z_plec OSOBY.plec%TYPE
) return int is
	z_licznik int;
begin
	Select count(id_os)
	into z_licznik
	from osoby
	where PLEC=z_plec;
	return z_licznik;
end f_licznik;

Declare
	licznik number;
	x_plec OSOBY.plec%type:='K'; 
BEGIN
	p_licznik(licznik,x_plec);
	DBMS_OUTPUT.PUT_LINE(licznik);
	licznik:=f_licznik(x_plec);
	DBMS_OUTPUT.PUT_LINE(licznik);
END;

--zaprojektowac procedure wprwadzania nowej osoby do tabeli osoby przy czym nalezy zaprojektowac osbluge bledu polegajacego na wprowadzeniu osoby juz wprowadzonej od tabeli
create or replace procedure p_addOsoba(
	z_id_os OSOBY.ID_OS%TYPE,
	z_nazwisko OSOBY.NAZWISKO%TYPE,
	z_imie1 OSOBY.IMIE1%TYPE,
	z_imie2 OSOBY.IMIE2%TYPE,
	z_d_ur OSOBY.D_UR%TYPE,
	z_plec OSOBY.PLEC%TYPE
)as
	duplikat EXCEPTION;
	z_count number;
begin
	select count(id_os)
	into z_count
	from osoby
	where ID_OS=z_id_os;

	if z_count > 0 then
		raise duplikat;
	end if;

	INSERT into OSOBY (id_os, nazwisko, imie1, imie2, d_ur, plec) values (z_id_os, z_nazwisko, z_imie1, z_imie2, z_d_ur, z_plec);
	commit;
exception
	when duplikat then
		DBMS_OUTPUT.PUT_LINE('juz jest');
end p_addOsoba;

SET SERVEROUTPUT ON
begin
	P_ADDOSOBA(1,'lis','JAN',null,TO_DATE('78/10/21','rrrr/mm/dd'),'M');
end;

--funkcja z wiecej niz 1 returnem ktora dla zadanego wydzialu wyswietli nam komunikat o procencie aktualnie zatrudnionych im osob w stosunku do wszystkich aktualnych zatrudnionych osob "wydzial 'x' zatrudnia od x% do x% wszystkich zarudnionych" osbluga wyjatu "wydzial mateamtyki nikogo nie zatrudnia"

create or replace FUNCTION f_wydzialy(
	z_wydzial WYDZIALY.NAZWA%TYPE
) return VARCHAR2 is
	z_procent number:=0;
	z_ogolnie number;
	z_na_wydziale number;
	pusto exception;
begin
	Select count(z.id_os)
	into z_ogolnie
	from zatrudnienia z  
	where do is null;

	select count(z.id_os)
	into z_na_wydziale
	from zatrudnienia z join wydzialy w on z.id_w=z.id_w
	where do is null and INITCAP(w.NAZWA)=INITCAP(z_wydzial);

	z_procent:=(z_na_wydziale/z_ogolnie)*100;

	if z_procent>0 and z_procent<25 then
		return 'wydzial '||z_wydzial||' zatrudnia od 1% do 24% wszystkich zarudnionych';
	elsif z_procent>=25 and z_procent<50 then
		return 'wydzial '||z_wydzial||' zatrudnia od 25% do 49% wszystkich zarudnionych';
	elsif z_procent>=50 and z_procent<75 then
		return 'wydzial '||z_wydzial||' zatrudnia od 50% do 74% wszystkich zarudnionych';
	elsif z_procent>=75 then
		return 'wydzial '||z_wydzial||' zatrudnia od 75% do 100% wszystkich zarudnionych';
	else
		raise pusto;
	end if;
	return z_procent;
exception
	when pusto then
		DBMS_OUTPUT.PUT_LINE('wydzial '||z_wydzial||' nikogo nie zatrudnia');
end f_wydzialy;

SET SERVEROUTPUT ON
begin
	DBMS_OUTPUT.PUT_LINE(f_wydzialy('matematyka'));
end;

--999) pakiety
--zaprojektowac pakiet zawierajacy procedure wprowadzania nowej osoby do tabeli osoby przy czym musi ona zawierac obsluge bledu iz taki id_osoby juz jest wprowadzony do tabeli osoby oraz oraz obsluge bledu iz taka osoba mogla zostac wprowadzona do tabeli pod innym id. 
--Procedure usuwania osoby z tabeli osoby przy czym musi ona zawierac osbsluge globalnie zadeklarowaniego bledu nie znalezienia rekordu do usuniecia. 
--Procedure wyswietlajaca alfabetycznie liste osob aktualnie zatrudnonych na wydziale: lista osob zatrudnionych na wydziale - wydzial matematyka: 1. .... 2. .... przy czym procedura ma zwracac liczbe aktualnie zatrudnionych osob na wydziale.
--Funkcje ktora ma zwracac liczbe osob aktualnie zatrudnionych na danym stanowisku.
--Utworzyc druga procedure o tej samej nazwie lecz z parametrem wejsciowym id_w ktory wyswietli nam liste aktualnie zatrudnionych osob (przeciazenie podprogramu w pakiecie)

create or replace PACKAGE pakiet as
    Procedure dodajOsobe(p_id in osoby.id_os%type,
                      p_imie1 in osoby.imie1%type,
                      p_imie2 in osoby.imie2%type,
                      p_nzawisko in osoby.nazwisko%type,
                      p_d_ur in osoby.d_ur%type,
                      p_plec in osoby.plec%type);
    Procedure usunOsobe(p_id in osoby.id_os%type);
    w_juzIstnieje Exception;
	w_nieZnaleziono Exception;
	Procedure wypisz(p_wydzial in wydzialy.nazwa%type,
					p_liczbaOsoby out number);
	Procedure wypisz(p_id_w in wydzialy.id_w%type,
					p_liczbaOsoby out number);
	Function osobyNaStanowisku(p_nazwa in stanowiska.nazwa%type,
								p_plec in osoby.plec%type) return NUMBER;
end pakiet;

create or replace PACKAGE BODY pakiet as
    Procedure dodajOsobe(p_id in osoby.id_os%type,
						p_imie1 in osoby.imie1%type,
						p_imie2 in osoby.imie2%type,
						p_nzawisko in osoby.nazwisko%type,
						p_d_ur in osoby.d_ur%type,
						p_plec in osoby.plec%type) AS
						CURSOR wszystkieOsoby IS
						Select * from osoby; 
	BEGIN 
		FOR osoba in wszystkieOsoby loop
		  if osoba.imie1=p_imie1 and osoba.imie2=p_imie2 and osoba.nazwisko=p_nzawisko and osoba.d_ur=p_d_ur and osoba.plec=p_plec then
			raise w_juzIstnieje;
		  end if;
		end loop;

		INSERT INTO osoby (id_os, nazwisko, imie1, imie2, d_ur, plec)
		VALUES(p_id, p_nzawisko, p_imie1, p_imie2, p_d_ur, p_plec);
		COMMIT;
	EXCEPTION
		when DUP_VAL_ON_INDEX or w_juzIstnieje then
		  DBMS_OUTPUT.PUT_LINE('Juz istnieje');
	end dodajOsobe;

	Procedure usunOsobe(p_id in osoby.id_os%type) as
	BEGIN
		DELETE FROM osoby where id_os=p_id;
		IF SQL%NOTFOUND then
		  raise w_nieZnaleziono;
		end if;
	EXCEPTION
		when w_nieZnaleziono then
		  DBMS_OUTPUT.PUT_LINE('Nie istnieje');
	END usunOsobe;

    Procedure wypisz(p_wydzial in wydzialy.nazwa%type,
					p_liczbaOsoby out number) as
					CURSOR osobyWydzialy is
                        Select * from osoby o join zatrudnienia z on o.id_os=z.id_os join wydzialy w on z.id_w=w.id_w
                        where z.do is null and INITCAP(p_wydzial)=INITCAP(w.nazwa)
                        order by o.nazwisko;
	BEGIN
		p_liczbaOsoby:=0;
		DBMS_OUTPUT.PUT_LINE('Liczba osob zatrudnionych na wydziale '||p_wydzial);
		for osoba in osobyWydzialy loop
			p_liczbaOsoby:=p_liczbaOsoby+1;
			DBMS_OUTPUT.PUT_LINE(p_liczbaOsoby||' '||osoba.nazwisko||' '||osoba.imie1);
		end loop;
	END wypisz;

	Procedure wypisz(p_id_w in wydzialy.id_w%type,
					p_liczbaOsoby out number) as
					CURSOR osobyWydzialy is
                        Select * from osoby o join zatrudnienia z on o.id_os=z.id_os join wydzialy w on z.id_w=w.id_w
                        where z.do is null and w.id_w=p_id_w
                        order by o.nazwisko;
					p_nazwa wydzialy.nazwa%type;
	BEGIN
		select nazwa
		into p_nazwa
		from wydzialy
		where id_w=p_id_w;
		p_liczbaOsoby:=0;
		DBMS_OUTPUT.PUT_LINE('Liczba osob zatrudnionych na wydziale '||p_nazwa);
		for osoba in osobyWydzialy loop
		  p_liczbaOsoby:=p_liczbaOsoby+1;
		  DBMS_OUTPUT.PUT_LINE(p_liczbaOsoby||' '||osoba.nazwisko||' '||osoba.imie1);
		end loop;
	end wypisz;

    Function osobyNaStanowisku(p_nazwa in stanowiska.nazwa%type,
                            p_plec in osoby.plec%type) return NUMBER is
                            CURSOR osobyWydzialy is
                                  Select * from osoby o join zatrudnienia z on o.id_os=z.id_os join stanowiska s on z.id_s=s.id_s
                                  where z.do is null and INITCAP(p_nazwa)=INITCAP(s.nazwa) and p_plec=o.plec;
                            licznik number :=0;
	BEGIN
		for osoba in osobyWydzialy loop
		  licznik:=licznik+1;
		end loop;
		return licznik;
	END osobyNaStanowisku;

end pakiet;

--000) tigery
--zaprojektowac wyzwalacz DML na poziomie wiersza ktory bedzie umozliwial wypelnienie pola klucza glownego tabeli osoby nastepna liczba z sekwencji

CREATE SEQUENCE kolejny
START WITH 31
INCREMENT BY 1;

CREATE OR REPLACE TRIGGER dodajOsobe
BEFORE INSERT ON osoby 
	FOR EACH ROW
BEGIN
	SELECT kolejny.NEXTVAL
	INTO :new.ID_OS
	FROM dual;
end dodajOsobe;

INSERT INTO osoby(imie1, nazwisko, D_UR, plec) values ('imie','nazwisko',TO_DATE('11/11/1695','DD/MM/RRRR'),'M');

--zaprojektowac wyzwalacz dml ktory w sposob ciagly bedzie aktualizowal tabele wydzold ktora zawiera informacje o aktualnie nadluzej procujacej osobie na kazdym wydziale

CREATE TABLE wydzOld AS
SELECT w.nazwa, IMIE1, NAZWISKO, od
FROM OSOBY o join zatrudnienia z on o.id_os=z.id_os join wydzialy w on z.id_w=w.id_w
where do is null and z.od=(SELECT min(z1.od)
                              from zatrudnienia z1 join wydzialy w1 on z1.id_w=w1.id_w
                              where z1.do is null and w.nazwa=w1.nazwa);

CREATE OR REPLACE TRIGGER dodajOsoby
  AFTER DELETE OR INSERT OR UPDATE on zatrudnienia
DECLARE 
	CURSOR najstarsze IS
	SELECT w.nazwa, IMIE1, NAZWISKO, od
	FROM OSOBY o join zatrudnienia z on o.id_os=z.id_os join wydzialy w on z.id_w=w.id_w
	where do is null and z.od=(SELECT min(z1.od)
                              from zatrudnienia z1 join wydzialy w1 on z1.id_w=w1.id_w
                              where z1.do is null and w.nazwa=w1.nazwa);
BEGIN 
	DELETE FROM WYDZOLD;
	FOR iosoba IN najstarsze LOOP
		INSERT INTO WYDZOLD VALUES iosoba;
	END LOOP;
end dodajOsoby;

--zaprojektowac wyzwalacz dml na poziomie wierszy ktory bedzie uniemozliwial zatrudnienie osoby ktora aktualnie jest zatrudniona

create or replace TRIGGER sprawdzb
	BEFORE INSERT OR UPDATE ON zatrudnienia
DECLARE
	z_id_os number;
	juzJEST EXCEPTION;
BEGIN 
	SELECT id_os
	into z_id_os
	from zatrudnienia
	where do is null and id_os=CZYZATRUDNIONA.z_id_os;
	IF SQL%FOUND then
		RAISE juzJEST;
	end if;
EXCEPTION
	WHEN juzJEST THEN
		RAISE_APPLICATION_ERROR('20000','Juz pracuje');
end sprawdz;

create or replace TRIGGER sprawdz
	BEFORE INSERT OR UPDATE ON zatrudnienia
	FOR EACH ROW
BEGIN 
	CZYZATRUDNIONA.z_id_os:=:new.id_os;
end sprawdz;

create or replace package czyZatrudniona as
	z_id_os osoby.id_os%TYPE;
end czyZatrudniona;

