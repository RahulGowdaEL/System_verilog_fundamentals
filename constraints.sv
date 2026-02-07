//without using Sort method on the array
class A;
  rand int a[];

  // Constraint to set array size and values between 1 and 10
  constraint size {
    a.size == 10;
    foreach (a[i])
      a[i] inside {[1:10]};
  }

  function void post_randomize();
    $display("Before sorting array is %0p",a);
    foreach(a[i])
		begin
      for(int j=i+1;j<$size(a);j++) begin
			if(a[i]>a[j])
			begin
 				a[i]=a[i]+a[j];
				a[j]=a[i]-a[j];
				a[i]=a[i]-a[j];
			end
    end
 end 
    $display("After sorting array is %0p",a);
  endfunction
  
endclass

module test;
  A req = new();

  initial begin
    if (req.randomize()) begin
      $display("The values after randomization are: %p", req.a);
    end else begin
      $display("Randomization failed");
    end
  end
endmodule

//without using system task reverse , the string

class A;
  rand int a[];

  constraint c1 {
    a.size == 10;
    foreach (a[i]) a[i] inside {[1:20]};
  }

  function void post_randomize();
    $display("Original array: %p", a);
    reverse_inline();
    $display("Reversed array: %p", a);
  endfunction

function void reverse_inline();
  for(int i = 0; i < a.size() / 2; i++) begin
    
    int j = a.size() - 1 - i;
    $display("value of max is %p", j);
    a[i] = a[i] ^ a[j];
    a[j] = a[i] ^ a[j];
    a[i] = a[i] ^ a[j];
  end
endfunction
  
endclass

module test;
  A obj = new();
  initial begin
    if (obj.randomize()) begin
      $display("Reversed array in module: %p", obj.a);
    end else
      $display("Randomization failed");
  end
endmodule

//Q1 : Write a constraint to generate the below pattern 01010101010................

class constraintc;
  rand int a[];
  constraint x{a.size==10;}
  constraint y{foreach (a[i])
    if (i%2==0)
      a[i]==0;
    else 
      a[i]==1;}
  function void post_randomize();
    $display("Randomized data is %0p",a);
  endfunction
  
endclass

module top;
  constraintc c;
  initial 
    begin 
     // constraintc c;
      c=new();
      c.randomize();
    end
endmodule 


output:  Randomized data is 0 1 0 1 0 1 0 1 0 1
https://www.edaplayground.com/x/unZ2

//Q2. Write a constraint to generate the below pattern 1234554321


class constraintc;
  rand int a[];
  constraint x{a.size==10;}
  constraint y{foreach (a[i])
    if(i<5)
      a[i]==i+1;
      else
        a[i]==10-i;}
  function void post_randomize();
    $display("Randomized data = %0p",a);
  endfunction
  
endclass

module top;
  constraintc c;
  initial 
    begin 
      c=new();
      c.randomize();
    end 
endmodule 
                            
                              
 output: 
Randomized data = 10 9 8 7 6 5 4 3 2 1
https://www.edaplayground.com/x/nav8

//Q3: Write a constraint to generate the below pattern 9 19 29 39 49 59 69 79 

  class constraintc;
  rand int a[];
  constraint a_c{a.size==7;}
  constraint a_loc{foreach(a[i])
    a[i]==(i*10)+9;}
  
  function void post_randomize();
    $display("randomized data = %0p",a);
  endfunction 
endclass 

module top;
  constraintc c;
  initial 
    begin 
      c = new();
      c.randomize();
    end 
endmodule 

output:

randomized data = 9 19 29 39 49 59 69

https://www.edaplayground.com/x/Y83a

//Q4: Write a constraint to generate below pattern 5 -10 15 -20 25 -30


class constraintc;
  rand int a[];
  constraint a_c{a.size==6;}
  constraint a_loc{foreach(a[i])
    if(i%2==0)
      a[i]==(i*5)+5;
                  else 
                    a[i]==-5*(i+1);
                  }
  function void post_randomize();
    $display("Required pattern is =%0p",a);
  endfunction
endclass

module top;
 constraintc c;
  initial 
    begin 
      c = new();
      c.randomize();
    end
endmodule
       
output :
Required pattern is =-5 -10 -15 -20 -25 -30
https://www.edaplayground.com/x/KkD9

//Q5: Write a constraint to generate the pattern  1122334455

class constraintc;
  rand int a[];
  constraint a_c{a.size==10;}
  constraint a_loc{foreach(a[i])
    a[i]==(i+2)/2;}
  function void post_randomize();
    $display("Randomized pattern = %0p",a);
  endfunction 
  
endclass 

