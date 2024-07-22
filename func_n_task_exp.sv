// Code your testbench here
// or browse Examples
module test();
  int d, result;
  int a = 2, b = 3;
  
  function mult(input int a, input int b, output int c);
    c = ( a * b) + 2;
    a++;
    $display($time, " FROM FUNC a = %0d, b = %0d, c = %0d", a, b, c);
  endfunction
  
  initial 
    fork
      begin
        #1;
        mult(a, b, d);
        $display("FROM BLK 1");
        $display($time," a = %0d, b = %0d, c = %0d", a, b, d);
      end
      begin
        #2;
        mult(a, b, d);
        $display("FROM BLK 2");
        $display($time, " a = %0d, b = %0d, c = %0d", a, b, d);
      end
    join
endmodule

/* 1 FROM FUNC a = 3, b = 3, c = 8
# FROM BLK 1
# 1 a = 2, b = 3, c = 8
# 2 FROM FUNC a = 3, b = 3, c = 8
# FROM BLK 2
# 2 a = 2, b = 3, c = 8
When we call mult function from blk 1, it will copy global variables a,b to the local variables a,b inside the function. then inside the function a is incremented which is bound to the function only, won't be reflected to the outside world. If we add function automatic - gives same output. we need to define variables with ref keyword for the variables to share the same memory
*/

function automatic mult(ref int a, ref int b, output int c);

/*# 1 FROM FUNC a = 3, b = 3, c = 8
# FROM BLK 1
# 1 a = 3, b = 3, c = 8
# 2 FROM FUNC a = 4, b = 3, c = 11
# FROM BLK 2
# 2 a = 4, b = 3, c = 11
When we use ref keyword, ref arguments will not have any local memory. Whatever variable we have passed while calling the function, to those variables it will point. So, whatever changes you do inside the function, we are doing on the variables we passed as an arguments means the global variables. If we don't give the ref keyword then individual mem will be allocated so same result we'll get.
*/

task automatic mult(input int a, input int b, output int c);
    #5;
    c = ( a * b) + 2;
    a++;
    $display($time, " FROM FUNC a = %0d, b = %0d, c = %0d", a, b, c);
  endtask
  
 //same result as function automatic only time will vary
 /* # 6 FROM FUNC a = 3, b = 3, c = 8
# FROM BLK 1
# 6 a = 2, b = 3, c = 8
# 7 FROM FUNC a = 3, b = 3, c = 8
# FROM BLK 2
# 7 a = 2, b = 3, c = 8
*/

class pass_by_ref;
  int refe = 2;
  int val = 2;
  
  function automatic int check_ref(ref int r);
    $display("\n---------------PASS BY REFERENCE------------");
    $display($time, " Initial value of REFE = %0d", r);
    r++;
    $display($time, " Final value of REFE = %0d", r);
  endfunction
  
  function int check_val(int v);
    $display("\n---------------PASS BY VALUE------------");
    $display($time, " Initial value of VAL = %0d", v);
    v++;
    $display($time, " Final value of VAL = %0d", v);
  endfunction
  
endclass



module test;
  initial begin
    pass_by_ref h1 = new();
    h1.check_ref(h1.refe);
    h1.check_val(h1.val);
    $display("\n---------------IN MEMORY------------");
    $display($time, " Value of refe after inc = %0d", h1.refe);
    $display($time, " value of val after inc = %0d", h1.val);
  end
endmodule
  
/*# ---------------PASS BY REFERENCE------------
# 0 Initial value of REFE = 2
# 0 Final value of REFE = 3
# 
# ---------------PASS BY VALUE------------
# 0 Initial value of VAL = 2
# 0 Final value of VAL = 3
# 
# ---------------IN MEMORY------------
# 0 Value of refe after inc = 3
# 0 value of val after inc = 2
*/

// Code your testbench here
// or browse Examples
module test();
  task dummy(input int x, string s);
    fork
      begin
        #x;
      end
      begin
        #10;
      end
    join_any
    disable fork;
      $display("%s is disabled at t = %0t", s, $time);
   endtask
      
   initial 
     fork
       begin
         #2;
         dummy(5, "CALL_1");
       end
       begin
         #1;
         dummy(15, "CALL_2");
       end
     join
endmodule
      
/*
1 - #15
 #10 - CALL_1 is diabled at 11 (1 + 10)

2 - #5 - CALL_1 is disabled at 7 (2 + 5)
 #10
    
*/

//Sorting without a.sort() function
class A;
  rand int a[];
  constraint size {a.size == 10;
                   foreach(a[i])
                     a[i] inside {[1:10]};
                  }
  
  function void post_randomize();
    int keyValue;
    int b;
    $display("Array elements ----BEFORE---- sorting = %p", a);

    for(int i = 1; i < 10; i++)
      begin
        keyValue = a[i];
        b = i - 1;
        while(b >= 0 && a[b] > keyValue)
         begin
            a[b + 1] = a[b];
            b = b - 1;
         end
         a[b + 1] = keyValue;
      end
              
    $display("Array elements ----AFTER---- sorting = %p", a);
  endfunction
endclass

module A;
  initial begin
    A h1 = new();
    h1.randomize();
  end
endmodule

//Array elements ----BEFORE---- sorting = '{7, 1, 7, 9, 6, 10, 7, 3, 3, 10}
//Array elements ----AFTER---- sorting = '{1, 3, 3, 6, 7, 7, 7, 9, 10, 10}

//Queue insertion
// Code your testbench here
// or browse Examples
module test;
  int q1[$] = {1, 2, 3};
  int q2[$] = {4, 5};
  
  initial begin
    //with method
    /*foreach(q2[i])
      q1.insert(i+3, q2[i]);*/
    
    
    
    //without method
    foreach(q2[i])
      q1 = {q1, q2[i]};
    $display("Q1 = %p", q1);
        
  end
endmodule
