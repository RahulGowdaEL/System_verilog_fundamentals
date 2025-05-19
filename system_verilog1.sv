module tb; 
	typedef struct { 
		string students; 
		string result; 
		byte standard; 
		int total_count; }st_example; 
		
		initial begin 

		st_example class7 = '{"Vani", "P", 7, 60 }; 
		st_example class8; 
		st_example class9 = '{"Chandrika", "F", 9, 10};
		
		$display ("class7 = %p class8 = %p class9 = %p", class7, class8, class9);
		
		// Change student name to Dhanal, and result to F 
		class7.students = "Dhana"; 
		class7.result = "F";
		$display ("class7 = %p class: = %p class9 = %p", class7, class8, class9);
		
		class8 = class7; 
		// Display the structure variable 
		$display (" class7 = %p class8 = %p class9 = %p", class7, class8, class9); 
		end 
endmodule 

//output:
/* class7 = '{students:"Vani", result:"P", standard:7, total_count:60} class8 = '{students:"", result:"", standard:0, total_count:0} class9 = '{students:"Chandrika", result:"F", standard:9, total_count:10}
 class7 = '{students:"Dhana", result:"F", standard:7, total_count:60} class: = '{students:"", result:"", standard:0, total_count:0} class9 = '{students:"Chandrika", result:"F", standard:9, total_count:10}
  class7 = '{students:"Dhana", result:"F", standard:7, total_count:60} class8 = '{students:"Dhana", result:"F", standard:7, total_count:60} class9 = '{students:"Chandrika", result:"F", standard:9, total_count:10}
*/