module top;
  constraintc c;
  initial 
    begin 
      c= new();
      c.randomize();
    end 
endmodule 

output :
Randomized pattern = 1 1 2 2 3 3 4 4 5 5

https://www.edaplayground.com/x/aPK_

//Q6: Write a code to generate a random number between 1.35 and 2.57

class constraintc;
  rand int a;
  real b;
  constraint size{a inside {[1350:2570]};}
  function void post_randomize();
    b=a/1000.0;
    $display("randomize pattern =%0f",b);
  endfunction 
  
endclass

module top;
  constraintc c;
  initial 
    begin 
      c=new();
      repeat(7)
      c.randomize();
    end
endmodule 

output:

randomize pattern =2.214000
 randomize pattern =1.684000
 randomize pattern =2.236000
 randomize pattern =1.425000
 randomize pattern =2.391000
 randomize pattern =1.911000
 randomize pattern =1.968000

https://www.edaplayground.com/x/Pdpi

//Q7:Write a constraint to generate the pattern 0102030405

class constraintc;
  rand int a[];
  constraint a_c{a.size==10;}
  constraint a_loc{foreach(a[i])
    if(i%2==0)
      a[i]==0;
    else 
      //a[i]==i+1;}   //it will generate at odd position 2,4,6,8,10
      a[i]==(i+2)/2;}
  
  function void post_randomize();
    $display("Randomize pattern = %0p",a);
  endfunction
endclass

module top ;
 constraintc c;
  initial 
    begin 
      c= new();
      c.randomize();
    end 
endmodule

output: 
Randomize pattern = 0 1 0 2 0 3 0 4 0 5
https://www.edaplayground.com/x/TRGR

//Q8: Write constraint to generate random values 25,27,30,40,45


class constraintc;
  rand int a;
  constraint a_c{a>24;a<46;}
  constraint a_loc{(a%5==0)||(a%9==0);a!=35;}
  
  function void post_randomize();
    $display("Randomized pattern =%0p",a);
  endfunction
  
endclass

module top;
  
  constraintc c;
  initial 
    begin 
      c= new();
      repeat(10)
        c.randomize();
    end 
endmodule 

  output:
Randomized pattern =36
Randomized pattern =36
Randomized pattern =40
Randomized pattern =40
Randomized pattern =25
Randomized pattern =25
Randomized pattern =40
Randomized pattern =36
Randomized pattern =45
Randomized pattern =27

https://www.edaplayground.com/x/sh9_

//Q9: Write a constraint to generate a random even number between 50 and 100.



class constraintc;
  rand int a[];
  constraint a_c{a.size==51;}
  constraint a_range{foreach (a[i])
    a[i] inside {[50:100]};}
  constraint a_value{foreach (a[i])
    a[i]%2==0;}
  
  function void post_randomize();
    $display("Randomized pattern =%0p",a);
  endfunction 
  
endclass 

module top;
  constraintc c;
  initial 
    begin
      c= new();
      c.randomize();
    end
endmodule 

output:

Random even number between 50 & 100 are :
92 66 62 68 66 96 88 90 50 58 66 52 92 62 60 74 54 72 94 72 66 84 100 56 86 90 94 56 86 64 64 58 50 78 78 86 80 100 56 54 66 58 80 66 80 68 90 60 80 96 92 90 98 88 98 90 78 94 84 56
 https://www.edaplayground.com/x/tn_K             
                   
 //Q10: Write a 32-bit rand variable such that it should have 12 numbers of 1's non consecutively.  
                

class constraintc;
  rand bit[31:0]a;
  constraint number_of_ones{$countones(a)==12;}
  constraint x{foreach(a[i])
    if(i>0&&a[i]==1)
      !a[i]==a[i-1];}
  function void post_randomize();
    $display("Randomized 32 bit varaible having 12 ones is =%0b",a);
  endfunction
  
endclass

module top;
 constraintc c;
  initial
    begin
      c= new();
      c.randomize();
    end
endmodule 
  
output;

Randomized 32 bit varaible having 12 ones is =10010010101001010010010010001010
Displaying number of ones in the varibale that we randomized =12
https://www.edaplayground.com/x/kt3B

//Q11:Write a constraint to generate FACTORIAL of  first 5 even numbers and odd numbers 


class constraintc;
  rand int even[];
  rand int odd[];
  
  function int fact(int i);
    if(i==0)
      fact=1;
    else 
      fact=i*fact(i-1);
  endfunction
  
  //constraint for size 
  constraint size{even.size==5;}
  
 //constraint for  factorial of even number 
  
  constraint even_fact{foreach (even[j])
    even[j]==fact(2*(j+1));}
  constraint odd_fact{foreach (odd[k])
    odd[k]==fact((2*k)+1);}
  
  function void post_randomize();
    $display("Factorial for first five even number = %0p",even);
    //$display("Factorial for first five odd number=%0p",odd);
  endfunction
  
