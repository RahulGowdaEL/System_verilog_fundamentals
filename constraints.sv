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
