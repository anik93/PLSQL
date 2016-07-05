create or replace 
TYPE users AS OBJECT(
  number1 NUMBER,
  number2 NUMBER,
  CONSTRUCTOR FUNCTION users(number1 IN NUMBER, number2 IN NUMBER) RETURN SELF AS RESULT,
  MEMBER FUNCTION sumNumber RETURN NUMBER,
  MEMBER FUNCTION getNumber1 RETURN NUMBER,
  MEMBER FUNCTION getNumber2 RETURN NUMBER
) NOT FINAL;

create or replace 
TYPE BODY users AS
  MEMBER FUNCTION sumNumber RETURN NUMBER IS
  BEGIN
    RETURN self.number1+self.number2;
  END sumNumber;
  
  MEMBER FUNCTION getNumber1 RETURN NUMBER IS
  BEGIN
    RETURN self.number1;
  END getNumber1;
  
  MEMBER FUNCTION getNumber2 RETURN NUMBER IS
  BEGIN
    RETURN self.number2;
  END getNumber2;
END;

create or replace 
TYPE numbers UNDER USERS(
  number3 NUMBER,
  MEMBER FUNCTION getNumber3 RETURN NUMBER,
  OVERRIDING MEMBER FUNCTION sumNumber RETURN NUMBER
);

create or replace 
TYPE BODY numbers AS
  OVERRIDING MEMBER FUNCTION sumNumber RETURN NUMBER IS
  BEGIN
    RETURN self.number1+self.number2+self.number3;
  END sumNumber;
  MEMBER FUNCTION getNumber3 RETURN NUMBER IS
  BEGIN
    RETURN self.number3;
  END getnumber3;
END;
	
SET SERVEROUTPUT ON
DECLARE
  z_users USERS := USERS(2,3);
  z_numbers NUMBERS := NUMBERS(2,3,4);
BEGIN
  dbms_output.put_line(z_users.getNumber1||'+'||z_users.getNumber2||'='||z_users.sumNumber);
  dbms_output.put_line(z_numbers.getNumber1||'+'||z_numbers.getNumber2||'+'||z_numbers.getNumber3||'='||z_numbers.sumNumber);
END;

DECLARE 
  TYPE ListOfObjectNumber IS VARRAY(10) of USERS;
  listOfNumber ListOfObjectNumber := ListOfObjectNumber();
  z_users USERS;
BEGIN
  listOfNumber.extend(10);
  z_users := USERS(1,2);
  for v_index IN 1..listOfNumber.count loop
    listOfNumber(v_index):=z_users; 
    z_users:=Users(z_users.getNumber1+1, z_users.getNumber2+1);
  end loop;
  for v_index IN 1..listOfNumber.count loop
    dbms_output.put_line('1: '||listofnumber(v_index).getNumber1||' 2: '||listofnumber(v_index).getNumber2);
  end loop;
END;