endclass

module top;
  constraintc c;
  initial 
    begin 
      c=new();
      c.randomize();
    end 
endmodule 
                                
output:
Factorial for first five even number = 2 24 720 40320 3628800
https://www.edaplayground.com/x/nAuh

//Q12:Write a constraint such that even locations contains odd numbers and odd locations contains even numbers.


class constraintc;
  rand int a[];
  constraint a_c{a.size inside {[10:20]};}
  constraint range{foreach (a[i]) a[i] inside {[1:100]};}
  constraint x{foreach (a[i])
    if(i%2==0)
      a[i]%2==1;
    else 
      a[i]%2==0;}
  function void post_randomize();
    $display("After randomized data=%0p",a);
  endfunction
  
endclass 
 
module top;
  constraintc c;
  initial 
    begin 
      c=new();
      c.randomize();
    end 
endmodule

output :
After randomized data=81 16 13 20 17 8 85 94 73 44 43 96 43 6
https://www.edaplayground.com/x/e2T2

//Q13: Write a SystemVerilog program to randomize a 32-bit variable, but only randomize the 12th bit 

class constraintc;
  rand bit[31:0]a;
  constraint a_c{foreach (a[i])
    if(i==12)
      a[i]inside{[0:1]};
      else 
        a[i]==0;}
  function void post_randomize();
    $display("randomize a 32 bit variable =%0b",a);
  endfunction
  
endclass 

module top;
  constraintc c;
  initial 
    begin 
      c= new();
      c.randomize();
    end 
endmodule 

output:
randomize a 32 bit variable =1000000000000

    https://www.edaplayground.com/x/EXtm

//Q14: Write a constraint on two two-dimensional arrays for generating even numbers in the first 4 locations and odd numbers in the next 4 locations. Also the even number should be in multiple of 4 and odd number should be multiple of 3.



class constraintc;
  rand int a[2][4];      //4 for 4 locations 
  constraint x{foreach (a[i])
    foreach (a[i][j])
      if(i==0)
        a[i][j]%4==0;
        else
          a[i][j]%2!=0 && a[i][j]%3==0;}
  constraint y{foreach(a[i]) foreach (a[i][j]) (a[i][j])inside {[1:100]};}
  
  function void post_randomize();
    $display("Randomized value is =%0p",a);
  endfunction 
  
endclass

module top;
  constraintc c;
  initial 
    begin
      c= new();
      c.randomize();
    end 
endmodule 
             
output:
 Randomized value is ={56 16 32 72} {21 3 9 63}             
https://www.edaplayground.com/x/mv8b


//Q15: Constraint to generate bit[7:0] array1[10] with unique values and also multiple of 3.

class constr;
  
  rand bit [7:0]array1[10];
  constraint y{foreach(array1[i])
    array1[i]%3==0 && array1[i] inside {[1:100]};}
  constraint z{unique {array1};}
endclass 


module test;
  
  constr c;
  
  initial 
    begin 
      c= new();
      c.randomize();
      $display("the value of array1=%0p",c.array1);
    end 
endmodule 
    
https://www.edaplayground.com/x/MZhj
output:

the value of array1=15 51 6 96 63 21 81 75 48 54


//Q16: Write a constraint to generate unique numbers in an array without using unique keyword.



class constr;
  rand int a[10];
  
  constraint x{foreach(a[i])
    foreach(a[j])
      if(i!=j)
        a[i]!=a[j];}
  constraint y{foreach(a[i]) a[i] inside {[1:100]};}
  
  function void post_randomize();
    $display("uniques values = %0p",a);
  endfunction 
  
endclass 

  module top;
    constr c;
    initial 
      begin 
        c= new();
        c.randomize();
      end 
  endmodule 
                       
   output:
     uniques values = 59 78 100 95 41 9 39 71 64 69     
            
https://www.edaplayground.com/x/ZZ_g

//Q17: Write a constraint to generate prime numbers between the range of 1 to 100.

class constr;
  rand int a;
  int b;
  constraint range{a inside {[1:100]};}
  
  function int prime(int a);
    if(a<=1)
      return 2;
    for(int i=2;i<a;i++)
      begin
        if(a%i==0)
          return 3;
        else 
          prime=a;
      end 
  endfunction
  
  function void post_randomize();
    b=prime(a);
    $display("prime number is =%0d",b);
  endfunction 
  
endclass

module top;
  constr c;
  initial 
    begin 
      c=new();
      repeat(10)
        c.randomize();
    end 
  
