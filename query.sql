select nazwisko, imie1
from osoby
where UPPER(imie1) like '%A%'
order by 1ASC;
select nazwisko||' '|| imie1 dane
from osoby
where UPPER(nazwisko) like '_O%'
order by 1ASC;
select UNIQUE(UPPER(nazwisko))
from osoby;
select nazwisko, imie1
from osoby
where lower(nazwisko)=nazwisko;
select decode(plec,'K','pani','M','pan','??')||' '||nazwisko||' '||imie1
from osoby;
select w.nazwa, o.nazwisko, o.imie1
from wydzialy w join zatrudnienia z on w.id_w=z.id_w join osoby o on z.id_os=o.id_os
where z.do is null;
select w.nazwa, o.nazwisko, o.imie1
from wydzialy w, zatrudnienia z join osoby o on z.id_os=o.id_os
where z.do is not null and UPPER(w.nazwa)='FIZYKA';
select nazwisko, imie1, d_ur
from osoby
where d_ur>to_date('01/01/1980','DD/MM/RRRR');
select nazwisko, imie1, pensja
from osoby o join zatrudnienia z on o.id_os=z.id_os
where pensja>1500 and pensja<2000 and z.do is null;
select nazwisko, plec
from osoby o join zatrudnienia z on o.id_os=z.id_os
where z.do is null
order by plec, nazwisko;
select w.nazwa, avg(z.pensja)
from wydzialy w join zatrudnienia z on w.id_w=z.id_w
where z.do is null
group by w.nazwa;
select w.nazwa, count(z.id_os) ilosc
from wydzialy w join zatrudnienia z on w.id_w=z.id_w
where z.do is null
group by w.nazwa;
with max_il as
(select w.nazwa, count(z.id_os) ilosc
from wydzialy w join zatrudnienia z on w.id_w=z.id_w
where z.do is null
group by w.nazwa)
select nazwa, ilosc
from max_il
where ilosc=(select max(ilosc)
from max_il);
select nazwa
from wydzialy
where UPPER(nazwa) like '%A%';
select plec, round(avg(pensja)) srednia
from osoby o join zatrudnienia z on o.id_os=z.id_os
where do is null
group by plec;
with min_os as
(select nazwa, count(id_os) ilosc
from wydzialy w join zatrudnienia z on w.id_w=z.id_w
where do is null
group by nazwa)
select nazwa, ilosc
from min_os
where ilosc=(select min(ilosc)
from min_os);
SELECT o.id_os, o.nazwisko, o.imie1, o.imie2, o.d_ur, o.plec
from osoby o
where d_ur>to_date('01/01/1983','DD/MM/RRRR')
order by nazwisko, imie1;
SELECT o.id_os, o.nazwisko, o.imie1
from osoby o
where o.id_os in( select z.id_os
from zatrudnienia z
group by z.id_os
having count(o.id_os)>1);
with bogaty as
(select nazwisko, imie1, pensja
from osoby o join zatrudnienia z on o.id_os=z.id_os join kierownicy k on z.id_os=k.id_os
where k.do is null)
select nazwisko, imie1, pensja
from bogaty
where pensja=(select max(pensja)
from bogaty);
select nazwisko, imie1, d_ur
from osoby o
where o.d_ur=(select min(o1.d_ur)
from osoby o1
where o.plec=o1.plec);
with najwiecej as
(select w.nazwa, count(z.id_os) ilosc
from wydzialy w join zatrudnienia z on w.id_w=z.id_w join osoby o on z.id_os=o.id_os
where plec='K' and z.do is null
group by nazwa)
select nazwa, ilosc
from najwiecej
where ilosc=(select max(ilosc)
from najwiecej);
with najstarszy as
(select nazwisko, d_ur
from kierownicy k join osoby o on k.id_os=o.id_os
where k.do is null)
select nazwisko, d_ur
from najstarszy
where d_ur=(select min(d_ur)
from najstarszy);
with najwiecej as
(select nazwa, count(id_os) ilosc
from wydzialy w join zatrudnienia z on w.id_w=z.id_w
where do is null
group by nazwa)
select nazwa, ilosc
from najwiecej
where ilosc=(select min(ilosc)
from najwiecej);
with kieros as
(select nazwa, d_ur
from osoby o join kierownicy k on o.id_os=k.id_os join wydzialy w on k.id_w=w.id_w
where k.do is null)
select nazwa, d_ur
from kieros 
where d_ur=(select max(d_ur)
from kieros);
with sre as
(select nazwa , round(avg(pensja)) srednia
from zatrudnienia z join stanowiska s on z.id_s=s.id_s
where do is null
group by nazwa)
select nazwa, srednia
from sre
where srednia=(select min(srednia)
from sre);
with il as
(select nazwa , count(id_os) ilosc
from zatrudnienia z join stanowiska s on z.id_s=s.id_s
where do is null
group by nazwa)
select nazwa, ilosc
from il
where ilosc=(select max(ilosc)
from il);