endmodule 

output: 
prime number is =3
prime number is =0
prime number is =29
prime number is =3
prime number is =0
prime number is =3
prime number is =3
prime number is =31
prime number is =3
prime number is =43   

https://www.edaplayground.com/x/RWQL

//Q19: Write a constraint to generate a variable with 0-31 bits should be 1,32-61 bits should be 0;


class constr;
  rand bit[0:61]a;
  constraint x{foreach (a[i])
    if(i<32)
      a[i]==1;
               else
                 a[i]==0;}
  
  function void post_randomize();
    $display("Randomized value is =%0b",a);
  endfunction
  
endclass 

module test;
  constr c;
  initial 
    begin 
      c=new();
      c.randomize();
    end 
endmodule 
  
output :
 Randomized value is = 11111111111111111111111111111111000000000000000000000000000000
https://www.edaplayground.com/x/MdVX

//Q20: Write a constraint to generate consecutive elements using Fized size array and also write the constraint to generate non consecutive elements ?

class constr;
  rand int a[10];
  
  //for consecutive elemenst 
  
  constraint x{foreach(a[i])
    a[i]==i;}
  
  //for non consecutive elements
  
  constraint y{foreach(a[i])
    foreach(a[j])
      if(i!=j)
        a[i]!=a[j];}
  
  constraint z{foreach(a[i]) 
    a[i] inside {[0:100]};}
  
  function void post_randomize();
    $display("Consecutive values are %p",a);
  endfunction 
  
endclass 

module test;
  constr c;
  initial 
    begin 
      c=new();
      c.randomize();
    end 
endmodule 

output:
Consecutive values are '{0, 1, 2, 3, 4, 5, 6, 7, 8, 9}
https://www.edaplayground.com/x/LfMF

//Q21: write a constraint to randomly generate 10 unique numbers between 99 to 100

class constr;
  rand int a[10];
  real b[10];
  
  constraint x{foreach(a[i])
    a[i] inside {[990:1000]};}
  constraint z{foreach (a[i]) 
    foreach (a[j])
    if(i!=j)
      a[i]!=a[j];}
  
  function void post_randomize();
    foreach(b[i])
      b[i]=a[i]/10.0;
    $display("10 unique numbers between 99 and 100 are :%0p ",b);
  endfunction 
  
endclass 

module test;
  constr c;
  initial 
    begin
      c= new();
      c.randomize();
    end
endmodule 

output: 10 unique numbers between 99 and 100 are:99.7 99.8 99 99.2 99.5 99.90000000000001 99.3 99.59999999999999 99.09999999999999 100  

https://www.edaplayground.com/x/Zy8E

//Q22: Write a constraint such that the array size is between 5 to 10 values of the array in ascending order. In this program, I am going to use extern constraint .


class constr;
  rand int a[];
  constraint size;
  constraint ascending;
  
  function void post_randomize();
    $display("After radomizing a is =%p",a);
  endfunction
  
endclass 

constraint constr::size{a.size inside{[5:10]};}
constraint constr::ascending{foreach (a[i])
  a[i] inside {[1:10]};
                             foreach(a[i])
                               if(i>0)
                                 a[i]>a[i-1];}    //ascending order
                                // a[i]<a[i-1];}
//descending order   a[i]<a[i-1];}

module test;
  constr c;
  initial
    begin 
      c=new();
      c.randomize();
    end 
endmodule                        
                                                   
output:
After radomizing a is ='{3, 6, 7, 9, 10}
https://www.edaplayground.com/x/ZUiq

//Q:23: Write a constraint to generate even numbers in the range of 10 to 30 using Fixed size array, Dynamic array and queue.


class constr;
  rand int a[10];   //Fixed size array
  rand int b[];    //dynamic array
  rand int c[$];   // queue
  
  constraint sizeb{b.size inside {[10:30]};}
  constraint sizec{c.size inside {[10:30]};}
  
  constraint x{foreach(a[i])
    a[i] inside {[10:30]} && a[i]%2==0;
                 foreach(a[i])
                   b[i] inside {[10:30]} && b[i]%2==0;
                 foreach(c[i])
                   c[i] inside {[10:30]} && c[i]%2==0;}
  
  function void post_randomize();
    $display("a is = %0p \n b is = %p \n c is = %p",a,b,c);
  endfunction
  
endclass 

module test ;
  constr c;
  initial 
    begin 
      c= new();
      c.randomize();
    end 
endmodule 

output :
a is = 14 14 12 20 26 14 28 26 22 20 
b is = '{20, 26, 30, 30, 28, 18, 14, 14, 24, 22, -356015325, -1451037513, 382252193} 
c is = '{30, 16, 18, 30, 28, 30, 20, 16, 30, 24, 28, 20, 22, 10, 16, 18, 18, 16, 28, 18, 26, 12, 16, 18, 24, 16}

https://www.edaplayground.com/x/dgp3

//Q24: Write a Constraint so that if we randomize a single bit variable 10 times values should generate be like 1010101010


class constr;
  rand bit a;
  bit b=0;
  
  constraint x{a!=b;}
  
  function void post_randomize();
    $write("%0b%0b",a,b);
  endfunction 
  
endclass 

module test;
  constr c;
  initial 
    begin 
      c=new();
      repeat(5)
      c.randomize();
    end 
endmodule 
  
output:
1010101010
https://www.edaplayground.com/x/8VHr

//Q25: Write a constraint to demonstrate solve before the constraint.

class constr;
  rand bit a;
  rand bit [3:0]b;
  
  constraint x{(a==0)->(b==1); solve a before b;}
  
  function void post_randomize();
    $display("a is %0d and b is %0d",a,b);
  endfunction 
  
endclass 

module test;
  constr c;
  initial 
    begin 
      c=new();
      c.randomize();
    end 
endmodule 

output:
a is 0 and b is 1
https://www.edaplayground.com/x/ph8p

//Q26: Write a code to generate unique elements in an array without using unique keyword and constraints .

module unique_e;
  int a[10];
  initial 
    begin 
      foreach(a[i])
        a[i]=i+1;
      a.shuffle();
      $display("%0p",a);
    end       
endmodule
 
output:
9 8 1 6 4 10 3 2 5 7
https://www.edaplayground.com/x/TiKX

//Q27: Write a constraint for 2D dynamic array to print consecutive elements .


class constr;
  rand int a[][];
  constraint size1{a.size inside {[10:20]};
                   foreach(a[i])
                     a[i].size==2;}
  constraint s{foreach(a[i])
    foreach(a[i][j])
      a[i][j]==i+j;}
  
  function void post_randomize();
    $display("Consecutive elements in 2D array are %0p",a);
  endfunction 
  
endclass 

module test;
  constr c;
  initial 
    begin 
      c=new();
      c.randomize();
    end 
endmodule 
            

output:
Consecutive elements in 2D array are {0 1} {1 2} {2 3} {3 4} {4 5} {5 6} {6 7} {7 8} {8 9} {9 10} {10 11} {11 12} {12 13}

https://www.edaplayground.com/x/kcgp

//Q28: Constraint to check whether the randomized number is palindrome or not 
Ans: Palindrome_number : A number is a number that remains the same when digits are reversed 



class constr;
  rand int num;
  
  constraint x{num inside {[100:999]};}
  
  function void post_randomize();
    int r,sum,temp;
    temp=num;
    
    //as we are checking 3 digits number is palindrome or not so we have 3 iterations here .
    
    for(int i=0;i<3; i++)
      begin 
        r=num%10;
        sum=(sum*10)+r;
        num=num/10;
      end
    
    if(temp==sum)
      $display("Number is palindrome =%0d",temp);
    else 
      $display("Number is not palindrom = %0d",temp);
  endfunction 
  
endclass 

module test;
  constr c;
  initial 
    begin 
      c=new();
      repeat(20)
      c.randomize();
    end 
endmodule 
    
output:

Number is not palindrom = 886
Number is not palindrom = 429
Number is not palindrom = 223
Number is not palindrom = 172
Number is not palindrom = 627
Number is palindrome =232
Number is not palindrom = 279
Number is palindrome =626
Number is not palindrom = 271
Number is not palindrom = 298
Number is not palindrom = 264
Number is not palindrom = 233
Number is not palindrom = 713
Number is not palindrom = 940
Number is not palindrom = 354
Number is not palindrom = 965
Number is not palindrom = 971
Number is not palindrom = 832
Number is not palindrom = 599
Number is not palindrom = 320
https://www.edaplayground.com/x/vDQr

//Q29: Write a constraint to display the Fibonacci sequence.

//Fibonacci sequence: The next number is found by adding up the two numbers before it .


class constr;
  rand int n;
  rand int a[];
  constraint x{n inside {[7:15]};}
  constraint y{a.size==n;}
  
  constraint z{foreach(a[i])
    if(i==0)
      a[i]==0;
               else if(i==1)
                 a[i]==1;
              else 
                a[i]==a[i-1]+a[i-2];}
  
  function void post_randomize();
    $display("Fibonacci sequence is %0p",a);
  endfunction 
  
endclass 

module test;
  constr c;
  initial 
    begin 
      c= new();
      c.randomize();
    end
endmodule 

output :
Fibonacci sequence is 0 1 1 2 3 5 8 13 21 34 55 89 144
https://www.edaplayground.com/x/na9S

//Q:30 Write a code to check whether the randomized number is an Armstrong number or not 

//Armstrong number: An Armstrong number is one whose sum of digits raised to the power three equals the number itself. For example, 371 is an armstrong number because 3*3 + 7*3 +1*3 =371 


class constr;
  rand int num;
  constraint x{num inside {[100:999]};}
  
  function void post_randomize();
    int temp,sum,r;
    temp=num;
    for(int i=0;i<3;i++)
      begin
        r=num%10;
        sum=(r*3)+sum;
        num=num/10;
      end 
    
    if(temp==sum)
      $display("armstrong number =%0d",temp);
    else 
      $display("it is not a armstong number =%0d",temp);
  endfunction
  
endclass 

module test;
  constr c;
  initial 
    begin 
      c=new();
      c.randomize();
    end 
endmodule 
    
    
output :
it is not a armstong number =886

https://www.edaplayground.com/x/hb6D

//Q31: Write a constraint so that the elements in two queues are different .


class constr;
  rand int q1[$];
  rand int q2[$];
  
  constraint distinct{q1.size inside {[10:20]};
                      q2.size inside {[10:20]};
                     
                      foreach(q1[i])
                        q1[i] inside {[1:100]};
                     
                      foreach(q2[i])
                          //1st logic to compare array elements 
                        !(q2[i] inside {q1});} 
  
                       //2nd  logic to compare array elements 
                       // q2[i]!=q1[i];}
  
  function void post_randomize();
    $display("the value or q1=%0p,\n value of q2=%0p",q1,q2);
  endfunction
  
endclass 
  
  module test;
    constr c;
    initial 
      begin 
        c=new();
        c.randomize();
      end 
  endmodule 

output:
the value or q1=27 70 3 89 36 19 65 83 97 14 85 2 35,
value of q2=883471907 310413165 657971087 300904082 142071706 -2000587923 -421806407 599792172 2047781930 913786049 -394113405 -2002442299 -2042107787

https://www.edaplayground.com/x/MmWN

//Q32: Constraint for the 0-100 range is 70% and the 101-255 range is 30% 


class constr;
  rand bit[7:0]a;
  
  constraint x{a dist {[0:100]:=70,[101:255]:=30};}
  
  function void post_randomize();
    $display("the value of ",a);
  endfunction 
  
endclass 

  module test;
    constr c;
    int count;
    initial 
      begin 
        c=new();
        repeat(10)
          begin
            c.randomize();
            if(c.a<101)
              count=count+1;
          end 
        $display("No of entries less than 100 are =%0d",count);
      end 
  endmodule 
                        
  
output:
the value of  86
the value of  37
the value of 204
the value of  63
the value of 243
the value of 102
the value of 139
the value of  51
the value of 165
the value of 239
No of entries less than 100 are =4
https://www.edaplayground.com/x/YnhG

//Q33: Write a constraint for 16-bit variables such that no two consecutive ones should be generated.

class constr;
  rand bit[15:0]a;
  
  constraint x{foreach(a[i])
    if(i>0 && a[i]==1)
      a[i]!=a[i-1];}
  
  function void post_randomize();
    $display("the values =%0b",a);
  endfunction 
  
endclass 

module test;
  constr c;
  initial 
    begin 
      c=new();
      c.randomize();
    end 
endmodule 

output:
the values =10010000101001
https://www.edaplayground.com/x/Mn74


//Q34: Write a constraint to generate 32 bit number with 1 bit high using $onehot().

//$onehot(expression): It returns true if exactly one bit of expression is high.


class constr;
  rand bit[31:0]a;
  
  constraint x{$onehot(a);}
  
  function void post_randomize();
    $display("1 bit high using $onehot()=%0b",a);
  endfunction
  
endclass 

module test;
  constr c;
  initial 
    begin 
      c=new();
      c.randomize();
    end 
endmodule

output :
1 bit high using $onehot()=1000000000000
https://www.edaplayground.com/x/YzW4

//Q35: Write a constraint to randomly generate unique prime numbers in an array between 1 and 200. The generated prime numbers should have 7 in it.



class constr;
  rand int a[];
  int q[$];
  
  constraint size{a.size inside{[1:200]};}
  
  constraint x{foreach(a[i])
    a[i]==prime(i);}
  
  function int prime(int j);
    if(j<=1)
      return 2;
    for(int k=2;k<j;k++)
    begin
      if(j%k==0)
        return 3;
      else
        prime=j;
    end
  endfunction
  
  function void post_randomize();
    foreach(a[i])
      begin 
        if(a[i]%10==7)
          q.push_front(a[i]);
      end 
    $display(" generated prime numbers having 7=%0p",q);
  endfunction

endclass 

module test;
  constr c;
  initial
    begin 
      c=new();
      c.randomize();
    end 
endmodule 

output:
 generated prime numbers having 7=67 47 37 17 7

https://www.edaplayground.com/x/GuJM

//Q36:write a constraint on a 16-bit rand vector to generate alternate pairs of 0's and 1's 

//EX:0011.... and 1100...


class constr;
  rand bit[15:0]a;
  constraint x{foreach(a[i])
    if(i<15)
      if(i%2==0)
        a[i+1]==a[i];
               else
                 a[i]!=a[i+1];
              }
  function void post_randomize();
    $display("generating alternate pairs of 1's or 0's =%0b",a);
  endfunction
  
endclass 

module test;
  constr c;
  initial 
    begin 
      c=new();
      c.randomize();
    end
endmodule



output:
 generating alternate pairs of 1's or 0's =11001100110011

https://www.edaplayground.com/x/qGYB


//Q37: Assume that you have two properties 
//rand bit[7:0]a and rand bit[2:0]b
//The range of values for b are 3,4,7
//if b==3 , the number of ones in the 'a' must be 4
//If b==4, the number of ones in the 'a' must be 5
//If b==7, the number of ones in the 'a' must be 8



class constr;
  rand bit[7:0]a;
  rand bit[7:0]b;
  
  constraint x{$countbits(a,1)==b+1;}   //1st logic 
  
  //2nd logic
  /*
  constraint x {b dist{3:/2, 4:/2, 7:/6};}
  constraint y{$countones(a)==b+1;}
  */
  
  function void post_randomize();
    $display("the no of 1's in a is =%0d, b=%0d",$countones(a),b);
  endfunction
endclass 

module test;
  constr c;
  initial 
    begin 
      c=new();
      repeat(10)
      c.randomize();
    end 
endmodule 
     

output:
the no of 1's in a is =4, b=3
the no of 1's in a is =2, b=1
the no of 1's in a is =5, b=4
the no of 1's in a is =4, b=3
the no of 1's in a is =4, b=3
the no of 1's in a is =4, b=3
the no of 1's in a is =5, b=4
the no of 1's in a is =3, b=2
the no of 1's in a is =5, b=4
the no of 1's in a is =3, b=2

https://www.edaplayground.com/x/ApRR

//Q38: Write a Constraint such that the sum of any three consecutive elements in an array should be an even number 


class constr;
  rand int a[];
  constraint x{a.size inside {[10:20]};}
  constraint y{foreach(a[i])
    if(i>0)
      (a[i]+a[i-1]+a[i-2])%2==0;}
  
  constraint z{foreach(a[i])
    a[i] inside {[0:10]};}
  
  function void post_randomize();
    $display("sum of three consecutive element of array is even no=%0p",a);
  endfunction 
  
endclass 

module test;
  constr c;
  initial 
    begin 
      c= new();
      c.randomize();
    end 
endmodule 

https://www.edaplayground.com/x/K2G6

output:
three consecutive element of array is even no=5 9 6 1 9 0 7 5 4 7 3 10 9


//Q39:Write a constraint for two random variables such that one variable should not match with the other & the total number of bits toggled in one variable should be 5 w.r.t the other 


class constr;
  rand bit[8:0] a;
  rand bit[8:0]b;
  
  constraint not_equal{a!=b;}
  constraint count{$countones(a)==5;}
  
  function void post_randomize();
    $display("a is %0b \n b is %0b",a,b);
  endfunction 
  
endclass 

module test;
  constr c;
  initial 
    begin 
      c=new();
      c.randomize();
    end 
endmodule 

output:
a is 11000111 
b is 111100000
https://www.edaplayground.com/x/ggju

//Q40: Write a constraint such that when rand bit[3:0] a is randomized the value of "a" should not be the same as 5 previous occurrences of the value of "a"



class constr;
  rand bit[3:0]a;
  int que[$];
  
  constraint x{!(a inside {que});}
  
  function void post_randomize();
    que.push_front(a);
    if(que.size==6)
      que.pop_back();
    $display("a is = %0d",a);
  endfunction 
  
endclass 

module test;
  constr c;
  initial 
    begin 
      c= new();
      repeat(20)
      c.randomize();
    end 
endmodule 
    

output:
a is = 9
a is = 3
a is = 2
a is = 11
a is = 4
a is = 15
a is = 6
a is = 13
a is = 14
a is = 0
a is = 1
a is = 5
a is = 4
a is = 15
a is = 10
a is = 8
a is = 14
a is = 9
a is = 1
a is = 7
https://www.edaplayground.com/x/Yb57

//Q41: Write a code to  have the cyclic randomization behavior without using the randc keyword


class constr;
  rand bit[7:0]a;
  int que[$];
  
  constraint x{!(a inside {que});}
  
  function void post_randomize();
    que.push_front(a);
    if(que.size==2**$size(a))
      begin 
        que={};
      end 
    $display("a is =%0d",a);
    
  endfunction 
endclass 

module test;
  constr c;
  initial
    begin 
      c=new();
      repeat(8)
        c.randomize();
    end 
endmodule 

output :
a is =217
a is =131
a is =66
a is =155
a is =187
a is =5
a is =28
a is =17

https://www.edaplayground.com/x/u6BS


//Q42: Write constraint for payload such that the size should be randomly generated between 11 and 22 and each value of the payload should be greater than previous value by 2


class constr;
  rand int payload[];
  constraint size{payload.size inside {[11:22]};}
  constraint x{foreach(payload[i])
    payload[i] inside {[0:100]};}
  constraint y{foreach(payload[i])
    if(i>0)
      payload[i]==payload[i-1]+2;}
  
  function void post_randomize();
    $display("After randomizing payload data =%0p",payload);
  endfunction 
  
endclass 

module test;
  constr c;
  initial
    begin 
      c=new();
      c.randomize();
    end 
endmodule 
    
  output:
After randomizing payload data =50 52 54 56 58 60 62 64 66 68 70 72 74

  https://www.edaplayground.com/x/CXL8

 
//Q43: Write a constraint to print unique elements in a 2D array without using a unique keyword.


class constr;
  rand int a[][];
  
  constraint x{a.size inside {[5:10]};
               foreach(a[i])
                 a[i].size inside {[1:3]};}
  
  constraint y{foreach(a[i])
    foreach(a[i][j])
      foreach(a[m])
        foreach(a[m][n])
          if(!(i==m && j==n))
            a[i][j]!=a[m][n];}
  
  constraint Z{foreach(a[i])
    foreach(a[i][j])
      a[i][j] inside{[0:100]};}
  
  function void post_randomize;
    foreach(a[i])
      begin
        foreach(a[i][j])
          $display("a[%0d][%0d]is %0d",i,j,a[i][j]);
      end
  endfunction
  
endclass

module tb_top;
  constr c;
  initial
    begin
      c=new();
      c.randomize();
    end 
endmodule 

output:https://www.edaplayground.com/x/CSQR

a[0][0]is 35
a[1][0]is 68
a[1][1]is 100
a[1][2]is 0
a[2][0]is 67
a[3][0]is 37
a[4][0]is 61
a[4][1]is 43
a[5][0]is 64
a[5][1]is 90
a[5][2]is 23
a[6][0]is 3
a[7][0]is 97
a[8][0]is 79
a[8][1]is 94
a[8][2]is 13

//44.Sorting the elements in the dynamic array using constraints.


class constr;
  rand int a[];
  constraint size{a.size inside {[10:20]};}
  constraint range{foreach(a[i])
    a[i] inside {[0:100]};}
   
  function void post_randomize;
    $display("Before sorting array is %0p",a);
    foreach(a[i])
      begin 
        for(int j=0;j<$size(a);j++)
          begin 
            if(a[i]>a[j])
              begin 
                a[i]=a[i]+a[j];
                a[j]=a[i]-a[j];
                a[i]=a[i]-a[j];
              end 
          end 
      end
    $display("after sorting array is %0p",a);
  endfunction 
  
endclass 

module top;
  initial begin 
    constr c;
    c=new();
    c.randomize;
  end 
endmodule 

Output:https://www.edaplayground.com/x/UWwh
# KERNEL: Before sorting array is 88 96 74 2 36 72 90 50 43 1 25 51 59 63
# KERNEL: after sorting array is 96 90 88 74 72 63 59 51 50 43 36 25 2 1

//Q45:Write a constraint to generate 1221122112211.....

class constr;
  rand int a[];
  constraint x{a.size inside {[10:20]};}
  constraint y{foreach(a[i])
    
    if(i%4==0 || i%4==3)
      a[i]==1;
               else 
                 a[i]==2;}
  function void post_randomize;
    $display("Required pattern is %0p",a);
  endfunction 
  
endclass 

module top;
  initial 
    begin
      constr c;
      c=new();
      c.randomize();
    end
endmodule 

Output : https://www.edaplayground.com/x/THBN
# KERNEL: Required pattern is 1 2 2 1 1 2 2 1 1 2 2 1 1 2
